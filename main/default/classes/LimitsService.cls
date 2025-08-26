public with sharing class LimitsService {

	private static final String DAILY_ASYNC_APEX_EXECUTIONS_LIMIT = 'DailyAsyncApexExecutions';
	private static final String SINGLE_EMAIL_LIMIT = 'SingleEmail';

	public static Integer getAvailableSingleEmail() {
		Map<String,System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		System.OrgLimit asyncLimit = mapOrgLimits.get(SINGLE_EMAIL_LIMIT);
		return asyncLimit.getLimit() - asyncLimit.getValue();
	}

	public static Boolean isAvailableSingleEmail(Double percentLimit) {
		Map<String,System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		System.OrgLimit emailLimit = mapOrgLimits.get(SINGLE_EMAIL_LIMIT);
		return (emailLimit.getLimit() * percentLimit) > emailLimit.getValue();
	}

	public static Integer getAvailableQuantityAsyncApexExecutions() {
		Map<String,System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		System.OrgLimit asyncLimit = mapOrgLimits.get(DAILY_ASYNC_APEX_EXECUTIONS_LIMIT);
		return asyncLimit.getLimit() - asyncLimit.getValue();
	}

    public static final Integer MAX_COUNT_HOLDING_BATCH_APEX_JOBS = 100;

	public static Boolean isFlexQueueSlotAvailable() {
        return getCountHoldingBatchApexJobs() < MAX_COUNT_HOLDING_BATCH_APEX_JOBS;
    }

	// The flex queue will only hold up to 100 jobs at a time. Once this limit is reached, you will see this error when a batch apex job is submitted
	// You've exceeded the limit of 100 jobs in the flex queue
	public static Integer getCountHoldingBatchApexJobs() {
        return [
            SELECT COUNT()
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex'
            AND Status = 'Holding'
        ];
    }

	public static Integer getMaxIssues() {
		if (PermissionsUtil.MaxIssues == 0) return null;
		return PermissionsUtil.MaxIssues;
	}

	public static Integer getAvailableNotifications24hr() {
		if (PermissionsUtil.MaxNotifications24hr == 0) return null;
		Integer notifications24hr = Integer.valueOf(ConfigUtil.SETTINGS.Notifications_24hr_Counter__c != null ? ConfigUtil.SETTINGS.Notifications_24hr_Counter__c : 0);
		return PermissionsUtil.MaxNotifications24hr - notifications24hr;
	}

}