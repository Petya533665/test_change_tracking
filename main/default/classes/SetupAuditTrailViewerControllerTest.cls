@IsTest
public with sharing class SetupAuditTrailViewerControllerTest {

	@TestSetup
	static void setupTestData() {
		Log__c log = new Log__c();
		log.Category__c = 'TestCategory';
		log.Type__c = 'TestType';
		log.Area__c = 'Apex';
		log.Details__c = 'Test details';
		log.Setup_Audit_Trail__c = '[{"DelegateUser":null,"Section":"Test Section","Display":"Test Display","CreatedDate":"2023-01-01T10:00:00.000+0000","CreatedBy":{"Name":"Test User"}}]';
		insert log;
	}

	@IsTest
	static void test_constructor_withBlurMode() {
		Log__c log = getLog();

		PageReference pageRef = Page.SetupAuditTrailViewer;
		pageRef.getParameters().put('recordId', log.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(log);
		SetupAuditTrailViewerController controller = new SetupAuditTrailViewerController(sc);
		Test.stopTest();

		Assert.areNotEqual(null, controller.log, 'Log should not be null');
		Assert.areNotEqual(null, controller.data, 'Data should not be null');
		Assert.areNotEqual(null, controller.isBlurMode, 'isBlurMode should not be null');
	}

	@IsTest
	static void test_constructor_loadsLogData() {
		Log__c log = getLog();

		PageReference pageRef = Page.SetupAuditTrailViewer;
		pageRef.getParameters().put('recordId', log.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(log);
		SetupAuditTrailViewerController controller = new SetupAuditTrailViewerController(sc);
		Test.stopTest();

		Assert.areEqual(log.Id, controller.log.Id, 'Log Id should match');
		Assert.areNotEqual(null, controller.log.Setup_Audit_Trail__c, 'Setup Audit Trail should not be null');
	}

	@IsTest
	static void test_getHoursOptions() {
		Log__c log = getLog();

		PageReference pageRef = Page.SetupAuditTrailViewer;
		pageRef.getParameters().put('recordId', log.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(log);
		SetupAuditTrailViewerController controller = new SetupAuditTrailViewerController(sc);

		Test.startTest();
		List<SelectOption> options = controller.getHoursOptions();
		Test.stopTest();

		Assert.areEqual(4, options.size(), 'Should return 4 hour options');
		Assert.areEqual('1', options[0].getValue(), 'First option value should be 1');
		Assert.areEqual('1 hour', options[0].getLabel(), 'First option label should be 1 hour');
		Assert.areEqual('12', options[1].getValue(), 'Second option value should be 12');
		Assert.areEqual('12 hours', options[1].getLabel(), 'Second option label should be 12 hours');
		Assert.areEqual('24', options[2].getValue(), 'Third option value should be 24');
		Assert.areEqual('24 hours', options[2].getLabel(), 'Third option label should be 24 hours');
		Assert.areEqual('48', options[3].getValue(), 'Fourth option value should be 48');
		Assert.areEqual('48 hours', options[3].getLabel(), 'Fourth option label should be 48 hours');
	}

	@IsTest
	static void test_userTimezoneOffset() {
		Log__c log = getLog();

		PageReference pageRef = Page.SetupAuditTrailViewer;
		pageRef.getParameters().put('recordId', log.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(log);
		SetupAuditTrailViewerController controller = new SetupAuditTrailViewerController(sc);

		Test.startTest();
		Integer offset = controller.userTimezoneOffset;
		Test.stopTest();

		Assert.areNotEqual(null, offset, 'User timezone offset should not be null');
	}

	@IsTest
	static void test_blurModeProperties() {
		Log__c log = getLog();

		PageReference pageRef = Page.SetupAuditTrailViewer;
		pageRef.getParameters().put('recordId', log.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(log);
		SetupAuditTrailViewerController controller = new SetupAuditTrailViewerController(sc);
		Test.stopTest();

		// Test that blur mode properties are set
		if (controller.isBlurMode) {
			Assert.areNotEqual(null, controller.blurModeUrlParameter, 'Blur mode URL parameter should not be null when blur mode is active');
		}
	}

	@IsTest
	static void test_hoursProperty() {
		Log__c log = getLog();

		PageReference pageRef = Page.SetupAuditTrailViewer;
		pageRef.getParameters().put('recordId', log.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(log);
		SetupAuditTrailViewerController controller = new SetupAuditTrailViewerController(sc);

		Test.startTest();
		controller.hours = 24;
		Test.stopTest();

		Assert.areEqual(24, controller.hours, 'Hours should be set to 24');
	}

	private static Log__c getLog() {
		return [SELECT Id, Setup_Audit_Trail__c, Created_At__c, CreatedDate, Issue__c FROM Log__c LIMIT 1];
	}

}