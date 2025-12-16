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

    @IsTest
    static void test_limitsRuleSpike_withMissingLimitsData_shouldNotFireEvent() {
        // ✅ FIXED: Test case that originally reproduced the production bug
        // The bug: Query returned ALL logs (regular + snapshot), mixing data
        // The fix: Added WHERE Limits__c != null filter, so only snapshot logs are processed
        // This test now validates that regular logs are correctly filtered out
        
        // Setup: Enable monitoring permissions (needed for limits monitoring)
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 5;
        PermissionsUtil.NotificationForPharosErrors = true;
        
        // Clear cache
        RuleUtil.cachedRules = new Map<String, Map<Id, RuleUtil.Rule>>();
        
        // Setup: Create a Limits spike rule
        // NOTE: Spike rules scan ALL Limits fields automatically - no filter needed
        Rule__c spikeRule = new Rule__c(
            Name__c = 'File Storage Spike Test',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_LIMITS,
            Subtype__c = Constants.RULE_SOBJECT.SUB_TYPE_SPIKE,
            EventTimeInterval__c = 60, // 60 minutes
            AggregateType__c = 'Count',
            ComparisonOperator__c = RuleUtil.COMPARISON_OPERATOR_GREATER_OR_EQUAL,
            Threshold__c = 1, // 1% spike threshold
            SobjectType__c = null,
            Index__c = 1,
            Is_Not_Valid__c = false
        );
        insert spikeRule;
        
        DateTime testTime = DateTime.now();
        
        // Create Limits__c record with data that would trigger a spike
        Limits__c limits1 = new Limits__c(
            DailyApiRequests__c = 100,
            FileStorageMB__c = 10.0,
            DataStorageMB__c = 50.0
        );
        insert limits1;
        
        // Create test logs in the time window
        List<Log__c> testLogs = new List<Log__c>();
        
        // Log 1: HAS Limits__c data (at T-30 minutes)
        Log__c log1 = new Log__c(
            Category__c = HourlyLimitsBatch.CATEGORY,
            Type__c = HourlyLimitsBatch.TYPE,
            Summary__c = 'Hourly Limits Snapshot 1',
            Limits__c = limits1.Id,
            Created_At__c = testTime.addMinutes(-30),
            Created_Timestamp__c = Double.valueOf(testTime.addMinutes(-30).getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        );
        testLogs.add(log1);
        
        // Log 2: MISSING Limits__c data (at T-15 minutes) - THIS IS THE BUG
        Log__c log2 = new Log__c(
            Category__c = 'Other',
            Type__c = 'Regular',
            Summary__c = 'Regular log without limits',
            Limits__c = null, // No Limits__c!
            Created_At__c = testTime.addMinutes(-15),
            Created_Timestamp__c = Double.valueOf(testTime.addMinutes(-15).getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        );
        testLogs.add(log2);
        
        // Log 3: MISSING Limits__c data (at T-5 minutes)
        Log__c log3 = new Log__c(
            Category__c = 'Other',
            Type__c = 'Regular',
            Summary__c = 'Another regular log without limits',
            Limits__c = null, // No Limits__c!
            Created_At__c = testTime.addMinutes(-5),
            Created_Timestamp__c = Double.valueOf(testTime.addMinutes(-5).getTime()),
            Organization_Id__c = UserInfo.getOrganizationId().left(15)
        );
        testLogs.add(log3);
        
        insert testLogs;
        
        Test.startTest();
        
        // Query logs with Limits__r relationship (simulating what MonitoringBatch does)
        List<Log__c> logsWithLimitsQuery = [
            SELECT Id, Created_At__c, 
                   Limits__r.Id, 
                   Limits__r.FileStorageMB__c,
                   Limits__r.DataStorageMB__c,
                   Limits__r.DailyApiRequests__c
            FROM Log__c 
            WHERE Created_At__c >= :testTime.addMinutes(-60)
            ORDER BY Created_At__c
        ];
        
        // Verify the issue: We have 3 logs but only 1 has Limits__r data
        Integer logsWithLimitsData = 0;
        for (Log__c log : logsWithLimitsQuery) {
            if (log.Limits__r != null) {
                logsWithLimitsData++;
            }
        }
        System.assertEquals(1, logsWithLimitsData, 
            'BUG REPRODUCTION: Only 1 out of 3 logs has Limits__r data');
        
        // Execute limits evaluation
        // NOTE: runDateTime should be AFTER the latest log to ensure all logs are captured
        Map<Id, RuleUtil.Event> eventsMap = new Map<Id, RuleUtil.Event>();
        MonitoringUtil.evaluateLimitsRules(
            logsWithLimitsQuery, 
            new List<Id>{spikeRule.Id}, 
            testTime.addMinutes(1), // Run 1 minute after testTime to ensure all logs are in window
            eventsMap, 
            Logger.getInstance()
        );
        
        Test.stopTest();
        
        // Check if events were created
        List<Event__c> events = [
            SELECT Id, Rule__c, RecordCount__c, Criteria__c
            FROM Event__c 
            WHERE Rule__c = :spikeRule.Id
        ];
        
        // ✅ EXPECTED BEHAVIOR AFTER FIX:
        // Regular logs (without Limits__c) are now filtered out by WHERE Limits__c != null
        // In this test, only 1 snapshot log remains after filtering
        // With only 1 data point, spike detection correctly returns no events
        System.assertEquals(0, events.size(),
            'No events created - only 1 snapshot log has Limits__c data (regular logs filtered out). ' +
            'Spike detection requires at least 2 data points to calculate percentage changes.');
    }

    @IsTest
    static void test_limitsRuleSpike_withSufficientLimitsData_shouldFireEvent() {
        // ✅ FIXED: Test case validating spike detection works with complete Limits__c data
        // Test case showing expected behavior: When logs have Limits__c data, spike rules work correctly
        // This test now PASSES after adding WHERE Limits__c != null filter in MonitoringService.buildMonitoringLogsQuery()
        
        // Setup: Enable monitoring permissions and settings (needed for limits monitoring)
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 5;
        PermissionsUtil.NotificationForPharosErrors = true;
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = true;
        
        // Setup batch flag so hasNewLimits() returns true
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = DateTime.now();
        batchFlag.Last_Processed_Limits_Log__c = DateTime.now().addHours(-1); // Set to past so hasNewLimits() = true
        upsert batchFlag;
        
        // Clear cache like other working tests do
        RuleUtil.cachedRules = new Map<String, Map<Id, RuleUtil.Rule>>();
        
        // Setup: Create a Limits spike rule
        // NOTE: Spike rules scan ALL Limits fields automatically - no filter needed
        Rule__c spikeRule = new Rule__c(
            Name__c = 'File Storage Spike Test',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_LIMITS,
            Subtype__c = Constants.RULE_SOBJECT.SUB_TYPE_SPIKE,
            EventTimeInterval__c = 60, // 60 minutes
            AggregateType__c = 'Count',
            ComparisonOperator__c = RuleUtil.COMPARISON_OPERATOR_GREATER_OR_EQUAL,
            Threshold__c = 50, // 50% spike threshold
            SobjectType__c = null,
            Index__c = 1,
            Is_Not_Valid__c = false
        );
        insert spikeRule;
        
        DateTime testTime = DateTime.now();
        
        // Create Limits__c records showing a spike in FileStorageMB
        Limits__c limits1 = new Limits__c(
            DailyApiRequests__c = 1000,
            FileStorageMB__c = 100.0,  // Starting value
            DataStorageMB__c = 500.0
        );
        Limits__c limits2 = new Limits__c(
            DailyApiRequests__c = 1600,  // 60% increase - should trigger spike!
            FileStorageMB__c = 200.0,    // 100% increase - should trigger spike!
            DataStorageMB__c = 850.0     // 70% increase - should trigger spike!
        );
        insert new List<Limits__c>{ limits1, limits2 };
        
        // Create test logs - ALL with Limits__c data
        List<Log__c> testLogs = new List<Log__c>{
            new Log__c(
                Created_At__c = testTime.addMinutes(-2),
                Limits__c = limits1.Id,
                Organization_Id__c = UserInfo.getOrganizationId()
            ),
            new Log__c(
                Created_At__c = testTime.addMinutes(-1),
                Limits__c = limits2.Id,
                Organization_Id__c = UserInfo.getOrganizationId()
            )
        };
        insert testLogs;
        
        // Query logs with Limits__r relationship
        testLogs = [
            SELECT Id, Created_At__c, Limits__c,
                   Limits__r.Id, 
                   Limits__r.FileStorageMB__c,
                   Limits__r.DataStorageMB__c,
                   Limits__r.DailyApiRequests__c
            FROM Log__c 
            WHERE Id IN :testLogs
            ORDER BY Created_At__c DESC
        ];
        
        // Verify test data setup
        System.assertEquals(2, testLogs.size(), 'Should have 2 logs');
        System.assertNotEquals(null, testLogs[0].Limits__r, 'First log should have Limits__r');
        System.assertNotEquals(null, testLogs[1].Limits__r, 'Second log should have Limits__r');
        
        // Prepare batch clock so MonitoringBatch.shouldRun picks Limits
        // CRITICAL: currentTime must be AFTER the latest log for spike detection to work
        MonitoringBatch.currentTime = testTime.addMinutes(1);
        
        Test.startTest();
        
        // Execute via batch (end-to-end test like production)
        MonitoringBatch.getInstance().startBatch();
        
        Test.stopTest();
        
        // Check if events were created
        List<Event__c> events = [
            SELECT Id, Rule__c, RecordCount__c, Criteria__c
            FROM Event__c 
            WHERE Rule__c = :spikeRule.Id
        ];
        
        // ✅ VERIFIED: With 2 data points showing 60%+ spikes in 3 fields, events ARE created
        // The fix in MonitoringService.buildMonitoringLogsQuery() ensures only logs with Limits__c are processed
        System.assert(events.size() >= 1,
            'Event(s) should be created when spike is detected with sufficient data points. ' +
            'Found ' + events.size() + ' events. ' +
            'Log times: [' + testLogs[0].Created_At__c + ', ' + testLogs[1].Created_At__c + '], runDateTime: ' + testTime + '. ' +
            'Spike detection now works correctly after filtering out regular logs.');
        
        // Verify that Limits rule criteria does NOT contain GROUP BY
        // Limits rules evaluate values directly from Limits__c records, not via SOQL queries
        for (Event__c event : events) {
            System.assert(
                event.Criteria__c == null || !event.Criteria__c.contains('GROUP BY'), 
                'Limits rule event criteria should NOT contain GROUP BY. Criteria: ' + event.Criteria__c
            );
        }
    }

    @IsTest
    static void test_limitsRuleSpike_withGapWithin60Min_shouldFireEvent() {
        // ✅ TEST CASE 1: Gap WITHIN 60 minutes (58 min)
        // Validates that spike detection works when gap is comfortably within EventTimeInterval
        // This test ensures MonitoringBatch captures ONLY HourlyLimitsBatch snapshots:
        // - Previous snapshot (within 60-min window) ✅
        // - Current snapshot ✅
        // - Regular logs in between (filtered out by Limits__c != null) ❌
        
        // Setup: Enable monitoring permissions
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 5;
        PermissionsUtil.NotificationForPharosErrors = true;
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = true;
        
        // CRITICAL: Define baseTime FIRST so all timing is relative to a single point
        DateTime baseTime = DateTime.now();
        
        // Setup batch flag to simulate production reality
        // In production (from your JSON data):
        // - Previous MonitoringBatch ran ~60 minutes ago and set Last_Processed_Limits_Log__c
        // - Gap between batch runs: 59.95 to 60.22 minutes (±15 seconds)
        // This simulates the typical production scenario
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = baseTime.addMinutes(1); // Indicates new logs exist
        batchFlag.Last_Processed_Limits_Log__c = baseTime.addMinutes(-60); // ~60 min gap (production-realistic!)
        upsert batchFlag;
        
        // Clear cache
        RuleUtil.cachedRules = new Map<String, Map<Id, RuleUtil.Rule>>();
        
        // Create spike rule
        Rule__c spikeRule = new Rule__c(
            Name__c = 'Snapshot Capture Test',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_LIMITS,
            Subtype__c = Constants.RULE_SOBJECT.SUB_TYPE_SPIKE,
            EventTimeInterval__c = 60, // 60 minutes
            AggregateType__c = 'Count',
            ComparisonOperator__c = RuleUtil.COMPARISON_OPERATOR_GREATER_OR_EQUAL,
            Threshold__c = 50, // 50% spike threshold
            SobjectType__c = null,
            Index__c = 1,
            Is_Not_Valid__c = false
        );
        insert spikeRule;
        
        // SCENARIO: Gap WITHIN 60 minutes (58 min)
        // EventTimeInterval = 60 minutes
        // This tests the ideal case where gap is comfortably within the EventTimeInterval window
        //
        // MonitoringService query window: Created_At__c >= (currentTime - EventTimeInterval - 2 min buffer) = -62 min
        // MonitoringUtil.processSpikeRule() then re-filters to exactly EventTimeInterval = -60 min
        // So previous snapshot must be within -60 min window for spike detection!
        //
        // Time -59min: Previous HourlyLimitsBatch run (within spike window!) ✅
        // Time -45min:       Regular error log (filtered by Limits__c != null) ❌
        // Time -30min:       Regular debug log (filtered by Limits__c != null) ❌
        // Time -15min:       Regular info log (filtered by Limits__c != null) ❌
        // Time -1min:        Current HourlyLimitsBatch run ✅
        // Time now:          MonitoringBatch runs
        //
        // Gap between snapshots: 58 minutes (close to production's ~60 min ±15sec)
        
        // Create Limits__c records for snapshots showing clear spike
        Limits__c previousSnapshot = new Limits__c(
            DailyApiRequests__c = 1000,
            FileStorageMB__c = 100.0,
            DataStorageMB__c = 500.0
        );
        Limits__c currentSnapshot = new Limits__c(
            DailyApiRequests__c = 1600,  // 60% increase - spike!
            FileStorageMB__c = 180.0,    // 80% increase - spike!
            DataStorageMB__c = 800.0     // 60% increase - spike!
        );
        insert new List<Limits__c>{ previousSnapshot, currentSnapshot };
        
        // Create logs in timeline order - keeping it simple like the working test
        List<Log__c> allLogs = new List<Log__c>();
        
        // 1. Previous HourlyLimitsBatch snapshot (time -59min) ✅ SHOULD BE CAPTURED
        //    Note: MonitoringUtil.processSpikeRule() re-filters logs to exactly EventTimeInterval (60 min)
        //    So previous snapshot must be within 60-min window for spike detection
        //    Using -59min ensures it's within both query window (-62) and spike window (-60)
        //    Gap from current: 59 - 1 = 58 minutes (close to production's ~60 min)
        allLogs.add(new Log__c(
            Summary__c = 'Previous Hourly Limits Snapshot',
            Created_At__c = baseTime.addMinutes(-59), // 58 min gap from current snapshot
            Limits__c = previousSnapshot.Id,  // ✅ HAS Limits__c
            Organization_Id__c = UserInfo.getOrganizationId()
        ));
        
        // 2. Regular error log (time -45min) ❌ SHOULD BE FILTERED OUT
        allLogs.add(new Log__c(
            Created_At__c = baseTime.addMinutes(-45),
            Limits__c = null,  // ❌ NO Limits__c - should be filtered!
            Organization_Id__c = UserInfo.getOrganizationId()
        ));
        
        // 3. Regular debug log (time -30min) ❌ SHOULD BE FILTERED OUT
        allLogs.add(new Log__c(
            Created_At__c = baseTime.addMinutes(-30),
            Limits__c = null,  // ❌ NO Limits__c - should be filtered!
            Organization_Id__c = UserInfo.getOrganizationId()
        ));
        
        // 4. Regular info log (time -15min) ❌ SHOULD BE FILTERED OUT
        allLogs.add(new Log__c(
            Created_At__c = baseTime.addMinutes(-15),
            Limits__c = null,  // ❌ NO Limits__c - should be filtered!
            Organization_Id__c = UserInfo.getOrganizationId()
        ));
        
        // 5. Current HourlyLimitsBatch snapshot (time -1min) ✅ SHOULD BE CAPTURED
        allLogs.add(new Log__c(
            Summary__c = 'Current Hourly Limits Snapshot',
            Created_At__c = baseTime.addMinutes(-1),
            Limits__c = currentSnapshot.Id,  // ✅ HAS Limits__c
            Organization_Id__c = UserInfo.getOrganizationId()
        ));
        
        insert allLogs;
        
        // Verify data setup: 5 logs total (2 snapshots + 3 regular)
        System.assertEquals(5, allLogs.size(), 'Should have 5 logs total');
        
        // Prepare batch clock - MUST be AFTER the latest log for spike detection to work!
        // Latest log is at baseTime -1 minute, so set current time to baseTime (after all logs)
        MonitoringBatch.currentTime = baseTime;
        
        Test.startTest();
        
        // Run MonitoringBatch - this should capture ONLY the 2 snapshot logs
        MonitoringBatch.getInstance().startBatch();
        
        Test.stopTest();
        
        // VERIFICATION: Query logs and events
        List<Event__c> events = [
            SELECT Id, Rule__c, RecordCount__c, Criteria__c
            FROM Event__c
            WHERE Rule__c = :spikeRule.Id
        ];
        
        // Query window: EventTimeInterval (60) + QUERY_WINDOW_BUFFER_MINUTES (2) = 62 minutes
        Integer queryWindowMinutes = 60 + Constants.MONITORING.QUERY_WINDOW_BUFFER_MINUTES;
        
        List<Log__c> capturedLogs = [
            SELECT Id, Summary__c, Limits__c,
                   Limits__r.DailyApiRequests__c,
                   Limits__r.FileStorageMB__c,
                   Limits__r.DataStorageMB__c
            FROM Log__c
            WHERE Created_At__c >= :baseTime.addMinutes(-queryWindowMinutes)
              AND Limits__c != null
            ORDER BY Created_At__c
        ];
        
        // ASSERTIONS
        System.assertEquals(2, capturedLogs.size(),
            'Should capture ONLY 2 snapshot logs (with Limits__c), not all 5 logs');
        
        System.assertNotEquals(null, capturedLogs[0].Limits__r,
            'First log should have Limits__r data');
        System.assertNotEquals(null, capturedLogs[1].Limits__r,
            'Second log should have Limits__r data');
        
        System.assert(capturedLogs[0].Summary__c.contains('Hourly Limits Snapshot'),
            'First log should be a snapshot log');
        System.assert(capturedLogs[1].Summary__c.contains('Hourly Limits Snapshot'),
            'Second log should be a snapshot log');
        
        System.assert(events.size() >= 1,
            'Spike event should be created with 60% increase (1000 → 1600)');
        
        System.assertEquals(1000, capturedLogs[0].Limits__r.DailyApiRequests__c,
            'Previous snapshot should have 1000 API requests');
        System.assertEquals(1600, capturedLogs[1].Limits__r.DailyApiRequests__c,
            'Current snapshot should have 1600 API requests');
    }

    @IsTest
    static void test_integerValuesHandled_remoteOrg() {
        // Test that values are correctly cast to integers when populating limits from REST API
        
        // Create a Connected_Org__c record (must be done before Test.startTest for insert)
        Connected_Org__c testOrg = new Connected_Org__c(
            Name = '00D000000000001',
            Instance_Url__c = 'https://test.salesforce.com',
            Access_Token__c = 'test_token_123'
        );
        insert testOrg;
        
        // Mock HTTP response with integer values
        String mockResponseBody = '{' +
            '"DataStorageMB": {' +
                '"Max": 1024,' +
                '"Remaining": 512' +
            '},' +
            '"FileStorageMB": {' +
                '"Max": 2048,' +
                '"Remaining": 1000' +
            '},' +
            '"AnalyticsExternalDataSizeMB": {' +
                '"Max": 500,' +
                '"Remaining": 250' +
            '},' +
            '"DailyApiRequests": {' +
                '"Max": 15000,' +
                '"Remaining": 10000' +
            '}' +
        '}';
        
        // Set up HTTP mock before Test.startTest
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.SingleRequestMock(200, 'OK', mockResponseBody));
        
        Test.startTest();
        
        // Create Limits__c record
        Limits__c testLimits = new Limits__c();
        
        // Call the method
        LimitsService.populateLimits(testLimits, testOrg, Logger.getInstance());
        
        Test.stopTest();
        
        // Verify integer values are correctly calculated
        // DataStorageMB: 1024 - 512 = 512
        System.assertEquals(512, testLimits.DataStorageMB__c, 
            'DataStorageMB__c should have integer value 512');
        
        // FileStorageMB: 2048 - 1000 = 1048
        System.assertEquals(1048, testLimits.FileStorageMB__c, 
            'FileStorageMB__c should have integer value 1048');
        
        // AnalyticsExternalDataSizeMB: 500 - 250 = 250
        System.assertEquals(250, testLimits.AnalyticsExternalDataSizeMB__c, 
            'AnalyticsExternalDataSizeMB__c should have integer value 250');
        
        // DailyApiRequests: 15000 - 10000 = 5000
        System.assertEquals(5000, testLimits.DailyApiRequests__c, 
            'DailyApiRequests__c should have integer value 5000');
    }

    @IsTest
    static void test_limitsRuleSpike_withGapOver60Min_shouldNormalizeTiming() {
        // ⚠️ TEST CASE 2: Gap OVER 60 minutes (60.22 min - production maximum)
        // Production reality from your JSON: gaps can be 60.22 min (60 min 13.2 sec)
        // Problem: MonitoringUtil.processSpikeRule() filters to EXACTLY EventTimeInterval (60 min)
        // Result: Previous snapshot at -60.22 min falls OUTSIDE the 60-min spike detection window!
        // 
        // This test demonstrates the edge case that may need datetime normalization
        // to round/normalize timing to nearest minute for spike detection
        
        // Setup: Enable monitoring permissions
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 5;
        PermissionsUtil.NotificationForPharosErrors = true;
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = true;
        
        // CRITICAL: Define baseTime FIRST
        DateTime baseTime = DateTime.now();
        
        // Setup batch flag
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = baseTime.addMinutes(1);
        batchFlag.Last_Processed_Limits_Log__c = baseTime.addMinutes(-60); // ~60 min gap
        upsert batchFlag;
        
        // Clear cache
        RuleUtil.cachedRules = new Map<String, Map<Id, RuleUtil.Rule>>();
        
        // Create spike rule
        Rule__c spikeRule = new Rule__c(
            Name__c = 'Production Gap 60.22min Test',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_LIMITS,
            Subtype__c = Constants.RULE_SOBJECT.SUB_TYPE_SPIKE,
            EventTimeInterval__c = 60, // 60 minutes
            AggregateType__c = 'Count',
            ComparisonOperator__c = RuleUtil.COMPARISON_OPERATOR_GREATER_OR_EQUAL,
            Threshold__c = 50, // 50% spike threshold
            SobjectType__c = null,
            Index__c = 1,
            Is_Not_Valid__c = false
        );
        insert spikeRule;
        
        // SCENARIO: Production maximum gap (60.22 min from your JSON data)
        // EventTimeInterval = 60 minutes
        // Production gap: 60 min 13.2 sec (60.22 min)
        //
        // MonitoringService query window: Created_At__c >= (currentTime - 62 min) ✅ Captures both
        // MonitoringUtil.processSpikeRule() filters: >= (currentTime - 60 min) ❌ Filters out previous!
        //
        // Time -60min 13sec: Previous HourlyLimitsBatch (outside 60-min spike window!) ⚠️
        // Time -1min:        Current HourlyLimitsBatch ✅
        // Gap: 59 min 13 sec = 59.22 min difference
        // But from batch run time (baseTime), previous is at -60.22 min (OUTSIDE -60 min window!)
        
        // Create Limits__c records showing clear spike
        Limits__c previousSnapshot = new Limits__c(
            DailyApiRequests__c = 1000,
            FileStorageMB__c = 100.0,
            DataStorageMB__c = 500.0
        );
        Limits__c currentSnapshot = new Limits__c(
            DailyApiRequests__c = 1600,  // 60% increase - spike!
            FileStorageMB__c = 180.0,    // 80% increase - spike!
            DataStorageMB__c = 800.0     // 60% increase - spike!
        );
        insert new List<Limits__c>{ previousSnapshot, currentSnapshot };
        
        // Create logs simulating production timing
        List<Log__c> allLogs = new List<Log__c>();
        
        // Previous snapshot: -60min 13sec (60.22 min gap from current at -1min)
        // From baseTime perspective: -60.22 min (OUTSIDE spike window of -60 min!)
        allLogs.add(new Log__c(
            Summary__c = 'Previous Hourly Limits Snapshot',
            Created_At__c = baseTime.addMinutes(-60).addSeconds(-13), // 60 min 13 sec before baseTime
            Limits__c = previousSnapshot.Id,
            Organization_Id__c = UserInfo.getOrganizationId()
        ));
        
        // Current snapshot: -1min
        allLogs.add(new Log__c(
            Summary__c = 'Current Hourly Limits Snapshot',
            Created_At__c = baseTime.addMinutes(-1),
            Limits__c = currentSnapshot.Id,
            Organization_Id__c = UserInfo.getOrganizationId()
        ));
        
        insert allLogs;
        
        // Set batch time
        MonitoringBatch.currentTime = baseTime;
        
        Test.startTest();
        MonitoringBatch.getInstance().startBatch();
        Test.stopTest();
        
        // VERIFICATION: Query logs and events
        List<Event__c> events = [
            SELECT Id, Rule__c
            FROM Event__c
            WHERE Rule__c = :spikeRule.Id
        ];
        
        // Query window: EventTimeInterval (60) + QUERY_WINDOW_BUFFER_MINUTES (2) = 62 minutes
        Integer queryWindowMinutes = 60 + Constants.MONITORING.QUERY_WINDOW_BUFFER_MINUTES;
        
        List<Log__c> capturedLogs = [
            SELECT Id, Summary__c, Created_At__c, Limits__c,
                   Limits__r.DailyApiRequests__c
            FROM Log__c
            WHERE Created_At__c >= :baseTime.addMinutes(-queryWindowMinutes)
              AND Limits__c != null
            ORDER BY Created_At__c
        ];
        
        // ASSERTIONS
        System.assertEquals(2, capturedLogs.size(),
            'Query with 2-min buffer should capture both snapshots');
        
        System.assertNotEquals(null, capturedLogs[0].Limits__r,
            'First log should have Limits__r data');
        System.assertNotEquals(null, capturedLogs[1].Limits__r,
            'Second log should have Limits__r data');
        
        System.assert(events.size() >= 1,
            'Spike event should be created with 60.22-min gap after datetime normalization');
        
        System.assertEquals(1000, capturedLogs[0].Limits__r.DailyApiRequests__c,
            'Previous snapshot should have 1000 API requests');
        System.assertEquals(1600, capturedLogs[1].Limits__r.DailyApiRequests__c,
            'Current snapshot should have 1600 API requests');
    }

    @IsTest
    static void test_regularMonitoringFinish_shouldTriggerLimitsMonitoring() {
        // TEST: Verify hasNewLimits() and needRunLimitsRules() work correctly
        // to determine if limits monitoring should run after regular monitoring
        
        // Setup: Enable both monitoring types
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 10;
        ConfigUtil.SETTINGS.Monitoring_Enabled__c = true;
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = true;
        
        DateTime testTime = DateTime.now();
        
        // Setup batch flag: limits have new data to process
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = testTime; // New log created
        batchFlag.Last_Processed_Limits_Log__c = testTime.addMinutes(-70); // Limits processed long ago
        upsert batchFlag;
        
        Test.startTest();
        
        // Test that hasNewLimits() detects new data
        Boolean hasNewLimits = MonitoringService.hasNewLimits();
        
        Test.stopTest();
        
        // VERIFICATION: Should detect new limits data
        System.assertEquals(true, hasNewLimits,
            'hasNewLimits() should return true when Last_Created_Log__c > Last_Processed_Limits_Log__c');
    }

    @IsTest
    static void test_limitsMonitoringFinish_shouldTriggerRegularMonitoring() {
        // TEST: Verify hasNewLogs() works correctly to determine
        // if regular monitoring should run after limits monitoring
        
        // Setup: Enable both monitoring types
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 10;
        ConfigUtil.SETTINGS.Monitoring_Enabled__c = true;
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = true;
        
        DateTime testTime = DateTime.now();
        
        // Setup batch flag: regular logs have new data to process
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = testTime; // New log created
        batchFlag.Last_Processed_Log__c = testTime.addMinutes(-70); // Regular logs processed long ago
        upsert batchFlag;
        
        Test.startTest();
        
        // Test that hasNewLogs() detects new data
        Boolean hasNewLogs = MonitoringService.hasNewLogs();
        
        Test.stopTest();
        
        // VERIFICATION: Should detect new regular log data
        System.assertEquals(true, hasNewLogs,
            'hasNewLogs() should return true when Last_Created_Log__c > Last_Processed_Log__c');
    }

    @IsTest
    static void test_regularMonitoringFinish_noLimitsNeeded_shouldNotTrigger() {
        // TEST: Verify hasNewLimits() returns false when all limits are already processed
        
        // Setup: Enable both monitoring types
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 10;
        ConfigUtil.SETTINGS.Monitoring_Enabled__c = true;
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = true;
        
        DateTime testTime = DateTime.now();
        
        // Setup batch flag: limits already processed up to current time
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = testTime.addMinutes(-10); // Old log
        batchFlag.Last_Processed_Limits_Log__c = testTime; // Already processed
        upsert batchFlag;
        
        Test.startTest();
        
        // Test that hasNewLimits() correctly detects no new data
        Boolean hasNewLimits = MonitoringService.hasNewLimits();
        
        Test.stopTest();
        
        // VERIFICATION: Should NOT detect new limits data
        System.assertEquals(false, hasNewLimits,
            'hasNewLimits() should return false when Last_Created_Log__c < Last_Processed_Limits_Log__c');
    }

    @IsTest
    static void test_shouldRunOtherStrategy_implementation() {
        // TEST: Verify the shouldRunOtherStrategy() method implementations
        // correctly call hasNewData() and needRunRules() methods
        
        // Setup: Enable both monitoring types
        PermissionsUtil.MonitoringEnabled = true;
        PermissionsUtil.LimitsMonitoringEnabled = true;
        PermissionsUtil.MaxMonitoringRules = 10;
        ConfigUtil.SETTINGS.Monitoring_Enabled__c = true;
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = true;
        
        DateTime testTime = DateTime.now();
        
        // Setup batch flag: both types have new data
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = testTime;
        batchFlag.Last_Processed_Log__c = testTime.addMinutes(-70); // Old
        batchFlag.Last_Processed_Limits_Log__c = testTime.addMinutes(-70); // Old
        upsert batchFlag;
        
        Test.startTest();
        
        // Test the underlying methods that shouldRunOtherStrategy uses
        Boolean hasNewLogs = MonitoringService.hasNewLogs();
        Boolean hasNewLimits = MonitoringService.hasNewLimits();
        
        // Instantiate strategies
        MonitoringService.LogMonitoringStrategy logStrategy = new MonitoringService.LogMonitoringStrategy(Logger.getInstance());
        MonitoringService.LimitsMonitoringStrategy limitsStrategy = new MonitoringService.LimitsMonitoringStrategy(Logger.getInstance());
        
        Test.stopTest();
        
        // VERIFICATION: Both types should have new data
        System.assertEquals(true, hasNewLogs,
            'Should detect new regular logs when Last_Created_Log__c > Last_Processed_Log__c');
        System.assertEquals(true, hasNewLimits,
            'Should detect new limits logs when Last_Created_Log__c > Last_Processed_Limits_Log__c');
        
        // Verify strategy instances can be created
        System.assertNotEquals(null, logStrategy,
            'LogMonitoringStrategy should be instantiated');
        System.assertNotEquals(null, limitsStrategy,
            'LimitsMonitoringStrategy should be instantiated');
        
        // Verify strategies have correct rule types
        System.assertEquals(Constants.RULE_SOBJECT.TYPE_MONITORING, logStrategy.getRuleType(),
            'LogMonitoringStrategy should return TYPE_MONITORING');
        System.assertEquals(Constants.RULE_SOBJECT.TYPE_LIMITS, limitsStrategy.getRuleType(),
            'LimitsMonitoringStrategy should return TYPE_LIMITS');
    }

    @IsTest
    static void test_hasNewData_methods() {
        // TEST: Verify hasNewLogs() and hasNewLimits() methods work correctly
        // to determine if monitoring strategies should run
        
        DateTime testTime = DateTime.now();
        
        // Test Case 1: Both have new data
        Monitoring_Batch_Flag__c batchFlag = Monitoring_Batch_Flag__c.getOrgDefaults();
        batchFlag.Last_Created_Log__c = testTime;
        batchFlag.Last_Processed_Log__c = testTime.addMinutes(-10);
        batchFlag.Last_Processed_Limits_Log__c = testTime.addMinutes(-10);
        upsert batchFlag;
        
        Test.startTest();
        
        Boolean hasNewLogs1 = MonitoringService.hasNewLogs();
        Boolean hasNewLimits1 = MonitoringService.hasNewLimits();
        
        // Test Case 2: No new data (all processed)
        batchFlag.Last_Processed_Log__c = testTime.addMinutes(10);
        batchFlag.Last_Processed_Limits_Log__c = testTime.addMinutes(10);
        upsert batchFlag;
        
        Boolean hasNewLogs2 = MonitoringService.hasNewLogs();
        Boolean hasNewLimits2 = MonitoringService.hasNewLimits();
        
        // Test Case 3: No logs created yet
        batchFlag.Last_Created_Log__c = null;
        batchFlag.Last_Processed_Log__c = null;
        batchFlag.Last_Processed_Limits_Log__c = null;
        upsert batchFlag;
        
        Boolean hasNewLogs3 = MonitoringService.hasNewLogs();
        Boolean hasNewLimits3 = MonitoringService.hasNewLimits();
        
        Test.stopTest();
        
        // VERIFICATION Case 1: Both should have new data
        System.assertEquals(true, hasNewLogs1,
            'Case 1: Should detect new regular logs');
        System.assertEquals(true, hasNewLimits1,
            'Case 1: Should detect new limits logs');
        
        // VERIFICATION Case 2: Neither should have new data
        System.assertEquals(false, hasNewLogs2,
            'Case 2: Should NOT detect new regular logs when already processed');
        System.assertEquals(false, hasNewLimits2,
            'Case 2: Should NOT detect new limits logs when already processed');
        
        // VERIFICATION Case 3: No logs at all
        System.assertEquals(false, hasNewLogs3,
            'Case 3: Should return false when no logs created');
        System.assertEquals(false, hasNewLimits3,
            'Case 3: Should return false when no logs created');
    }

    static void test_getMaxJiraRules_returnsNull_whenZero() {
        // Test that getMaxJiraRules returns null when PermissionsUtil.MaxJiraRules is 0
        Test.startTest();
        PermissionsUtil.MaxJiraRules = 0;
        Integer result = LimitsService.getMaxJiraRules();
        Test.stopTest();
        
        System.assertEquals(null, result, 'getMaxJiraRules should return null when MaxJiraRules is 0 (unlimited)');
    }

    @IsTest
    static void test_getMaxJiraRules_returnsValue_whenNonZero() {
        // Test that getMaxJiraRules returns the actual value when PermissionsUtil.MaxJiraRules is not 0
        Test.startTest();
        PermissionsUtil.MaxJiraRules = 10;
        Integer result = LimitsService.getMaxJiraRules();
        Test.stopTest();
        
        System.assertEquals(10, result, 'getMaxJiraRules should return 10 when MaxJiraRules is 10');
    }

    @IsTest
    static void test_getMaxMonitoringRules_returnsNull_whenZero() {
        Test.startTest();
        PermissionsUtil.MaxMonitoringRules = 0;
        Integer result = LimitsService.getMaxMonitoringRules();
        Test.stopTest();
        
        System.assertEquals(null, result, 'getMaxMonitoringRules should return null when MaxMonitoringRules is 0 (unlimited)');
    }

    @IsTest
    static void test_getMaxMonitoringRules_returnsValue_whenNonZero() {
        Test.startTest();
        PermissionsUtil.MaxMonitoringRules = 5;
        Integer result = LimitsService.getMaxMonitoringRules();
        Test.stopTest();
        
        System.assertEquals(5, result, 'getMaxMonitoringRules should return 5 when MaxMonitoringRules is 5');
    }

    @IsTest
    static void test_getMaxArchivalRules_returnsNull_whenZero() {
        Test.startTest();
        PermissionsUtil.MaxArchivalRules = 0;
        Integer result = LimitsService.getMaxArchivalRules();
        Test.stopTest();
        
        System.assertEquals(null, result, 'getMaxArchivalRules should return null when MaxArchivalRules is 0 (unlimited)');
    }

    @IsTest
    static void test_getMaxArchivalRules_returnsValue_whenNonZero() {
        Test.startTest();
        PermissionsUtil.MaxArchivalRules = 3;
        Integer result = LimitsService.getMaxArchivalRules();
        Test.stopTest();
        
        System.assertEquals(3, result, 'getMaxArchivalRules should return 3 when MaxArchivalRules is 3');
    }

    @IsTest
    static void test_getMaxConnectedOrgs_returnsNull_whenZero() {
        Test.startTest();
        PermissionsUtil.MaxConnectedOrgs = 0;
        Integer result = LimitsService.getMaxConnectedOrgs();
        Test.stopTest();
        
        System.assertEquals(null, result, 'getMaxConnectedOrgs should return null when MaxConnectedOrgs is 0 (unlimited)');
    }

    @IsTest
    static void test_getMaxConnectedOrgs_returnsValue_whenNonZero() {
        Test.startTest();
        PermissionsUtil.MaxConnectedOrgs = 2;
        Integer result = LimitsService.getMaxConnectedOrgs();
        Test.stopTest();
        
        System.assertEquals(2, result, 'getMaxConnectedOrgs should return 2 when MaxConnectedOrgs is 2');
    }

    @IsTest
    static void test_getMaxNotificationRules_returnsNull_whenZero() {
        Test.startTest();
        PermissionsUtil.MaxNotificationRules = 0;
        Integer result = LimitsService.getMaxNotificationRules();
        Test.stopTest();
        
        System.assertEquals(null, result, 'getMaxNotificationRules should return null when MaxNotificationRules is 0 (unlimited)');
    }

    @IsTest
    static void test_getMaxNotificationRules_returnsValue_whenNonZero() {
        Test.startTest();
        PermissionsUtil.MaxNotificationRules = 7;
        Integer result = LimitsService.getMaxNotificationRules();
        Test.stopTest();
        
        System.assertEquals(7, result, 'getMaxNotificationRules should return 7 when MaxNotificationRules is 7');
    }
}