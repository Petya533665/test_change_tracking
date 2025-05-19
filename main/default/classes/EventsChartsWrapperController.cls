global with sharing class EventsChartsWrapperController {
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
			SELECT Id, Records__c, Rule__c, CreatedDate,
            Rule__r.Name, Rule__r.Threshold__c, Rule__r.EventTimeInterval__c, Rule__r.AggregateInterval__c, Rule__r.Subtype__c, Rule__r.Type__c
			FROM Event__c
			WHERE Id= :eventId
		];
		String ruleId = event.Rule__c;
		Rule__c currentRule = event.Rule__r;
		Boolean stdInterval = false;
		if(currentRule.Subtype__c == 'Impact') {
			stdInterval = true;
		}
        DateTime eventTime = event.CreatedDate;
        DateTime startTime = eventTime.addMinutes(-60);
        DateTime endTime = eventTime.addMinutes(60);
		
        Integer shiftMinutes = Integer.valueOf(range);
        startTime = eventTime.addMinutes(-shiftMinutes);
		endTime = eventTime.addMinutes(shiftMinutes);
		
		return JSON.serialize(MonitoringUtil.getChartData(ruleId, event.Id, startTime, endTime, stdInterval));
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