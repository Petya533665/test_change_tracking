global with sharing class EventsChartsWrapperController {

	private static final Integer EVENT_CHART_MAX_RECORDS = 9000;

	public Boolean isDev { get; set; }
	public Rule__c currentRule { get; set; }
	public Event__c currentEvent { get; set; }
	public String packageNamespace { get {return Configutil.getNameSpacePrefix();} set; }

	public Integer userTimezoneOffset {
        get {
            return AdminService.getUserTimezoneOffset();
        }
        set;
    }

    public EventsChartsWrapperController(ApexPages.StandardController stdController) {
	    String recordId = ApexPages.currentPage().getParameters().get('recordId');
        String isDevParam = ApexPages.currentPage().getParameters().get('dev');
        if(String.isNotBlank(isDevParam)) {
            Cookie devCookie = new Cookie('a2developmentMode', isDevParam, null, -1, false);
            // ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });
            isDev = Boolean.valueOf(isDevParam);
        }
        else {
            Cookie devCookie = ApexPages.currentPage().getCookies().get('a2developmentMode');
            isDev = devCookie != null ? Boolean.valueOf(devCookie.getValue()) : false;
        }

        currentEvent = [
            SELECT Id, Records__c, Rule__c, CreatedDate,
                Rule__r.Name, Rule__r.Threshold__c, Rule__r.EventTimeInterval__c,
                Rule__r.AggregateInterval__c, Rule__r.Subtype__c, Rule__r.Type__c
            FROM Event__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        currentRule = currentEvent.Rule__r;
    }

	// ===== #1 chart (Occurrence)
	public static String getEvents(Integer showDaysOccurrence, String EventRuleId) {
		DateTime endDate;
		DateTime startDate;

		if (showDaysOccurrence == 7 || showDaysOccurrence == 30 || showDaysOccurrence == 60 || showDaysOccurrence == 180) {
			endDate = DateTime.now();
			startDate = endDate.addDays(-1 * showDaysOccurrence);
		} else {
			endDate = DateTime.now();
			startDate = endDate.addDays(-30);
		}

		List<Event__c> events = [
			SELECT Id, Name, CreatedDate
			FROM Event__c
			WHERE Rule__c = :EventRuleId AND
							CreatedDate >= :startDate AND
							CreatedDate <= :endDate
			ORDER BY CreatedDate];

			return JSON.serialize(events);
	}
	
	// ===== #2 chart (Event Log Records / User Impact)
    public static String getLogRecords(String eventId, Integer range) {
		// default 1h range from now
		Event__c event = [
			SELECT Id, CreatedDate, Rule__r.Type__c
			FROM Event__c
			WHERE Id= :eventId
		];
		String ruleId = event.Rule__c;
		String ruleType = event.Rule__r.Type__c;

        DateTime eventTime = event.CreatedDate;
        DateTime startTime = eventTime.addMinutes(-60);
        DateTime endTime = eventTime.addMinutes(60);
		
        Integer shiftMinutes = Integer.valueOf(range);
        startTime = eventTime.addMinutes(-shiftMinutes);
		endTime = eventTime.addMinutes(shiftMinutes);
		
		return JSON.serialize(getChartData(ruleId, ruleType, event.Id, startTime, endTime));
	}
	
	// ===== #3 chart (Logs Timing)
	public static String getTimingLogs(DateTime eventTime, Integer showRangeTiming) {
		DateTime endDate;
		DateTime startDate;
		DateTime dt = Datetime.valueOf(eventTime);

		if (showRangeTiming == 10 || showRangeTiming == 30 || showRangeTiming == 60) {
			endDate = dt.addMinutes( 1 * Integer.valueOf(showRangeTiming));
			startDate = dt.addMinutes( -1 * Integer.valueOf(showRangeTiming));
		} else {
			endDate = dt.addMinutes(10);
			startDate = dt.addMinutes(-10);
		}

		List<Log__c> timingLogs = [
			SELECT Id, Name, Created_At__c, Summary__c, Hash_1__c
			FROM Log__c
			WHERE Created_At__c >= :startDate AND
                  		  Created_At__c <= :endDate
			ORDER BY Created_At__c];

		return JSON.serialize(timingLogs);
	}

	public static List<String> parseIds(String input) {
		List<String> result = new List<String>();
		if(input.startsWith('{')) {
			Map<String, List<String>> idsMap = (Map<String, List<String>>)System.JSON.deserialize(input, Map<String, List<String>>.class);
			for(List<String> ids : idsMap.values()) {
				result.addAll(ids);
			}
		}
		else {
			List<String> ids = (List<String>)System.JSON.deserialize(input, List<String>.class);
			result.addAll(ids);
		}
		return result;
    }

    public static String getLogsJson(String input) {
        List<String> logs = parseIds(input);

        List<Log__c> eventLogs = [
                SELECT Id, Name, Hash_1__c, Created_At__c, Summary__c, Type__c
                FROM Log__c
                WHERE Id IN: logs
                ORDER BY Created_At__c];

        return JSON.serialize(eventLogs);
    }

	private static ChartData getChartData(Id ruleId, String ruleType, Id eventId, DateTime startTime, DateTime endTime) {
		if (ruleType == Constants.RULE_SOBJECT.TYPE_LIMITS) {
			return getLimitsChartData(ruleId, eventId, startTime, endTime);
		}
		else {
			return getMonitoringChartData(ruleId, eventId, startTime, endTime);
		}
	}

	private static ChartData getMonitoringChartData(Id ruleId, Id eventId, DateTime startTime, DateTime endTime) {
		List<RuleUtil.Rule> rules = RuleUtil.getMonitoringRules(new List<Id>{ruleId});
		if(rules.get(0).subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_SPIKE)) {
			ChartData result = new ChartData();
			List<String> logFields = RuleUtil.getLogFieldNames(rules);
			logFields.add('Created_At__c');
			logFields.add('Hash_1__c');
			logFields.add('Summary__c');
			String eventLogsQuery = new QBuilder(Log__c.SObjectType)
				.selectFields(new Set<String>(logFields))
				.add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':startTime'))
				.add(QBuilder.condition('Created_At__c').isLessOrEquals(':endTime'))
				.add(QBuilder.orderBy('Created_At__c').ascending())
				.addLimit(EVENT_CHART_MAX_RECORDS)
				.build();
			ChartData resultData = new ChartData();
			for(Log__c log : rules.get(0).applyRuleFilters(Database.query(eventLogsQuery))) {
				resultData.logs.add(new Map<String, Object> {'CreatedDate' => log.Created_At__c});
			}

			resultData.countLogs = resultData.logs.size();
			return resultData;
		}
		else {
			return getImpactChartData(ruleId, eventId, startTime, endTime);
		}
	}

	private static ChartData getLimitsChartData(Id ruleId, Id eventId, DateTime startTime, DateTime endTime) {
		ChartData result = new ChartData();
		List<RuleUtil.Rule> rules = RuleUtil.getLimitsRules(new List<Id>{ruleId});
		if(rules.isEmpty()) {
			return result;
		}
		
		RuleUtil.Rule rule = rules.get(0);
		
		// Get limit fields to query
		List<String> logFields = RuleUtil.getLogFieldNames(rules);
		logFields.add('Created_At__c');
		logFields.add('Limits__c');
		
		// Query logs with Limits__r relationship
		String eventLogsQuery = new QBuilder(Log__c.SObjectType)
			.selectFields(new Set<String>(logFields))
			.add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':startTime'))
			.add(QBuilder.condition('Created_At__c').isLessOrEquals(':endTime'))
			.add(QBuilder.condition('Limits__c').isNotNull())
			.add(QBuilder.orderBy('Created_At__c').ascending())
			.addLimit(EVENT_CHART_MAX_RECORDS)
			.build();
		
		List<Log__c> logs = Database.query(eventLogsQuery);
		
		// Get org limits to calculate percentages
		Map<String, System.OrgLimit> orgLimits = OrgLimits.getMap();
		
		// Determine which limit field(s) are being monitored
		Set<String> monitoredFields = new Set<String>();
		if(rule.groupFieldNames != null && !rule.groupFieldNames.isEmpty()) {
			// Use groupFieldNames if available (set during rule processing)
			for(String groupFieldName : rule.groupFieldNames) {
				monitoredFields.add(groupFieldName);
			}
		} else {
			// Fallback: check rule filters for Limits__r fields
			for(RuleUtil.RuleFilter filter : rule.ruleFilters) {
				if(filter.fieldName != null && filter.fieldName.startsWith('Limits__r.')) {
					String fieldName = filter.fieldName.substringAfter('Limits__r.');
					monitoredFields.add(fieldName);
				}
			}
		}
		
		// If no specific fields found, monitor all limit fields
		if(monitoredFields.isEmpty()) {
			for(String limitKey : LimitsService.FIELD_MAP.keySet()) {
				Schema.DescribeFieldResult fieldDescribe = LimitsService.FIELD_MAP.get(limitKey);
				monitoredFields.add(fieldDescribe.getName());
			}
		}
		
		// Group logs by time intervals (similar to splitLogsBySeconds)
		Map<Long, List<Log__c>> logsByInterval = new Map<Long, List<Log__c>>();
		for(Log__c log : logs) {
			if(log.Created_At__c == null || log.Limits__r == null) continue;
			
			Long roundedMills = log.Created_At__c.getTime();
			List<Log__c> logsByMills = logsByInterval.get(roundedMills) != null
				? logsByInterval.get(roundedMills)
				: new List<Log__c>();
			
			logsByMills.add(log);
			logsByInterval.put(roundedMills, logsByMills);
		}
		
		// Process each interval and calculate limit values
		for(Long datetimeLong : logsByInterval.keySet()) {
			List<Log__c> intervalLogs = logsByInterval.get(datetimeLong);
			if(intervalLogs.isEmpty()) continue;
			
			// Get the most recent log in the interval (or average if multiple)
			Log__c representativeLog = intervalLogs[intervalLogs.size() - 1];
			if(representativeLog.Limits__r == null) continue;
			
			ChartDataInterval interval = new ChartDataInterval();
			interval.logValues = new Map<Integer, Map<String, Decimal>>();
			interval.logValues.put(1, new Map<String, Decimal>());
			
			Map<String, Object> populated = representativeLog.Limits__r.getPopulatedFieldsAsMap();
			if(populated == null) continue;
			
			Decimal totalValue = 0;
			Integer fieldCount = 0;
			
			// Process each monitored limit field
			for(String fieldName : monitoredFields) {
				if(!populated.containsKey(fieldName)) continue;
				
				Object fieldValue = populated.get(fieldName);
				if(fieldValue == null) continue;
				
				try {
					Decimal usedValue = Decimal.valueOf(String.valueOf(fieldValue));
					
					// Find the corresponding limit key in LimitsService.FIELD_MAP
					String limitKey = null;
					for(String key : LimitsService.FIELD_MAP.keySet()) {
						Schema.DescribeFieldResult fieldDescribe = LimitsService.FIELD_MAP.get(key);
						if(fieldDescribe.getName() == fieldName) {
							limitKey = key;
							break;
						}
					}
					
					if(limitKey != null) {
						System.OrgLimit orgLimit = orgLimits.get(limitKey);
						if(orgLimit != null && orgLimit.getLimit() != null && orgLimit.getLimit() > 0) {
							// Calculate percentage
							Decimal percentage = (usedValue / orgLimit.getLimit()) * 100;
							
							// Store both absolute value and percentage
							// Use fieldName as key, store percentage as the value for chart display
							interval.logValues.get(1).put(fieldName, percentage);
							
							// Also store absolute value in a separate key for hover tooltip
							interval.logValues.get(1).put(fieldName + '_absolute', usedValue);
							interval.logValues.get(1).put(fieldName + '_max', Decimal.valueOf(orgLimit.getLimit()));
							
							totalValue += percentage;
							fieldCount++;
						} else {
							// If no org limit available, just store the absolute value
							interval.logValues.get(1).put(fieldName, usedValue);
							totalValue += usedValue;
							fieldCount++;
						}
					}
				} catch(Exception e) {
					// Skip invalid values
					continue;
				}
			}
			
			// Set interval value - use the first/primary field's percentage for single field,
			// or average if multiple fields are monitored
			if(fieldCount > 0) {
				if(fieldCount == 1) {
					// Single field: use its percentage directly
					interval.value = totalValue;
				} else {
					// Multiple fields: use average percentage
					interval.value = totalValue / fieldCount;
				}
			}
			
			result.mapIntervals.put(datetimeLong, interval);
		}
		
		result.countLogs = logs.size();
		return result;
	}

	public static ChartData getImpactChartData(Id ruleId, Id eventId, DateTime startTime, DateTime endTime) {
		ChartData result = new ChartData();

		List<RuleUtil.Rule> rules = RuleUtil.getMonitoringRules(new List<Id>{ruleId});
		Rule__c rule = [SELECT Id, EventTimeInterval__c FROM Rule__c WHERE Id = :ruleId];
		Event__c event = [SELECT Id, CreatedDate, Records__c FROM Event__c WHERE Id = :eventId];
		Set<String> eventRecordIds = new Set<String>(parseIds(event.Records__c));
		Integer eventInterval = Integer.valueOf(rule.EventTimeInterval__c);
		DateTime eventEndDate = event.CreatedDate;
		DateTime eventStartDate = eventEndDate.addMinutes(-eventInterval);

		List<Log__c> logsBeforeEvent = getLogs(rules, startTime, eventStartDate, EVENT_CHART_MAX_RECORDS/2);
		List<Log__c> logsAfterEvent = getLogs(rules, eventEndDate, endTime, EVENT_CHART_MAX_RECORDS/2);
		Map<Long, List<Log__c>> logsBefore = splitLogsBySeconds(logsBeforeEvent);
		Map<Long, List<Log__c>> logsAfter = splitLogsBySeconds(logsAfterEvent);

		List<String> logFields = RuleUtil.getLogFieldNames(rules);
		logFields.add('Created_At__c');
		String eventLogsQuery = new QBuilder(Log__c.SObjectType)
			.selectFields(new Set<String>(logFields))
			.add(QBuilder.condition('Id').isIn(':eventRecordIds'))
			.addLimit(EVENT_CHART_MAX_RECORDS)
			.build();
		List<Log__c> eventLogs = Database.query(eventLogsQuery);
		Map<Long, List<Log__c>> logsEvent = new Map<Long, List<Log__c>>{eventEndDate.getTime() => eventLogs};

		addIntervalsToChart(rules, result, logsBefore);
		addIntervalsToChart(rules, result, logsEvent);
		addIntervalsToChart(rules, result, logsAfter);
		result.countLogs = logsBeforeEvent.size() + logsAfterEvent.size() + eventLogs.size();

		return result;
	}

	private static void addIntervalsToChart(List<RuleUtil.Rule> rules, ChartData result, Map<Long, List<Log__c>> logsByInterval) {
		for(Long datetimeLong : logsByInterval.keySet()) {
			RuleUtil.Rule cloneRule = rules.get(0).clone();

			List<Log__c> logsInterval = logsByInterval.get(datetimeLong);
			cloneRule.value = 0;
			cloneRule.groupValues = new Map<Integer, Map<String, Decimal>>();
			MonitoringUtil.applyRulesFilters(new List<RuleUtil.Rule>{cloneRule}, logsInterval, DateTime.now(), new Map<Id, RuleUtil.Event>(), false);

			ChartDataInterval interval = new ChartDataInterval();
			interval.logValues = cloneRule.groupValues;
			interval.value = cloneRule.value;
			if(!interval.logValues.isEmpty()) {
				interval.value = 0;
				for(Map<String, Decimal> intervalCounts : interval.logValues.values()) {
					for(Decimal listCounts : intervalCounts.values()) {
						interval.value += listCounts;
					}
				}
			}
			result.mapIntervals.put(datetimeLong, interval);
		}
	}

	public static Map<Long, List<Log__c>> splitLogsBySeconds(List<Log__c> logs) {

		Map<Long, List<Log__c>> result = new Map<Long, List<Log__c>>();
		for(Log__c log : logs) {

			Long roundedMills = log.Created_At__c.getTime();
			List<Log__c> logsByMills = result.get(roundedMills) != null
					? result.get(roundedMills)
					: new List<Log__c>();

			logsByMills.add(log);
			result.put(roundedMills, logsByMills);
		}
		return result;
	}

	private static  List<Log__c> getLogs(List<RuleUtil.Rule> rules, DateTime startTime, DateTime endTime, Integer limitLogs) {
		List<String> logFields = RuleUtil.getLogFieldNames(rules);
		logFields.add('Created_At__c');
		String query = new QBuilder(Log__c.SObjectType)
				.selectFields(new Set<String>(logFields))
				.add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':startTime'))
				.add(QBuilder.condition('Created_At__c').isLessOrEquals(':endTime'))
				.addLimit(limitLogs)
				.build();
		List<Log__c> logs = Database.query(query);
		return logs;
	}

	public class ChartData {
		public Map<Long, ChartDataInterval> mapIntervals;
		public List<Map<String, Object>> logs;
		public Integer countLogs;
		public ChartData() {
			this.mapIntervals = new Map<Long, ChartDataInterval>();
			this.logs = new List<Map<String, Object>>();
			this.countLogs = 0;
		}
	}

	public class ChartDataInterval {
		public Decimal value;
		public Map<Integer, Map<String, Decimal>> logValues;

		public ChartDataInterval() {
			this.logValues = new Map<Integer, Map<String, Decimal>>();
			this.value = 0;
		}
	}

	@RemoteAction
    global static String remoteActionHandler(String input) {
		Map<String, Object> request = (Map<String, Object> )JSON.deserializeUntyped(input);
        RemoteActionResponse response = new RemoteActionResponse();
		response.params = request;
		String method = (String)request.get('method');
		Object data = request.get('data');
		Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
		String eventId = (String)payload.get('eventId');
		Event__c event = [
			SELECT Id, Records__c, Rule__c, CreatedDate,
            Rule__r.Name, Rule__r.Threshold__c, Rule__r.EventTimeInterval__c, Rule__r.AggregateInterval__c, Rule__r.Subtype__c, Rule__r.Type__c
			FROM Event__c
			WHERE Id= :eventId
		];
		Map<String, Object> output = new Map<String, Object>();
		DateTime eventTime = event.CreatedDate;
		String EventRuleId = event.Rule__c;

        try {
            if (method == 'getOccurrenceEvents') {		
                Integer showDays = (Integer)payload.get('showDays');
				List<Event__c> events = (List<Event__c>)JSON.deserialize(getEvents(showDays, EventRuleId), List<Event__c>.class);
				output.put('events', ConfigUtil.getSObjectWithoutNameSpace(events));
			} 
			else if (method == 'getEventRecords') {
				Integer range = (Integer)payload.get('range');
				output.put('eventRecords', JSON.deserializeUntyped(getLogRecords(eventId, range)));
			} 
			else if (method == 'getTimingLogs') {
				Integer range = (Integer)payload.get('range');
				List<Log__c> logs = (List<Log__c>)JSON.deserialize(getTimingLogs(eventTime, range), List<Log__c>.class);
				output.put('timingLogs', ConfigUtil.getSObjectWithoutNameSpace(logs));
			} 
			else {
                response.error = 'Action not found';
            }
        } catch (Exception e) {
            response.error = e.getMessage();
            response.stack = e.getStackTraceString();
            Logger.getInstance().internalError(e, EventsChartsWrapperController.class.getName(), 'remoteActionHandler');
		}
		response.data = output;
		return JSON.serialize(response);
    }

    public class RemoteActionResponse {
        public Object params;
        public Object data;
        public String error;
        public String stack;
    }

}