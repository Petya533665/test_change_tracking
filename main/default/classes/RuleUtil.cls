public with sharing class RuleUtil {

	public static final String KEY_RULE = 'rule';
	public static final String KEY_RULES = 'rules';
	public static final String KEY_RULE_ID = 'ruleId';
	public static final String KEY_RULE_TYPE = 'ruleType';
	public static final String KEY_RULE_SUBTYPES = 'ruleSubtypes';
	public static final String KEY_RULE_ENABLED = 'ruleEnabled';
	public static final String KEY_RULE_COMPARISON_OPERATORS = 'comparisonOperators';
	public static final String KEY_RULE_FILTER_COMPARISON_OPERATORS = 'ruleFilterComparisonOperators';
	public static final String KEY_RULE_FILTERS = 'ruleFilters';
	public static final String KEY_RULE_ACTIONS = 'ruleActions';
	public static final String KEY_RULE_ACTION_ID = 'ruleActionId';
	public static final String KEY_ACTION_ID = 'actionId';
	public static final String KEY_EVENTS = 'events';
	public static final String KEY_ACTIONS = 'actions';
	public static final String KEY_ACTION_TYPES = 'actionTypesMap';
	public static final String KEY_LOG_FIELDS = 'logFields';
	public static final String KEY_ISSUE_FIELDS = 'issueFields';
	public static final String KEY_ISSUE_FIELDS_FOR_UPDATE = 'updateIssueFields';
	public static final String KEY_SERVICE_ENABLE = 'servicesEnable';
	public static final String KEY_USER_TIMEZONE_OFFSET = 'userTimezoneOffset';

	public static final String KEY_SUCCESS = 'success';
	public static final String KEY_MESSAGE = 'message';
	public static final String KEY_MESSAGE_PARAMS_RULE_ID_NOT_FOUND = 'Rule Id not found';
	public static final String DELETE_RULE_ACTION_MESSAGE_ACTION_RESULT = 'actionResult';

	public static final String EVENT_RT_MONITORING = 'Monitoring';
	public static final String EVENT_RT_ARCHIVAL = 'Archival';

	public static final String ACTION_RT_MONITORING = 'Monitoring';
	public static final String ACTION_RT_ARCHIVAL = 'Archival';

	public enum RuleType {
		MONITORING,
		ARCHIVAL,
		JIRA_UPDATE,
		NOTIFICATION,
		BROADCAST,
		AZURE_DEV_OPS
	}
	public static final String RULE_TYPE_MONITORING = 'Monitoring';
	public static final String RULE_TYPE_ARCHIVAL = 'Archival';
	public static final String RULE_TYPE_JIRA_UPDATE = 'JIRA Update';
	public static final String RULE_TYPE_AZURE_DEV_OPS = 'Azure Dev Ops';
	public static final String RULE_TYPE_NOTIFICATION = 'Notification';
	public static final String RULE_TYPE_BROADCAST = 'Broadcast';
	public static final Set<String> IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS = new Set<String>{RULE_TYPE_JIRA_UPDATE, RULE_TYPE_NOTIFICATION, RULE_TYPE_BROADCAST};
	public static final Map<String, RuleType> MAP_RULE_TYPE = new Map<String, RuleType> {
			RULE_TYPE_MONITORING => RuleType.MONITORING,
			RULE_TYPE_ARCHIVAL => RuleType.ARCHIVAL,
			RULE_TYPE_JIRA_UPDATE => RuleType.JIRA_UPDATE,
			RULE_TYPE_NOTIFICATION => RuleType.NOTIFICATION,
			RULE_TYPE_BROADCAST => RuleType.BROADCAST,
			RULE_TYPE_AZURE_DEV_OPS => RuleType.AZURE_DEV_OPS
	};

	public static final Map<String, Boolean> MAP_RULES_ENABLED = new Map<String, Boolean> {
			RULE_TYPE_MONITORING => ConfigUtil.SETTINGS.Monitoring_Enabled__c,
			RULE_TYPE_ARCHIVAL => ConfigUtil.SETTINGS.Archival_Enabled__c,
			RULE_TYPE_NOTIFICATION => PermissionsUtil.NotificationIntegrationEnabled
	};

	public enum ComparisonOperator {
		EQUAL,
		NOT_EQUAL,
		GREATER_THAN,
		GREATER_OR_EQUAL,
		LESS_THAN,
		LESS_OR_EQUAL,
		CONTAINS,
		DOESNT_CONTAIN
	}
	public static final String COMPARISON_OPERATOR_EQUAL = 'Equal';
	public static final String COMPARISON_OPERATOR_NOT_EQUAL = 'Not equal';
	public static final String COMPARISON_OPERATOR_GREATER_THEN = 'Greater than';
	public static final String COMPARISON_OPERATOR_GREATER_OR_EQUAL = 'Greater or equal';
	public static final String COMPARISON_OPERATOR_LESS_THAN = 'Less than';
	public static final String COMPARISON_OPERATOR_LESS_OR_EQUAL = 'Less or equal';
	public static final String COMPARISON_OPERATOR_CONTAINS = 'Contains';
	public static final String COMPARISON_OPERATOR_DOSENT_CONTAINS = 'Doesn\'t Contain';
	public static Map<String, ComparisonOperator> MAP_COMPARISON_OPERATOR_BY_STRING = new Map<String, ComparisonOperator> {
			COMPARISON_OPERATOR_EQUAL => ComparisonOperator.EQUAL,
			COMPARISON_OPERATOR_NOT_EQUAL => ComparisonOperator.NOT_EQUAL,
			COMPARISON_OPERATOR_GREATER_THEN => ComparisonOperator.GREATER_THAN,
			COMPARISON_OPERATOR_GREATER_OR_EQUAL => ComparisonOperator.GREATER_OR_EQUAL,
			COMPARISON_OPERATOR_LESS_THAN => ComparisonOperator.LESS_THAN,
			COMPARISON_OPERATOR_LESS_OR_EQUAL => ComparisonOperator.LESS_OR_EQUAL,
			COMPARISON_OPERATOR_CONTAINS => ComparisonOperator.CONTAINS,
			COMPARISON_OPERATOR_DOSENT_CONTAINS => ComparisonOperator.DOESNT_CONTAIN
	};

	public enum AggregateType {
		COUNT,
		AVERAGE
	}
	public static final Map<String, AggregateType> MAP_AGGREGATE_TYPES_BY_STRINGS = new Map<String, AggregateType> {
			'Count' => AggregateType.COUNT,
			'Average' => AggregateType.AVERAGE
	};

	public enum ComparisonType {
		FIELD,
		VALUE
	}
	public static final String COMPARISON_TYPE_FIELD = 'Field';
	public static final String COMPARISON_TYPE_VALUE = 'Value';
	public static final Map<String, ComparisonType> MAP_COMPARISON_TYPES_BY_STRINGS = new Map<String, ComparisonType> {
			COMPARISON_TYPE_FIELD => ComparisonType.FIELD,
			COMPARISON_TYPE_VALUE => ComparisonType.VALUE
	};

	public enum FieldType {
		FT_DOUBLE,
		FT_DATE,
		FT_DATETIME,
		FT_ID,
		FT_REFERENCE,
		FT_TEXTAREA,
		FT_URL,
		FT_PICKLIST,
		FT_STRING,
		FT_NUMBER,
		FT_BOOLEAN
	}
	public static final String FIELD_TYPE_DOUBLE = 'DOUBLE';
	public static final String FIELD_TYPE_DATE = 'DATE';
	public static final String FIELD_TYPE_DATETIME = 'Datetime';
	public static final String FIELD_TYPE_ID = 'ID';
	public static final String FIELD_TYPE_REFERENCE = 'REFERENCE';
	public static final String FIELD_TYPE_TEXTAREA = 'TEXTAREA';
	public static final String FIELD_TYPE_URL = 'URL';
	public static final String FIELD_TYPE_PICKLIST = 'PICKLIST';
	public static final String FIELD_TYPE_STRING = 'STRING';
	public static final String FIELD_TYPE_NUMBER = 'NUMBER';
	public static final String FIELD_TYPE_BOOLEAN = 'BOOLEAN';
	public static final Map<String, FieldType> MAP_FIELD_TYPES_BY_STRINGS = new Map<String, FieldType> {
			FIELD_TYPE_DOUBLE => FieldType.FT_DOUBLE,
			FIELD_TYPE_DATE => FieldType.FT_DATE,
			FIELD_TYPE_DATETIME => FieldType.FT_DATETIME,
			FIELD_TYPE_ID => FieldType.FT_ID,
			FIELD_TYPE_REFERENCE => FieldType.FT_REFERENCE,
			FIELD_TYPE_TEXTAREA => FieldType.FT_TEXTAREA,
			FIELD_TYPE_URL => FieldType.FT_URL,
			FIELD_TYPE_PICKLIST => FieldType.FT_PICKLIST,
			FIELD_TYPE_STRING => FieldType.FT_STRING,
			FIELD_TYPE_NUMBER => FieldType.FT_NUMBER,
			FIELD_TYPE_BOOLEAN => FieldType.FT_BOOLEAN
	};

	public enum ActionSubtype {
		DEFAULT_ACTION
	}
	public static final String ACTION_SUBTYPE_DEFAULT = 'Default';
	public static final Map<String, ActionSubtype> MAP_ACTION_SUBTYPES_BY_STRINGS = new Map<String, ActionSubtype> {
			ACTION_SUBTYPE_DEFAULT => ActionSubtype.DEFAULT_ACTION
	};

	public enum ActionType {
		EMAIL,
		SLACK,
		JIRA,
		PAGERDUTY,
		REMOVAL,
		ARCHIVAL_TO_BIG_OBJECT,
		EXTERNAL_ARCHIVAL,
		TEAMS,
		AZURE_DEV_OPS,
		JIRA_TICKET_COMMENT,
        AZURE_DEV_OPS_WORK_ITEM_COMMENT
	}
	public static final String ACTION_TYPE_TEAMS_NOTIFICATION = 'Teams Notification';
	public static final String ACTION_TYPE_EMAIL_NOTIFICATION = 'Email Notification';
	public static final String ACTION_TYPE_SLACK_NOTIFICATION = 'Slack Notification';
	public static final String ACTION_TYPE_JIRA_NOTIFICATION = 'Jira Notification';
	public static final String ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION = 'Azure Dev Ops Notification';
	public static final String ACTION_TYPE_PAGERDUTY_NOTIFICATION = 'PagerDuty Notification';
	public static final String ACTION_TYPE_REMOVAL = 'Removal';
	public static final String ACTION_TYPE_LOCAL_ARCHIVAL = 'Local Archival';
	public static final String ACTION_TYPE_EXTERNAL_ARCHIVAL = 'External Archival';
	public static final String ACTION_SUBTYPE_NOTIFICATION = 'Notification';
	public static final String ACTION_TYPE_JIRA_TICKET_COMMENT = 'JIRA Ticket Comment';
    public static final String ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT = 'Azure Dev Ops Work Item Comment';

	public static final Map<String, ActionType> MAP_ACTION_TYPES_BY_STRINGS = new Map<String, ActionType> {
			ACTION_TYPE_EMAIL_NOTIFICATION => ActionType.EMAIL,
			ACTION_TYPE_SLACK_NOTIFICATION => ActionType.SLACK,
			ACTION_TYPE_JIRA_NOTIFICATION => ActionType.JIRA,
			ACTION_TYPE_PAGERDUTY_NOTIFICATION => ActionType.PAGERDUTY,
			ACTION_TYPE_REMOVAL => ActionType.REMOVAL,
			ACTION_TYPE_LOCAL_ARCHIVAL => ActionType.ARCHIVAL_TO_BIG_OBJECT,
			ACTION_TYPE_EXTERNAL_ARCHIVAL => ActionType.EXTERNAL_ARCHIVAL,
			ACTION_TYPE_TEAMS_NOTIFICATION => ActionType.TEAMS,
			ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION => ActionType.AZURE_DEV_OPS,
			ACTION_TYPE_JIRA_TICKET_COMMENT => ActionType.JIRA_TICKET_COMMENT,
        	ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT => ActionType.AZURE_DEV_OPS_WORK_ITEM_COMMENT
	};
	public static final Map<String, List<String>> MAP_ACTION_TYPES_BY_RULE_TYPE = new Map<String, List<String>> {
			RULE_TYPE_MONITORING => new List<String> {
					ACTION_TYPE_EMAIL_NOTIFICATION,
					ACTION_TYPE_SLACK_NOTIFICATION,
					ACTION_TYPE_JIRA_NOTIFICATION,
					ACTION_TYPE_PAGERDUTY_NOTIFICATION,
					ACTION_TYPE_TEAMS_NOTIFICATION,
					ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION,
					ACTION_TYPE_JIRA_TICKET_COMMENT,
					ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT
			},
			RULE_TYPE_ARCHIVAL => new List<String> {
					ACTION_TYPE_REMOVAL,
					ACTION_TYPE_LOCAL_ARCHIVAL,
					ACTION_TYPE_EXTERNAL_ARCHIVAL
			},
			RULE_TYPE_JIRA_UPDATE => new List<String> {
					ACTION_TYPE_JIRA_NOTIFICATION,
					ACTION_TYPE_JIRA_TICKET_COMMENT
			},
			RULE_TYPE_AZURE_DEV_OPS => new List<String>{
				ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION,
				ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT
				
			},
			RULE_TYPE_NOTIFICATION => new List<String> {
					ACTION_TYPE_EMAIL_NOTIFICATION,
					ACTION_TYPE_SLACK_NOTIFICATION,
					ACTION_TYPE_PAGERDUTY_NOTIFICATION,
					ACTION_TYPE_TEAMS_NOTIFICATION,
					ACTION_TYPE_JIRA_TICKET_COMMENT,
					ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT
			},
			RULE_TYPE_BROADCAST => new List<String> {
			}
	};
	public static final Map<String, String> MAP_ACTION_SUBTYPES = new Map<String, String> {
			RULE_TYPE_NOTIFICATION => ACTION_SUBTYPE_NOTIFICATION
	};

	public static final String RULE_SUBTYPE_FREQUENCY = 'Frequency';
	public static final String RULE_SUBTYPE_IMPACT = 'Impact';
	public static final String RULE_SUBTYPE_SPIKE = 'Spike';

	public final static List<String> RULE_FIELDS = new List<String>{
			'Id', 'Name', 'Active__c', 'Description__c', 'Related_Id__c', 'CreatedBy.Name', 'Name__c', 'ComparisonOperator__c',
			'AggregateType__c', 'FilterLogic__c', 'Index__c', 'Threshold__c', 'EventTimeInterval__c', 'AggregateInterval__c',
			'Type__c', 'Subtype__c', 'SobjectType__c', 'Is_Not_Valid__c', 'Is_Update__c'
	};

	public final static List<String> RULE_FILTER_FIELDS = new List<String>{
			'Id', 'Name', 'ComparisonOperator__c', 'Comparison_Type__c', 'FieldName__c', 'Index__c', 'Rule__c', 'Value__c', 'Field_Type__c', 'Is_Old__c'
	};

	public final static List<String> RULE_ACTION_FIELDS = new List<String>{
			'Id', 'Rule__r.Type__c', 'Rule__r.Name__c', 'Rule__r.Description__c', 'Action__r.Id', 'Action__r.Name', 'Action__r.Name__c', 'Action__r.CreatedDate', 'Action__r.Body__c', 'Action__r.Description__c', 'Action__r.EmailBody__c', 'Action__r.EmailCC__c', 'Action__r.EmailTemplateId__c', 'Action__r.EmailTo__c',
			'Action__r.JIRAAssignee__c','Action__r.JIRAAssignee_Id__c', 'Action__r.JIRAComponents__c', 'Action__r.JIRAEpic__c', 'Action__r.JIRAIssueType__c', 'Action__r.JIRALabels__c', 'Action__r.JIRAPriority__c', 'Action__r.JIRAProject__c',
			'Action__r.SlackChannels__c', 'Action__r.Subject__c', 'Action__r.Action_Type__c', 'Action__r.Subtype__c', 'Action__r.PagerDuty_Type__c', 'Action__r.Contact__c', 'Action__r.Contact__r.Name', 'Action__r.CreatedBy.Name', 'Action__r.RecordTypeId', 'Action__r.Type__c',
			'Action__r.Team_Id__c', 'Action__r.Channel_Id__c', 'Action__r.SlackChannels__c', 'Action__r.SObjectType__c', 'Action__r.Additional_Metadata__c', 'Action__r.Iteration__c', 'Action__r.Is_Update__c'
	};

	public final static List<String> ACTION_FIELDS = new List<String>{
			'Id', 'Name', 'Name__c', 'Body__c', 'Description__c', 'EmailBody__c', 'EmailCC__c', 'EmailTemplateId__c', 'EmailTo__c',
			'JIRAAssignee__c','JIRAAssignee_Id__c', 'JIRAComponents__c', 'JIRAEpic__c', 'JIRAIssueType__c', 'JIRALabels__c', 'JIRAPriority__c', 'JIRAProject__c',
			'SlackChannels__c', 'Subject__c', 'Action_Type__c', 'Subtype__c', 'PagerDuty_Type__c', 'Contact__c', 'Contact__r.Name', 'CreatedBy.Name', 'RecordTypeId','Type__c',
			'Team_Id__c', 'Channel_Id__c', 'SlackChannels__c', 'SObjectType__c', 'Additional_Metadata__c', 'Iteration__c', 'CreatedDate', 'Is_Update__c'
	};

	private static final List<String> REQUIRED_RULE_FIELDS = new List<String> {
			'Id', 'CreatedDate', 'Created_At__c'
	};

	public static List<String> getLogFieldNames(List<Rule> rules) {
		List<String> logFieldLocalNames = new List<String>();
		List<String> logFields = getLogFields(rules);
		for (String fieldName : logFields) {
			logFieldLocalNames.add(fieldName.replace(ConfigUtil.nameSpacePrefix, ''));
		}
		return logFieldLocalNames;
	}

	public static List<String> getLogFields(List<Rule> rules) {
		Set<String> filterFields = new Set<String>(REQUIRED_RULE_FIELDS);
		Schema.DescribeSObjectResult d = Log__c.sObjectType.getDescribe();
		Map<String, Schema.SObjectField> fieldsMap = d.fields.getMap();
		Set<String> logFieldsSet = fieldsMap.keySet();
		for (Rule rule : rules) {
			for (RuleFilter filter : rule.ruleFilters) {
				if (logFieldsSet.contains(filter.fieldName.toLowerCase())) {
					filterFields.add(filter.fieldName);
				}
			}
			for (String groupFiledName : rule.groupFieldNames) {
				if (logFieldsSet.contains(groupFiledName.toLowerCase())) {
					filterFields.add(groupFiledName);
				}
			}
		}
		return new List<String>(filterFields);
	}

	public static List<Rule__c> getRules(Id ruleId, String ruleType) {
		return getRules(ruleId, new List<String>{ruleType});
	}

	public static List<Rule__c> getRules(Id ruleId, List<String> ruleTypes) {
		String query = new QBuilder(Rule__c.SObjectType)
				.selectFields(new Set<String>(RULE_FIELDS))
				.addSubquery(new QBuilder('RuleActions__r')
						.selectFields(new Set<String>(RULE_ACTION_FIELDS))
						.add(QBuilder.orderBy('CreatedDate').descending()))
				.addSubquery(new QBuilder('RuleFilters__r')
						.selectFields(new Set<String>(RULE_FILTER_FIELDS)))
				.add(ruleId != null ? QBuilder.condition('Id').equalsTo(ruleId) : null)
				.add(ruleTypes != null ? QBuilder.condition('Type__c').isIn(ruleTypes) : null)
				.add(QBuilder.orderBy('Index__c').ascending().nullsLast())
				.build();
		return Database.query(query);
	}

	public static List<RuleFilter__c> getRuleFilters(Id ruleId) {
		String query = new QBuilder(RuleFilter__c.SObjectType)
				.selectFields(new Set<String>(RULE_FILTER_FIELDS))
				.add(ruleId != null ? QBuilder.condition('Rule__c').equalsTo(ruleId) : null)
				.add(QBuilder.orderBy('Index__c').descending())
				.build();
		return Database.query(query);
	}

	public static List<Action__c> getActions(String ruleType, String subtype) {
		List<String> actionTypes = MAP_ACTION_TYPES_BY_RULE_TYPE.get(ruleType);
		if (actionTypes == null || actionTypes.isEmpty()) {
			return new List<Action__c>();
		}
		String query = new QBuilder(Action__c.SObjectType)
				.selectFields(new Set<String>(ACTION_FIELDS))
				.add(QBuilder.condition('Action_Type__c').isIn(actionTypes))
				.add(String.isNotBlank(subtype) ? QBuilder.condition('Subtype__c').equalsTo(subtype) : null)
				.add(String.isBlank(subtype) ? QBuilder.condition('Subtype__c').notEqualsTo(ACTION_SUBTYPE_NOTIFICATION) : null)
				.add(QBuilder.orderBy('CreatedDate').descending())
				.build();
		return Database.query(query);
	}

	public static List<String> addAllTicketingRuleTypes(String ruleType) {
        List<String> result = new List<String>();
        if(ruleType == RuleUtil.RULE_TYPE_JIRA_UPDATE || ruleType == RuleUtil.RULE_TYPE_AZURE_DEV_OPS) {
            result.add(RuleUtil.RULE_TYPE_JIRA_UPDATE);
            result.add(RuleUtil.RULE_TYPE_AZURE_DEV_OPS);
        }
        else {
            result.add(ruleType);
        }
        return result;
    }

	public static void setRuleIndex(Rule__c rule) {
		Integer countRules = [SELECT COUNT() FROM Rule__c WHERE Type__c IN :addAllTicketingRuleTypes(rule.Type__c) AND Active__c = TRUE];
		rule.Index__c = rule.Index__c == null ? countRules + 1 : rule.Index__c;
	}

	public static void reIndexRules(String ruleType) {
		reIndexRules(new List<String>{ruleType});
	}

	public static void reIndexRules(List<String> ruleTypes) {
		List<Rule__c> rules = getRules(null, ruleTypes);
		List<Rule__c> rulesToUpdate = new List<Rule__c>();
		Integer counter = 1;
		if (!rules.isEmpty()) {
			for (Integer i = 0; i < rules.size(); i++){
				Integer ruleIndex = (rules.get(i).Active__c) ? counter++ : null;
				rulesToUpdate.add(new Rule__c(Id = rules.get(i).Id, Index__c = ruleIndex));
			}
		}
		if (!rulesToUpdate.isEmpty()) {
			DatabaseUtils.getInstance().performUpdateDML(rulesToUpdate, Schema.SObjectType.Rule__c)
					.handleError(RuleUtil.class.getName(), '.reIndexRules');
		}
	}

	public static void upsertRuleFilters(Map<String, Object> input, Id ruleId) {
		if (input.get(KEY_RULE_FILTERS) != null) {
			List<RuleFilter> ruleFilterWrappers = (List<RuleFilter>)JSON.deserialize(JSON.serialize(input.get(KEY_RULE_FILTERS)), List<RuleFilter>.class);
			ruleFilterWrappers.sort();
			List<RuleFilter__c> ruleFiltersOld = getRuleFilters(ruleId);
			List<RuleFilter__c> ruleFiltersToDelete = new List<RuleFilter__c>();
			List<RuleFilter__c> ruleFiltersToUpsert = new List<RuleFilter__c>();
			Set<Id> setRuleFilterIds = new Set<Id>();
			Integer indexValue = 1;
			Integer indexField = 1;
			for (RuleFilter ruleFilterWrapper: ruleFilterWrappers) {
				if (ruleFilterWrapper.id != null) setRuleFilterIds.add(ruleFilterWrapper.id);
				RuleFilter__c ruleFilter = ruleFilterWrapper.getRuleFilter();
				if (ruleFilter.Rule__c == null) ruleFilter.Rule__c = ruleId;
				if (ruleFilter.Comparison_Type__c == 'Value') {
					ruleFilter.Index__c = indexValue;
					indexValue++;
				} else {
					ruleFilter.Index__c = indexField;
					indexField++;
				}
				ruleFiltersToUpsert.add(ruleFilter);
			}
			for (RuleFilter__c ruleFilter: ruleFiltersOld) {
				if (!setRuleFilterIds.contains(ruleFilter.Id)) ruleFiltersToDelete.add(ruleFilter);
			}
			if (!ruleFiltersToDelete.isEmpty()) {
				DatabaseUtils.getInstance().performDeleteDML(ruleFiltersToDelete, Schema.SObjectType.RuleFilter__c, true);
			}
			if (!ruleFiltersToUpsert.isEmpty()) {
				DatabaseUtils.getInstance().performUpsertDML(ruleFiltersToUpsert, Schema.SObjectType.RuleFilter__c, true);
			}
		}
	}

	public static void upsertRuleActionsWithActions(String actionsJSON, String ruleActionsJSON, String ruleId, String recordTypeName) {
		List<Action> actionWrappers = (List<Action>)JSON.deserialize(actionsJSON, List<Action>.class);
		List<RuleAction> ruleActionWrappers = (List<RuleAction>)JSON.deserialize(ruleActionsJSON, List<RuleAction>.class);
		List<Action__c> actionsToUpsert = new List<Action__c>();
		List<RuleAction__c> ruleActionsToUpsert = new List<RuleAction__c>();
		Map<Id, RuleAction__c> mapExistRuleActions = new Map<Id, RuleAction__c>([
				SELECT Id, Rule__c, Action__c, Action__r.Subtype__c
				FROM RuleAction__c
				WHERE Rule__c = :ruleId AND Action__c != NULL
		]);

		List<Action__c> newActions = new List<Action__c>();
		Integer ruleActionIndex = 0;
		for (Action actionWrapper : actionWrappers) {
			RuleAction ruleActionWrapper = ruleActionWrappers.get(ruleActionIndex++);
			Action__c action = actionWrapper.getAction(recordTypeName);
			if (action.Id == null
					&& (ruleActionWrapper.id == null || ruleActionWrapper.actionId == null)){
				newActions.add(action);
			}
		}
		if (!newActions.isEmpty()) {
			DatabaseUtils.getInstance().performInsertDML(newActions, Schema.SObjectType.Action__c, true);
		}
		ruleActionIndex = 0;
		Integer newActionIndex = 0;
		for (Action actionWrapper : actionWrappers) {
			RuleAction ruleActionWrapper = ruleActionWrappers.get(ruleActionIndex++);
			Action__c action = actionWrapper.getAction(recordTypeName);
			// new ruleAction
			if (ruleActionWrapper.id == null) {
				// add new Action to rule
				if (action.Id == null) {
					RuleAction__c newRuleAction = ruleActionWrapper.getRuleAction();
					newRuleAction.Action__c = newActions.get(newActionIndex++).Id;
					newRuleAction.Rule__c = ruleId;
					ruleActionsToUpsert.add(newRuleAction);
				}
				// add exist Action__c to rule
				else if (action.Id == ruleActionWrapper.actionId) {
					RuleAction__c newRuleAction = ruleActionWrapper.getRuleAction();
					newRuleAction.Rule__c = ruleId;
					ruleActionsToUpsert.add(newRuleAction);
					actionsToUpsert.add(action);
				}
			}
			// update ruleAction
			else {
				RuleAction__c existRuleAction = mapExistRuleActions.get(ruleActionWrapper.id);
				// update exist Action__c on exist RuleAction__c
				if (action.Id != null && action.Id == ruleActionWrapper.actionId) {
					actionsToUpsert.add(action);
				}
				else if (action.Id == null && ruleActionWrapper.actionId == null) {
					RuleAction__c newRuleAction = ruleActionWrapper.getRuleAction();
					newRuleAction.Action__c = newActions.get(newActionIndex++).Id;
					ruleActionsToUpsert.add(newRuleAction);
				}
			}
		}
		if (!actionsToUpsert.isEmpty()) {
			DatabaseUtils.getInstance().performUpdateDML(actionsToUpsert, Schema.SObjectType.Action__c, true);
		}
		if (!ruleActionsToUpsert.isEmpty()) {
			DatabaseUtils.getInstance().performUpsertDML(ruleActionsToUpsert, Schema.SObjectType.RuleAction__c, true);
		}
	}

	public static Map<Id, Event> getLastCreatedEventsMap() {
		Map<Id, Event> result = new Map<Id, Event>();
		List<AggregateResult> events = [
				SELECT MAX(CreatedDate) CreatedDate, Rule__c RuleId
				FROM Event__c
				GROUP BY Rule__c
		];
		for (AggregateResult event : events) {
			Datetime createdDate = (Datetime)event.get('CreatedDate');
			Id ruleId = (Id)event.get('RuleId');
			if (ruleId != null && createdDate != null) {
				Event maxEvent = new Event(createdDate, ruleId);
				result.put(ruleId, maxEvent);
			}
		}
		return result;
	}

	private static Boolean inCurrentInterval(
			Datetime createdDatetime,
			Datetime runTime,
			Datetime lastProcessedDatetime,
			Decimal eventTimeInterval) {

		Datetime startTime;
		Datetime endTime;

		if (lastProcessedDatetime == null) {
			startTime = (eventTimeInterval != null)
					? runTime.addMinutes(-1*Integer.valueOf(eventTimeInterval))
					: null;
			endTime = runTime;
		}
		else {
			startTime = eventTimeInterval != null
					? (lastProcessedDatetime >= runTime.addMinutes(-1*Integer.valueOf(eventTimeInterval))
							? lastProcessedDatetime
							: runTime.addMinutes(-1*Integer.valueOf(eventTimeInterval)))
					: lastProcessedDatetime;
			endTime = runTime;
		}
		return createdDatetime <= endTime && createdDatetime >= startTime;
	}

	public static List<Rule> getRuleWrappers(String ruleType) {
		return getRuleWrappers(null, ruleType);
	}

	public static List<Rule> getRuleWrappers(String ruleId, String ruleType) {
		return getRuleWrappers(ruleId, new List<String>{ruleType});
	}

	public static List<Rule> getRuleWrappers(String ruleId, List<String> ruleTypes) {
		List<Rule> ruleWrappers = new List<Rule>();
		List<Rule__c> rules = getRules(ruleId, ruleTypes);
		if (rules != null && !rules.isEmpty()) {
			for (Rule__c rule: rules) {
				ruleWrappers.add(new Rule(rule)
						.addFilters(rule.RuleFilters__r)
						.addActions(rule.RuleActions__r)
						.addRuleActions(rule.RuleActions__r)
				);
			}
		}
		return ruleWrappers;
	}

	public static List<RuleFilter> getRuleFilterWrappers() {
		return getRuleFilterWrappers(null);
	}

	public static List<RuleFilter> getRuleFilterWrappers(Id ruleId) {
		List<RuleFilter> ruleFilterWrappers = new List<RuleFilter>();
		List<RuleFilter__c> ruleFilters = getRuleFilters(ruleId);
		if (ruleFilters != null && !ruleFilters.isEmpty()) {
			for (RuleFilter__c ruleFilter: ruleFilters) {
				ruleFilterWrappers.add(new RuleFilter(ruleFilter));
			}
		}
		return ruleFilterWrappers;
	}

	public static List<RuleAction> getRuleActionWrappers(String ruleType, String subtype) {
		List<RuleAction> ruleActionWrappers = new List<RuleAction>();
		for (RuleAction__c ruleAction : getRuleActions(ruleType, subtype)) {
			ruleActionWrappers.add(new RuleAction(ruleAction));
		}
		return ruleActionWrappers;
	}

	public static List<RuleAction__c> getRuleActions(String ruleType, String subtype) {
		List<String> actionTypes = MAP_ACTION_TYPES_BY_RULE_TYPE.get(ruleType);
		if (actionTypes == null || actionTypes.isEmpty()) {
			return new List<RuleAction__c>();
		}
		String query = new QBuilder(RuleAction__c.SObjectType)
				.selectFields(new Set<String>(RULE_ACTION_FIELDS))
				.add(QBuilder.condition('Action__r.Action_Type__c').isIn(actionTypes))
				.add(String.isNotBlank(subtype) ? QBuilder.condition('Action__r.Subtype__c').equalsTo(subtype) : null)
				.add(String.isBlank(subtype) ? QBuilder.condition('Action__r.Subtype__c').notEqualsTo(ACTION_SUBTYPE_NOTIFICATION) : null)
				.add(QBuilder.orderBy('CreatedDate').descending())
				.build();
		return Database.query(query);
	}

	public static List<Action> getActionWrappers(String ruleType, String subtype) {
		List<Action> actionWrappers = new List<Action>();
		List<Action__c> actions = getActions(ruleType, subtype);
		if (actions != null && !actions.isEmpty()) {
			for (Action__c action : actions) {
				actionWrappers.add(new Action(action));
			}
		}
		return actionWrappers;
	}

	public static Map<String, List<SelectOptionWrapper>> getActionTypes(String ruleType) {
		Map<String, List<SelectOptionWrapper>> result = new Map<String, List<SelectOptionWrapper>>();
		Map<String, Schema.RecordTypeInfo> mapRecordTypeInfoByName = Schema.SObjectType.Action__c.getRecordTypeInfosByName();
		String recordTypeName = ruleType == ACTION_RT_ARCHIVAL ? ACTION_RT_ARCHIVAL : ACTION_RT_MONITORING;
		if (mapRecordTypeInfoByName.containsKey(recordTypeName)) {
			List<SelectOptionWrapper> selectOptions = new List<SelectOptionWrapper>();
			for (String actionType : MAP_ACTION_TYPES_BY_RULE_TYPE.get(ruleType)) {
				selectOptions.add(new SelectOptionWrapper(actionType, actionType));
			}
			result.put(mapRecordTypeInfoByName.get(recordTypeName).getRecordTypeId(), selectOptions);
		}
		return result;
	}

	public static void updateOldJiraRuleActionTypeField() {
		List<Rule__c> rules = getRules(null, RULE_TYPE_JIRA_UPDATE);
		Map<Id, RuleAction__c> toDelete = new Map<Id, RuleAction__c>();
		Map<Id, Action__c> toUpdate = new Map<Id, Action__c>();

		for(Rule__c rule : rules) {
			Integer maxActionsPerJiraRule = 1;
			if(!rule.RuleActions__r.isEmpty()) {
				for(RuleAction__c ruleAction : rule.RuleActions__r) {
					if(maxActionsPerJiraRule > 1) {
						toDelete.put(ruleAction.Id, new RuleAction__c(Id = ruleAction.Id));
					}
					else {
						if(ruleAction?.Action__r?.Action_Type__c == null && ruleAction?.Action__r?.Type__c != null) {
							toUpdate.put(ruleAction.Action__r.Id, new Action__c(Id = ruleAction?.Action__r.Id, Action_Type__c = ruleAction.Action__r.Type__c));
						}
					}
					maxActionsPerJiraRule++;
				}
			}
		}
		if (!toUpdate.isEmpty()) {
			DatabaseUtils.getInstance().performUpdateDML(toUpdate.values(), Schema.SObjectType.Action__c)
					.handleError(RuleUtil.class.getName(), '.updateOldJiraRuleActionTypeField');
		}
		if (!toDelete.isEmpty()) {
			DatabaseUtils.getInstance().performDeleteDML(toDelete.values(), Schema.SObjectType.RuleAction__c)
					.handleError(RuleUtil.class.getName(), '.updateOldJiraRuleActionTypeField');
		}

		List<Action__c> oldDefaultAction = [
			SELECT Id, Subtype__c
			FROM Action__c
			WHERE Subtype__c = :ACTION_SUBTYPE_DEFAULT
			LIMIT 1
		];
		if (!oldDefaultAction.isEmpty()) {
			oldDefaultAction.get(0).Subtype__c = null;
			DatabaseUtils.getInstance().performUpdateDML(oldDefaultAction, Schema.SObjectType.Action__c)
					.handleError(RuleUtil.class.getName(), '.updateOldJiraRuleActionTypeField');
		}
	}

	public static Database.DeleteResult deleteRule(String ruleId) {
		Set<Id> actionIds = new Set<Id>();
		for (RuleAction__c ruleAction : [SELECT Id, Action__c FROM RuleAction__c WHERE Rule__c = :ruleId]) {
			if (String.isNotBlank(ruleAction.Action__c)) actionIds.add(ruleAction.Action__c);
		}
		for (Action__c action : [SELECT Id FROM Action__c WHERE Id IN (SELECT Action__c FROM RuleAction__c WHERE Action__c IN :actionIds AND Rule__c != :ruleId)]) {
			actionIds.remove(action.Id);
		}
		if (!actionIds.isEmpty()) {
			DatabaseUtils.getInstance().performDeleteDML(new List<Id>(actionIds), Schema.SObjectType.Action__c)
					.handleError(RuleUtil.class.getName(), '.deleteRule');
		}
		return DatabaseUtils.getInstance().performDeleteDML(new List<Id>{ruleId}, Schema.SObjectType.Rule__c)
				.handleError(RuleUtil.class.getName(), '.deleteRule').deleteResults[0];
	}

	public static Boolean isJiraRule(String ruleId) {
		Boolean result = false;
		if (String.isNotBlank(ruleId)) {
			List<Rule> rules = getRuleWrappers(RULE_TYPE_JIRA_UPDATE);
			for (Rule rule : rules) {
				if (rule.id != null && Id.valueOf(rule.id) == Id.valueOf(ruleId)) {
					result = true;
					break;
				}
			}
		}
		return result;
	}

	public static Map<String, Object> deleteRuleAction(String ruleActionId) {
		Map<String, Object> result = new Map<String, Object>();
		List<RuleAction__c> ruleAction = [SELECT Id, Action__c, Rule__c FROM RuleAction__c WHERE Id = :ruleActionId LIMIT 1];
		List<RuleAction__c> actionsAttachedToOtherRules = new List<RuleAction__c>();

		if (!ruleAction.isEmpty() && String.isNotBlank(ruleAction.get(0).Action__c)) {
			actionsAttachedToOtherRules = [
					SELECT Id
					FROM RuleAction__c
					WHERE Action__c = :ruleAction.get(0).Action__c
					AND Rule__c != :ruleAction.get(0).Rule__c
					LIMIT 1
			];
		}

		if (actionsAttachedToOtherRules.isEmpty()) {
			Database.DeleteResult dr = DatabaseUtils.getInstance().performDeleteDML(new List<Id>{ruleAction.get(0).Action__c}, Schema.SObjectType.Action__c)
					.handleError(RuleUtil.class.getName(), '.deleteRuleAction').deleteResults[0];
			Map<String, Object> actionResult = new Map<String, Object>();
			actionResult.put(KEY_SUCCESS, dr.isSuccess());
			actionResult.put(KEY_MESSAGE, dr.getErrors());
			result.put(ConfigUtil.DELETE_MONITORING_RULE_ACTION_KEY_ACTION_RESULT, actionResult);
		}
		Map<String, Object> ruleActionResult = new Map<String, Object>();
		Database.DeleteResult dr = DatabaseUtils.getInstance().performDeleteDML(new List<Id>{ruleAction.get(0).Id}, Schema.SObjectType.RuleAction__c)
				.handleError(RuleUtil.class.getName(), '.deleteRuleAction').deleteResults[0];
		ruleActionResult.put(KEY_SUCCESS, dr.isSuccess());
		ruleActionResult.put(KEY_MESSAGE, dr.getErrors());
		result.put(DELETE_RULE_ACTION_MESSAGE_ACTION_RESULT, ruleActionResult);

		return result;
	}

	public static Map<String, Object> deleteAction(String actionId) {
		List<Action__c> action = [SELECT Id FROM Action__c WHERE Id = :actionId LIMIT 1];

		Map<String, Object> actionResult = new Map<String, Object>();
		Database.DeleteResult dr = DatabaseUtils.getInstance().performDeleteDML(new List<Id>{action.get(0).Id}, Schema.SObjectType.Action__c)
				.handleError(RuleUtil.class.getName(), '.deleteAction').deleteResults[0];
		actionResult.put(KEY_SUCCESS, dr.isSuccess());
		actionResult.put(KEY_MESSAGE, dr.getErrors());
		return actionResult;
	}

	public class Rule {
		public Id id;
		public Id relatedId;
		public String sObjectType;
		public String name;
		public String description;
		public String createdBy;
		public String type;
		public String subtype;
		public String filterLogic;
		public String aggregateType;
		public String comparisonOperator;
		public Boolean active;
		public Boolean isUpdateRule;
		public Integer index;
		public Decimal eventTimeInterval;
		public Decimal aggregateInterval;
		public Decimal threshold;
		public Decimal value;
		public Set<String> groupFieldNames;
		public List<RuleFilter> ruleFilters;
		public List<RuleAction> ruleActions;
		public List<Action> actions;
		public Boolean isNotValid;

		public Integer maxIndex;

		public Rule() {}

		public Rule(Rule rule) {
			this.id = rule.id;
			this.relatedId = rule.relatedId;
			this.sObjectType = rule.sObjectType;
			this.name = rule.name;
			this.description = rule.description;
			this.createdBy = rule.createdBy;
			this.type = rule.type;
			this.subtype = rule.subtype;
			this.filterLogic = rule.filterLogic;
			this.aggregateType = rule.aggregateType;
			this.comparisonOperator = rule.comparisonOperator;
			this.active = rule.active;
			this.index = rule.index;
			this.eventTimeInterval = rule.eventTimeInterval;
			this.aggregateInterval = rule.aggregateInterval;
			this.threshold = rule.threshold;
			this.value = 0;
			this.groupFieldNames = rule.groupFieldNames;
			this.ruleFilters = rule.ruleFilters;
			this.ruleActions = rule.ruleActions;
			this.actions = rule.actions;
			this.maxIndex = rule.maxIndex;
			this.isNotValid = rule.isNotValid;
			this.isUpdateRule = (rule.isUpdateRule == null) ? false : rule.isUpdateRule;
		}

		public Rule(Rule__c rule) {
			this.id = rule.Id;
			this.relatedId = rule.Related_Id__c;
			this.sObjectType = rule.SobjectType__c;
			this.name = rule.Name__c;
			this.description = rule.Description__c;
			this.createdBy = rule.CreatedBy.Name;
			this.type = rule.Type__c;
			this.subtype = rule.Subtype__c;
			this.filterLogic = rule.FilterLogic__c;
			this.aggregateType = rule.AggregateType__c;
			this.comparisonOperator = rule.ComparisonOperator__c;
			this.active = rule.Active__c;
			this.index = Integer.valueOf(rule.Index__c);
			this.eventTimeInterval = rule.EventTimeInterval__c;
			this.aggregateInterval = rule.AggregateInterval__c;
			this.threshold = rule.Threshold__c;
			this.value = 0;
			this.groupFieldNames = new Set<String>();
			this.ruleFilters = new List<RuleFilter>();
			this.ruleActions = new List<RuleAction>();
			this.actions = new List<Action>();
			this.maxIndex = 0;
			this.isNotValid = rule.Is_Not_Valid__c;
			this.isUpdateRule = rule.Is_Update__c;
		}

		public Rule__c getRule() {
			return new Rule__c(
					Id = id,
					Related_Id__c = relatedId,
					SobjectType__c = sObjectType,
					Name__c = name,
					Description__c = description,
					Type__c = type,
					Subtype__c = subtype,
					FilterLogic__c = filterLogic,
					AggregateType__c = aggregateType,
					ComparisonOperator__c = comparisonOperator,
					Active__c = active,
					Index__c = index,
					EventTimeInterval__c = eventTimeInterval,
					AggregateInterval__c = aggregateInterval,
					Threshold__c = threshold,
					Is_Update__c = (isUpdateRule == null) ? false : isUpdateRule
			);
		}

		public MonitoringUtil.MonitoringRule toRule() {
			MonitoringUtil.MonitoringRule result = new MonitoringUtil.MonitoringRule();
			result.ruleType = this.type;
			result.filterLogic = this.filterLogic;

			result.actions = new List<MonitoringUtil.Action>();
			for(Action ra : this.actions) {
				MonitoringUtil.Action action = new MonitoringUtil.Action();
				action.type = ra.type;
				action.actionType = MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(action.type);
				result.actions.add(action);
			}

			result.filters = new List<MonitoringUtil.RuleFilter>();
			for(RuleFilter rf : this.ruleFilters) {
				MonitoringUtil.RuleFilter ruleFilter = new MonitoringUtil.RuleFilter();
				ruleFilter.fieldName = ruleFilter.fieldName;
				ruleFilter.fieldType = ruleFilter.fieldType;
				ruleFilter.value = ruleFilter.value;
				ruleFilter.index = ruleFilter.index;
				ruleFilter.comparisonType = ruleFilter.comparisonType;
				ruleFilter.comparisonOperator = ruleFilter.comparisonOperator;
				result.filters.add(ruleFilter);
			}
			return result;
		}

		public Rule addRuleActions(List<RuleAction__c> ruleActions) {
			for (RuleAction__c ruleAction : ruleActions) {
				this.ruleActions.add(new RuleAction(ruleAction));
			}
			return this;
		}

		public Rule addActions(List<RuleAction__c> ruleActions) {
			for (RuleAction__c ruleAction : ruleActions) {
				if (ruleAction.Action__r != null) {
					this.actions.add(new Action(ruleAction.Action__r));
				}
			}
			return this;
		}

		public Rule addFilters(List<RuleFilter__c> ruleFilters) {
			for (RuleFilter__c ruleFilter : ruleFilters) {
				RuleFilter ruleFilterWrapper = new RuleFilter(ruleFilter);
				if (this.type == RULE_TYPE_ARCHIVAL && ruleFilterWrapper.index == 1) {
					ruleFilterWrapper.value = minutesToLabel(ruleFilterWrapper.value);
				}
				switch on MAP_COMPARISON_TYPES_BY_STRINGS.get(ruleFilterWrapper.comparisonType) {
					when VALUE {
						this.ruleFilters.add(ruleFilterWrapper);
						this.maxIndex = Math.max(this.maxIndex, Integer.valueOf(ruleFilterWrapper.index));
					}
					when FIELD {
						this.ruleFilters.add(ruleFilterWrapper);
						this.groupFieldNames.add(ruleFilterWrapper.fieldName);
					}
				}
			}
			buildDefaultANDFilter();
			return this;
		}

		private String minutesToLabel(String strMinutes) {
			Integer days = Integer.valueOf(strMinutes) / 60 / 24 ;
			Integer hours = (Integer.valueOf(strMinutes) - days * 60 * 24) / 60 ;
			Integer minutes = Integer.valueOf(strMinutes) - days * 60 * 24 - hours * 60 ;
			String label = ((days != 0) ? days + '(Days) ' : '') + ((hours != 0) ? hours + '(Hours) ' : '') + ((minutes != 0) ? minutes + '(Minutes)' : '');
			return label;
		}

		public void buildDefaultANDFilter() {
			if(String.isBlank(this.filterLogic)) {
                List<Integer> indexFilter = new List<Integer>();
                Integer indexesCount = getIndexesCount();
                if(this.type == RULE_TYPE_ARCHIVAL) {
                    indexesCount += -1;
                }
                for(Integer i = 1; i <= indexesCount; i++) {
                    indexFilter.add(i);
                }
                this.filterLogic = String.join(indexFilter, ' AND ');
                if(this.type == RULE_TYPE_ARCHIVAL && String.isBlank(this.filterLogic)) {
                    this.filterLogic = '1';
                }
            }
		}

		public Integer getIndexesCount() {
			return this.maxIndex;
		}

		public List<Log__c> applyBroadcastRuleFilters(List<Log__c> logs) {
			List<Log__c> result = new List<Log__c>();
			for (Log__c log : logs) {
				Map<String, Object> objectMap = log.getPopulatedFieldsAsMap();
				List<Boolean> booleanValues = new Boolean[getIndexesCount()];
				for (RuleFilter filter : this.ruleFilters) {
					if (MAP_COMPARISON_TYPES_BY_STRINGS.get(filter.comparisonType) == ComparisonType.VALUE) {
						Boolean booleanValue = filter.evaluateFilter(objectMap);
						Integer index = Integer.valueOf(filter.index) - 1;
						booleanValues.set(index, booleanValue);
					}
				}
				Boolean rulesResult = (String.isNotBlank(this.filterLogic))
						? FilterEvaluator.evaluate(this.filterLogic, booleanValues)
						: true;
				if (rulesResult) {
					result.add(log);
				}
			}
			return result;
		}

		public List<Log__c> applyRuleFilters(List<Log__c> logs) {
			List<Log__c> result = new List<Log__c>();
			for (Log__c log : logs) {
				Map<String, Object> objectMap = log.getPopulatedFieldsAsMap();
				List<Boolean> booleanValues = new Boolean[getIndexesCount()];
				for (RuleFilter filter : this.ruleFilters) {
					if (MAP_COMPARISON_TYPES_BY_STRINGS.get(filter.comparisonType) == ComparisonType.VALUE) {
						Boolean booleanValue = (filter.isFilterable) ? true : filter.evaluateFilter(objectMap);
						Integer index = Integer.valueOf(filter.index) - 1;
						booleanValues.set(index, booleanValue);
					}
				}
				Boolean rulesResult = (String.isNotBlank(this.filterLogic))
						? FilterEvaluator.evaluate(this.filterLogic, booleanValues)
						: true;
				if (rulesResult) {
					result.add(log);
				}
			}
			return result;
		}
	}

	public class RuleFilter implements Comparable{
		public Id id;
		public Id ruleId;
		public String value;
		public String oldValue;
		public String fieldName;
		public String fieldType;
		public String comparisonType;
		public String comparisonOperator;
		public String comparisonOperatorOldValue;
		public Decimal index;
		public Boolean isFilterable;
		public Boolean isOld;

		public RuleFilter() {}

		public RuleFilter(RuleFilter__c ruleFilter) {
			this.id = ruleFilter.Id;
			this.ruleId = ruleFilter.Rule__c;
			this.value = ruleFilter.Value__c;
			this.fieldName = ruleFilter.FieldName__c;
			this.fieldType = ruleFilter.Field_Type__c;
			this.comparisonType = ruleFilter.Comparison_Type__c;
			this.comparisonOperator = ruleFilter.ComparisonOperator__c;
			this.index = ruleFilter.Index__c;
			this.isOld = ruleFilter.Is_Old__c == null ? false : ruleFilter.Is_Old__c;

			this.isFilterable = ConfigUtil.MAP_LOG_FIELDS.containsKey(this.fieldName.toLowerCase())
				&& ConfigUtil.MAP_LOG_FIELDS.get(this.fieldName.toLowerCase()).isFilterable()
				&& MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) != RuleUtil.ComparisonOperator.CONTAINS
				&& MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) != RuleUtil.ComparisonOperator.DOESNT_CONTAIN;
		}

		public RuleFilter__c getRuleFilter() {
			return new RuleFilter__c(
				Id = id,
				Rule__c = ruleId,
				Value__c = value,
				FieldName__c = fieldName,
				Field_Type__c = fieldType,
				Comparison_Type__c = comparisonType,
				ComparisonOperator__c = comparisonOperator,
				Index__c = index,
				Is_Old__c = (isOld == null ? false : isOld)
			);
		}

		public String getStringFilter() {
			String result = '';
			switch on MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) {
				when EQUAL {
					result = this.fieldName + ' = ' + this.value;
				}
				when NOT_EQUAL {
					result = this.fieldName + ' != ' + this.value;
				}
				when GREATER_THAN {
					result = this.fieldName + ' > ' + this.value;
				}
				when GREATER_OR_EQUAL {
					result = this.fieldName + ' >= ' + this.value;
				}
				when LESS_THAN {
					result = this.fieldName + ' < ' + this.value;
				}
				when LESS_OR_EQUAL {
					result = this.fieldName + ' <= ' + this.value;
				}
				when CONTAINS {
					result = this.fieldName + ' CONTAINS(' + this.value + ')';
				}
				when DOESNT_CONTAIN {
					result = this.fieldName + ' NOT CONTAINS(' + this.value + ')';
				}
				when else {
					// undefined comparison operator
				}
			}
			return result;
		}

		public Boolean evaluateFilter(Map<String, Object> objectMap) {
			Boolean result = false;
			RuleUtil.FieldType fieldType;
			if (String.isNotBlank(this.fieldName)
					&& ConfigUtil.MAP_LOG_FIELDS.get(this.fieldName.toLowerCase()) != null) {
				String displayType = String.valueOf(ConfigUtil.MAP_LOG_FIELDS.get(this.fieldName.toLowerCase()).getType());
				fieldType = MAP_FIELD_TYPES_BY_STRINGS.get(displayType);
			}
			switch on fieldType {
				when FT_BOOLEAN {
					switch on MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) {
						when EQUAL {
							result = getStringValue(objectMap.get(this.fieldName)) == this.value;
						}
						when NOT_EQUAL {
							result = getStringValue(objectMap.get(this.fieldName)) != this.value;
						}
						when else {
							// undefined comparison operator
						}
					}
				}
				when FT_ID, FT_PICKLIST, FT_REFERENCE, FT_STRING, FT_TEXTAREA, FT_URL {
					switch on MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) {
						when EQUAL {
							result = getStringValue(objectMap.get(this.fieldName)) == this.value;
						}
						when NOT_EQUAL {
							result = getStringValue(objectMap.get(this.fieldName)) != this.value;
						}
						when CONTAINS {
							result = getStringValue(objectMap.get(this.fieldName)).containsIgnoreCase(getStringValue(this.value));
						}
						when DOESNT_CONTAIN {
							result = !getStringValue(objectMap.get(this.fieldName)).containsIgnoreCase(getStringValue(this.value));
						}
						when else {
							// undefined comparison operator
						}
					}
				}
				when FT_NUMBER, FT_DOUBLE {
					switch on MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) {
						when EQUAL {
							result = getDecimalValue(objectMap.get(this.fieldName)) == getDecimalValue(this.value);
						}
						when NOT_EQUAL {
							result = getDecimalValue(objectMap.get(this.fieldName)) != getDecimalValue(this.value);
						}
						when GREATER_THAN {
							result = getDecimalValue(objectMap.get(this.fieldName)) > getDecimalValue(this.value);
						}
						when GREATER_OR_EQUAL {
							result = getDecimalValue(objectMap.get(this.fieldName)) >= getDecimalValue(this.value);
						}
						when LESS_THAN {
							result = getDecimalValue(objectMap.get(this.fieldName)) < getDecimalValue(this.value);
						}
						when LESS_OR_EQUAL {
							result = getDecimalValue(objectMap.get(this.fieldName)) <= getDecimalValue(this.value);
						}
						when CONTAINS {
							result = getStringValue(objectMap.get(this.fieldName)).containsIgnoreCase(getStringValue(this.value));
						}
						when DOESNT_CONTAIN {
							result = !getStringValue(objectMap.get(this.fieldName)).containsIgnoreCase(getStringValue(this.value));
						}
						when else {
							// undefined comparison operator
						}
					}
				}
				when FT_DATE {
					switch on MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) {
						when EQUAL {
							result = getDateValue(objectMap.get(this.fieldName)) == getDateValue(String.valueOf(this.value));
						}
						when NOT_EQUAL {
							result = getDateValue(objectMap.get(this.fieldName)) != getDateValue(String.valueOf(this.value));
						}
						when GREATER_THAN {
							result = getDateValue(objectMap.get(this.fieldName)) > getDateValue(String.valueOf(this.value));
						}
						when GREATER_OR_EQUAL {
							result = getDateValue(objectMap.get(this.fieldName)) >= getDateValue(String.valueOf(this.value));
						}
						when LESS_THAN {
							result = getDateValue(objectMap.get(this.fieldName)) < getDateValue(String.valueOf(this.value));
						}
						when LESS_OR_EQUAL {
							result = getDateValue(objectMap.get(this.fieldName)) <= getDateValue(String.valueOf(this.value));
						}
						when else {
							// undefined comparison operator
						}
					}
				}
				when FT_DATETIME {
					switch on MAP_COMPARISON_OPERATOR_BY_STRING.get(this.comparisonOperator) {
						when EQUAL {
							result = getDatetimeValue(objectMap.get(this.fieldName)) == getDatetimeValue(String.valueOf(this.value));
						}
						when NOT_EQUAL {
							result = getDatetimeValue(objectMap.get(this.fieldName)) != getDatetimeValue(String.valueOf(this.value));
						}
						when GREATER_THAN {
							result = getDatetimeValue(objectMap.get(this.fieldName)) > getDatetimeValue(String.valueOf(this.value));
						}
						when GREATER_OR_EQUAL {
							result = getDatetimeValue(objectMap.get(this.fieldName)) >= getDatetimeValue(String.valueOf(this.value));
						}
						when LESS_THAN {
							result = getDatetimeValue(objectMap.get(this.fieldName)) < getDatetimeValue(String.valueOf(this.value));
						}
						when LESS_OR_EQUAL {
							result = getDatetimeValue(objectMap.get(this.fieldName)) <= getDatetimeValue(String.valueOf(this.value));
						}
						when else {
							// undefined comparison operator
						}
					}
				}
			}
			return result;
		}

		private String getStringValue(Object obj) {
			String reString = '';
			if (obj != null) {
				reString = obj.toString();
			}
			return reString;
		}

		private Decimal getDecimalValue(Object obj) {
			Decimal result = null;
			if (obj != null) {
				result = Decimal.valueOf(String.valueOf(obj));
			}
			return result;
		}

		private Date getDateValue(Object obj) {
			Date result = null;
			if (obj != null) {
				result = (Date)obj;
			}
			return result;
		}

		private Date getDateValue(String obj) {
			Date result = null;
			if (obj != null) {
				result = Date.valueOf(obj);
			}
			return result;
		}

		private Datetime getDatetimeValue(Object obj) {
			Datetime result = null;
			if (obj != null) {
				result = (Datetime)obj;
			}
			return result;
		}

		private Datetime getDatetimeValue(String obj) {
			Datetime result = null;
			if (obj != null) {
				result = Datetime.valueOfGmt(obj);
			}
			return result;
		}

		public Integer compareTo(Object compareTo) {
            RuleFilter that = (RuleFilter)compareTo;
            if (this.index == that.index) return 0;
            if (this.index == null) return 1;
            if (that.index == null) return -1;
            return (this.index > that.index) ? 1 : -1;
        }
	}

	public class RuleAction {
		public Id id;
		public Id ruleId;
		public Id actionId;
		
		public String ruleName;
		public String ruleType;
		public String ruleDescription;
		public String actionName;
		public String actionType;
		public String actionSubject;

		public RuleAction() {}

		public RuleAction(RuleAction__c ruleAction) {
			id = ruleAction.Id;
			ruleId = ruleAction.Rule__c;
			actionId = ruleAction.Action__c;

			ruleName = ruleAction.Rule__r.Name__c;
			ruleType = ruleAction.Rule__r.Type__c;
			ruleDescription = ruleAction.Rule__r.Description__c;
			actionName = ruleAction.Action__r.Name;
			actionType = ruleAction.Action__r.Action_Type__c;
			actionSubject = ruleAction.Action__r.Subject__c;
		}
		
		public RuleAction__c getRuleAction() {
			return new RuleAction__c(
					Id = id,
					Rule__c = ruleId,
					Action__c = actionId
			);
		}
	}

	public class Action {
		public Id id;
		public Id recordTypeId;
		public Id contactId;
		public String contactName;
		public String createBy;
		public String name;
		public String actionName;
		public String body;
		public String description;
		public String type;
		public String subtype;
		public String subject;
		public String pagerDutyType;
		public String teamId;
		public String channelId;
		public String slackChannels;
		public String emailBody;
		public String emailCC;
		public String emailTemplateId;
		public String emailTo;
		public String jiraAssigneeId;
		public String jiraAssignee;
		public String jiraProject;
		public String jiraPriority;
		public String jiraLabels;
		public String jiraIssueType;
		public String jiraEpic;
		public String jiraComponents;
		public String iteration;
		public String area;
		public String additionalMetadata;
		public String sObjectType;
		public Datetime createdDate;
		public Boolean isUpdate;

		public String content;
		public Action__c fields;

		public Action() {}

		public Action(Action__c action) {
			this.id = action.Id;
			this.recordTypeId = action.RecordTypeId;
			this.contactId = action.Contact__c;
			this.contactName = action.Contact__c != null ? action.Contact__r.Name : null;
			this.createBy = action.CreatedBy.Name;
			this.name = action.Name;
			this.actionName = action.Name__c;
			this.body = action.Body__c;
			this.description = action.Description__c;
			this.type = action.Action_Type__c != null ? action.Action_Type__c : action.Type__c;
			this.subtype = action.Subtype__c;
			this.subject = action.Subject__c;
			this.pagerDutyType = action.PagerDuty_Type__c;
			this.teamId = action.Team_Id__c;
			this.channelId = action.Channel_Id__c;
			this.slackChannels = action.SlackChannels__c;
			this.emailBody = action.EmailBody__c;
			this.emailCC = action.EmailCC__c;
			this.emailTemplateId = action.EmailTemplateId__c;
			this.emailTo = action.EmailTo__c;
			this.jiraAssigneeId = action.JIRAAssignee_Id__c;
			this.jiraAssignee = action.JIRAAssignee__c;
			this.jiraProject = action.JIRAProject__c;
			this.jiraPriority = action.JIRAPriority__c;
			this.jiraLabels = action.JIRALabels__c;
			this.jiraIssueType = action.JIRAIssueType__c;
			this.jiraEpic = action.JIRAEpic__c;
			this.jiraComponents = action.JIRAComponents__c;
			this.area = action.JIRAComponents__c;
			this.iteration = action.Iteration__c;
			this.additionalMetadata = action.Additional_Metadata__c;
			this.sObjectType = action.SobjectType__c;
			this.actionName = action.Name__c;
			this.createdDate = action.CreatedDate;
			this.isUpdate = action.Is_Update__c != null ? action.Is_Update__c : false;

			this.fields = action;

			switch on MAP_ACTION_TYPES_BY_STRINGS.get(this.type) {
				when JIRA {
					Map<String, Object> contentMap = new Map<String, Object>();
					contentMap.put('Assignee', action.JIRAAssignee__c);
					contentMap.put('Components', action.JIRAComponents__c);
					contentMap.put('Epic', action.JIRAEpic__c);
					contentMap.put('IssueType', action.JIRAIssueType__c);
					contentMap.put('Labels', action.JIRALabels__c);
					contentMap.put('Priority', action.JIRAPriority__c);
					contentMap.put('Project', action.JIRAProject__c);
					this.content = JSON.serialize(contentMap);
				}
				when SLACK {
					Map<String, Object> contentMap = new Map<String, Object>();
					contentMap.put('SlackChannel', action.SlackChannels__c);
					contentMap.put('Subject', action.Subject__c);
					contentMap.put('Body', action.Body__c);
					this.content = JSON.serialize(contentMap);
				}
				when EMAIL {
					Map<String, Object> contentMap = new Map<String, Object>();
					contentMap.put('TO', action.EmailTo__c);
					contentMap.put('CC', action.EmailCC__c);
					contentMap.put('Subject', action.Subject__c);
					contentMap.put('Message', action.EmailBody__c);
					this.content = JSON.serialize(contentMap);
				}
				when PAGERDUTY {
					Map<String, Object> contentMap = new Map<String, Object>();
					contentMap.put('Type', null);
					contentMap.put('Date', null);
					contentMap.put('Service', null);
					contentMap.put('Assigned', null);
					this.content = JSON.serialize(contentMap);
				}
				when REMOVAL, EXTERNAL_ARCHIVAL, ARCHIVAL_TO_BIG_OBJECT {
					this.content = this.type;
				}
			}
		}

		public Action__c getAction(String recordTypeName) {
			Schema.RecordTypeInfo recordTypeInfo = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(recordTypeName);
			return new Action__c(
					Id = id,
					RecordTypeId = recordTypeInfo != null ? recordTypeInfo.getRecordTypeId() : null,
					Contact__c = contactId,
					Body__c = body,
					Description__c = description,
					Action_Type__c = type,
					Subtype__c = subtype,
					Subject__c = subject,
					PagerDuty_Type__c = pagerDutyType,
					Team_Id__c = teamId,
					Channel_Id__c = channelId,
					SlackChannels__c = slackChannels,
					EmailBody__c = emailBody,
					EmailCC__c = emailCC,
					EmailTemplateId__c = emailTemplateId,
					EmailTo__c = emailTo,
					JIRAAssignee_Id__c = jiraAssigneeId,
					JIRAAssignee__c = jiraAssignee,
					JIRAProject__c = jiraProject,
					JIRAPriority__c = jiraPriority,
					JIRALabels__c = jiraLabels,
					JIRAIssueType__c = jiraIssueType,
					JIRAEpic__c = jiraEpic,
					JIRAComponents__c = type == ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION ? area : jiraComponents,
					Iteration__c = iteration,
					Additional_Metadata__c = additionalMetadata,
					Name__c = actionName,
					SobjectType__c = sObjectType,
					Is_Update__c = isUpdate != null ? isUpdate : false
			);
		}

	}

	public class Event {
		public Datetime createdDate;
		public Id ruleId;

		public Event(Datetime createdDate, Id ruleId) {
			this.createdDate = createdDate;
			this.ruleId = ruleId;
		}
	}

	public class SelectOptionWrapper {
		public String value;
		public String label;

		public SelectOptionWrapper(String value, String label) {
			this.value = value;
			this.label = label;
		}
	}

}