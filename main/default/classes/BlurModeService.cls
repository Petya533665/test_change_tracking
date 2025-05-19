public with sharing class BlurModeService {

	private static final SObjectType LOG_SOBJECT_TYPE = Log__c.SObjectType;
	private static final SObjectType ISSUE_SOBJECT_TYPE = Issue__c.SObjectType;

	public static Integer AVAILABLE_ISSUES_COUNT {
		get {
			if (AVAILABLE_ISSUES_COUNT == null) {
				AVAILABLE_ISSUES_COUNT = LimitsService.getMaxIssues();
				if (AVAILABLE_ISSUES_COUNT == null) return null;
				List<Issue__c> issues = [SELECT Id, Name FROM Issue__c WHERE Name != NULL ORDER BY Name DESC LIMIT 1];
				if (!issues.isEmpty()) {
					List<String> parts = issues[0].Name.split('-');
					if (parts.size() == 2) {
						String numericPart = parts[1].trim();
						Integer lastIssueNum = Integer.valueOf(numericPart) + 1;
						AVAILABLE_ISSUES_COUNT -= lastIssueNum;
					}
				}
			}
			return AVAILABLE_ISSUES_COUNT;
		}
		set;
	}

	public static Boolean isAvailableDebugView(String recordId) {
		if (String.isBlank(recordId)) return true;
		Integer maxIssues = LimitsService.getMaxIssues();
		if (maxIssues == null) return true;
		Schema.SObjectType sObjectType;
		try {
			sObjectType = Id.valueOf(recordId).getSobjectType();
		} catch (Exception e) {
			// catch Invalid Id
		}
		if (sObjectType == null) return true;
		String issueId;
		if (sObjectType == LOG_SOBJECT_TYPE) {
			List<Log__c> logs = [SELECT Id, Issue__c FROM Log__c WHERE Id = :recordId];
			if (!logs.isEmpty()) issueId = logs[0].Issue__c;
		} else if (sObjectType == ISSUE_SOBJECT_TYPE) {
			issueId = recordId;
		} else {
			return true;
		}
		Integer extractedInteger;
		if (String.isNotBlank(issueId)) {
			List<Issue__c> issues = [SELECT Id, Name FROM Issue__c WHERE Id = :issueId];
			if (!issues.isEmpty()) {
				List<String> parts = issues[0].Name.split('-');
				if (parts.size() == 2) {
					String numericPart = parts[1].trim();
					extractedInteger = Integer.valueOf(numericPart);
				}
			}
		} else {
			return false;
		}
		return extractedInteger != null && extractedInteger <= maxIssues;
	}

	public static Boolean isAvailableNotifications24hr() {
		Integer availableNotifications24hr = LimitsService.getAvailableNotifications24hr();
		return availableNotifications24hr == null || availableNotifications24hr > 0;
	}

	public static void increment24hrCounter() {
		Boolean isUpdated = false;
		if (LimitsService.getAvailableNotifications24hr() != null) {
			ConfigUtil.SETTINGS.X24_Hour_Counter__c = ConfigUtil.SETTINGS.X24_Hour_Counter__c != null ? ConfigUtil.SETTINGS.X24_Hour_Counter__c + 1 : 1;
			if (ConfigUtil.SETTINGS.X24_Hour_Counter__c >= 24) {
				ConfigUtil.SETTINGS.X24_Hour_Counter__c = 0;
				ConfigUtil.SETTINGS.Notifications_24hr_Counter__c = 0;
			}
			isUpdated = true;
		} else if (ConfigUtil.SETTINGS.X24_Hour_Counter__c != null || ConfigUtil.SETTINGS.Notifications_24hr_Counter__c != null) {
			ConfigUtil.SETTINGS.X24_Hour_Counter__c = null;
			ConfigUtil.SETTINGS.Notifications_24hr_Counter__c = null;
			isUpdated = true;
		}
		if (isUpdated) {
			DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c)
					.handleError(ConfigUtil.class.getName(), 'count24hr', Logger.getInstance());
			Logger.getInstance().flush();
		}
	}

	public static void incrementNotifications24hrCounter() {
		if (LimitsService.getAvailableNotifications24hr() != null) {
			List<AsyncApexJob> logServiceScheduler = DatabaseUtils.getCurrentJobs(new List<String>{'LogServiceScheduler'});
			if (logServiceScheduler.isEmpty()) {
				ConfigUtil.SETTINGS.Notifications_24hr_Counter__c = ConfigUtil.SETTINGS.Notifications_24hr_Counter__c != null ? ConfigUtil.SETTINGS.Notifications_24hr_Counter__c + 1 : 1;
				DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c)
						.handleError(ConfigUtil.class.getName(), 'countNotifications24h', Logger.getInstance());
				Logger.getInstance().flush();
			}
		}
	}

	private static final String PRIVATE_KEY_VALUE = 'uCfEc3j+/EPv69BiJxhKCw==';
	private static final String INITIALIZATION_VECTOR_VALUE = 'Dk8wgBB448FjI48EYaY8Tw==';

	public static String getEncryptedUrlParameter() {
		Blob key = EncodingUtil.base64Decode(PRIVATE_KEY_VALUE);
		Blob initializationVector = EncodingUtil.base64Decode(INITIALIZATION_VECTOR_VALUE);
		Blob data = Blob.valueOf(JSON.serialize(
				new Map<String, String>{
						'orgId' => UserInfo.getOrganizationId(),
						'orgName' => UserInfo.getOrganizationName(),
						'firstName' => UserInfo.getFirstName(),
						'salt' => EncodingUtil.base64Encode(Crypto.generateAesKey(128)),
						'email' => UserInfo.getUserEmail()
				}
		));
		Blob encrypted = Crypto.encrypt('AES128', key, initializationVector, data);
		return EncodingUtil.urlEncode(EncodingUtil.base64Encode(encrypted), 'UTF-8');
	}

}