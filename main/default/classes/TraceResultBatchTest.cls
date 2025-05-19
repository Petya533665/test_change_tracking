@IsTest
private class TraceResultBatchTest {
    
    private static TestData createTestData() {
        // Create two issues for different scenarios
        Issue__c issue = new Issue__c(Status__c = 'New');
        Issue__c otherIssue = new Issue__c(Status__c = 'New');
        insert new List<Issue__c>{issue, otherIssue};

        Trace_Schedule__c schedule = new Trace_Schedule__c(Issue__c = issue.Id);
        Trace_Schedule__c otherSchedule = new Trace_Schedule__c(Issue__c = otherIssue.Id);
        insert new List<Trace_Schedule__c>{schedule, otherSchedule};
        
        Trace_Request__c request = new Trace_Request__c(
            Status__c = 'In Progress',
            Start_Date__c = DateTime.now().addHours(1),
            End_Date__c = DateTime.now().addHours(2),
            Traced_Entity_Id__c = UserInfo.getUserId(),
            Source__c = UserInfo.getOrganizationId(),
            Trace_Schedule__c = schedule.Id
        );
        Trace_Request__c otherRequest = new Trace_Request__c(
            Status__c = 'In Progress',
            Start_Date__c = DateTime.now().addHours(1),
            End_Date__c = DateTime.now().addHours(2),
            Traced_Entity_Id__c = UserInfo.getUserId(),
            Source__c = UserInfo.getOrganizationId(),
            Trace_Schedule__c = otherSchedule.Id
        );
        insert new List<Trace_Request__c>{request, otherRequest};

        // Create two trace results that will be deleted
        List<Trace_Result__c> traceResults = new List<Trace_Result__c>{
            new Trace_Result__c(
                Issue__c = issue.Id,
                Trace_Request__c = request.Id,
                Trace_Start_Date__c = DateTime.now().addHours(1),
                Trace_End_Date__c = DateTime.now().addHours(2)
            ),
            new Trace_Result__c(
                Issue__c = issue.Id,
                Trace_Request__c = otherRequest.Id,
                Trace_Start_Date__c = DateTime.now().addHours(1),
                Trace_End_Date__c = DateTime.now().addHours(2)
            )
        };
        insert traceResults;
        
        // Create test ContentVersion records for specific scenarios
        List<ContentVersion> versions = new List<ContentVersion>{
            // Doc 1: Will be linked to both Issue and Trace Result
            new ContentVersion(
                Title = 'Test Doc 1 - Issue and Trace',
                PathOnClient = 'test1.txt',
                VersionData = Blob.valueOf('Test Content 1'),
                IsMajorVersion = true
            ),
            // Doc 2: Will be linked only to Issue
            new ContentVersion(
                Title = 'Test Doc 2 - Issue Only',
                PathOnClient = 'test2.txt',
                VersionData = Blob.valueOf('Test Content 2'),
                IsMajorVersion = true
            ),
            // Doc 3: Will be linked to other Issue (control)
            new ContentVersion(
                Title = 'Test Doc 3 - Other Issue',
                PathOnClient = 'test3.txt',
                VersionData = Blob.valueOf('Test Content 3'),
                IsMajorVersion = true
            )
        };
        insert versions;
        
        List<ContentVersion> insertedVersions = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :versions
            ALL ROWS
        ];
        
