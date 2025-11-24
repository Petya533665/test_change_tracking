public with sharing class MonitoringUtil {

    private static final Integer MAX_SIZE_TEXTAREA_FILED = 32000;
    private static final Integer MAX_SIZE_IDS_TEXTAREA_FILED = 131000;
    private static final List<String> ACTION_BATCH_CLASS_NAMES = new List<String> {'NotificationBatch', 'ArchivalBatch'};

    private static final List<String> NOTIFICATION_BATCH_INACTIVE_STATUSES = new List<String> {
        Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_QUEUED,
        Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_PROCESSING,
        Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_PREPARING,
        Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_HOLDING
    };

    public static void evaluateArchivalRules(List<RuleUtil.Rule> rules, List<Log__c> logs, Logger logger) {
        List<RuleUtil.Rule> toCreateEvents = new List<RuleUtil.Rule>();
        List<Event__c> newEvents = new List<Event__c>();
        List<EventAction__c> newEventActions = new List<EventAction__c>();
        for (RuleUtil.Rule rule : rules) {
            rule.applyArchivalRules(logs);
            if (!rule.archivalLogs.isEmpty()) {
                rule.populateCriteria();
                toCreateEvents.add(rule);
            }
        }
        if (!toCreateEvents.isEmpty()) {
            newEvents = createEvents(toCreateEvents);
            newEventActions = createEventActions(toCreateEvents, logger);
        }
    }

    public static void evaluateRules(
        List<Log__c> logs,
        List<Id> ruleIds,
        Datetime runDateTime,
        Map<Id, RuleUtil.Event> eventsMap,
        Logger logger) {

        List<RuleUtil.Rule> rules = RuleUtil.getMonitoringRules(ruleIds, true);
        List<RuleUtil.Rule> toCreateEvents = new List<RuleUtil.Rule>();
        List<Event__c> newEvents = new List<Event__c>();
        List<EventAction__c> newEventActions = new List<EventAction__c>();

        applyRulesFilters(rules, logs, runDateTime, eventsMap);
        toCreateEvents = filterRulesByTresholds(rules);
        if (!toCreateEvents.isEmpty()) {
            newEvents = createEvents(toCreateEvents);
            newEventActions = createEventActions(toCreateEvents, logger);
        }
    }

    public static void evaluateLimitsRules(
        List<Log__c> logs,
        List<Id> ruleIds,
        Datetime runDateTime,
        Map<Id, RuleUtil.Event> eventsMap,
        Logger logger) {

        List<RuleUtil.Rule> rules = RuleUtil.getLimitsRules(ruleIds, true);
        List<RuleUtil.Rule> toCreateEvents = new List<RuleUtil.Rule>();
        List<Event__c> newEvents = new List<Event__c>();
        List<EventAction__c> newEventActions = new List<EventAction__c>();

        applyLimitsRulesFilters(rules, logs, runDateTime, eventsMap, logger);
        toCreateEvents = filterRulesByTresholds(rules);
        if (!toCreateEvents.isEmpty()) {
            newEvents = createEvents(toCreateEvents);
            newEventActions = createEventActions(toCreateEvents, logger);
        }
    }

    public static void applyRulesFilters(
            List<RuleUtil.Rule> rules,
            List<Log__c> logs,
            DateTime runDatetime,
            Map<Id, RuleUtil.Event> eventsMap) {

        applyRulesFilters(rules, logs, runDatetime, eventsMap, true);
    }

    public static void applyRulesFilters(
        List<RuleUtil.Rule> rules,
        List<Log__c> logs,
        DateTime runDatetime,
        Map<Id, RuleUtil.Event> eventsMap,
        Boolean checkLogsInterval) {

        for(RuleUtil.Rule rule : rules) {
            if(rule.sobjectType != null) continue;

            switch on RuleUtil.MAP_AGGREGATE_TYPES_BY_STRINGS.get(rule.aggregateType) {
                when COUNT {
                    if(rule.aggregateInterval != null || rule.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_FREQUENCY)) {
                        List<List<Log__c>> logsIntervals = splitLogsByInterval(runDatetime, logs, rule, eventsMap, checkLogsInterval);
                        Integer countIntervals = logsIntervals.size();
                        Integer currentInterval = 1;

                        for(List<Log__c> logsInterval : logsIntervals) {
                            rule.applyFilters(logsInterval, currentInterval, countIntervals, runDatetime, eventsMap, checkLogsInterval);
                            currentInterval += 1;
                        }
                    }
                    else {
                        rule.applyFilters(logs, 1, 1, runDatetime, eventsMap, checkLogsInterval);
                    }
                }
                when AVERAGE {
                    List<List<Log__c>> logsIntervals = splitLogsByInterval(runDatetime, logs, rule, eventsMap, checkLogsInterval);
                    Integer countIntervals = logsIntervals.size();
                    Integer currentInterval = 1;

                    for(List<Log__c> logsInterval : logsIntervals) {
                        rule.applyFilters(logsInterval, currentInterval, countIntervals, runDatetime, eventsMap, checkLogsInterval);
                        currentInterval += 1;
                    }

                    if(rule.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_FREQUENCY)) {
                        for(Integer interval : rule.groupValues.keySet()) {
                            for(String key : rule.groupValues.get(interval).keySet()) {
                                Decimal groupValue = rule.groupValues.get(interval).get(key);
                                groupValue = groupValue / countIntervals;
                                rule.groupValues.get(interval).put(key, groupValue);
                            }
                        }
                    }
                }
            }
        }
    }

    private static void applyLimitsRulesFilters(
        List<RuleUtil.Rule> rules,
        List<Log__c> logs,
        DateTime runDatetime,
        Map<Id, RuleUtil.Event> eventsMap,
        Logger logger) {

        for(RuleUtil.Rule rule : rules) {
            if(rule.sobjectType != null) continue;
            
            // Route to appropriate processor based on rule subtype
            if(rule.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_SPIKE)) {
                processSpikeRule(rule, logs, runDatetime, eventsMap, logger);
            } else if(rule.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_THRESHOLD)) {
                processThresholdRule(rule, logs, runDatetime, eventsMap, logger);
            }
        }
    }

    // Helper methods for limits processing
    
    /**
     * Normalize DateTime to the nearest minute by zeroing out seconds and milliseconds
     * This handles production timing variance where HourlyLimitsBatch runs with ±15 second delays
     * Example: 14:15:13 → 14:15:00
     */
    private static DateTime normalizeToMinute(DateTime dt) {
        if (dt == null) return null;
        return DateTime.newInstance(
            dt.year(), 
            dt.month(), 
            dt.day(),
            dt.hour(), 
            dt.minute(), 
            0  // Zero out seconds and milliseconds
        );
    }
    
    /**
     * Filter logs by time interval with second-level tolerance
     * Production reality: HourlyLimitsBatch runs every ~60 min ±15 seconds variance
     * Without buffer, logs at exactly -60min 13sec fall outside the -60min window
     * Solution: Add buffer to start time to accommodate production variance
     */
    private static List<Log__c> filterLogsByTimeInterval(List<Log__c> logs, DateTime start, DateTime endTime) {
        // FIX: Add buffer to start time to handle production timing variance
        // Production data shows gaps of 60.22 min (60 min 13 sec) which would be excluded
        // by strict 60-minute window. The buffer ensures we capture these logs.
        DateTime normalizedStart = start.addMinutes(-Constants.MONITORING.SPIKE_DETECTION_BUFFER_MINUTES);
        
        List<Log__c> filtered = new List<Log__c>();
        for(Log__c log : logs) {
            if(log?.Created_At__c >= normalizedStart && log?.Created_At__c <= endTime) {
                filtered.add(log);
            }
        }
        return filtered;
    }

    private static Map<String, List<Decimal>> extractFieldValues(List<Log__c> logs, RuleUtil.Rule rule) {
        Map<String, List<Decimal>> fieldValues = new Map<String, List<Decimal>>();
        
        // Get the list of fields to monitor based on rule filters
        Set<String> fieldsToMonitor = getFieldsToMonitorForSpike(rule);
        
        for(String limitKey : LimitsService.FIELD_MAP.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = LimitsService.FIELD_MAP.get(limitKey);
            String fieldName = fieldDescribe.getName();
            
            // Skip fields that are not in the filter (if filters exist)
            if(!fieldsToMonitor.isEmpty() && !fieldsToMonitor.contains(fieldName)) {
                continue;
            }
            
            List<Decimal> values = new List<Decimal>();
            
            for(Log__c log : logs) {
                if (log.Limits__r != null) {
                    Map<String, Object> populated = log.Limits__r.getPopulatedFieldsAsMap();
                    if (populated != null && populated.containsKey(fieldName)) {
                        Object value = populated.get(fieldName);
                        if (value != null) {
                            try {
                                values.add(Decimal.valueOf(String.valueOf(value)));
                            } catch (Exception e) {
                                // Skip non-numeric values
                                continue;
                            }
                        }
                    }
                }
            }
            
            if(!values.isEmpty()) {
                fieldValues.put(fieldName, values);
            }
        }
        
        return fieldValues;
    }
    
    /**
     * Get the set of fields to monitor for spike detection based on rule filters
     * @param rule The rule to check for filters
     * @return Set of field names to monitor. Empty set means monitor all fields.
     */
    private static Set<String> getFieldsToMonitorForSpike(RuleUtil.Rule rule) {
        Set<String> fieldsToMonitor = new Set<String>();
        
        if(rule.ruleFilters != null && !rule.ruleFilters.isEmpty()) {
            for(RuleUtil.RuleFilter filter : rule.ruleFilters) {
                if(String.isNotBlank(filter.fieldName)) {
                    fieldsToMonitor.add(filter.fieldName);
                }
            }
        }
        
        return fieldsToMonitor;
    }

    private static Log__c getLatestLog(List<Log__c> logs) {
        Log__c latest = null;
        DateTime latestTime = null;
        
        for(Log__c log : logs) {
            if(log?.Created_At__c != null) {
                if(latestTime == null || log.Created_At__c > latestTime) {
                    latest = log;
                    latestTime = log.Created_At__c;
                }
            }
        }
        
        return latest;
    }

    private static Decimal getMinValue(List<Decimal> values) {
        if(values.isEmpty()) return null;
        Decimal min = values[0];
        for(Decimal value : values) {
            if(value < min) min = value;
        }
        return min;
    }

    private static Decimal getMaxValue(List<Decimal> values) {
        if(values.isEmpty()) return null;
        Decimal max = values[0];
        for(Decimal value : values) {
            if(value > max) max = value;
        }
        return max;
    }

    // Spike rule processing method
    private static void processSpikeRule(
        RuleUtil.Rule rule, 
        List<Log__c> logs, 
        DateTime runDatetime, 
        Map<Id, RuleUtil.Event> eventsMap,
        Logger logger) {
        
        // 1. Filter logs within time interval
        DateTime intervalStart = runDatetime.addMinutes(-Integer.valueOf(rule.eventTimeInterval));
        List<Log__c> intervalLogs = filterLogsByTimeInterval(logs, intervalStart, runDatetime);
        
        if(intervalLogs.size() < 2) {
            // Need at least 2 data points to detect a spike
            return;
        }
        
        // 2. Group by monitored fields
        Map<String, List<Decimal>> fieldValues = extractFieldValues(intervalLogs, rule);
        
        // 3. Calculate percentage changes
        for(String fieldName : fieldValues.keySet()) {
            List<Decimal> values = fieldValues.get(fieldName);
            if(values.size() < 2) continue;
            
            Decimal minValue = getMinValue(values);
            Decimal maxValue = getMaxValue(values);
            
            if(minValue != null && minValue > 0 && maxValue != null) {
                Decimal percentageChange = ((maxValue - minValue) / minValue) * 100;
                
                // 4. Check against threshold (absolute value for bidirectional detection)
                if(Math.abs(percentageChange) >= rule.threshold) {
                    // Mark this field as triggered for the rule
                    if(rule.groupValues == null) {
                        rule.groupValues = new Map<Integer, Map<String, Decimal>>();
                    }
                    if(!rule.groupValues.containsKey(1)) {
                        rule.groupValues.put(1, new Map<String, Decimal>());
                    }
                    
                    // Store the percentage change as the group value
                    rule.groupValues.get(1).put(fieldName, Math.abs(percentageChange));
                    
                    // Set groupFieldNames to indicate this is a grouped rule
                    if(rule.groupFieldNames == null) {
                        rule.groupFieldNames = new Set<String>();
                    }
                    rule.groupFieldNames.add(fieldName);
                    
                    // Also store in legacy format for compatibility
                    if(rule.groupRecordIds == null) {
                        rule.groupRecordIds = new Map<String, Set<String>>();
                    }
                    rule.groupRecordIds.put(fieldName, new Set<String>());
                    
                    // Add record IDs from interval logs and count them for rule.value
                    Set<String> allRecordIds = new Set<String>();
                    for(Log__c log : intervalLogs) {
                        if(log.Limits__r != null) {
                            String limitId = log.Limits__r.Id;
                            rule.groupRecordIds.get(fieldName).add(limitId);
                            allRecordIds.add(limitId);
                        }
                    }
                    
                    // Set rule.value for traditional event creation compatibility
                    rule.value = allRecordIds.size();
                    
                    // Mark that rule was triggered with record ids for criteria
                    if(rule.recordIds == null) {
                        rule.recordIds = new Set<String>();
                    }
                    rule.recordIds.addAll(allRecordIds);
                }
            }
        }
    }

    // Threshold rule processing method
    private static void processThresholdRule(
        RuleUtil.Rule rule, 
        List<Log__c> logs, 
        DateTime runDatetime, 
        Map<Id, RuleUtil.Event> eventsMap,
        Logger logger) {
        
        // 1. Get latest snapshot
        Log__c latestLog = getLatestLog(logs);
        if(latestLog?.Limits__r == null) return;
        
        // 2. Get org limits
        Map<String, System.OrgLimit> orgLimits = OrgLimits.getMap();
        
        // Get the list of fields to monitor based on rule filters
        Set<String> fieldsToMonitor = getFieldsToMonitorForSpike(rule);
        
        // 3. Calculate current percentages
        for(String limitKey : LimitsService.FIELD_MAP.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = LimitsService.FIELD_MAP.get(limitKey);
            String fieldName = fieldDescribe.getName();
            
            // Skip fields that are not in the filter (if filters exist)
            if(!fieldsToMonitor.isEmpty() && !fieldsToMonitor.contains(fieldName)) {
                continue;
            }
            
            // Get current usage from limits record only if field was queried
            Map<String, Object> populated = latestLog.Limits__r.getPopulatedFieldsAsMap();
            if (populated == null || !populated.containsKey(fieldName)) {
                continue;
            }
            Object currentUsage = populated.get(fieldName);
            if(currentUsage == null) continue;
            
            // Get org limit
            System.OrgLimit orgLimit = orgLimits.get(limitKey);
            if(orgLimit?.getLimit() == null || orgLimit.getLimit() <= 0) continue;
            
            try {
                // Calculate percentage
                Decimal usage = Decimal.valueOf(String.valueOf(currentUsage));
                Decimal currentPercentage = (usage / orgLimit.getLimit()) * 100;
                
                // 4. Check against threshold
                if(currentPercentage >= rule.threshold) {
                    // Mark this field as triggered for the rule
                    if(rule.groupValues == null) {
                        rule.groupValues = new Map<Integer, Map<String, Decimal>>();
                    }
                    if(!rule.groupValues.containsKey(1)) {
                        rule.groupValues.put(1, new Map<String, Decimal>());
                    }
                    
                    // Store the current percentage as the group value
                    rule.groupValues.get(1).put(fieldName, currentPercentage);
                    
                    // Set groupFieldNames to indicate this is a grouped rule
                    if(rule.groupFieldNames == null) {
                        rule.groupFieldNames = new Set<String>();
                    }
                    rule.groupFieldNames.add(fieldName);
                    
                    // Also store in legacy format for compatibility
                    if(rule.groupRecordIds == null) {
                        rule.groupRecordIds = new Map<String, Set<String>>();
                    }
                    rule.groupRecordIds.put(fieldName, new Set<String>{latestLog.Limits__r.Id});
                    
                    // Set rule.value and recordIds for traditional event creation compatibility
                    rule.value = 1; // One record triggered the threshold
                    if(rule.recordIds == null) {
                        rule.recordIds = new Set<String>();
                    }
                    rule.recordIds.add(latestLog.Limits__r.Id);
                }
            }
            catch(Exception e) {
                logger.add(logger.getInternalError(e, latestLog?.Limits__r?.Id, MonitoringUtil.class.getName(), 'Error processing threshold rule'));
                continue;
            }
        }
    }

    private static List<RuleUtil.Rule> filterRulesByTresholds(List<RuleUtil.Rule> rules) {
        List<RuleUtil.Rule> result = new List<RuleUtil.Rule>();
        for(RuleUtil.Rule rule : rules) {
            Boolean ruleResult = false;

            if(!rule.groupFieldNames.isEmpty() || rule.aggregateInterval != null || rule.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_FREQUENCY) || rule.type.equals(Constants.RULE_SOBJECT.TYPE_LIMITS)) {
                
                for(Integer interval : rule.groupValues.keySet()) {
                    Boolean intervalGroupResult = false;

                    for(String key : rule.groupValues.get(interval).keySet()) {
                        Boolean ruleGroupResult = false;
                        Decimal groupValue = rule.groupValues.get(interval).get(key);
                        Set<String> groupRecordIds = rule.groupRecordIds.get(key);
                        if(groupRecordIds == null) {
                            groupRecordIds = new Set<String>();
                        }

                        switch on RuleUtil.MAP_COMPARISON_OPERATOR_BY_STRING.get(rule.comparisonOperator) {
                            when EQUAL {
                                ruleGroupResult = groupValue == rule.threshold;
                            }
                            when NOT_EQUAL {
                                ruleGroupResult = groupValue != rule.threshold;
                            }
                            when GREATER_THAN {
                                ruleGroupResult = groupValue > rule.threshold;
                            }
                            when GREATER_OR_EQUAL {
                                ruleGroupResult = groupValue >= rule.threshold;
                            }
                            when LESS_THAN {
                                ruleGroupResult = groupValue < rule.threshold;
                            }
                            when LESS_OR_EQUAL {
                                ruleGroupResult = groupValue <= rule.threshold;
                            }
                        }

                        if(ruleGroupResult) {
                            rule.value += groupValue;
							rule.recordIds.addAll(groupRecordIds);
                            intervalGroupResult = true;
                        }
                        else {
                            rule.groupValues.get(interval).remove(key);
                            rule.groupRecordIds.remove(key);
                        }
                    }

                    if(intervalGroupResult) {
                        ruleResult = true;
                    }
                    else {
                        ruleResult = false;
                        break;
                    }
                }
            }
            else {
                switch on RuleUtil.MAP_COMPARISON_OPERATOR_BY_STRING.get(rule.comparisonOperator) {
                    when EQUAL {
                        ruleResult = rule.value == rule.threshold;
                    }
                    when NOT_EQUAL {
                        ruleResult = rule.value != rule.threshold;
                    }
                    when GREATER_THAN {
                        ruleResult = rule.value > rule.threshold;
                    }
                    when GREATER_OR_EQUAL {
                        ruleResult = rule.value >= rule.threshold;
                    }
                    when LESS_THAN {
                        ruleResult = rule.value < rule.threshold;
                    }
                    when LESS_OR_EQUAL {
                        ruleResult = rule.value <= rule.threshold;
                    }
                }
            }

            // create Monitoring Events
            if(ruleResult) {
                rule.populateCriteria();
                result.add(rule);
            }
        }
		// split rules by key groups (but NOT for limits rules - they should create one event per rule)
        Map<String, RuleUtil.Rule> mapRulesByGroupKey = new Map<String, RuleUtil.Rule>();
        for(RuleUtil.Rule rule : result) {
            // Exclude limits rules from splitting - they should create one consolidated event with all breached fields
            if(rule.type.equals(Constants.RULE_SOBJECT.TYPE_LIMITS)) {
                continue;
            }
            
            if(!rule.groupFieldNames.isEmpty() || rule.aggregateInterval != null || rule.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_FREQUENCY)) {
                for(Integer interval : rule.groupValues.keySet()) {
                    for (String key : rule.groupValues.get(interval).keySet()) {
                        Decimal groupValue = rule.groupValues.get(interval).get(key);
                        Set<String> groupRecordIds = rule.groupRecordIds.get(key);

                        RuleUtil.Rule groupKeyRule = mapRulesByGroupKey.get(key);
                        if(groupKeyRule == null) {
                            groupKeyRule = new RuleUtil.Rule(rule);
                            groupKeyRule.groupValues.put(interval, new Map<String, Decimal>());

                        }
                        groupKeyRule.groupValues.put(interval, new Map<String, Decimal>());
                        groupKeyRule.groupRecordIds.put(key, groupRecordIds);
                        groupKeyRule.groupValues.get(interval).put(key, groupValue);
                        mapRulesByGroupKey.put(key, groupKeyRule);
                    }
                }
            }
        }
        if(!mapRulesByGroupKey.isEmpty()) {
            return mapRulesByGroupKey.values();
        }

        return result;
    }

    public static List<List<Log__c>> splitLogsByInterval(
            DateTime runTime,
            List<Log__c> logs,
            RuleUtil.Rule rule,
            Map<Id, RuleUtil.Event> eventsMap) {

        return splitLogsByInterval(runTime, logs, rule, eventsMap, true);
    }

    public static List<List<Log__c>> splitLogsByInterval(
        DateTime runTime,
        List<Log__c> logs,
        RuleUtil.Rule rule,
        Map<Id, RuleUtil.Event> eventsMap,
        Boolean checkLogIntervalTime) {

        Integer eventTypeInterval = Integer.valueOf(rule.eventTimeInterval);
        Integer intervalInMinutes = Integer.valueOf(rule.aggregateInterval);
        Integer countIntervals = (intervalInMinutes != 0) ? eventTypeInterval / intervalInMinutes : 0;
        RuleUtil.Event event = (eventsMap != null && eventsMap.get(rule.id) != null)
            ? eventsMap.get(rule.id)
            : null;

        DateTime runTimeLocal = runTime;
        List<List<Log__c>> result = new List<List<Log__c>>();
        DateTime lastProcessDatetime = event != null ? event.createdDate : null;
        Map<Long, List<Log__c>> mapLogsByIntervals = new Map<Long, List<Log__c>>();

        for(Integer i = 0; i < countIntervals; i++) {
            Integer hours = intervalInMinutes / 60;
            Integer minutes = Math.mod(intervalInMinutes, 60);

            Datetime roundedDateTimeByInterval = runTimeLocal.addMinutes(
                runTimeLocal.minute() > 30
                    ? - (runTimeLocal.minute() - minutes)
                    : - runTimeLocal.minute()
            );
            if(hours != 0) {
                Integer nearHour = ((roundedDateTimeByInterval.hour() / hours) * hours);
                roundedDateTimeByInterval = roundedDateTimeByInterval.addHours( -(roundedDateTimeByInterval.hour() - nearHour));
            }

            Long roundedMills = roundedDateTimeByInterval.getTime();
            roundedMills = roundedMills/100000*100000;
            mapLogsByIntervals.put(roundedMills, new List<Log__c>());
            runTimeLocal = runTimeLocal.addMinutes(-intervalInMinutes);
        }



        for(Log__c log : logs) {
            if(checkLogIntervalTime && !inCurrentInterval(log.Created_At__c, runTime, lastProcessDatetime, eventTypeInterval)) {
                continue;
            }

            Integer hours = intervalInMinutes / 60;
            Integer minutes = Math.mod(intervalInMinutes, 60);

            Datetime roundedDateTimeByInterval = log.Created_At__c.addMinutes(
                log.Created_At__c.minute() > 30
                    ? - (log.Created_At__c.minute() - minutes)
                    : - log.Created_At__c.minute()
            );
            if(hours != 0) {
                Integer nearHour = ((roundedDateTimeByInterval.hour() / hours) * hours);
                roundedDateTimeByInterval = roundedDateTimeByInterval.addHours( -(roundedDateTimeByInterval.hour() - nearHour));
            }

            Long roundedMills = roundedDateTimeByInterval.getTime();
            roundedMills = roundedMills/100000*100000;
            List<Log__c> logsByMills = mapLogsByIntervals.get(roundedMills) != null
                ? mapLogsByIntervals.get(roundedMills)
                : new List<Log__c>();

            logsByMills.add(log);
            mapLogsByIntervals.put(roundedMills, logsByMills);
        }
        for(List<Log__c> logsList : mapLogsByIntervals.values()) {
            result.add(logsList);
        }
        return result;
    }


    public static List<EventAction__c> createEventActions(List<RuleUtil.Rule> rules, Logger logger) {
        List<EventAction__c> newEventActions = new List<EventAction__c>();
        for(RuleUtil.Rule rule : rules) {

            if(RuleUtil.IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS.contains(rule.type)) continue;

            for(RuleUtil.Action action : rule.actions) {
                EventAction__c newEventAction = new EventAction__c();
                newEventAction.Action_Type__c = action.type;
                newEventAction.Event__c = rule.eventId;
                newEventAction.Contents__c = action.content;
                newEventAction.Action__c = action.id;
                newEventAction.Subject__c = action.fields.Subject__c;
                newEventAction.Body__c = action.fields.Body__c;

                switch on RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) {
                    when TEAMS {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_TEAMS + action.fields.Channel_Id__c;
                    }
                    when SLACK {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_SLACK + action.fields.SlackChannels__c.split(',');
                    }
                    when JIRA {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_JIRA;
                    }
                    when EMAIL {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_EMAIL + action.fields.EmailTo__c;
                    }
                    when PAGERDUTY {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_PAGER_DUTY + action.fields.PagerDuty_Type__c + ' :';
                    }
                    when REMOVAL {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_REMOVAL;
                    }
                    when ARCHIVAL_TO_BIG_OBJECT {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_LOCAL_ARCHIVAL;
                    }
                    when EXTERNAL_ARCHIVAL {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_SPLUNK;
                    }
                }

                if ((RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.SLACK
                        && PermissionsUtil.SlackIntegrationEnabled
                        && ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c
                        && ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c != null)
                    || (RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.TEAMS
                        && PermissionsUtil.TeamsIntegrationEnabled
                        && ConfigUtil.GRAPH_API_SETTINGS.Enabled__c)
                    || (RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.JIRA && PermissionsUtil.JiraIntegrationEnabled)
                    || RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.EMAIL
                    || (RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.PAGERDUTY && PermissionsUtil.PagerDutyIntegrationEnabled)
                    || (RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.REMOVAL && PermissionsUtil.ArchivalEnabled)
                    || (RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.ARCHIVAL_TO_BIG_OBJECT && PermissionsUtil.ArchivalEnabled)
                    || (RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) == RuleUtil.ActionType.EXTERNAL_ARCHIVAL && PermissionsUtil.SplunkIntegrationEnabled)) {

                    newEventActions.add(newEventAction);
                }
            }
        }

        if(!newEventActions.isEmpty()) {
            Map<String, List<String>> contentsMap = new Map<String, List<String>>();
            for(EventAction__c newEventAction : newEventActions) {
                contentsMap.put(newEventAction.Event__c, new List<String>{newEventAction.Subject__c, newEventAction.Body__c});
            }
            Map<String, List<String>> renderResult = NotificationService.renderMergeFields(contentsMap);
            for(EventAction__c newEventAction : newEventActions) {
                List<String> renderedMessages = renderResult.get(newEventAction.Event__c);
                newEventAction.Subject__c = renderedMessages.get(0);
                newEventAction.Body__c = renderedMessages.get(1);
            }
            newEventActions = DatabaseUtils.getInstance().performInsertDML(newEventActions, Schema.SObjectType.EventAction__c)
                    .handleError(MonitoringUtil.class.getName(), '.createEventActions', logger).getSuccessSObjects();
        }
        return newEventActions;
    }

    public static void checkStartActionsBatch() {
        checkStartActionsBatch(System.isBatch());
    }

    public static void checkStartActionsBatch(Boolean isBatchContext) {
        if (!isBatchContext) {
            List<EventAction__c> sendlist = [
                SELECT Id, Type__c, Action_Type__c
                FROM EventAction__c
                WHERE Event__r.Rule__r.Active__c = TRUE 
                    AND Executed_On__c = NULL
                    AND Action__c != NULL
                ORDER BY Index__c DESC
                LIMIT 1
            ];
            Boolean startBatch = !sendlist.isEmpty();
            Boolean freeSlotBatch = false;

            List<AsyncApexJob> active_batches = [
                SELECT Id FROM AsyncApexJob
                WHERE
                    ApexClass.Name IN :ACTION_BATCH_CLASS_NAMES
                    AND Status IN :NOTIFICATION_BATCH_INACTIVE_STATUSES
                    AND JobType = :Constants.JOBS.ASYNC_APEX_JOB_PROCESS_TYPE_BATCH_APEX
                LIMIT 1
            ];
            freeSlotBatch = active_batches.isEmpty();

            if(startBatch && freeSlotBatch) {
                String actionType = sendlist.get(0).Action_Type__c != null ? sendlist.get(0).Action_Type__c : sendlist.get(0).Type__c;
                switch on RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(actionType) {
                    when EMAIL, SLACK, PAGERDUTY, JIRA, TEAMS {
                        NotificationBatch.getInstance().startBatch();
                    }
                    when REMOVAL, ARCHIVAL_TO_BIG_OBJECT {
                        ArchivalBatch.getInstance(sendlist.get(0), 200).startBatch();
                    }
                    when EXTERNAL_ARCHIVAL {
                        ArchivalBatch.getInstance(sendlist.get(0), 1).startBatch();
                    }
                }
            }
        }
    }

    public static List<Event__c> createEvents(List<RuleUtil.Rule> rules) {
        List<Event__c> newEvents = new List<Event__c>();
        Map<String, List<Log__c>> mapRuleLogs = getMapRuleLogs(rules);
        Schema.DescribeSObjectResult eventDescribe = Schema.SObjectType.Event__c;
        Map<String,Schema.RecordTypeInfo> rtMapByName = eventDescribe.getRecordTypeInfosByName();
        Id rtMonitoringId =  rtMapByName.get(Constants.EVENT_SOBJECT.RT_MONITORING).getRecordTypeId();
        Id rtArchivalId =  rtMapByName.get(Constants.EVENT_SOBJECT.RT_ARCHIVAL).getRecordTypeId();

        for(RuleUtil.Rule rule : rules) {

            if(RuleUtil.IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS.contains(rule.type)) continue;

            Event__c newEvent = new Event__c();
            newEvent.RecordTypeId = (rule.type.equals(Constants.RULE_SOBJECT.TYPE_ARCHIVAL)) ? rtArchivalId : rtMonitoringId;
            newEvent.Criteria__c = rule.criteria;

            if(rule.type.equals(Constants.RULE_SOBJECT.TYPE_ARCHIVAL)) {
                // Fix: Added null check for archivalLogs
                List<Id> archivalLogsToProcess = rule.archivalLogs != null ? rule.archivalLogs : new List<Id>();
                newEvent.RecordCount__c = archivalLogsToProcess.size();
                newEvent.Records__c = JSON.serialize(archivalLogsToProcess).abbreviate(MAX_SIZE_IDS_TEXTAREA_FILED);
            }
            else {
                // Fix: Added null check for recordIds
                newEvent.RecordCount__c = rule.recordIds != null ? rule.recordIds.size() : 0;
                if(rule.groupRecordIds != null && !rule.groupRecordIds.isEmpty()) {
                    newEvent.Records__c = JSON.serialize(rule.groupRecordIds).abbreviate(MAX_SIZE_IDS_TEXTAREA_FILED);
                    newEvent.Grouped_Field_Values__c = JSON.serialize(rule.groupRecordIds.keySet()).abbreviate(MAX_SIZE_TEXTAREA_FILED);
                    // Fix: Added null check for individual Set<String> values in the collection
                    Set<String> firstGroupRecordSet = null;
                    if (rule.groupRecordIds != null && !rule.groupRecordIds.isEmpty() && rule.groupRecordIds.values() != null && !rule.groupRecordIds.values().isEmpty()) {
                        for (Set<String> recordSet : rule.groupRecordIds.values()) {
                            if (recordSet != null) {
                                firstGroupRecordSet = recordSet;
                                break;
                            }
                        }
                    }
                    newEvent.RecordCount__c = (firstGroupRecordSet != null) ? firstGroupRecordSet.size() : 0;
                }
                else {
                    // Fix: Added null check for recordIds serialization
                    Set<String> recordIdsToSerialize = rule.recordIds != null ? rule.recordIds : new Set<String>();
                    newEvent.Records__c = JSON.serialize(recordIdsToSerialize).abbreviate(MAX_SIZE_IDS_TEXTAREA_FILED);
                }
                // Fix: Added null checks for aggregateTypeString and value
                String aggregateTypeStr = rule.aggregateType != null ? rule.aggregateType : 'Unknown';
                String valueStr = '0';
                try {
                    valueStr = rule.value != null ? rule.value.toPlainString() : '0';
                } catch (Exception e) {
                    // Fallback if value access fails
                    valueStr = '0';
                }
                newEvent.Description__c = 'Rule Id:' + rule.id
                        + ' ' + aggregateTypeStr + ':' + valueStr;
                // Fix: Added null checks for groupFieldNames and groupValues
                if(rule.groupFieldNames != null && !rule.groupFieldNames.isEmpty()) {
                    Map<Integer, Map<String, Decimal>> groupValuesToSerialize = rule.groupValues != null ? rule.groupValues : new Map<Integer, Map<String, Decimal>>();
                    newEvent.Description__c += json.serialize(groupValuesToSerialize);
                }
                newEvent.Description__c = newEvent.Description__c.abbreviate(255);

                Map<String, Integer> actionsMap = new Map<String, Integer>();
                // Fix: Added null check for actions collection
                if (rule.actions != null) {
                    for(RuleUtil.Action ent : rule.actions) {
                        if (ent != null && ent.type != null) {
                            Integer actionCount = actionsMap.get(ent.type) != null ? actionsMap.get(ent.type) : 0;
                            actionCount += 1;
                            actionsMap.put(ent.type, actionCount);
                        }
                    }
                }
                if(!actionsMap.isEmpty()) {
                    newEvent.Actions__c = JSON.serialize(actionsMap);
                }
                if(mapRuleLogs.get(rule.id) != null) {
                    newEvent.Event_Details__c = getEventDetails(mapRuleLogs.get(rule.id));
                }
            }

            newEvent.Rule__c = rule.id;
            newEvents.add(newEvent);
        }

        if(!newEvents.isEmpty()) {
            DatabaseUtils.getInstance().performInsertDML(newEvents, Schema.SObjectType.Event__c)
                .handleError(MonitoringUtil.class.getName(), '.createEvents', Logger.getInstance());

            for(Integer i = 0; i < newEvents.size(); i++) {
                if(RuleUtil.IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS.contains(rules.get(i).type)) continue;
                rules.get(i).eventId = newEvents.get(i).Id;
            }
        }

        return newEvents;
    }

    private static String getEventDetails(List<Log__c> ruleLogs) {
        String result = '';
        for(Log__c log : ruleLogs) {
            result +=  '\n' + log.Summary__c + '\n';
            result += 'Link to Log:' + URL.getOrgDomainUrl().toExternalForm() + '/' + log.Id + '\n';
        }
        return result;
    }

    @TestVisible
    private static Map<String, List<Log__c>> getMapRuleLogs(List<RuleUtil.Rule> rules) {
        Map<String, List<Log__c>> result = new Map<String, List<Log__c>>();
        Set<Id> allRecordIds = new Set<Id>();
        final Integer limitLogsPerRule = 5;
        Map<String, String> mapRuleIdbyLogId = new Map<String, String>();

        for(RuleUtil.Rule rule : rules) {
            Integer logsPerRule = 0;
            if(rule.groupRecordIds != null && !rule.groupRecordIds.isEmpty() && rule.groupRecordIds.values() != null) {
                for(Set<String> logIdList : rule.groupRecordIds.values()) {
                    if(logIdList != null) {
                        for(String logId : logIdList) {
                            if(logId != null) {
                                allRecordIds.add(logId);
                                mapRuleIdbyLogId.put(logId, rule.id);
                                logsPerRule += 1;
                                if(logsPerRule > limitLogsPerRule) break;
                            }
                        }
                    }
                    if(logsPerRule > limitLogsPerRule) break;
                }
            }
            else if (rule.recordIds != null && !rule.recordIds.isEmpty()) {
                for(String logId : rule.recordIds) {
                    if(logId != null) {
                        allRecordIds.add(logId);
                        mapRuleIdbyLogId.put(logId, rule.id);
                        logsPerRule += 1;
                        if(logsPerRule > limitLogsPerRule) break;
                    }
                }
            }
        }

        if(!allRecordIds.isEmpty()) {
            List<Log__c> logs = [SELECT Id, Summary__c FROM Log__c WHERE Id IN :allRecordIds];
            for(Log__c log : logs) {
                String ruleId = mapRuleIdbyLogId.get(log.Id);
                if(ruleId != null) {
                    List<Log__c> ruleLogs = (result.get(ruleId) != null) ? result.get(ruleId) : new List<Log__c>();
                    ruleLogs.add(log);
                    result.put(ruleId, ruleLogs);
                }
            }
        }
        return result;
    }

    public static Map<Id, RuleUtil.Event> getLastCreatedEventsMap() {
        Map<Id, RuleUtil.Event> result = new Map<Id, RuleUtil.Event>();
        List<AggregateResult> events = [
            SELECT MAX(CreatedDate) CreatedDate, Rule__c RuleId
            FROM Event__c
            GROUP BY Rule__c
            LIMIT :Constants.QUERY_LIMITS.LARGE_DATA_QUERY_LIMIT
        ];
        for(AggregateResult event : events) {
            DateTime createdDate = (DateTime)event.get('CreatedDate');
            Id ruleId = (Id)event.get('RuleId');
            if (ruleId != null && createdDate != null) {
                RuleUtil.Event maxEvent = new RuleUtil.Event(createdDate, ruleId);
                result.put(ruleId, maxEvent);
            }
        }
        return result;
    }

    private static Boolean inCurrentInterval(
        Datetime createdDateTime,
        DateTime runTime,
        DateTime lastProcessedDateTime,
        Decimal eventTypeInterval) {

        DateTime startTime;
        DateTime endTime;

        if(lastProcessedDateTime == null) {
            startTime = (eventTypeInterval != null)
                ? runTime.addMinutes(-1*Integer.valueOf(eventTypeInterval))
                : null;
            endTime = runTime;
        }
        else {
            startTime = eventTypeInterval != null
                ? (lastProcessedDateTime >= runTime.addMinutes(-1*Integer.valueOf(eventTypeInterval))
                    ? lastProcessedDateTime
                    : runTime.addMinutes(-1*Integer.valueOf(eventTypeInterval)))
                : lastProcessedDateTime;
            endTime = runTime;
        }
        return createdDateTime <= endTime && createdDateTime >= startTime;
    }
}