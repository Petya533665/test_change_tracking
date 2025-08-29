global virtual with sharing class LogBuilder {

	private final Log__c log;

	private static final Integer MAX_LENGTH_TEXT_FIELD = 255;

	global static LogBuilder getInstance() {
		return new LogBuilder();
	}

	global LogBuilder() {
		log = (Log__c)PermissionsUtil.newSObject(Schema.SObjectType.Log__c);
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Created_Timestamp__c, Double.valueOf(System.now().getTime()));
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Request_Id_External__c, System.Request.getCurrent().getRequestId());
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Do_Not_Create_Issue__c, true);
	}

	global LogBuilder type(String value) {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Type__c, value);
		return this;
	}

	global LogBuilder summary(String value) {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Summary__c, String.isEmpty(value) ? null : value.abbreviate(MAX_LENGTH_TEXT_FIELD));
		return this;
	}

	global LogBuilder details(String value) {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Details__c, value);
		return this;
	}

	global LogBuilder category(String value) {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Category__c, value);
		return this;
	}

	global LogBuilder stackTrace(String value) {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Stacktrace__c, value);
		return this;
	}

	global LogBuilder area(String value) {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Area__c, value);
		return this;
	}

	global LogBuilder postProcessing(String settingsJSON) {
		Map<String, Boolean> settings;
		try {
			settings = (Map<String, Boolean>)JSON.deserialize(settingsJSON, Map<String, Boolean>.class);
		} catch (JSONException e) {
			// catch JSON deserialize issue
		}
		Set<String> setSettings = new Set<String>();
		if (settings != null) {
			for (String key : settings.keySet()) {
				if (settings.get(key) && LogPostProcessingService.SETTINGS_ABBREVIATION.containsKey(key)) {
					setSettings.add(LogPostProcessingService.SETTINGS_ABBREVIATION.get(key));
				}
			}
		}
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Post_Processing_Settings__c, JSON.serialize(setSettings));
		return this;
	}

	global LogBuilder transactionId(String value) {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Transaction_Id_External__c, value);
		return this;
	}

	global LogBuilder createIssue() {
		PermissionsUtil.putSObjectField(this.log, Schema.SObjectType.Log__c.fields.Do_Not_Create_Issue__c, false);
		return this;
	}

	global LogBuilder attribute(String field, Object value) {
		if (value != null) {
			try {
				if (field.equals(Schema.SObjectType.Log__c.fields.Related_Id__c.getName())) {
					Id relatedId = (Id) value;
				}
				if (field.equals(Schema.SObjectType.Log__c.fields.User_Id__c.getName())) {
					Id userId = (Id) value;
					if (userId.getSObjectType() != Constants.USER_SOBJECT.SOBJECT_TYPE) {
						value = null;

						Logger.getInstance().add(
							getInstance()
								.category(Logger.CATEGORY_PHAROS_ERROR)
								.summary('The ' + Schema.SObjectType.Log__c.fields.User_Id__c.getName() + 'field should contain the record id of the User object')
								.area(Logger.AREA_PHAROS_ERROR)
								.type(Logger.AREA_PHAROS_ERROR)
								.details('The ' + Schema.SObjectType.Log__c.fields.User_Id__c.getName() + 'field should contain the record id of the User object')
								.attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
								.attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), LogBuilder.class.getName() + ':' + 'attribute')
								.build()
						);
					}
				}
				if (field.equals(Schema.SObjectType.Log__c.fields.Related_Objects__c.getName())) {
					Set<Id> recordIds = (Set<Id>) JSON.deserialize((String) value, Set<Id>.class);
				}
			} catch (Exception ex) {
				value = null;
				Logger.getInstance().addInternalError(ex, LogBuilder.class.getName(), 'attribute');
			}
		}

		PermissionsUtil.putSObjectField(this.log, field, value);
		return this;
	}

	global virtual LogBuilder tracePoint() {
		LogService.calculateHashes(this.log);
		return this;
	}

	global virtual String getTraceId() {
		return this.log?.Hash_1__c;
	}

	global Log__c build() {
		return log;
	}

}