        // Create ContentDocumentLinks for each scenario
        List<ContentDocumentLink> links = new List<ContentDocumentLink>{
            // Scenario 1: Doc linked to both Issue and Trace Result
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[0].ContentDocumentId,
                LinkedEntityId = issue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[0].ContentDocumentId,
                LinkedEntityId = traceResults[0].Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            
            // Scenario 2: Doc linked only to Issue
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[1].ContentDocumentId,
                LinkedEntityId = issue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            
            // Scenario 3: Doc linked to other Issue (should not be affected)
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[2].ContentDocumentId,
                LinkedEntityId = otherIssue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            )
        };
        insert links;
        
        return new TestData(issue, otherIssue, traceResults, insertedVersions);
    }
    
    private class TestData {
        public Issue__c issue;
        public Issue__c otherIssue;
        public List<Trace_Result__c> traceResults;
        public List<ContentVersion> contentVersions;
        
        public TestData(Issue__c issue, Issue__c otherIssue, List<Trace_Result__c> traceResults, List<ContentVersion> contentVersions) {
            this.issue = issue;
            this.otherIssue = otherIssue;
            this.traceResults = traceResults;
            this.contentVersions = contentVersions;
        }
    }
    
    @IsTest
    static void testBatchExecution() {
        TestData testData = createTestData();
        
        // Get initial state of ContentDocuments and their links
        Set<Id> contentDocumentIdsBefore = new Set<Id>();
        for(ContentVersion cv : testData.contentVersions) {
            contentDocumentIdsBefore.add(cv.ContentDocumentId);
        }
        
        Test.startTest();
        // Delete Trace Results to trigger the batch
        delete testData.traceResults;
        Test.stopTest();
        
        // Verify results
        Set<Id> remainingDocIds = new Set<Id>();
        
        for(ContentDocumentLink cdl : [
            SELECT LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN :contentDocumentIdsBefore
        ]) {
            if(cdl.LinkedEntityId == testData.otherIssue.Id || cdl.LinkedEntityId == testData.traceResults[1].Id) {
                remainingDocIds.add(cdl.ContentDocumentId);
            }
        }
        Set<Id> remainingCVIds = new Set<Id>();
        for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :testData.contentVersions]) {
            remainingCVIds.add(cv.Id);
        }
        
        // Doc 1: Should be deleted as it has links to both Issue and Trace Result, link to trace result is deleted by trigger
        System.assert(!remainingDocIds.contains(testData.contentVersions[0].ContentDocumentId), 
            'Doc 1 should be deleted as it has links to both Issue and Trace Result');
        System.assert(!remainingCVIds.contains(testData.contentVersions[0].Id), 
            'Doc 1 should be deleted as it has links to both Issue and Trace Result');
            
        // Doc 2: Should be deleted as it's only linked to the affected Issue, link to trace result is deleted as well
        System.assert(!remainingDocIds.contains(testData.contentVersions[1].ContentDocumentId), 
            'Doc 2 should be deleted as it only has Issue link');
        System.assert(!remainingCVIds.contains(testData.contentVersions[1].Id), 
            'Doc 2 should be deleted as it only has Issue link');
            
        // Doc 3: Should remain as it's linked to unaffected Issue
        System.assert(remainingDocIds.contains(testData.contentVersions[2].ContentDocumentId), 
            'Doc 3 should remain as it is linked to unaffected Issue');
        System.assert(remainingCVIds.contains(testData.contentVersions[2].Id), 
            'Doc 3 should remain as it is linked to unaffected Issue');
    }
    
    @IsTest
    static void testBatchWithNoDeletedRecords() {
        // Create test data
        createTestData();
        
        Test.startTest();
        // Set future timestamp and verify no records are processed
        DateTime futureTime = DateTime.now().addDays(1);
        TraceResultBatch.putLastDeleteTraceResultBatchTimeStamp(futureTime);
        Integer count = TraceResultBatch.getLastDeleteTraceResultBatchCount(futureTime);
        Test.stopTest();
        
        System.assertEquals(0, count, 'No deleted records should be found for future timestamp');
    }
    
    @IsTest
    static void testBatchWithNullTimestamp() {
        // Create test data
        TestData testData = createTestData();
        
        Test.startTest();
        // Delete records but with null timestamp
        TraceResultBatch.putLastDeleteTraceResultBatchTimeStamp(null);
        delete new List<Trace_Result__c>{testData.traceResults[0], testData.traceResults[1]};
        Test.stopTest();
        
        // Verify all documents still exist
        List<ContentDocument> remainingDocs = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :testData.contentVersions)
            ALL ROWS
        ];
        
        System.assertEquals(testData.contentVersions.size(), remainingDocs.size(), 
            'All ContentDocument records should remain when timestamp is null');
    }
    
    @IsTest
    static void testGetLastDeleteTraceResultBatchCount() {
        // Create test data
        TestData testData = createTestData();
        
        Test.startTest();
        // Delete records and verify count
        delete new List<Trace_Result__c>{testData.traceResults[0], testData.traceResults[1]};
        Integer count = TraceResultBatch.getLastDeleteTraceResultBatchCount(DateTime.now().addMinutes(-5));
        Test.stopTest();
        
        System.assertEquals(2, count, 'Should return correct count of deleted records after timestamp');
    }
    
    @IsTest
    static void testTimestampCacheOperations() {
        Test.startTest();
        DateTime testTimestamp = DateTime.now();
        TraceResultBatch.putLastDeleteTraceResultBatchTimeStamp(testTimestamp);
        DateTime retrievedTimestamp = TraceResultBatch.getLastDeleteTraceResultBatchTimeStamp();
        Test.stopTest();
        
        System.assertEquals(testTimestamp, retrievedTimestamp, 'Retrieved timestamp should match stored timestamp');
        
        TraceResultBatch.putLastDeleteTraceResultBatchTimeStamp(null);
        System.assertEquals(null, TraceResultBatch.getLastDeleteTraceResultBatchTimeStamp(), 
            'Null timestamp should be handled correctly');
    }
    
    @IsTest
    static void testDocumentDeletionEdgeCases() {
        // Create base data
        Issue__c issue = new Issue__c(Status__c = 'New');
        Issue__c otherIssue = new Issue__c(Status__c = 'New');
        insert new List<Issue__c>{issue, otherIssue};
        
        // Create some other records for additional links
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'Test Contact');
        insert testContact;

        Trace_Schedule__c schedule = new Trace_Schedule__c(Issue__c = issue.Id);
        insert schedule;
        Trace_Request__c request = new Trace_Request__c(
            Status__c = 'In Progress',
            Start_Date__c = DateTime.now().addHours(1),
            End_Date__c = DateTime.now().addHours(2),
            Traced_Entity_Id__c = UserInfo.getUserId(),
            Source__c = UserInfo.getOrganizationId(),
            Trace_Schedule__c = schedule.Id
        );
        insert request;
        
        // Create trace result that will be deleted
        Trace_Result__c traceResult = new Trace_Result__c(
            Issue__c = issue.Id,
            Trace_Request__c = request.Id,
            Trace_Start_Date__c = DateTime.now().addHours(1),
            Trace_End_Date__c = DateTime.now().addHours(2)
        );
        insert traceResult;
        
        // Create ContentVersion records for different edge cases
        List<ContentVersion> versions = new List<ContentVersion>{
            // Case 1: Document linked only to the Issue
            new ContentVersion(
                Title = 'Edge Case 1 - Issue Only',
                PathOnClient = 'edge1.txt',
                VersionData = Blob.valueOf('Test Content Edge 1'),
                IsMajorVersion = true
            ),
            // Case 2: Document linked to Issue and other unrelated object
            new ContentVersion(
                Title = 'Edge Case 2 - Issue and Account',
                PathOnClient = 'edge2.txt',
                VersionData = Blob.valueOf('Test Content Edge 2'),
                IsMajorVersion = true
            ),
            // Case 3: Document linked to Issue, Account, and Contact
            new ContentVersion(
                Title = 'Edge Case 3 - Issue and Multiple Others',
                PathOnClient = 'edge3.txt',
                VersionData = Blob.valueOf('Test Content Edge 3'),
                IsMajorVersion = true
            ),
            // Case 4: Document linked to Issue and Other Issue
            new ContentVersion(
                Title = 'Edge Case 4 - Multiple Issues',
                PathOnClient = 'edge4.txt',
                VersionData = Blob.valueOf('Test Content Edge 4'),
                IsMajorVersion = true
            ),
            // Case 5: Document linked to other objects only (control)
            new ContentVersion(
                Title = 'Edge Case 5 - No Issue Link',
                PathOnClient = 'edge5.txt',
                VersionData = Blob.valueOf('Test Content Edge 5'),
                IsMajorVersion = true
            )
        };
        insert versions;
        
        List<ContentVersion> insertedVersions = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :versions
        ];
        
        // Create ContentDocumentLinks for each edge case
        List<ContentDocumentLink> links = new List<ContentDocumentLink>{
            // Case 1: Only linked to the Issue
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[0].ContentDocumentId,
                LinkedEntityId = issue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            
            // Case 2: Linked to Issue and Account
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[1].ContentDocumentId,
                LinkedEntityId = issue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[1].ContentDocumentId,
                LinkedEntityId = testAccount.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            
            // Case 3: Linked to Issue, Account, and Contact
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[2].ContentDocumentId,
                LinkedEntityId = issue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[2].ContentDocumentId,
                LinkedEntityId = testAccount.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[2].ContentDocumentId,
                LinkedEntityId = testContact.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            
            // Case 4: Linked to both Issues
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[3].ContentDocumentId,
                LinkedEntityId = issue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[3].ContentDocumentId,
                LinkedEntityId = otherIssue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            
            // Case 5: Linked to other objects only
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[4].ContentDocumentId,
                LinkedEntityId = testAccount.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = insertedVersions[4].ContentDocumentId,
                LinkedEntityId = testContact.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            )
        };
        insert links;
        
        // Store ContentDocument IDs for later verification
        Set<Id> contentDocIds = new Set<Id>();
        for(ContentVersion cv : insertedVersions) {
            contentDocIds.add(cv.ContentDocumentId);
        }
        
        Test.startTest();
        // Set the timestamp and delete the trace result
        delete traceResult;
        Test.stopTest();
        
        // Query remaining documents
        Map<Id, ContentDocument> remainingDocs = new Map<Id, ContentDocument>([
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN :contentDocIds
        ]);
        
        // Verify Case 1: Document linked only to Issue should be DELETED
        System.assert(!remainingDocs.containsKey(insertedVersions[0].ContentDocumentId),
            'Case 1: Document linked only to Issue should be deleted');
            
        // Verify Case 2: Document linked to Issue and Account should be DELETED
        // because it's linked to the affected Issue and no Trace_Result__c
        System.assert(!remainingDocs.containsKey(insertedVersions[1].ContentDocumentId),
            'Case 2: Document linked to Issue and Account should be deleted');
            
        // Verify Case 3: Document linked to Issue, Account, Contact should be DELETED
        // because it's linked to the affected Issue and no Trace_Result__c
        System.assert(!remainingDocs.containsKey(insertedVersions[2].ContentDocumentId),
            'Case 3: Document linked to Issue and multiple other objects should be deleted');
            
        // Verify Case 4: Document linked to both Issues should be DELETED
        // because it's linked to affected Issue and no Trace_Result__c
        System.assert(!remainingDocs.containsKey(insertedVersions[3].ContentDocumentId),
            'Case 4: Document linked to multiple Issues should be deleted');
            
        // Verify Case 5: Document linked to other objects only should REMAIN
        System.assert(remainingDocs.containsKey(insertedVersions[4].ContentDocumentId),
            'Case 5: Document not linked to any Issue should remain');
    }
    
    @IsTest
    static void testHighVolumeContent() {
        // Create test data structure
        Issue__c issue = new Issue__c(Status__c = 'New');
        insert issue;
        
        // Create Trace Schedule and Request
        Trace_Schedule__c schedule = new Trace_Schedule__c(Issue__c = issue.Id);
        insert schedule;
        
        Trace_Request__c request = new Trace_Request__c(
            Status__c = 'In Progress',
            Start_Date__c = DateTime.now().addHours(1),
            End_Date__c = DateTime.now().addHours(2),
            Traced_Entity_Id__c = UserInfo.getUserId(),
            Source__c = UserInfo.getOrganizationId(),
            Trace_Schedule__c = schedule.Id
        );
        insert request;
        
        // Create trace result that will be deleted
        Trace_Result__c traceResult = new Trace_Result__c(
            Issue__c = issue.Id,
            Trace_Request__c = request.Id,
            Trace_Start_Date__c = DateTime.now().addHours(1),
            Trace_End_Date__c = DateTime.now().addHours(2)
        );
        insert traceResult;
        
        Integer contentVersionCount = 200; 
        
        // Create ContentVersion records in bulk
        List<ContentVersion> versions = new List<ContentVersion>();
        for(Integer i = 0; i < contentVersionCount; i++) {
            ContentVersion cv = new ContentVersion(
                Title = 'High Volume Doc ' + i,
                PathOnClient = 'highvolume_' + i + '.txt',
                VersionData = Blob.valueOf('Test Content for High Volume ' + i),
                IsMajorVersion = true
            );
            versions.add(cv);
        }
        insert versions;
        
        // Query for ContentDocumentIds
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([
            SELECT Id, ContentDocumentId, Title 
            FROM ContentVersion 
            WHERE Id IN :versions
        ]);
        
        // Create ContentDocumentLinks for each ContentVersion
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for(ContentVersion cv : contentVersionMap.values()) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = issue.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            links.add(cdl);
        }
        insert links;
        
        // Store ContentDocument IDs for verification
        Set<Id> contentDocIds = new Set<Id>();
        for(ContentVersion cv : contentVersionMap.values()) {
            contentDocIds.add(cv.ContentDocumentId);
        }
        
        // Count documents before deletion
        Integer docCountBefore = [SELECT COUNT() FROM ContentDocument WHERE Id IN :contentDocIds];
        System.assertEquals(contentVersionCount, docCountBefore, 'Should have correct number of documents before deletion');
        
        Test.startTest();
        // Delete the trace result - should trigger batch process
        delete traceResult;
        Test.stopTest();
        
        // Verify document deletion
        Integer docCountAfter = [SELECT COUNT() FROM ContentDocument WHERE Id IN :contentDocIds];
        System.assertEquals(0, docCountAfter, 'All documents should be deleted after batch execution');

    }
}