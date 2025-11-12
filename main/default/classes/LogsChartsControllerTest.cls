@IsTest
private class LogsChartsControllerTest {

    @TestSetup
    static void testSetup() {
        Log__c log = new Log__c();
        log.Hash_1__c = 'test_hash1';
        log.Hash_2__c = 'test_hash2';
        log.Hash_3__c = 'test_hash3';
        insert log;
    }

    @IsTest
    static void test_constructor_withDevParameterTrue() {
        Log__c log = getLog();

        PageReference pageRef = Page.LogsChartsWrapper;
        pageRef.getParameters().put('recordId', log.Id);
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        LogsChartsWrapperController controller = new LogsChartsWrapperController(sc);
        Test.stopTest();

        Assert.areEqual(true, controller.isDev, 'isDev should be true when dev parameter is true');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.currentLog, 'currentLog should not be null');
        Assert.areEqual(log.Id, controller.currentLog.Id, 'currentLog Id should match');
    }

    @IsTest
    static void test_constructor_withDevParameterFalse() {
        Log__c log = getLog();

        PageReference pageRef = Page.LogsChartsWrapper;
        pageRef.getParameters().put('recordId', log.Id);
        pageRef.getParameters().put('dev', 'false');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        LogsChartsWrapperController controller = new LogsChartsWrapperController(sc);
        Test.stopTest();

        Assert.areEqual(false, controller.isDev, 'isDev should be false when dev parameter is false');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.currentLog, 'currentLog should not be null');
        Assert.areEqual(log.Id, controller.currentLog.Id, 'currentLog Id should match');
    }

    @IsTest
    static void test_constructor_withoutDevParameter() {
        Log__c log = getLog();

        PageReference pageRef = Page.LogsChartsWrapper;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        LogsChartsWrapperController controller = new LogsChartsWrapperController(sc);
        Test.stopTest();

        Assert.areEqual(false, controller.isDev, 'isDev should be false when no dev parameter is provided');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.currentLog, 'currentLog should not be null');
        Assert.areEqual(log.Id, controller.currentLog.Id, 'currentLog Id should match');
    }

    @IsTest
    static void test_constructor_withCookie() {
        Log__c log = getLog();

        PageReference pageRef = Page.LogsChartsWrapper;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        // Set a cookie for development mode
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        LogsChartsWrapperController controller = new LogsChartsWrapperController(sc);
        Test.stopTest();

        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.currentLog, 'currentLog should not be null');
        Assert.areEqual(log.Id, controller.currentLog.Id, 'currentLog Id should match');
        // Note: Cookie reading might not work in test context, so isDev will likely be false
    }

    @IsTest
    static void test_packageNamespace_property() {
        Log__c log = getLog();

        PageReference pageRef = Page.LogsChartsWrapper;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        LogsChartsWrapperController controller = new LogsChartsWrapperController(sc);

        Test.startTest();
        String namespace = controller.packageNamespace;
        Test.stopTest();

        Assert.areNotEqual(null, namespace, 'packageNamespace should not be null');
    }

    @IsTest
    static void test_isBlurMode_property() {
        Log__c log = getLog();

        PageReference pageRef = Page.LogsChartsWrapper;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        LogsChartsWrapperController controller = new LogsChartsWrapperController(sc);

        Test.startTest();
        Boolean blurMode = controller.isBlurMode;
        Test.stopTest();

        Assert.areNotEqual(null, blurMode, 'isBlurMode should not be null');
    }

    @IsTest
    static void test_currentLog_property() {
        Log__c log = getLog();

        PageReference pageRef = Page.LogsChartsWrapper;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        LogsChartsWrapperController controller = new LogsChartsWrapperController(sc);

        Test.startTest();
        Log__c currentLog = controller.currentLog;
        Test.stopTest();

        Assert.areNotEqual(null, currentLog, 'currentLog should not be null');
        Assert.areEqual(log.Id, currentLog.Id, 'currentLog Id should match');
    }

    @IsTest
    static void test_remoteActionHandler_getOccurrenceLogs_withShowDays1() {
        Log__c log = getLog();
        
        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getOccurrenceLogs',
            'data' => new Map<String, Object>{
                'showDays' => 1,
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');
    }

    @IsTest
    static void test_remoteActionHandler_getOccurrenceLogs_withShowDays7() {
        Log__c log = getLog();
        
        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getOccurrenceLogs',
            'data' => new Map<String, Object>{
                'showDays' => 7,
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');
    }

    @IsTest
    static void test_remoteActionHandler_getTimingLogs_withShowRange1() {
        Log__c log = getLog();
        
        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getTimingLogs',
            'data' => new Map<String, Object>{
                'showRange' => 1,
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');
    }

    @IsTest
    static void test_remoteActionHandler_getTimingLogs_withShowRange10() {
        Log__c log = getLog();
        
        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getTimingLogs',
            'data' => new Map<String, Object>{
                'showRange' => 10,
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');
    }

    @IsTest
    static void test_remoteActionHandler_getDateRange() {
        Log__c log = getLog();

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getDateRange',
            'data' => new Map<String, Object>{
                'dateRange' => 1,
                'logId' => log.Id
            }
        };

        disableBlurMode();

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');

        Map<String, Object> data = (Map<String, Object>) response.get('data');
        Assert.areEqual(LogsChartsWrapperController.LAST_7_DAYS_DATE_RANGE, data.get('dateRange'), 'Date range does not match');
    }

    @IsTest
    static void test_remoteActionHandler_getDateRange_notAvailableDebugView() {
        Log__c log = getLog();

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getDateRange',
            'data' => new Map<String, Object>{
                'dateRange' => 1,
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');

        Map<String, Object> data = (Map<String, Object>) response.get('data');
        Assert.areEqual(LogsChartsWrapperController.LAST_7_DAYS_DATE_RANGE, data.get('dateRange'), 'Date range does not match');
    }

    @IsTest
    static void test_remoteActionHandler_getReportUrl_labelSame() {
        Log__c log = getLog();

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getReportUrl',
            'data' => new Map<String, Object>{
                'label' => LogsChartsWrapperController.LABEL_SAME,
                'date' => '',
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');

        Map<String, Object> data = (Map<String, Object>) response.get('data');
        // reportUrl is blank because the report 'Summary by Date Filtered 1' does not exist in test context
        Assert.isTrue(String.isBlank((String) data.get('reportUrl')), 'Report URL does not match');
    }

    @IsTest
    static void test_remoteActionHandler_getReportUrl_labelSimilar() {
        Log__c log = getLog();

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getReportUrl',
            'data' => new Map<String, Object>{
                'label' => LogsChartsWrapperController.LABEL_SIMILAR,
                'date' => '',
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');

        Map<String, Object> data = (Map<String, Object>) response.get('data');
        // reportUrl is blank because the report 'Summary by Date Filtered 2' does not exist in test context
        Assert.isTrue(String.isBlank((String) data.get('reportUrl')), 'Report URL does not match');
    }

    @IsTest
    static void test_remoteActionHandler_getReportUrl_labelPossiblyRelated() {
        Log__c log = getLog();

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getReportUrl',
            'data' => new Map<String, Object>{
                'label' => LogsChartsWrapperController.LABEL_POSSIBLY_RELATED,
                'date' => '',
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');

        Map<String, Object> data = (Map<String, Object>) response.get('data');
        // reportUrl is blank because the report 'Summary by Date Filtered 3' does not exist in test context
        Assert.isTrue(String.isBlank((String) data.get('reportUrl')), 'Report URL does not match');
    }

    @IsTest
    static void test_remoteActionHandler_getReportUrl_labelTiming() {
        Log__c log = getLog();

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getReportUrl',
            'data' => new Map<String, Object>{
                'label' => LogsChartsWrapperController.LABEL_TIMING,
                'date' => '',
                'logId' => log.Id
            }
        };

        Map<String, Object> response;
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
        Assert.isTrue(String.isBlank((String)response.get('error')), 'Error should be blank');

        Map<String, Object> data = (Map<String, Object>) response.get('data');
        // reportUrl is blank because the report 'Summary by Timing' does not exist in test context
        Assert.isTrue(String.isBlank((String) data.get('reportUrl')), 'Report URL does not match');
    }

    @IsTest
    static void test_remoteActionHandler_InvalidMethod() {
        Map<String, Object> input = new Map<String, Object>{
            'method' => 'invalidMethod',
            'data' => new Map<String, Object>()
        };

        Map<String, Object> response;
        
        Test.startTest();
            response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(JSON.serialize(input)));
        Test.stopTest();

        Assert.areEqual('Action not found', response.get('error'), 'Response should contain error for invalid method');
    }

    private static Log__c getLog() {
        return [SELECT Id FROM Log__c LIMIT 1];
    }

    private static void disableBlurMode() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
                0=>0, 1=>0,	2=>0,
                3=>0, 4=>0,	5=>0,
                6=>0, 7=>0,	8=>0,
                9=>0, 10=>0, 11=>0,
                12=>0, 13=>0, 14=>0,
                15=>0, 16=>0, 17=>0,
                18=>0, 19=>0, 20=>0,
                21=>0, 22=>0, 23=>0,
                24=>0, 25=>0, 26=>0,
                27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap10IntValue = intValue;
        PermissionsUtil.MaxIssues = intValue;
    }
}