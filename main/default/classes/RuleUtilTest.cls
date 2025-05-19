@IsTest
private class RuleUtilTest {

	@IsTest
	public static void test_rule_action_create_and_delete() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
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
			createRule(RuleUtil.RULE_TYPE_JIRA_UPDATE, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Name', null, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
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
			createRule(RuleUtil.RULE_TYPE_NOTIFICATION, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Name', null, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
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
			createRule(RuleUtil.RULE_TYPE_MONITORING, RuleUtil.RULE_SUBTYPE_IMPACT, null, true, 60, 1));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, '1', RuleUtil.COMPARISON_TYPE_FIELD, RuleUtil.COMPARISON_OPERATOR_EQUAL, null)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
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
			createRule(RuleUtil.RULE_TYPE_MONITORING, RuleUtil.RULE_SUBTYPE_IMPACT, null, true, 60, 1));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, '1', RuleUtil.COMPARISON_TYPE_FIELD, RuleUtil.COMPARISON_OPERATOR_EQUAL, null)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		// first create rule
		AdminController.remoteActionHandler(JSON.serialize(input));

		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_MONITORING);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);

		Test.startTest();
		Integer limitRules = 1;
		setMaxMonitoringRules(limitRules);
		Map<String, Object> dataUpdate = new Map<String, Object>();
		RuleUtil.Rule updatedRule = createRule(RuleUtil.RULE_TYPE_MONITORING, RuleUtil.RULE_SUBTYPE_IMPACT, null, true, 60, 1);
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
				createRule(RuleUtil.RULE_TYPE_MONITORING, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_MONITORING);
		AdminService.getRuleSettings(input);
	}

	@IsTest
	public static void test_monitoring_impact_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
			createRule(RuleUtil.RULE_TYPE_MONITORING, RuleUtil.RULE_SUBTYPE_IMPACT, null, true, 60, 1));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, '1', RuleUtil.COMPARISON_TYPE_FIELD, RuleUtil.COMPARISON_OPERATOR_EQUAL, null)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
			createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_MONITORING);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		System.assertNotEquals(null, result);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);
		System.assertNotEquals(null, rules);
		System.assertEquals(true, String.isBlank(rules.get(0).filterLogic));
		System.assertEquals(false, rules.get(0).isNotValid);
	}

	@IsTest
	public static void test_archival_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(RuleUtil.RULE_TYPE_ARCHIVAL, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
				createRuleAction()});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.RuleAction>{createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_ARCHIVAL);
		AdminService.getRuleSettings(input);
	}

	@IsTest
	public static void test_archival_rule_update_filters() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(RuleUtil.RULE_TYPE_ARCHIVAL, null, null, true, 60, null));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', null, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
				createRuleAction()});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.RuleAction>{createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_ARCHIVAL);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);

		createEvent(rules.get(0).id);
		Integer countEventsBefore = [SELECT COUNT() FROM Event__c WHERE Rule__c = :rules.get(0).id LIMIT 1];
		system.assertEquals(1, countEventsBefore);
		
		Test.startTest();
		Map<String, Object> dataUpdate = new Map<String, Object>();
		RuleUtil.Rule updatedRule = createRule(RuleUtil.RULE_TYPE_ARCHIVAL, null, '1', true, 60, null);
		updatedRule.id = rules.get(0).id;
		dataUpdate.put(RuleUtil.KEY_RULE, updatedRule);

		dataUpdate.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Created_At__c', null, '2880', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_GREATER_THEN, 1),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'someuser', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 2)});

		dataUpdate.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
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
				createRule(RuleUtil.RULE_TYPE_ARCHIVAL, null, '1 AND 2', true, 60, null));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Created_At__c', null, '2880', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_GREATER_THEN, 1),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'valid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 2),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'notvalid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_NOT_EQUAL, 3)
		});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
				createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
		data.put(RuleUtil.KEY_RULE_ACTIONS, new List<RuleUtil.RuleAction>{
				createRuleAction()});
		data.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.RuleAction>{createRuleAction()});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_ARCHIVAL);
		Map<String, Object> result = AdminService.getRuleSettings(input);
		List<RuleUtil.Rule> rules = (List<RuleUtil.Rule>)result.get(RuleUtil.KEY_RULES);

		createEvent(rules.get(0).id);
		Integer countEventsBefore = [SELECT COUNT() FROM Event__c WHERE Rule__c = :rules.get(0).id LIMIT 1];
		system.assertEquals(1, countEventsBefore);
		
		Test.startTest();
		Map<String, Object> dataUpdate = new Map<String, Object>();
		String changedFilterLogic = isPositive ? '1 OR 2' : '1 AND 2';
		RuleUtil.Rule updatedRule = createRule(RuleUtil.RULE_TYPE_ARCHIVAL, null, changedFilterLogic, true, 60, null);
		updatedRule.id = rules.get(0).id;
		dataUpdate.put(RuleUtil.KEY_RULE, updatedRule);

		dataUpdate.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
			createRuleFilter('Created_At__c', null, '2880', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_GREATER_THEN, 1),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'valid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 2),
			createRuleFilter(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), null, 'notvalid', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_NOT_EQUAL, 3)});

		dataUpdate.put(RuleUtil.KEY_ACTIONS, new List<RuleUtil.Action>{
			createAction(RuleUtil.ACTION_TYPE_REMOVAL, null, null, null)});
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
				createRule(RuleUtil.RULE_TYPE_JIRA_UPDATE, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_JIRA_UPDATE);
		AdminService.getRuleSettings(input);
	}

	@IsTest
	public static void test_Notification_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(RuleUtil.RULE_TYPE_NOTIFICATION, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_NOTIFICATION);
		AdminService.getRuleSettings(input);
	}

	@IsTest
	public static void test_broadcast_rule() {
		Map<String, Object> data = new Map<String, Object>();
		data.put(RuleUtil.KEY_RULE,
				createRule(RuleUtil.RULE_TYPE_BROADCAST, null, true));
		data.put(RuleUtil.KEY_RULE_FILTERS, new List<RuleUtil.RuleFilter>{
				createRuleFilter('Name', RuleUtil.FIELD_TYPE_STRING, '1', RuleUtil.COMPARISON_TYPE_VALUE, RuleUtil.COMPARISON_OPERATOR_EQUAL, 1)});
		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'setRule');
		input.put('data', data);
		AdminController.remoteActionHandler(JSON.serialize(input));
		input.put('method', 'getRuleSettings');
		input.put('ruleType', RuleUtil.RULE_TYPE_BROADCAST);
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

}