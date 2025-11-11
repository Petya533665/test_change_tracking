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

    @IsTest
    static void test_createLimitsForLogs_hourlySnapshotLogs() {
        // Test that Limits__c records are created ONLY for hourly snapshot logs
        
        Test.startTest();
        
        // Create hourly snapshot logs (should get limits)
        List<Log__c> snapshotLogs = new List<Log__c>();
        for (Integer i = 0; i < 3; i++) {
            Log__c log = new Log__c(
                Category__c = HourlyLimitsBatch.CATEGORY,
                Type__c = HourlyLimitsBatch.TYPE,
                Summary__c = 'Hourly Limits Snapshot ' + i,
                Created_Timestamp__c = Double.valueOf(System.now().getTime()),
                Organization_Id__c = UserInfo.getOrganizationId().left(15)
            );
            snapshotLogs.add(log);
        }
        
        // Call createLimitsForLogs
        LimitsService.createLimitsForLogs(snapshotLogs, true, false, Logger.getInstance());
        
        Test.stopTest();
        
        // Verify that all snapshot logs have Limits__c populated
        Integer logsWithLimits = 0;
        Id sharedLimitId = null;
        for (Log__c log : snapshotLogs) {
            if (log.Limits__c != null) {
                logsWithLimits++;
                if (sharedLimitId == null) {
                    sharedLimitId = log.Limits__c;
                } else {
                    // All local logs should share the same Limits__c record
                    System.assertEquals(sharedLimitId, log.Limits__c, 
                        'All local snapshot logs should share the same Limits__c record');
                }
            }
        }
        
        System.assertEquals(3, logsWithLimits, 
            'All 3 hourly snapshot logs should have Limits__c populated');
        
        // Verify the Limits__c record exists and has data
        List<Limits__c> limitsRecords = [SELECT Id, DailyApiRequests__c, SingleEmail__c 
                                         FROM Limits__c WHERE Id = :sharedLimitId];
        System.assertEquals(1, limitsRecords.size(), 
            'One Limits__c record should be created for all local logs');
    }

    @IsTest
    static void test_createLimitsForLogs_nonHourlyLogs() {
        // Test that Limits__c records are NOT created for non-hourly logs
        
        Test.startTest();
        
        // Create regular logs (should NOT get limits)
        List<Log__c> regularLogs = new List<Log__c>();
        
        // Various non-snapshot log types
        regularLogs.add(new Log__c(
            Category__c = 'Error',
            Type__c = 'Exception',
            Summary__c = 'Test Error Log',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        regularLogs.add(new Log__c(
            Category__c = 'Pharos',
            Type__c = 'SomeOtherType',
            Summary__c = 'Pharos but not HourlyLimitsBatch',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        regularLogs.add(new Log__c(
            Category__c = 'Integration',
            Type__c = 'API',
            Summary__c = 'Integration Log',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        // Call createLimitsForLogs
        LimitsService.createLimitsForLogs(regularLogs, true, false, Logger.getInstance());
        
        Test.stopTest();
        
        // Verify that NO regular logs have Limits__c populated
        for (Log__c log : regularLogs) {
            System.assertEquals(null, log.Limits__c, 
                'Non-hourly snapshot logs should NOT have Limits__c populated. Log: ' + log.Summary__c);
        }
        
        // Verify no Limits__c records were created
        List<Limits__c> limitsRecords = [SELECT Id FROM Limits__c];
        System.assertEquals(0, limitsRecords.size(), 
            'No Limits__c records should be created for non-hourly logs');
    }

    @IsTest
    static void test_createLimitsForLogs_mixedLogs() {
        // Test mixed scenario: some hourly snapshot logs, some regular logs
        
        Test.startTest();
        
        List<Log__c> mixedLogs = new List<Log__c>();
        
        // Add 2 hourly snapshot logs
        mixedLogs.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Snapshot 1',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        mixedLogs.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Snapshot 2',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        // Add 3 regular logs
        mixedLogs.add(new Log__c(
            Category__c = 'Error',
            Type__c = 'Exception',
            Summary__c = 'Regular Log 1',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        mixedLogs.add(new Log__c(
            Category__c = 'Debug',
            Type__c = 'Info',
            Summary__c = 'Regular Log 2',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        mixedLogs.add(new Log__c(
            Category__c = 'Integration',
            Type__c = 'API',
            Summary__c = 'Regular Log 3',
            Created_Timestamp__c = Double.valueOf(System.now().getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        // Call createLimitsForLogs
        LimitsService.createLimitsForLogs(mixedLogs, true, false, Logger.getInstance());
        
        Test.stopTest();
        
        // Verify only snapshot logs have Limits__c
        Integer logsWithLimits = 0;
        Integer logsWithoutLimits = 0;
        
        for (Log__c log : mixedLogs) {
            if (log.Category__c == HourlyLimitsBatch.CATEGORY && 
                log.Type__c == HourlyLimitsBatch.TYPE) {
                System.assertNotEquals(null, log.Limits__c, 
                    'Snapshot log should have Limits__c: ' + log.Summary__c);
                logsWithLimits++;
            } else {
                System.assertEquals(null, log.Limits__c, 
                    'Regular log should NOT have Limits__c: ' + log.Summary__c);
                logsWithoutLimits++;
            }
        }
        
        System.assertEquals(2, logsWithLimits, 'Should have 2 logs with limits');
        System.assertEquals(3, logsWithoutLimits, 'Should have 3 logs without limits');
        
        // Verify only one Limits__c record was created
        List<Limits__c> limitsRecords = [SELECT Id FROM Limits__c];
        System.assertEquals(1, limitsRecords.size(), 
            'Only one Limits__c record should be created for local snapshot logs');
    }

    @IsTest
    static void test_deleteLimits_orphanedRecordsDeleted() {
        // Test that Limits__c records are deleted when associated logs are deleted
        // and no other logs reference them
        
        // Create and insert a Limits__c record
        Limits__c testLimit = new Limits__c(
            DailyApiRequests__c = 100,
            SingleEmail__c = 50
        );
        insert testLimit;
        
        // Create and insert logs that reference this limit
        List<Log__c> logsToDelete = new List<Log__c>();
        logsToDelete.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Snapshot Log 1',
            Limits__c = testLimit.Id,
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        insert logsToDelete;
        
        // Verify the Limits__c record exists
        List<Limits__c> limitsBeforeDelete = [SELECT Id FROM Limits__c WHERE Id = :testLimit.Id];
        System.assertEquals(1, limitsBeforeDelete.size(), 
            'Limits__c record should exist before log deletion');
        
        Test.startTest();
        
        // Delete the logs
        delete logsToDelete;
        
        Test.stopTest();
        
        // Verify the Limits__c record was deleted (orphaned)
        List<Limits__c> limitsAfterDelete = [SELECT Id FROM Limits__c WHERE Id = :testLimit.Id];
        System.assertEquals(0, limitsAfterDelete.size(), 
            'Orphaned Limits__c record should be deleted when log is deleted');
    }

    @IsTest
    static void test_deleteLimits_sharedRecordsNotDeleted() {
        // Test that Limits__c records are NOT deleted when multiple logs reference them
        // and only some logs are deleted
        
        // Create and insert a Limits__c record
        Limits__c sharedLimit = new Limits__c(
            DailyApiRequests__c = 200,
            SingleEmail__c = 100
        );
        insert sharedLimit;
        
        // Create logs - some to keep, some to delete
        List<Log__c> logsToKeep = new List<Log__c>();
        logsToKeep.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Keep Log 1',
            Limits__c = sharedLimit.Id,
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        logsToKeep.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Keep Log 2',
            Limits__c = sharedLimit.Id,
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        insert logsToKeep;
        
        List<Log__c> logsToDelete = new List<Log__c>();
        logsToDelete.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Delete Log 1',
            Limits__c = sharedLimit.Id,
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        insert logsToDelete;
        
        // Verify we have 3 logs and 1 limit
        System.assertEquals(3, [SELECT COUNT() FROM Log__c WHERE Limits__c = :sharedLimit.Id], 
            'Should have 3 logs referencing the limit');
        
        Test.startTest();
        
        // Delete one log
        delete logsToDelete;
        
        Test.stopTest();
        
        // Verify the Limits__c record still exists (not orphaned)
        List<Limits__c> limitsAfterDelete = [SELECT Id FROM Limits__c WHERE Id = :sharedLimit.Id];
        System.assertEquals(1, limitsAfterDelete.size(), 
            'Shared Limits__c record should NOT be deleted when other logs still reference it');
        
        // Verify we still have 2 logs
        Integer remainingLogs = [SELECT COUNT() FROM Log__c WHERE Limits__c = :sharedLimit.Id];
        System.assertEquals(2, remainingLogs, 
            'Should have 2 logs remaining that reference the limit');
    }

    @IsTest
    static void test_deleteLimits_multipleOrphanedRecords() {
        // Test deletion of multiple logs with different Limits__c records
        
        // Create multiple Limits__c records
        List<Limits__c> limits = new List<Limits__c>();
        limits.add(new Limits__c(DailyApiRequests__c = 100));
        limits.add(new Limits__c(DailyApiRequests__c = 200));
        limits.add(new Limits__c(DailyApiRequests__c = 300));
        insert limits;
        
        // Create logs, each with a different limit
        List<Log__c> logsToDelete = new List<Log__c>();
        for (Integer i = 0; i < limits.size(); i++) {
            logsToDelete.add(new Log__c(
                Category__c = HourlyLimitsBatch.CATEGORY,
                Type__c = HourlyLimitsBatch.TYPE,
                Summary__c = 'Log ' + i,
                Limits__c = limits[i].Id,
                Organization_Id__c = UserInfo.getOrganizationId().left(15)
            ));
        }
        insert logsToDelete;
        
        // Verify all limits exist
        System.assertEquals(3, [SELECT COUNT() FROM Limits__c], 
            'Should have 3 Limits__c records before deletion');
        
        Test.startTest();
        
        // Delete all logs
        delete logsToDelete;
        
        Test.stopTest();
        
        // Verify all limits are deleted
        System.assertEquals(0, [SELECT COUNT() FROM Limits__c], 
            'All orphaned Limits__c records should be deleted');
    }

    @IsTest
    static void test_deleteLimits_logsWithoutLimits() {
        // Test deleting logs that don't have Limits__c - should not cause errors
        
        List<Log__c> logsWithoutLimits = new List<Log__c>();
        logsWithoutLimits.add(new Log__c(
            Category__c = 'Error',
            Type__c = 'Exception',
            Summary__c = 'Regular Log 1',
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        logsWithoutLimits.add(new Log__c(
            Category__c = 'Debug',
            Type__c = 'Info',
            Summary__c = 'Regular Log 2',
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        insert logsWithoutLimits;
        
        Test.startTest();
        
        // Delete logs without limits - should not error
        try {
            delete logsWithoutLimits;
            System.assert(true, 'Deleting logs without Limits__c should succeed');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception when deleting logs without limits: ' + e.getMessage());
        }
        
        Test.stopTest();
        
        // Verify logs were deleted
        System.assertEquals(0, [SELECT COUNT() FROM Log__c WHERE Id IN :logsWithoutLimits], 
            'Logs should be deleted successfully');
    }

    @IsTest
    static void test_deleteLimits_mixedScenario() {
        // Test complex scenario: multiple logs, some with shared limits, some with unique limits, some with no limits
        
        // Create Limits__c records
        Limits__c sharedLimit = new Limits__c(DailyApiRequests__c = 100);
        Limits__c uniqueLimit = new Limits__c(DailyApiRequests__c = 200);
        insert new List<Limits__c>{ sharedLimit, uniqueLimit };
        
        // Create logs to keep (using sharedLimit)
        Log__c logToKeep = new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Keep Log',
            Limits__c = sharedLimit.Id,
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        );
        insert logToKeep;
        
        // Create logs to delete
        List<Log__c> logsToDelete = new List<Log__c>();
        
        // Log with shared limit (should NOT delete the limit)
        logsToDelete.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Delete Log with Shared Limit',
            Limits__c = sharedLimit.Id,
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        // Log with unique limit (should delete the limit)
        logsToDelete.add(new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Delete Log with Unique Limit',
            Limits__c = uniqueLimit.Id,
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        // Log without limit
        logsToDelete.add(new Log__c(
            Category__c = 'Error',
            Type__c = 'Exception',
            Summary__c = 'Delete Log without Limit',
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        ));
        
        insert logsToDelete;
        
        // Verify initial state: 2 limits, 4 logs
        System.assertEquals(2, [SELECT COUNT() FROM Limits__c], 
            'Should start with 2 Limits__c records');
        System.assertEquals(4, [SELECT COUNT() FROM Log__c], 
            'Should start with 4 Log__c records');
        
        Test.startTest();
        
        // Delete the logs
        delete logsToDelete;
        
        Test.stopTest();
        
        // Verify results:
        // - sharedLimit should still exist (referenced by logToKeep)
        // - uniqueLimit should be deleted (orphaned)
        List<Limits__c> remainingLimits = [SELECT Id FROM Limits__c];
        System.assertEquals(1, remainingLimits.size(), 
            'Should have 1 Limits__c record remaining');
        System.assertEquals(sharedLimit.Id, remainingLimits[0].Id, 
            'The shared limit should remain, unique limit should be deleted');
        
        // Verify logToKeep still exists
        System.assertEquals(1, [SELECT COUNT() FROM Log__c], 
            'Should have 1 Log__c record remaining');
    }
}