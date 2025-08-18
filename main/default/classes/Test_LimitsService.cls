@isTest(IsParallel=true)
public class Test_LimitsService {

    @IsTest
    static void test_fieldMap_configuration() {
        // Test that the FIELD_MAP is properly configured with Limits__c fields
        
        Test.startTest();
        
        // Verify FIELD_MAP contains expected entries
        System.assert(LimitsService.FIELD_MAP.size() >= 52, 
            'FIELD_MAP should contain at least 52 limit field mappings, found ' + LimitsService.FIELD_MAP.size());
        
        // Test a few key field mappings
        System.assert(LimitsService.FIELD_MAP.containsKey('DailyApiRequests'), 
            'FIELD_MAP should contain DailyApiRequests mapping');
        System.assert(LimitsService.FIELD_MAP.containsKey('DataStorageMB'), 
            'FIELD_MAP should contain DataStorageMB mapping');
        System.assert(LimitsService.FIELD_MAP.containsKey('SingleEmail'), 
            'FIELD_MAP should contain SingleEmail mapping');
        
        // Verify field accessibility
        for (String limitKey : LimitsService.FIELD_MAP.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = LimitsService.FIELD_MAP.get(limitKey);
            
            System.assertNotEquals(null, fieldDescribe, 
                'Field describe should not be null for ' + limitKey);
            
            String fieldName = fieldDescribe.getName();
            System.assertNotEquals(null, fieldName, 
                'Field name should not be null for ' + limitKey);
            
            // Verify it's a numeric field type
            Schema.DisplayType fieldType = fieldDescribe.getType();
            System.assert(
                fieldType == Schema.DisplayType.Double || 
                fieldType == Schema.DisplayType.Integer || 
                fieldType == Schema.DisplayType.Currency ||
                fieldType == Schema.DisplayType.Percent,
                'Limit field ' + fieldName + ' should be a numeric type, but was ' + fieldType
            );
        }
        
        Test.stopTest();
    }

    @IsTest
    static void test_populateLimits_with_Limits_object() {
        // Test the new populateLimits method that works with Limits__c objects
        
        Test.startTest();
        
        // Create test Limits__c record
        Limits__c testLimits = new Limits__c();
        
        // Populate the limits
        LimitsService.populateLimits(testLimits, Logger.getInstance());
        
        // Verify some key fields are populated
        Map<String, System.OrgLimit> orgLimits = OrgLimits.getMap();
        
        if (orgLimits.containsKey('DailyApiRequests')) {
            System.assertEquals(orgLimits.get('DailyApiRequests').getValue(), testLimits.DailyApiRequests__c, 
                'DailyApiRequests__c should be populated correctly');
        }
        
        if (orgLimits.containsKey('DataStorageMB')) {
            System.assertEquals(orgLimits.get('DataStorageMB').getValue(), testLimits.DataStorageMB__c, 
                'DataStorageMB__c should be populated correctly');
        }
        
        if (orgLimits.containsKey('SingleEmail')) {
            System.assertEquals(orgLimits.get('SingleEmail').getValue(), testLimits.SingleEmail__c, 
                'SingleEmail__c should be populated correctly');
        }
        
        Test.stopTest();
    }

    @IsTest
    static void test_populateLimits_handles_null_limits() {
        Test.startTest();
        
        try {
            LimitsService.populateLimits((Limits__c)null, Logger.getInstance());
            System.assert(false, 'Should have thrown exception for null limits');
        } catch (Exception e) {
            System.assert(true, 'Expected exception for null limits parameter');
        }
        
        Test.stopTest();
    }

    @IsTest
    static void test_getAvailableSingleEmail() {
        Test.startTest();
        
        Integer availableEmails = LimitsService.getAvailableSingleEmail();
        
        Test.stopTest();
        
        System.assertNotEquals(null, availableEmails, 'Available single emails should not be null');
        System.assert(availableEmails >= 0, 'Available single emails should be non-negative');
        
        // Verify calculation
        Map<String, System.OrgLimit> orgLimits = OrgLimits.getMap();
        System.OrgLimit emailLimit = orgLimits.get('SingleEmail');
        if (emailLimit != null) {
            Integer expectedAvailable = emailLimit.getLimit() - emailLimit.getValue();
            System.assertEquals(expectedAvailable, availableEmails, 
                'Available emails calculation should be correct');
        }
    }

    @IsTest
    static void test_getAvailableQuantityAsyncApexExecutions() {
        Test.startTest();
        
        Integer availableAsync = LimitsService.getAvailableQuantityAsyncApexExecutions();
        
        Test.stopTest();
        
        System.assertNotEquals(null, availableAsync, 'Available async apex executions should not be null');
        System.assert(availableAsync >= 0, 'Available async apex executions should be non-negative');
        
        // Verify calculation
        Map<String, System.OrgLimit> orgLimits = OrgLimits.getMap();
        System.OrgLimit asyncLimit = orgLimits.get('DailyAsyncApexExecutions');
        if (asyncLimit != null) {
            Integer expectedAvailable = asyncLimit.getLimit() - asyncLimit.getValue();
            System.assertEquals(expectedAvailable, availableAsync, 
                'Available async apex executions calculation should be correct');
        }
    }

    @IsTest
    static void test_getCountHoldingBatchApexJobs() {
        Test.startTest();
        
        Integer holdingJobs = LimitsService.getCountHoldingBatchApexJobs();
        
        Test.stopTest();
        
        System.assertNotEquals(null, holdingJobs, 'Holding batch apex jobs count should not be null');
        System.assert(holdingJobs >= 0, 'Holding batch apex jobs count should be non-negative');
    }

    @IsTest
    static void test_isFlexQueueSlotAvailable() {
        Test.startTest();
        
        Boolean slotAvailable = LimitsService.isFlexQueueSlotAvailable();
        
        Test.stopTest();
        
        // Should return a boolean value
        System.assertNotEquals(null, slotAvailable, 'Flex queue slot availability should not be null');
        
        // Verify logic
        Integer holdingJobs = LimitsService.getCountHoldingBatchApexJobs();
        Boolean expectedAvailable = holdingJobs < LimitsService.MAX_COUNT_HOLDING_BATCH_APEX_JOBS;
        System.assertEquals(expectedAvailable, slotAvailable, 
            'Flex queue slot availability should match calculation');
    }
}