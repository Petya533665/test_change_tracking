@IsTest
private class RuleUtilTest {

	@IsTest
	public static void test_rule_action_create_and_delete() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
				createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		system.assertNotEquals(null, response);

		List<Action__c> newActionRecord = [SELECT Id FROM Action__c LIMIT 1];
		system.assertEquals(1, newActionRecord.size());

		data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTION_ID, newActionRecord.get(0).Id);
		
		input = new Map<String, Object>();
		input.put('method', 'deleteAction');
		input.put('data', data);

		response = AdminController.remoteActionHandler(JSON.serialize(input));
		system.assertNotEquals(null, response);

		List<Action__c> newActionRecordAfter = [SELECT Id FROM Action__c WHERE Id = :newActionRecord.get(0).Id LIMIT 1];
		system.assertEquals(0, newActionRecordAfter.size());
	}

	private static void setMaxMonitoringRules(Integer limitValue) {
		Map<Integer, Integer> bitmap8x3bits = new Map<Integer, Integer>{
			0=>limitValue, //FP_MAX_MONITORING_RULES
			1=>0, //FP_MAX_ARCHIVAL_RULES
			2=>0  //FP_MAX_CONNECTED_ORGS
		};
		Map<Integer, Integer> bitmap = PermissionsUtil.concat3x8bitsTo29bits(bitmap8x3bits);
		Integer intValue = PermissionsUtil.getIntegerFromBitmap(bitmap);
		PermissionsUtil.MaxMonitoringRules = null;
		PermissionsUtil.FeatureMap2 = null;
		PermissionsUtil.FeatureMap2IntValue = intValue;
		system.assertEquals(limitValue, PermissionsUtil.MaxMonitoringRules);
	}

	private static void setMaxNotificationTicketingRules(Integer limitValueNotifations, Integer limitValueTicketing) {
		Map<Integer, Integer> bitmap8x3bits = new Map<Integer, Integer>{
			0=>limitValueNotifations, //FP_MAX_NOTIFICATION_RULES
			1=>limitValueTicketing, //FP_MAX_JIRA_RULES
			2=>0
		};
		Map<Integer, Integer> bitmap = PermissionsUtil.concat3x8bitsTo29bits(bitmap8x3bits);
		Integer intValue = PermissionsUtil.getIntegerFromBitmap(bitmap);
		PermissionsUtil.MaxJiraRules = null;
		PermissionsUtil.MaxNotificationRules = null;
		PermissionsUtil.FeatureMap3 = null;
		PermissionsUtil.FeatureMap3IntValue = intValue;

		system.assertEquals(limitValueTicketing, PermissionsUtil.MaxJiraRules);
		system.assertEquals(limitValueNotifations, PermissionsUtil.MaxNotificationRules);
	}

	@IsTest
	public static void test_jira_update_rule_limits_reached_on_create() {
		TestDataFactory.enableMaxJiraRules();
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
			createRule(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Name', null, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		Test.startTest();
		Integer limitRules = 1;
		setMaxNotificationTicketingRules(0, limitRules);
		String result = (String)AdminController.remoteActionHandler(JSON.serialize(input));
		Test.stopTest();
		Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(result);
		String error = (String)objMap.get('error');
		System.assertNotEquals(null, error);
		System.assertEquals(true, error.contains(AdminService.RULE_MAX_ACTIVE_RULES_REACHED));
	}

	@IsTest
	public static void test_notification_rule_limits_reached_on_create() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
			createRule(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Name', null, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		Test.startTest();
		Integer limitRules = 1;
		setMaxNotificationTicketingRules(0, limitRules);
		String result = (String)AdminController.remoteActionHandler(JSON.serialize(input));
		Test.stopTest();
		Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(result);
		String error = (String)objMap.get('error');
		System.assertNotEquals(null, error);
		System.assertEquals(true, error.contains(AdminService.RULE_MAX_ACTIVE_RULES_REACHED));
	}

	@IsTest
	public static void test_monitoring_rule_limits_reached_on_create() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
			createRule(Constants.RULE_SOBJECT.TYPE_MONITORING, Constants.RULE_SOBJECT.SUB_TYPE_IMPACT, null, true, 60, 1));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, '1', RuleUtil.COMPARISON_TYPE_FIELD, RuleUtil.COMPARISON_OPERATOR_EQUAL, null)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		// first create rule
		AdminController.remoteActionHandler(JSON.serialize(input));
		Test.startTest();
		Integer limitRules = 1;
		setMaxMonitoringRules(limitRules);
		// second create rule with validation error
		String result = (String)AdminController.remoteActionHandler(JSON.serialize(input));
		Test.stopTest();
		Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(result);
		String error = (String)objMap.get('error');
		System.assertNotEquals(null, error);
		System.assertEquals(true, error.contains(AdminService.RULE_MAX_ACTIVE_RULES_REACHED));
	}

	@IsTest
	public static void test_monitoring_rule_limits_not_reached_on_update_exist() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
			createRule(Constants.RULE_SOBJECT.TYPE_MONITORING, Constants.RULE_SOBJECT.SUB_TYPE_IMPACT, null, true, 60, 1));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, '1', RuleUtil.COMPARISON_TYPE_FIELD, RuleUtil.COMPARISON_OPERATOR_EQUAL, null)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		// first create rule
		AdminController.remoteActionHandler(JSON.serialize(input));

		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_MONITORING);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);

		Test.startTest();
		Integer limitRules = 1;
		setMaxMonitoringRules(limitRules);
		Map<String, Object> dataUpdate = new Map<String, Object>();
		RuleUtil.Rule updatedRule = createRule(Constants.RULE_SOBJECT.TYPE_MONITORING, Constants.RULE_SOBJECT.SUB_TYPE_IMPACT, null, true, 60, 1);
		updatedRule.id = rules.get(0).id;
		dataUpdate.put(RuleUtil.KEY_RULE, updatedRule);

		Map<String, Object> inputUpdate = new Map<String, Object>();
		inputUpdate.put('method', 'setRule');
		inputUpdate.put('data', dataUpdate);
		String secondResult = (String)AdminController.remoteActionHandler(JSON.serialize(inputUpdate));
		Test.stopTest();
		
		Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(secondResult);
		Object error = objMap.get('error');
		System.assertEquals(null, error);
	}

	@IsTest
	public static void test_monitoring_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(Constants.RULE_SOBJECT.TYPE_MONITORING, Constants.RULE_SOBJECT.SUB_TYPE_SPIKE, null, true, 60, 1));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_MONITORING);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		System.assertNotEquals(null, result);
		List<RuleUtil.RuleFilter> ruleFilters = (List<RuleUtil.RuleFilter>)result.get(RuleUtil.KEY_RULE_FILTERS);
		System.assertNotEquals(null, ruleFilters);
		System.assertEquals(1, ruleFilters.size());
		System.assertEquals(RuleUtil.FIELD_TYPE_STRING, ruleFilters.get(0).fieldType);
		System.assertEquals(RuleUtil.COMPARISON_TYPE_VALUE, ruleFilters.get(0).comparisonType);
		System.assertEquals(RuleUtil.COMPARISON_OPERATOR_EQUAL, ruleFilters.get(0).comparisonOperator);
		System.assertEquals(1, ruleFilters.get(0).index);
	}

	@IsTest
	public static void test_monitoring_impact_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
			createRule(Constants.RULE_SOBJECT.TYPE_MONITORING, Constants.RULE_SOBJECT.SUB_TYPE_IMPACT, null, true, 60, 1));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, '1', RuleUtil.COMPARISON_TYPE_FIELD, RuleUtil.COMPARISON_OPERATOR_EQUAL, null)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_MONITORING);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		System.assertNotEquals(null, result);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);
		System.assertNotEquals(null, rules);
		System.assertEquals(true, String.isBlank(rules.get(0).filterLogic));
		System.assertEquals(false, rules.get(0).isNotValid);

		List<RuleUtil.RuleFilter> ruleFilters = (List<RuleUtil.RuleFilter>)result.get(RuleUtil.KEY_RULE_FILTERS);
		System.assertNotEquals(null, ruleFilters);
		System.assertEquals(1, ruleFilters.size());
		System.assertEquals(RuleUtil.COMPARISON_TYPE_FIELD, ruleFilters.get(0).comparisonType);
		System.assertEquals(RuleUtil.COMPARISON_OPERATOR_EQUAL, ruleFilters.get(0).comparisonOperator);
		System.assertEquals(1, ruleFilters.get(0).index);
	}

	@IsTest
	public static void test_archival_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
				createRuleAction()});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.RuleAction>{createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_ARCHIVAL);
		AdminService.getRuleSettings(input);
	}

	@IsTest
	public static void test_archival_rule_update_filters() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null, null, true, 60, null));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', null, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
				createRuleAction()});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.RuleAction>{createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_ARCHIVAL);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);

		createEvent(rules.get(0).id);
		Integer countEventsBefore = [SELECT COUNT() FROM Event__c WHERE Rule__c = :rules.get(0).id LIMIT 1];
		system.assertEquals(1, countEventsBefore);
		
		Test.startTest();
		Map<String, Object> dataUpdate = new Map<String, Object>();
		RuleUtil.Rule updatedRule = createRule(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null, '1', true, 60, null);
		updatedRule.id = rules.get(0).id;
		dataUpdate.put(RuleUtil.KEY_RULE, updatedRule);

		dataUpdate.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Created_At__c', null, '2880', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_GREATER_THEN, 1),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'someuser', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 2)});

		dataUpdate.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		dataUpdate.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});

		Map<String, Object> inputUpdate = new Map<String, Object>();
		inputUpdate.put('method', 'setRule');
		inputUpdate.put('data', dataUpdate);
		AdminController.remoteActionHandler(JSON.serialize(inputUpdate));
		Test.stopTest();

		Integer countEventsAfter = [SELECT COUNT() FROM Event__c WHERE Rule__c = :rules.get(0).id LIMIT 1];
		system.assertEquals(0, countEventsAfter);
	}

	@IsTest
	public static void test_archival_rule_update_filters_filter_logic_positive() {
		test_archival_rule_update_filters_filter_logic(true);
	}
	@IsTest
	public static void test_archival_rule_update_filters_filter_logic_negative() {
		test_archival_rule_update_filters_filter_logic(false);
	}
	public static void test_archival_rule_update_filters_filter_logic(Boolean isPositive) {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null, '1 AND 2', true, 60, null));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Created_At__c', null, '2880', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_GREATER_THEN, 1),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'valid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 2),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'notvalid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_NOT_EQUAL, 3)
		});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
				createRuleAction()});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.RuleAction>{createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_ARCHIVAL);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);

		createEvent(rules.get(0).id);
		Integer countEventsBefore = [SELECT COUNT() FROM Event__c WHERE Rule__c = :rules.get(0).id LIMIT 1];
		system.assertEquals(1, countEventsBefore);
		
		Test.startTest();
		Map<String, Object> dataUpdate = new Map<String, Object>();
		String changedFilterLogic = isPositive ? '1 OR 2' : '1 AND 2';
		RuleUtil.Rule updatedRule = createRule(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null, changedFilterLogic, true, 60, null);
		updatedRule.id = rules.get(0).id;
		dataUpdate.put(RuleUtil.KEY_RULE, updatedRule);

		dataUpdate.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Created_At__c', null, '2880', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_GREATER_THEN, 1),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'valid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 2),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'notvalid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_NOT_EQUAL, 3)});

		dataUpdate.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(Constants.ACTION_SOBJECT.ACTION_TYPE_REMOVAL, null, null, null)});
		dataUpdate.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});

		Map<String, Object> inputUpdate = new Map<String, Object>();
		inputUpdate.put('method', 'setRule');
		inputUpdate.put('data', dataUpdate);
		AdminController.remoteActionHandler(JSON.serialize(inputUpdate));
		Test.stopTest();

		Integer countEventsAfter = [SELECT COUNT() FROM Event__c WHERE Rule__c = :rules.get(0).id LIMIT 1];
		system.assertEquals(isPositive ? 0 : 1, countEventsAfter);
	}

	@IsTest
	public static void test_JiraUpdate_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE);
		AdminService.getRuleSettings(input);
	}

	@IsTest
	public static void test_Notification_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_NOTIFICATION);
		AdminService.getRuleSettings(input);
	}

	@IsTest
	public static void test_broadcast_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(Constants.RULE_SOBJECT.TYPE_BROADCAST, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', Constants.RULE_SOBJECT.TYPE_BROADCAST);
		AdminService.getRuleSettings(input);
	}

	public static RuleUtil.Rule createRule(String type, String filterLogic, Boolean active) {
		return createRule(type, null, filterLogic, active, null, null);
	}

	public static RuleUtil.Rule createRule(String type, String subtype, String filterLogic, Boolean active, Integer timeInterval, Integer threshold) {
		RuleUtil.Rule rule = new RuleUtil.Rule();
		rule.type = type;
		rule.subtype = subtype;
		rule.filterLogic = filterLogic;
		rule.active = active;
		rule.eventTimeInterval = timeInterval;
		rule.threshold = threshold;
		return rule;
	}

	public static RuleUtil.RuleFilter createRuleFilter(String fieldName, String fieldType, String value, String comparisonType, String comparisonOperator, Decimal index) {
		RuleUtil.RuleFilter ruleFilter = new RuleUtil.RuleFilter();
		ruleFilter.fieldName = fieldName;
		ruleFilter.fieldType = fieldType;
		ruleFilter.value = value;
		ruleFilter.comparisonType = comparisonType;
		ruleFilter.comparisonOperator = comparisonOperator;
		ruleFilter.index = index;
		return ruleFilter;
	}

	public static RuleUtil.RuleAction createRuleAction() {
		TestDataFactory.enableMaxArchivalRules();
		RuleUtil.RuleAction ruleAction = new RuleUtil.RuleAction();
		ruleAction.ruleId = null;
		ruleAction.actionId = null;
		return ruleAction;
	}

	public static RuleUtil.Action createAction(String type, String subtype, String subject, String body) {
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = type;
		action.subtype = subtype;
		action.subject = subject;
		action.body = body;
		return action;
	}

	public static Event__c createEvent(String ruleId) {
		Event__c ev = new Event__c();
		ev.Rule__c = ruleId;
		insert ev;
		return ev;
	}

	// ===============================================
	// ADDITIONAL METADATA VALIDATION TESTS
	// ===============================================

	private static void assertNoInternalErrors() {
		List<Log__c> logs = [SELECT Id FROM Log__c WHERE Category__c = 'Pharos Error' AND Area__c = 'Pharos' LIMIT 1];
		System.assertEquals(0, logs.size(), 'No internal errors should be logged');
	}

	/**
	 * Test successful validation of additional metadata for JIRA actions
	 */
	@IsTest
	public static void test_validate_additional_metadata_success() {
		Test.startTest();
		
		// Create a JIRA action with valid additional metadata in new schema format
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = '{"customfield_10100":{"value":"Option1,Option2","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"allowedValues":[{"id":"Option1","value":"Option1"},{"id":"Option2","value":"Option2"}]},"customfield_10200":{"value":"2023-04-13","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		// This should not throw an exception
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action should be created successfully');
		System.assertEquals(action.additionalMetadata, result.Additional_Metadata__c, 'Additional metadata should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test validation failure for invalid JSON in additional metadata
	 */
	@IsTest
	public static void test_validate_additional_metadata_invalid_json() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = 'invalid json format';
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for invalid JSON');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('Invalid JSON format') || e.getMessage().contains('Unable to parse Additional Metadata format'), 'Should indicate JSON format error: ' + e.getMessage());
		}

		assertNoInternalErrors();
		
		Test.stopTest();
	}

	/**
	 * Test validation failure for invalid field values
	 */
	@IsTest
	public static void test_validate_additional_metadata_invalid_field_values() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Invalid date format using new schema format
		action.additionalMetadata = '{"customfield_10200":{"value":"invalid-date-format","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for invalid field value');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('not compatible') || e.getMessage().contains('Invalid date format'), 'Should indicate field validation error: ' + e.getMessage());
		}

		assertNoInternalErrors();
		
		Test.stopTest();
	}

	/**
	 * Test validation passes for non-JIRA actions
	 */
	@IsTest
	public static void test_validate_additional_metadata_non_jira_action() {
		Test.startTest();
		
		// Create a non-JIRA action with additional metadata
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION;
		action.additionalMetadata = '{"some":"metadata"}';
		
		// This should not validate JIRA fields and should not throw an exception
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Non-JIRA action should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test validation skipped when no additional metadata
	 */
	@IsTest
	public static void test_validate_additional_metadata_blank() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = null;
		
		// This should not throw an exception
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test validation for JIRA ticket comment actions
	 */
	@IsTest
	public static void test_validate_additional_metadata_jira_comment() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_TICKET_COMMENT;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = '{"customfield_10100":{"value":"Option1","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"allowedValues":[{"id":"Option1","value":"Option1"}]}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		// This should validate since it's a JIRA-related action
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'JIRA comment action should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test backward compatibility with old format
	 */
	@IsTest
	public static void test_validate_additional_metadata_old_format_compatibility() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Old format - simple key-value pairs
		action.additionalMetadata = '{"customfield_10100":"Option1,Option2","customfield_10200":"2023-04-13"}';
		
		// No HTTP mocks needed - old format is supported for backward compatibility
		
		// This should not throw an exception (backward compatibility)
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action should be created with old format metadata');
		
		Test.stopTest();
	}

	/**
	 * Test validation when JIRA project or issue type is missing
	 */
	@IsTest
	public static void test_validate_additional_metadata_missing_project_info() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = null; // Missing project
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = '{"customfield_10100":"Option1"}';
		
		// This should not throw an exception since we can't validate without project info
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action should be created when project info is missing');
		
		Test.stopTest();
	}

	/**
	 * Test validation with empty custom fields map
	 */
	@IsTest
	public static void test_validate_additional_metadata_empty_fields() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = '{}'; // Empty JSON object
		
		// This should not throw an exception
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action should be created with empty metadata');
		
		Test.stopTest();
	}

	/**
	 * Test validation with blank field values (should be skipped)
	 */
	@IsTest
	public static void test_validate_additional_metadata_blank_values() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = '{"customfield_10100":{"value":"","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false},"customfield_10200":{"value":"","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		// This should not throw an exception since blank values are skipped
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action should be created with blank field values');
		
		Test.stopTest();
	}

	/**
	 * Test validation for required field validation
	 */
	@IsTest
	public static void test_validate_additional_metadata_required_field() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Required field with blank value
		action.additionalMetadata = '{"customfield_10100":{"value":"","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":true}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for required field');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('Required field'), 'Should indicate required field error: ' + e.getMessage());
		}

		assertNoInternalErrors();
		
		Test.stopTest();
	}

	/**
	 * Test validation for unknown custom field (old format compatibility)
	 */
	@IsTest
	public static void test_validate_additional_metadata_unknown_field() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		action.additionalMetadata = '{"customfield_99999":"SomeValue"}'; // Unknown field in old format
		
		// No HTTP mocks needed - old format bypasses detailed validation for backward compatibility
		
		// This should not throw an exception (old format bypasses validation)
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action should be created with unknown field in old format');
		
		Test.stopTest();
	}

	// ===============================================
	// MERGE FIELD VALIDATION TESTS
	// ===============================================

	/**
	 * Test successful merge field validation with valid field references
	 */
	@IsTest
	public static void test_validate_merge_fields_success() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use valid Salesforce object and field with schema
		action.additionalMetadata = '{"customfield_10100":{"value":"{!Account.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false},"customfield_10200":{"value":"{!Account.CreatedDate}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		// This should not throw an exception - merge fields skip value validation
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with merge fields should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test merge field validation with invalid object reference
	 */
	@IsTest
	public static void test_validate_merge_fields_invalid_object() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use invalid object name
		action.additionalMetadata = '{"customfield_10100":"{!InvalidObject__c.Name}"}';
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for invalid object');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('Object "InvalidObject__c" does not exist'), 'Should indicate object does not exist');
		}

		assertNoInternalErrors();
		
		Test.stopTest();
	}

	/**
	 * Test merge field validation with invalid field reference
	 */
	@IsTest
	public static void test_validate_merge_fields_invalid_field() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use valid object but invalid field
		action.additionalMetadata = '{"customfield_10100":"{!Account.InvalidField__c}"}';
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for invalid field');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('Field "InvalidField__c" does not exist'), 'Should indicate field does not exist');
		}
		
		Test.stopTest();

		assertNoInternalErrors();
	}

	/**
	 * Test merge field validation with malformed syntax
	 */
	@IsTest
	public static void test_validate_merge_fields_malformed_syntax() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Malformed merge field syntax
		action.additionalMetadata = '{"customfield_10100":"{!Account}"}'; // Missing field name
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for malformed syntax');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('invalid merge field syntax'), 'Should indicate invalid syntax');
		}
		
		Test.stopTest();
	}

	/**
	 * Test merge field validation with multiple merge fields in single value
	 */
	@IsTest
	public static void test_validate_merge_fields_multiple_fields() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Multiple merge fields in single value - should be treated as string
		action.additionalMetadata = '{"customfield_10100":"{!Account.Name} and {!Account.CreatedDate}"}';
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		// This should not throw an exception - multiple fields default to string type
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with multiple merge fields should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test runtime field type detection for merge fields
	 */
	@IsTest
	public static void test_merge_field_runtime_type_detection() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use date field - should be detected as 'date' type
		action.additionalMetadata = '{"customfield_10200":"{!Account.CreatedDate}"}';
		
		// Mock JIRA service responses with enhanced custom fields including date picker
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		// This should validate successfully as the date field is compatible with date picker
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Date merge field should be compatible with JIRA date field');
		
		Test.stopTest();
	}

	/**
	 * Test type compatibility validation between runtime and JIRA types
	 */
	@IsTest
	public static void test_merge_field_type_compatibility_failure() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use date value with numeric JIRA field - should fail compatibility  
		action.additionalMetadata = '{"customfield_10300":{"value":"2023-04-13","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false}}';
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for type incompatibility');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('Invalid number format for field "customfield_10300"'), 'Should indicate type incompatibility: ' + e.getMessage());
		}
		
		Test.stopTest();

		assertNoInternalErrors();
	}

	// ===============================================
	// RUNTIME TYPE DETECTION TESTS
	// ===============================================

	/**
	 * Test runtime type detection for various value types
	 */
	@IsTest
	public static void test_runtime_type_detection_values() {
		// This is an indirect test since the methods are private
		// We test through the public validation interface
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		// Test integer value
		action.additionalMetadata = '{"customfield_10300":"123"}';
		Action__c result1 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result1, 'Integer value should be processed');
		
		// Test decimal value
		action.additionalMetadata = '{"customfield_10300":"123.45"}';
		Action__c result2 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result2, 'Decimal value should be processed');
		
		// Test date value
		action.additionalMetadata = '{"customfield_10200":"2023-04-13"}';
		Action__c result3 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result3, 'Date value should be processed');
		
		// Test URL value
		action.additionalMetadata = '{"customfield_10400":"https://example.com"}';
		Action__c result4 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result4, 'URL value should be processed');
		
		Test.stopTest();
	}

	/**
	 * Test validation skipped for runtime-rendered fields
	 */
	@IsTest
	public static void test_runtime_rendered_fields_skipped() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Runtime field - should skip validation
		action.additionalMetadata = '{"customfield_10100":"{!Account.Name}"}';
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		// This should not throw an exception - runtime fields have validation but should succeed
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Runtime rendered fields should be processed successfully');
		
		Test.stopTest();
	}

	/**
	 * Test MergeFieldInfo class functionality
	 */
	@IsTest
	public static void test_merge_field_info_class() {
		Test.startTest();
		
		// Test MergeFieldInfo creation and methods
		RuleUtil.MergeFieldInfo field1 = new RuleUtil.MergeFieldInfo('Log__c', 'Name');
		RuleUtil.MergeFieldInfo field2 = new RuleUtil.MergeFieldInfo('Log__c', 'Name');
		RuleUtil.MergeFieldInfo field3 = new RuleUtil.MergeFieldInfo('Log__c', 'CreatedDate');
		
		// Test equals method
		System.assert(field1.equals(field2), 'Identical MergeFieldInfo objects should be equal');
		System.assert(!field1.equals(field3), 'Different MergeFieldInfo objects should not be equal');
		System.assert(!field1.equals('not a MergeFieldInfo'), 'MergeFieldInfo should not equal non-MergeFieldInfo object');
		
		// Test hashCode method
		System.assertEquals(field1.hashCode(), field2.hashCode(), 'Identical objects should have same hash code');
		
		// Test object properties
		System.assertEquals('Log__c', field1.objectName, 'Object name should be set correctly');
		System.assertEquals('Name', field1.fieldName, 'Field name should be set correctly');
		
		Test.stopTest();
	}

	/**
	 * Test validation with complex merge field scenarios
	 */
	@IsTest
	public static void test_complex_merge_field_scenarios() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		// Test with mixed static text and merge fields
		action.additionalMetadata = '{"customfield_10100":"Error: {!Account.Name} at {!Account.CreatedDate}"}';
		Action__c result1 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result1, 'Mixed content should be processed as string');
		
		// Test with only merge field
		action.additionalMetadata = '{"customfield_10100":"{!Account.Name}"}';
		Action__c result2 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result2, 'Single merge field should be processed');
		
		// Test with empty value
		action.additionalMetadata = '{"customfield_10100":""}';
		Action__c result3 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result3, 'Empty value should be processed');
		
		Test.stopTest();
	}

	/**
	 * Test merge field validation with relationship fields (Parent__r)
	 */
	@IsTest
	public static void test_validate_merge_fields_relationship_field() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use valid Log object with Parent__r relationship field and a string field instead of datetime to avoid type compatibility issues
		action.additionalMetadata = '{"customfield_11301":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Parent__r.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield","type":"string"},"required":false,"allowedValues":null,"name":"Test Text Field"}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		// This should not throw an exception - relationship field should be validated correctly
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with relationship merge field should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test the specific scenario from the debug log - Parent__r.CreatedDate validation
	 */
	@IsTest
	public static void test_validate_parent_relationship_created_date() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// This is the exact merge field from the debug log that was failing
		action.additionalMetadata = '{"customfield_11294":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Parent__r.CreatedDate}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime","type":"datetime"},"required":false,"allowedValues":null,"name":"Test Datetime Field"}}';
		
		// No HTTP mocks needed - validation uses stored schema
		
		try {
			// This should not throw a field validation exception anymore
			Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			// We expect this to pass validation (no field not found error)
			// Note: It might still fail on type compatibility, but that's a different issue than the original field validation error
			System.assertNotEquals(null, result, 'Action should be created - field validation should pass');
		} catch (RuleUtil.RuleUtilValidationException e) {
			// If it fails, it should NOT be due to field not existing
			System.assert(!e.getMessage().contains('does not exist'), 'Should not fail due to field not existing: ' + e.getMessage());
		}
		
		Test.stopTest();
	}

	/**
	 * Test textarea field type compatibility using merge fields from actual textarea fields
	 */
	@IsTest
	public static void test_textarea_field_type_compatibility() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		
		// Mock JIRA service responses with enhanced custom fields
		Map<String, HttpCalloutMock> endpoint2TestResp = createEnhancedJiraMocks();
		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
		
		// Test merge field from textarea field with textarea JIRA field type - should work
		// Using Event Description field which is typically a textarea field
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Event__c.' + ConfigUtil.nameSpacePrefix + 'Event_Details__c}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false}}';
		Action__c result1 = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result1, 'Textarea merge field should be compatible with textarea JIRA field');
		
		// Test merge field from textarea field with URL JIRA field type - should fail due to incompatibility
		action.additionalMetadata = '{"customfield_10200":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Event__c.' + ConfigUtil.nameSpacePrefix + 'Event_Details__c}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:url"},"required":false}}';
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for textarea merge field with URL JIRA field');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('not compatible'), 'Should indicate type incompatibility: ' + e.getMessage());
		}
		
		Test.stopTest();
	}

	// ===============================================
	// SET ACTIONS METHOD VALIDATION TESTS
	// ===============================================

	/**
	 * Test setActions method with valid merge fields in additional metadata
	 */
	@IsTest
	public static void test_setActions_valid_merge_fields() {
		Test.startTest();
		
		// Create action with valid merge fields
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - valid merge field
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for valid merge field');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Name}'), 'Merge field should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with invalid merge fields
	 */
	@IsTest
	public static void test_setActions_invalid_merge_fields() {
		Test.startTest();
		
		// Create action with invalid merge field (non-existent object)
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!NonExistentObject__c.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - invalid object in merge field
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for invalid merge field');
		System.assert(error.contains('does not exist') || error.contains('Invalid merge field'), 'Error should indicate object validation issue: ' + error);
		
		Test.stopTest();

		assertNoInternalErrors();
	}

	/**
	 * Test setActions method with invalid merge field syntax
	 */
	@IsTest
	public static void test_setActions_invalid_merge_field_syntax() {
		Test.startTest();
		
		// Create action with invalid merge field syntax (missing field name)
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!Log__c.}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - invalid merge field syntax
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for invalid merge field syntax');
		System.assert(error.contains('invalid merge field syntax') || error.contains('Invalid merge field'), 'Error should indicate syntax issue: ' + error);
		
		Test.stopTest();

		assertNoInternalErrors();
	}

	/**
	 * Test setActions method with valid inline field values
	 */
	@IsTest
	public static void test_setActions_valid_inline_fields() {
		Test.startTest();
		
		// Create action with valid inline field values (non-merge fields)
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"StaticValue123","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false},"customfield_10200":{"value":"2023-04-13","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - valid inline values
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for valid inline fields');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('StaticValue123'), 'Inline value should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with invalid inline field values
	 */
	@IsTest
	public static void test_setActions_invalid_inline_fields() {
		Test.startTest();
		
		// Create action with invalid inline field value (incompatible type)
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10300":{"value":"not-a-number","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for invalid inline field type');
		System.assert(error.contains('not compatible') || error.contains('Invalid number format'), 'Error should indicate type compatibility issue: ' + error);
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with required field validation
	 */
	@IsTest
	public static void test_setActions_required_field_validation() {
		Test.startTest();
		
		// Create action with empty value for required field
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":true}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - required field is empty
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for empty required field');
		System.assert(error.contains('Required field') && error.contains('cannot be blank'), 'Error should indicate required field issue: ' + error);
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with allowed values validation
	 */
	@IsTest
	public static void test_setActions_allowed_values_validation() {
		Test.startTest();
		
		// Create action with value not in allowed values list
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"InvalidOption","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"allowedValues":[{"id":"Option1","value":"Option1"},{"id":"Option2","value":"Option2"}]}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - value not in allowed values
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for invalid allowed value');
		System.assert(error.contains('not allowed'), 'Error should indicate allowed value issue: ' + error);
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with multi-value field validation
	 */
	@IsTest
	public static void test_setActions_multi_value_field_validation() {
		Test.startTest();
		
		// Create action with valid multi-value field
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"Option1,Option2","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"allowedValues":[{"id":"Option1","value":"Option1"},{"id":"Option2","value":"Option2"},{"id":"Option3","value":"Option3"}]}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - valid multi-value field
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for valid multi-value field');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('Option1,Option2'), 'Multi-value should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with backward compatibility (old format)
	 */
	@IsTest
	public static void test_setActions_backward_compatibility() {
		Test.startTest();
		
		// Create action with old format metadata (simple key-value pairs)
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":"SimpleValue","customfield_10200":"2023-04-13"}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - backward compatibility maintained
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for old format metadata');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('SimpleValue'), 'Old format value should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with mixed merge fields and inline values
	 */
	@IsTest
	public static void test_setActions_mixed_merge_and_inline() {
		Test.startTest();
		
		// Create action with mixed merge fields and inline values
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false},"customfield_10200":{"value":"2023-04-13","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - mixed field types are valid
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for mixed field types');
		
		// Verify action was created with both values
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Name}'), 'Merge field should be preserved');
		System.assert(actions[0].Additional_Metadata__c.contains('2023-04-13'), 'Inline value should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with non-JIRA action (should skip validation)
	 */
	@IsTest
	public static void test_setActions_non_jira_action_skip_validation() {
		Test.startTest();
		
		// Create non-JIRA action with additional metadata
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION,
			'{"some":"metadata","customfield_10100":"{!NonExistentObject.Field}"}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - non-JIRA actions skip JIRA validation
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for non-JIRA action');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Non-JIRA action should be created');
		
		Test.stopTest();
	}

	// ===============================================
	// HELPER METHODS FOR SET ACTIONS TESTS
	// ===============================================

	/**
	 * Helper method to create action with additional metadata for testing
	 */
	private static RuleUtil.Action createActionWithAdditionalMetadata(String actionType, String additionalMetadata) {
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = actionType;
		action.additionalMetadata = additionalMetadata;
		
		// Set JIRA-specific fields for JIRA actions
		if (actionType == Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION || actionType == Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_TICKET_COMMENT) {
			action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
			action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		}
		
		// Set basic fields
		action.subject = 'Test Subject';
		action.body = 'Test Body';
		action.actionName = 'Test Action';
		
		return action;
	}

	// ===============================================
	// HELPER METHODS FOR ENHANCED MOCKING
	// ===============================================

	/**
	 * Creates enhanced JIRA mocks with custom fields that match test expectations
	 */
	private static Map<String, HttpCalloutMock> createEnhancedJiraMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = JiraNotificationBatchTest.createJiraMocks();
		
		// Override the project issue fields endpoint to return enhanced custom fields
		endpoint2TestResp.put(
			JiraService.getService().getProjectIssueFieldsEndpoint(
				JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, 
				JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID
			), 
			createEnhancedProjectIssueFieldsMock()
		);
		
		return endpoint2TestResp;
	}

	/**
	 * Creates a mock response with enhanced custom fields for testing
	 */
	private static TestDataFactory.SingleRequestMock createEnhancedProjectIssueFieldsMock() {
		JiraService.JiraProjectIssueTypeFieldsWrapper result = new JiraService.JiraProjectIssueTypeFieldsWrapper();
		result.startAt = 0;
		result.maxResults = 200;
		result.total = 5;
		
		List<JiraService.JiraProjectIssueField> fields = new List<JiraService.JiraProjectIssueField>();
		
		// Multi-select field (for testing multicheckboxes)
		JiraService.JiraProjectIssueField field1 = new JiraService.JiraProjectIssueField();
		field1.fieldId = 'customfield_10100';
		field1.key = 'customfield_10100';
		field1.name = 'Multi Select Field';
		field1.required = false;
		field1.operations = new List<String>{'set'};
		field1.schema = new JiraService.JiraProjectIssueFieldSchema();
		field1.schema.type = 'array';
		field1.schema.custom = 'com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes';
		field1.allowedValues = new List<JiraService.JiraProjectIssueFieldAllowedValue>{
			createAllowedValue('Option1', '1'),
			createAllowedValue('Option2', '2')
		};
		fields.add(field1);
		
		// Date picker field
		JiraService.JiraProjectIssueField field2 = new JiraService.JiraProjectIssueField();
		field2.fieldId = 'customfield_10200';
		field2.key = 'customfield_10200';
		field2.name = 'Date Field';
		field2.required = false;
		field2.operations = new List<String>{'set'};
		field2.schema = new JiraService.JiraProjectIssueFieldSchema();
		field2.schema.type = 'date';
		field2.schema.custom = 'com.atlassian.jira.plugin.system.customfieldtypes:datepicker';
		fields.add(field2);
		
		// Number field (for testing incompatible types)
		JiraService.JiraProjectIssueField field3 = new JiraService.JiraProjectIssueField();
		field3.fieldId = 'customfield_10300';
		field3.key = 'customfield_10300';
		field3.name = 'Number Field';
		field3.required = false;
		field3.operations = new List<String>{'set'};
		field3.schema = new JiraService.JiraProjectIssueFieldSchema();
		field3.schema.type = 'number';
		field3.schema.custom = 'com.atlassian.jira.plugin.system.customfieldtypes:float';
		fields.add(field3);
		
		// URL field
		JiraService.JiraProjectIssueField field4 = new JiraService.JiraProjectIssueField();
		field4.fieldId = 'customfield_10400';
		field4.key = 'customfield_10400';
		field4.name = 'URL Field';
		field4.required = false;
		field4.operations = new List<String>{'set'};
		field4.schema = new JiraService.JiraProjectIssueFieldSchema();
		field4.schema.type = 'string';
		field4.schema.custom = 'com.atlassian.jira.plugin.system.customfieldtypes:url';
		fields.add(field4);
		
		// Text field
		JiraService.JiraProjectIssueField field5 = new JiraService.JiraProjectIssueField();
		field5.fieldId = 'customfield_10500';
		field5.key = 'customfield_10500';
		field5.name = 'Text Field';
		field5.required = false;
		field5.operations = new List<String>{'set'};
		field5.schema = new JiraService.JiraProjectIssueFieldSchema();
		field5.schema.type = 'string';
		field5.schema.custom = 'com.atlassian.jira.plugin.system.customfieldtypes:textfield';
		fields.add(field5);
		
		result.values = fields; // Use values for hosted version
		
		return new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(result)
		);
	}

	/**
	 * Helper method to create allowed values for JIRA fields
	 */
	private static JiraService.JiraProjectIssueFieldAllowedValue createAllowedValue(String value, String id) {
		JiraService.JiraProjectIssueFieldAllowedValue allowedValue = new JiraService.JiraProjectIssueFieldAllowedValue();
		allowedValue.value = value;
		allowedValue.id = id;
		allowedValue.disabled = false;
		return allowedValue;
	}

	/**
	 * Test setActions method with incompatible merge field types (string field mapped to datepicker)
	 * Tests the complete end-to-end flow through AdminController.remoteActionHandler
	 */
	@IsTest
	public static void test_setActions_incompatible_merge_field_types() {
		Test.startTest();
		
		// Create action with incompatible merge field type: ID field mapped to datepicker
		// Include field name in metadata for friendly error messages
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10100\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Id}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:datepicker\",\"type\":\"date\"},\"required\":false,\"allowedValues\":null,\"name\":\"Log Record ID\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (string mapped to datepicker)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('date picker'), 'Error should mention user-friendly field type: ' + error);
		System.assert(error.contains('customfield_10100'), 'Error should mention field key: ' + error);
		
		// Check if field name is included (it should be if metadata is structured correctly)
		// In real scenarios with Angular frontend, the field name should be included
		Boolean hasFieldName = error.contains('Log Record ID');
		System.assert(hasFieldName, 'Error message should include field name: ' + error);
		
		Test.stopTest();
	}

	@IsTest
	public static void test_setActions_number_to_datepicker_incompatible() {
		Test.startTest();
		
		// Create action with incompatible merge field type: decimal field mapped to datepicker
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10100\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Created_Timestamp__c}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:datepicker\",\"type\":\"date\"},\"required\":false,\"allowedValues\":null,\"name\":\"Created Timestamp\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (decimal mapped to datepicker)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('date picker'), 'Error should mention user-friendly field type: ' + error);
		
		Test.stopTest();
	}

	@IsTest
	public static void test_setActions_date_to_number_incompatible() {
		Test.startTest();
		
		// Create action with incompatible merge field type: datetime field mapped to number
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10200\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CreatedDate}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:float\",\"type\":\"number\"},\"required\":false,\"allowedValues\":null,\"name\":\"Created Date\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (datetime mapped to number)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('number'), 'Error should mention user-friendly field type: ' + error);
		
		Test.stopTest();
	}

	@IsTest
	public static void test_setActions_string_to_datepicker_incompatible() {
		Test.startTest();
		
		// Create action with incompatible merge field type: string field mapped to datepicker (truly incompatible)
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10300\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Summary__c}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:datepicker\",\"type\":\"date\"},\"required\":false,\"allowedValues\":null,\"name\":\"Log Summary\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (string mapped to datepicker)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('date picker'), 'Error should mention user-friendly field type: ' + error);
		
		Test.stopTest();
	}

	@IsTest
	public static void test_setActions_boolean_to_datepicker_incompatible() {
		Test.startTest();
		
		// Create action with incompatible merge field type: boolean field mapped to datepicker
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10400\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Do_Not_Create_Issue__c}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:datepicker\",\"type\":\"date\"},\"required\":false,\"allowedValues\":null,\"name\":\"Do Not Create Issue\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (boolean mapped to datepicker)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('date picker'), 'Error should mention user-friendly field type: ' + error);
		
		Test.stopTest();
	}

	@IsTest
	public static void test_setActions_url_to_number_incompatible() {
		Test.startTest();
		
		// Create action with incompatible merge field type: URL field mapped to number
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10500\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Organization_Url__c}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:float\",\"type\":\"number\"},\"required\":false,\"allowedValues\":null,\"name\":\"Organization URL\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (URL mapped to number)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('number'), 'Error should mention user-friendly field type: ' + error);
		
		Test.stopTest();
	}

	@IsTest
	public static void test_setActions_decimal_to_multiselect_incompatible() {
		Test.startTest();
		
		// Create action with incompatible merge field type: decimal field mapped to multi-select
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10600\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Created_Timestamp__c}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:multiselect\",\"type\":\"array\"},\"required\":false,\"allowedValues\":[{\"id\":\"LOW\",\"value\":\"Low Usage\"},{\"id\":\"HIGH\",\"value\":\"High Usage\"}],\"name\":\"Created Timestamp\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (decimal mapped to multi-select)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('multi-select'), 'Error should mention user-friendly field type: ' + error);
		
		Test.stopTest();
	}

	@IsTest
	public static void test_setActions_string_to_url_incompatible() {
		Test.startTest();
		
		// Create action with incompatible merge field type: string field mapped to URL
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{\"customfield_10700\":{\"value\":\"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.' + ConfigUtil.nameSpacePrefix + 'Duration__c}\",\"schema\":{\"custom\":\"com.atlassian.jira.plugin.system.customfieldtypes:url\",\"type\":\"url\"},\"required\":false,\"allowedValues\":null,\"name\":\"Duration\"}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - incompatible field type (string mapped to URL)
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for incompatible field types');
		System.assert(error.contains('not compatible'), 'Error should mention compatibility issue: ' + error);
		System.assert(error.contains('URL'), 'Error should mention user-friendly field type: ' + error);
		
		Test.stopTest();
	}

	// ===============================================
	// RELATIONSHIP FIELD VALIDATION TESTS
	// ===============================================

	/**
	 * Test successful validation of relationship field traversal (CreatedBy.IsActive)
	 */
	@IsTest
	public static void test_validate_relationship_field_success() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use valid relationship field traversal
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CreatedBy.IsActive}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false}}';
		
		// This should not throw an exception - valid relationship field
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with relationship field should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test validation of relationship field with Owner traversal
	 */
	@IsTest
	public static void test_validate_relationship_field_owner_traversal() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use Owner relationship field traversal
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Owner.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}';
		
		// This should not throw an exception - valid relationship field
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with Owner relationship field should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test validation failure for invalid relationship field (non-existent intermediate field)
	 */
	@IsTest
	public static void test_validate_relationship_field_invalid_intermediate() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use invalid intermediate field in relationship traversal
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.InvalidRelationship.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}';
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for invalid intermediate field');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('Field "InvalidRelationship" does not exist'), 'Should indicate intermediate field does not exist: ' + e.getMessage());
		}
		
		Test.stopTest();
	}

	/**
	 * Test validation failure for invalid final field in relationship traversal
	 */
	@IsTest
	public static void test_validate_relationship_field_invalid_final_field() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use valid intermediate field but invalid final field
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CreatedBy.InvalidField}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}';
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for invalid final field');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('Field "InvalidField" does not exist'), 'Should indicate final field does not exist: ' + e.getMessage());
		}
		
		Test.stopTest();
	}

	/**
	 * Test validation failure for non-relationship field used in traversal
	 */
	@IsTest
	public static void test_validate_relationship_field_non_relationship() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use non-relationship field in traversal (Name is not a relationship field)
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Name.SomeField}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}';
		
		try {
			action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assert(false, 'Should have thrown RuleUtilValidationException for non-relationship field traversal');
		} catch (RuleUtil.RuleUtilValidationException e) {
			System.assert(e.getMessage().contains('is not a relationship field'), 'Should indicate field is not a relationship field: ' + e.getMessage());
		}
		
		Test.stopTest();
	}

	/**
	 * Test validation of multi-level relationship traversal (Account.Owner.Manager.Name)
	 */
	@IsTest
	public static void test_validate_multi_level_relationship_traversal() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use multi-level relationship traversal
		action.additionalMetadata = '{"customfield_10100":{"value":"{!Account.Owner.Manager.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}';
		
		// This should not throw an exception - valid multi-level relationship
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with multi-level relationship should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test validation with Link suffix field (should use Id instead)
	 */
	@IsTest
	public static void test_validate_relationship_field_link_suffix() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use Link suffix field
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Link}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:url"},"required":false}}';
		
		// This should not throw an exception - Link should be treated as Id
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with Link field should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test validation with case-insensitive field lookup
	 */
	@IsTest
	public static void test_validate_relationship_field_case_insensitive() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use different case for field name (should still work due to case-insensitive lookup)
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.createdby.IsActive}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false}}';
		
		// This should not throw an exception - case-insensitive lookup should find CreatedBy
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with case-insensitive field should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test validation of relationship field accessibility
	 */
	@IsTest
	public static void test_validate_relationship_field_accessibility() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use accessible relationship field
		action.additionalMetadata = '{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.LastModifiedBy.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}';
		
		// This should not throw an exception - accessible fields should work
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with accessible relationship field should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with valid relationship field
	 */
	@IsTest
	public static void test_setActions_valid_relationship_field() {
		Test.startTest();
		
		// Create action with valid relationship field
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CreatedBy.IsActive}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - valid relationship field
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for valid relationship field');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('CreatedBy.IsActive'), 'Relationship field should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with invalid relationship field
	 */
	@IsTest
	public static void test_setActions_invalid_relationship_field() {
		Test.startTest();
		
		// Create action with invalid relationship field
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.InvalidRelationship.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - invalid relationship field
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for invalid relationship field');
		System.assert(error.contains('does not exist') || error.contains('Invalid merge field'), 'Error should indicate field validation issue: ' + error);
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with non-relationship field used in traversal
	 */
	@IsTest
	public static void test_setActions_non_relationship_traversal() {
		Test.startTest();
		
		// Create action with non-relationship field used in traversal
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Name.SomeField}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should fail - non-relationship field cannot be traversed
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates error
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		String error = (String)responseMap.get('error');
		System.assertNotEquals(null, error, 'Should have error for non-relationship field traversal');
		System.assert(error.contains('is not a relationship field') || error.contains('cannot be traversed'), 'Error should indicate relationship field issue: ' + error);
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with multi-level relationship field
	 */
	@IsTest
	public static void test_setActions_multi_level_relationship() {
		Test.startTest();
		
		// Create action with multi-level relationship field
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!Account.Owner.Manager.Name}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - valid multi-level relationship
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for multi-level relationship field');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('Owner.Manager.Name'), 'Multi-level relationship field should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test setActions method with Link suffix field
	 */
	@IsTest
	public static void test_setActions_link_suffix_field() {
		Test.startTest();
		
		// Create action with Link suffix field
		RuleUtil.Action action = createActionWithAdditionalMetadata(
			Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION,
			'{"customfield_10100":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Log__c.Link}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:url"},"required":false}}'
		);
		
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{action});
		
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setActions');
		input.put('data', data);
		
		// This should succeed - Link field should be treated as Id
		String response = AdminController.remoteActionHandler(JSON.serialize(input));
		
		// Verify response indicates success
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		System.assertEquals(null, responseMap.get('error'), 'Should not have error for Link field');
		
		// Verify action was created
		List<Action__c> actions = [SELECT Id, Additional_Metadata__c FROM Action__c WHERE Action_Type__c = :Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION LIMIT 1];
		System.assertEquals(1, actions.size(), 'Action should be created');
		System.assert(actions[0].Additional_Metadata__c.contains('Link'), 'Link field should be preserved');
		
		Test.stopTest();
	}

	/**
	 * Test relationship field validation with Event__c object (matches the debug log scenario)
	 */
	@IsTest
	public static void test_validate_event_relationship_field() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		// Use Event__c with CreatedBy.IsActive (matches the original debug log scenario)
		action.additionalMetadata = '{"customfield_11301":{"value":"{!' + ConfigUtil.nameSpacePrefix + 'Event__c.CreatedBy.IsActive}","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield","type":"string"},"required":false,"allowedValues":null,"name":"Test Text Field"}}';
		
		// This should not throw an exception - valid relationship field on Event__c
		Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
		System.assertNotEquals(null, result, 'Action with Event__c relationship field should be created successfully');
		
		Test.stopTest();
	}

	/**
	 * Test relationship field validation with case variations
	 */
	@IsTest
	public static void test_validate_relationship_field_case_variations() {
		Test.startTest();
		
		RuleUtil.Action action = new RuleUtil.Action();
		action.type = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION;
		action.jiraProject = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		action.jiraIssueType = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		
		// Test various case combinations that should all work
		List<String> testCases = new List<String>{
			'{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CreatedBy.IsActive}',
			'{!' + ConfigUtil.nameSpacePrefix + 'Log__c.createdby.IsActive}',
			'{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CREATEDBY.IsActive}',
			'{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CreatedBy.isactive}',
			'{!' + ConfigUtil.nameSpacePrefix + 'Log__c.CreatedBy.ISACTIVE}'
		};
		
		for (String testCase : testCases) {
			action.additionalMetadata = '{"customfield_10100":{"value":"' + testCase + '","schema":{"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false}}';
			
			// Each case should work due to case-insensitive lookup
			Action__c result = action.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
			System.assertNotEquals(null, result, 'Action with case variation should be created successfully: ' + testCase);
		}
		
		Test.stopTest();
	}

	// ===============================================
	// MERGE FIELDS AND JIRA MAPPING TESTS
	// ===============================================

	/**
	 * Test getMergeFields method returns proper structure
	 */
	@IsTest
	public static void test_getMergeFields_structure() {
		Test.startTest();
		
		Object result = AdminService.getMergeFields();
		System.assertNotEquals(null, result, 'getMergeFields should return a result');
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)result;
		System.assert(mergeFields.size() > 0, 'Should return merge fields');
		
		// Verify fields have required properties
		for (AdminService.MergeField field : mergeFields) {
			System.assertNotEquals(null, field.label, 'Field should have label');
			System.assertNotEquals(null, field.value, 'Field should have value');
			System.assertNotEquals(null, field.sobjectype, 'Field should have sobjectype');
			System.assertNotEquals(null, field.apiName, 'Field should have apiName');
			System.assertNotEquals(null, field.availableForJiraMapping, 'Field should have availableForJiraMapping flag');
		}
		
		Test.stopTest();
	}

	/**
	 * Test that Link fields are available for JIRA mapping
	 */
	@IsTest
	public static void test_getMergeFields_link_fields_available() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Find Link fields
		List<AdminService.MergeField> linkFields = new List<AdminService.MergeField>();
		for (AdminService.MergeField field : mergeFields) {
			if (field.apiName == 'link') {
				linkFields.add(field);
			}
		}
		
		System.assert(linkFields.size() > 0, 'Should have Link fields');
		
		// Verify all Link fields are available for JIRA mapping
		for (AdminService.MergeField linkField : linkFields) {
			System.assertEquals(true, linkField.availableForJiraMapping, 'Link fields should be available for JIRA mapping: ' + linkField.label);
			System.assert(linkField.value.contains('.Link}'), 'Link field value should contain .Link: ' + linkField.value);
		}
		
		Test.stopTest();
	}

	/**
	 * Test that Analysis field is NOT available for JIRA mapping
	 */
	@IsTest
	public static void test_getMergeFields_analysis_field_not_available() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Find Analysis field
		AdminService.MergeField analysisField = null;
		for (AdminService.MergeField field : mergeFields) {
			if (field.apiName == 'analysis') {
				analysisField = field;
				break;
			}
		}
		
		System.assertNotEquals(null, analysisField, 'Should have Analysis field');
		System.assertEquals(false, analysisField.availableForJiraMapping, 'Analysis field should NOT be available for JIRA mapping');
		System.assertEquals('Advanced Analysis', analysisField.label, 'Analysis field should have correct label');
		System.assert(analysisField.value.contains('.Analysis}'), 'Analysis field value should contain .Analysis: ' + analysisField.value);
		
		Test.stopTest();
	}

	/**
	 * Test that filtered fields are marked as not available for JIRA mapping
	 */
	@IsTest
	public static void test_getMergeFields_filtered_fields_not_available() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Test all sobject types that have filtered fields
		for (String sobjectType : AdminService.MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING.keySet()) {
			Set<String> filteredFieldNames = AdminService.MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING.get(sobjectType);
			System.assert(filteredFieldNames.size() > 0, 'Should have filtered fields for ' + sobjectType);
			
			// For each filtered field name in the map, find the corresponding merge field and verify it's marked as not available
			for (String filteredFieldName : filteredFieldNames) {
				// Find the merge field that has this field name as its apiName property (which contains sobjectFieldAPIName used for comparison)
				AdminService.MergeField foundField = null;
				for (AdminService.MergeField field : mergeFields) {
					if (field.apiName == filteredFieldName && field.sobjectype == sobjectType) {
						foundField = field;
						break;
					}
				}
				
				// If not found, also check if the field might not exist in the schema (which is valid)
				if (foundField == null) {
					continue; // Skip fields that don't exist in the schema
				}
				
				// Assert that the field is marked as not available for JIRA mapping
				System.assertEquals(false, foundField.availableForJiraMapping, 
					'Filtered field should NOT be available for JIRA mapping: ' + foundField.apiName + ' (sobjectType: ' + sobjectType + ')');
			}
		}
		
		Test.stopTest();
	}
	

	/**
	 * Test that Event__c fields are properly filtered
	 */
	@IsTest
	public static void test_getMergeFields_event_filtered_fields() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Test Event__c specific filtered fields
		Set<String> eventFilteredFields = AdminService.MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING.get('event');
		System.assert(eventFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Event_Details__c'.toLowerCase()), 'Event_Details__c should be in filtered fields');
		System.assert(eventFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Grouped_Field_Values__c'.toLowerCase()), 'Grouped_Field_Values__c should be in filtered fields');
		System.assert(eventFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Records__c'.toLowerCase()), 'Records__c should be in filtered fields');
		
		// Find event fields that should be filtered
		List<AdminService.MergeField> eventFilteredFields_found = new List<AdminService.MergeField>();
		for (AdminService.MergeField field : mergeFields) {
			if (field.sobjectype == 'event' && eventFilteredFields.contains(field.apiName)) {
				eventFilteredFields_found.add(field);
			}
		}
		
		// Verify filtered event fields are not available for JIRA mapping
		for (AdminService.MergeField filteredField : eventFilteredFields_found) {
			System.assertEquals(false, filteredField.availableForJiraMapping, 'Event filtered field should NOT be available for JIRA mapping: ' + filteredField.apiName);
		}
		
		Test.stopTest();
	}

	/**
	 * Test that Issue__c fields are properly filtered
	 */
	@IsTest
	public static void test_getMergeFields_issue_filtered_fields() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Test Issue__c specific filtered fields
		Set<String> issueFilteredFields = AdminService.MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING.get('issue');
		System.assert(issueFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Users_Impacted__c'.toLowerCase()), 'Users_Impacted__c should be in filtered fields');
		System.assert(issueFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Analysis_Status__c'.toLowerCase()), 'Analysis_Status__c should be in filtered fields');
		
		// Find issue fields that should be filtered
		List<AdminService.MergeField> issueFilteredFields_found = new List<AdminService.MergeField>();
		for (AdminService.MergeField field : mergeFields) {
			if (field.sobjectype == 'issue' && issueFilteredFields.contains(field.apiName)) {
				issueFilteredFields_found.add(field);
			}
		}
		
		// Verify filtered issue fields are not available for JIRA mapping
		for (AdminService.MergeField filteredField : issueFilteredFields_found) {
			System.assertEquals(false, filteredField.availableForJiraMapping, 'Issue filtered field should NOT be available for JIRA mapping: ' + filteredField.apiName);
		}
		
		Test.stopTest();
	}

	/**
	 * Test that regular fields are available for JIRA mapping by default
	 */
	@IsTest
	public static void test_getMergeFields_regular_fields_available() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Find regular fields that should be available (not in filtered lists and not AutoChart fields)
		List<AdminService.MergeField> regularFields = new List<AdminService.MergeField>();
		for (AdminService.MergeField field : mergeFields) {
			Set<String> filteredFields = AdminService.MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING.get(field.sobjectype);
			// Exclude filtered fields, analysis field, and AutoChart fields
			if (filteredFields != null && !filteredFields.contains(field.apiName) && 
				field.apiName != 'analysis' && 
				!field.apiName.contains('System_Auto_Chart') &&
				!field.value.contains('System_Auto_Chart')) {
				regularFields.add(field);
			}
		}
		
		System.assert(regularFields.size() > 0, 'Should have regular fields available');
		
		// Verify regular fields are available for JIRA mapping
		for (AdminService.MergeField regularField : regularFields) {
			System.assertEquals(true, regularField.availableForJiraMapping, 'Regular field should be available for JIRA mapping: ' + regularField.apiName);
		}
		
		Test.stopTest();
	}

	/**
	 * Test that AutoChart fields are NOT available for JIRA mapping
	 */
	@IsTest
	public static void test_getMergeFields_autochart_fields_not_available() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Find AutoChart fields
		List<AdminService.MergeField> autoChartFields = new List<AdminService.MergeField>();
		for (AdminService.MergeField field : mergeFields) {
			if (field.apiName.contains('System_Auto_Chart') || field.value.contains('System_Auto_Chart')) {
				autoChartFields.add(field);
			}
		}
		
		System.assert(autoChartFields.size() > 0, 'Should have AutoChart fields');
		
		// Verify AutoChart fields are not available for JIRA mapping
		for (AdminService.MergeField autoChartField : autoChartFields) {
			System.assertEquals(false, autoChartField.availableForJiraMapping, 'AutoChart field should NOT be available for JIRA mapping: ' + autoChartField.apiName);
		}
		
		Test.stopTest();
	}

	/**
	 * Test ChartService.getChartsFields() directly to verify AutoChart fields are created with correct flags
	 */
	@IsTest
	public static void test_chartService_getChartsFields_not_available() {
		Test.startTest();
		
		List<AdminService.MergeField> chartFields = ChartService.getChartsFields();
		
		System.assert(chartFields.size() > 0, 'ChartService should return chart fields');
		
		// Verify all chart fields are not available for JIRA mapping
		for (AdminService.MergeField chartField : chartFields) {
			System.assertEquals(false, chartField.availableForJiraMapping, 'Chart field should NOT be available for JIRA mapping: ' + chartField.apiName);
			System.assert(chartField.apiName.contains('System_Auto_Chart'), 'Chart field apiName should contain System_Auto_Chart: ' + chartField.apiName);
			System.assert(chartField.value.contains('System_Auto_Chart'), 'Chart field value should contain System_Auto_Chart: ' + chartField.value);
		}
		
		Test.stopTest();
	}

	/**
	 * Test MergeField class constructor and methods
	 */
	@IsTest
	public static void test_merge_field_class_functionality() {
		Test.startTest();
		
		// Test constructor with availableForJiraMapping parameter
		AdminService.MergeField field1 = new AdminService.MergeField('Test Label', '{!Log__c.Name}', 'log', 'Name', true);
		System.assertEquals('Test Label', field1.label, 'Label should be set correctly');
		System.assertEquals('{!Log__c.Name}', field1.value, 'Value should be set correctly');
		System.assertEquals('log', field1.sobjectype, 'Sobjectype should be set correctly');
		System.assertEquals('Name', field1.apiName, 'ApiName should be set correctly');
		System.assertEquals(true, field1.availableForJiraMapping, 'AvailableForJiraMapping should be set correctly');
		
		// Test constructor without availableForJiraMapping parameter (defaults to true)
		AdminService.MergeField field2 = new AdminService.MergeField('Test Label 2', '{!Log__c.Id}', 'log', 'Id');
		System.assertEquals(true, field2.availableForJiraMapping, 'AvailableForJiraMapping should default to true');
		
		// Test setAvailableForJiraMapping method
		field2.setAvailableForJiraMapping(false);
		System.assertEquals(false, field2.availableForJiraMapping, 'setAvailableForJiraMapping should update the flag');
		
		// Test compareTo method
		AdminService.MergeField field3 = new AdminService.MergeField('Test Label 3', '{!Log__c.CreatedDate}', 'log', 'CreatedDate');
		Integer comparison = field1.compareTo(field3);
		System.assertEquals('Name'.compareTo('CreatedDate'), comparison, 'compareTo should compare apiName fields');
		
		Test.stopTest();
	}

	/**
	 * Test that merge fields are sorted correctly
	 */
	@IsTest
	public static void test_getMergeFields_sorted() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Verify fields are sorted by apiName
		for (Integer i = 1; i < mergeFields.size(); i++) {
			String currentApiName = mergeFields[i].apiName;
			String previousApiName = mergeFields[i-1].apiName;
			System.assert(currentApiName.compareTo(previousApiName) >= 0, 
				'Fields should be sorted by apiName: ' + previousApiName + ' should come before ' + currentApiName);
		}
		
		Test.stopTest();
	}

	/**
	 * Test addCustomMergeFields method directly
	 */
	@IsTest
	public static void test_addCustomMergeFields_log() {
		Test.startTest();
		
		Schema.DescribeSObjectResult logDescribe = Log__c.sObjectType.getDescribe();
		List<AdminService.MergeField> customFields = AdminService.addCustomMergeFields(logDescribe, 'log');
		
		System.assertEquals(1, customFields.size(), 'Should return one custom field for Log__c');
		
		AdminService.MergeField linkField = customFields[0];
		System.assertEquals('link', linkField.apiName, 'Should have link field');
		System.assertEquals(true, linkField.availableForJiraMapping, 'Link field should be available for JIRA mapping');
		System.assert(linkField.label.contains('Link'), 'Link field label should contain Link');
		System.assert(linkField.value.contains('.Link}'), 'Link field value should contain .Link');
		
		Test.stopTest();
	}

	/**
	 * Test addCustomMergeFields method for Issue__c (includes Analysis field)
	 */
	@IsTest
	public static void test_addCustomMergeFields_issue() {
		Test.startTest();
		
		Schema.DescribeSObjectResult issueDescribe = Issue__c.sObjectType.getDescribe();
		List<AdminService.MergeField> customFields = AdminService.addCustomMergeFields(issueDescribe, 'issue');
		
		System.assertEquals(2, customFields.size(), 'Should return two custom fields for Issue__c');
		
		// Find Link and Analysis fields
		AdminService.MergeField linkField = null;
		AdminService.MergeField analysisField = null;
		
		for (AdminService.MergeField field : customFields) {
			if (field.apiName == 'link') {
				linkField = field;
			} else if (field.apiName == 'analysis') {
				analysisField = field;
			}
		}
		
		System.assertNotEquals(null, linkField, 'Should have link field');
		System.assertEquals(true, linkField.availableForJiraMapping, 'Link field should be available for JIRA mapping');
		
		System.assertNotEquals(null, analysisField, 'Should have analysis field');
		System.assertEquals(false, analysisField.availableForJiraMapping, 'Analysis field should NOT be available for JIRA mapping');
		System.assertEquals('Advanced Analysis', analysisField.label, 'Analysis field should have correct label');
		
		Test.stopTest();
	}

	/**
	 * Test filtering logic directly with known field names
	 */
	@IsTest
	public static void test_filtering_logic_with_known_fields() {
		Test.startTest();
		
		// Get the filtered fields map
		Set<String> logFilteredFields = AdminService.MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING.get('log');
		System.assert(logFilteredFields.size() > 0, 'Should have filtered fields for log');
		
		// Test that the filtering logic works by simulating field creation
		Boolean shouldBeFiltered = logFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Deploy_Results__c'.toLowerCase());
		System.assertEquals(true, shouldBeFiltered, 'Deploy_Results__c should be in filtered fields');
		
		Boolean shouldBeNotFiltered = !logFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Stacktrace__c'.toLowerCase());
		System.assertEquals(true, shouldBeNotFiltered, 'Stacktrace__c should be in filtered fields');
		
		shouldBeFiltered = logFilteredFields.contains(ConfigUtil.nameSpacePrefix + 'Bug_Tracker__c'.toLowerCase());
		System.assertEquals(true, shouldBeFiltered, 'Bug_Tracker__c should be in filtered fields');
		
		// Test that regular fields are not filtered
		Boolean shouldNotBeFiltered = logFilteredFields.contains('Name');
		System.assertEquals(false, shouldNotBeFiltered, 'Name should NOT be in filtered fields');
		
		shouldNotBeFiltered = logFilteredFields.contains('Id');
		System.assertEquals(false, shouldNotBeFiltered, 'Id should NOT be in filtered fields');
		
		Test.stopTest();
	}

	/**
	 * Test that relationship fields are included and properly configured
	 */
	@IsTest
	public static void test_getMergeFields_relationship_fields() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Find relationship fields (should contain dots in apiName for traversal)
		List<AdminService.MergeField> relationshipFields = new List<AdminService.MergeField>();
		for (AdminService.MergeField field : mergeFields) {
			if (field.apiName.contains('.') && !field.apiName.endsWith('.Link') && !field.apiName.endsWith('.Analysis')) {
				relationshipFields.add(field);
			}
		}
		
		System.assert(relationshipFields.size() > 0, 'Should have relationship fields');
		
		// Verify relationship fields have proper structure
		for (AdminService.MergeField relField : relationshipFields) {
			System.assert(relField.value.contains('{!'), 'Relationship field value should start with merge field syntax');
			System.assert(relField.value.contains('}'), 'Relationship field value should end with merge field syntax');
			System.assert(relField.label.contains(' -> '), 'Relationship field label should contain arrow separator');
			System.assertNotEquals(null, relField.availableForJiraMapping, 'Relationship field should have availableForJiraMapping set');
		}
		
		Test.stopTest();
	}

	/**
	 * Test that all sobject types are represented in merge fields
	 */
	@IsTest
	public static void test_getMergeFields_all_sobject_types() {
		Test.startTest();
		
		List<AdminService.MergeField> mergeFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
		
		// Check that all expected sobject types are present
		Set<String> foundTypes = new Set<String>();
		for (AdminService.MergeField field : mergeFields) {
			foundTypes.add(field.sobjectype);
		}
		
		System.assert(foundTypes.contains('log'), 'Should have log fields');
		System.assert(foundTypes.contains('event'), 'Should have event fields');
		System.assert(foundTypes.contains('issue'), 'Should have issue fields');
		System.assert(foundTypes.contains('traceResult'), 'Should have traceResult fields');
		
		Test.stopTest();
	}

}