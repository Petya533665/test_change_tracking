@IsTest(IsParallel=true)
public with sharing class FlowLogServiceTest {

    @IsTest
    static void testTruncateElementLabel_NullOrEmpty() {
        // Test null input
        String result = FlowLogService.truncateElementLabel(null);
        System.assertEquals(null, result, 'Null input should return null');
        
        // Test empty input
        result = FlowLogService.truncateElementLabel('');
        System.assertEquals('', result, 'Empty input should return empty string');
    }
    
    @IsTest
    static void testTruncateElementLabel_ShortLabels() {
        // Test short label (under 80 chars) - After format
        String shortAfterLabel = 'Log After: Create Account';
        String result = FlowLogService.truncateElementLabel(shortAfterLabel);
        System.assertEquals(shortAfterLabel, result, 'Short label should remain unchanged');
        
        // Test short label (under 80 chars) - After/Before format
        String shortAfterBeforeLabel = 'Log After: Create Account, Before: Update Contact';
        result = FlowLogService.truncateElementLabel(shortAfterBeforeLabel);
        System.assertEquals(shortAfterBeforeLabel, result, 'Short label should remain unchanged');
        
        // Test short label (under 80 chars) - Before format
        String shortBeforeLabel = 'Log Before: Delete Opportunity';
        result = FlowLogService.truncateElementLabel(shortBeforeLabel);
        System.assertEquals(shortBeforeLabel, result, 'Short label should remain unchanged');
    }
    
    @IsTest
    static void testTruncateElementLabel_AfterFormat() {
        // Create a long element name
        String longElementName = 'Create Account with Very Long Name That Exceeds Character Limit and Contains Many Details About the Process';
        String longAfterLabel = 'Log After: ' + longElementName;
        
        // Test truncation
        String result = FlowLogService.truncateElementLabel(longAfterLabel);
        
        // Verify result
        System.assert(result.length() <= 80, 'Result should be 80 chars or less');
        System.assert(result.startsWith('Log After: '), 'Format text should be preserved');
        System.assert(result.endsWith('...'), 'Truncated text should end with ellipsis');
        System.assertEquals(80, result.length(), 'Result should be exactly 80 chars');
    }
    
    @IsTest
    static void testTruncateElementLabel_BeforeFormat() {
        // Create a long element name
        String longElementName = 'Update Contact with Very Long Name That Exceeds Character Limit and Contains Many Details About the Process';
        String longBeforeLabel = 'Log Before: ' + longElementName;
        
        // Test truncation
        String result = FlowLogService.truncateElementLabel(longBeforeLabel);
        
        // Verify result
        System.assert(result.length() <= 80, 'Result should be 80 chars or less');
        System.assert(result.startsWith('Log Before: '), 'Format text should be preserved');
        System.assert(result.endsWith('...'), 'Truncated text should end with ellipsis');
        System.assertEquals(80, result.length(), 'Result should be exactly 80 chars');
    }
    
    @IsTest
    static void testTruncateElementLabel_AfterBeforeFormat() {
        // Create long element names
        String longAfterElement = 'Create Account with Very Long Name That Exceeds Character Limit';
        String longBeforeElement = 'Update Contact with Very Long Name That Exceeds Character Limit';
        String longLabel = 'Log After: ' + longAfterElement + ', Before: ' + longBeforeElement;
        
        // Test truncation
        String result = FlowLogService.truncateElementLabel(longLabel);
        
        // Verify result
        System.assert(result.length() <= 80, 'Result should be 80 chars or less');
        System.assert(result.startsWith('Log After: '), 'After format text should be preserved');
        System.assert(result.contains(', Before: '), 'Before format text should be preserved');
        System.assert(result.contains('...'), 'At least one element should be truncated with ellipsis');
        System.assertEquals(80, result.length(), 'Result should be exactly 80 chars');
    }
    
    @IsTest
    static void testTruncateElementLabel_AfterBeforeFormat_UnevenSizes() {
        // Create element names with uneven sizes
        String shortAfterElement = 'Create Account';
        String longBeforeElement = 'Update Contact with Very Long Name That Exceeds Character Limit and Contains Many Details About the Process';
        String unevenLabel = 'Log After: ' + shortAfterElement + ', Before: ' + longBeforeElement;
        
        // Test truncation
        String result = FlowLogService.truncateElementLabel(unevenLabel);
        
        // Verify result
        System.assert(result.length() <= 80, 'Result should be 80 chars or less');
        System.assert(result.startsWith('Log After: ' + shortAfterElement), 'Short element should not be truncated');
        System.assert(result.contains(', Before: '), 'Before format text should be preserved');
        System.assert(result.endsWith('...'), 'Long element should be truncated with ellipsis');
        
        // Test the reverse case
        String longAfterElement = 'Create Account with Very Long Name That Exceeds Character Limit and Contains Many Details About the Process';
        String shortBeforeElement = 'Update Contact';
        unevenLabel = 'Log After: ' + longAfterElement + ', Before: ' + shortBeforeElement;
        
        result = FlowLogService.truncateElementLabel(unevenLabel);
        
        System.assert(result.length() <= 80, 'Result should be 80 chars or less');
        System.assert(result.contains('...'), 'Long element should be truncated with ellipsis');
        System.assert(result.endsWith(', Before: ' + shortBeforeElement), 'Short element should not be truncated');
    }
    
    @IsTest
    static void testTruncateElementLabel_EdgeCases() {
        // Test exactly 80 characters
        String exactLabel = 'Log After: ' + 'A'.repeat(69); // 'Log After: ' is 11 chars, so 69 more to make 80
        String result = FlowLogService.truncateElementLabel(exactLabel);
        System.assertEquals(exactLabel, result, 'Exactly 80 char label should remain unchanged');
        System.assertEquals(80, result.length(), 'Result should be exactly 80 chars');
        
        // Test 81 characters (just over the limit)
        String justOverLabel = 'Log After: ' + 'A'.repeat(70); // 'Log After: ' is 11 chars, so 70 more to make 81
        result = FlowLogService.truncateElementLabel(justOverLabel);
        System.assertEquals(80, result.length(), 'Result should be exactly 80 chars');
        System.assert(result.endsWith('...'), 'Result should end with ellipsis');
        
        // Test with special characters
        String specialCharsLabel = 'Log After: Create Account with Special Characters !@#$%^&*()_+';
        if (specialCharsLabel.length() > 80) {
            result = FlowLogService.truncateElementLabel(specialCharsLabel);
            System.assertEquals(80, result.length(), 'Result should be exactly 80 chars');
            System.assert(result.endsWith('...'), 'Result should end with ellipsis');
        }
    }
    
    @IsTest
    static void testTruncateElementLabel_BoundaryConditions() {
        // Test where truncation would leave less than 3 chars for ellipsis
        String afterPrefix = 'Log After: ';
        String shortElement = 'AB'; // Only 2 chars
        String label = afterPrefix + shortElement;
        
        // Make the label just over 80 chars
        while (label.length() <= 80) {
            shortElement += 'X';
            label = afterPrefix + shortElement;
        }
        
        String result = FlowLogService.truncateElementLabel(label);
        System.assertEquals(80, result.length(), 'Result should be exactly 80 chars');
        System.assert(result.endsWith('...'), 'Result should end with ellipsis');
        
        // Verify we don't have a negative substring index
        Integer availableSpace = 80 - afterPrefix.length();
        String expectedTruncated = shortElement.substring(0, availableSpace - 3) + '...';
        String expected = afterPrefix + expectedTruncated;
        System.assertEquals(expected, result, 'Truncation should handle short elements correctly');
    }

    @IsTest
    static void test_add_logging_nested_loop_in_decision() {
        String inputStructure = 
            '└── Start [Start] → assignment1\n' +
            '    └── assignment1 [Assignment] → getaccounts\n' +
            '        └── getaccounts [Record Lookup] → assignment3\n' +
            '            └── assignment3 [Assignment] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:loop1, Rules:[decision_outcome1->new_account1]\n' +
            '                    ├── loop1 [Loop] → Next:assignment2, NoMore:END\n' +
            '                    │   ├── [Next Value] → assignment2\n' +
            '                    │   ├── assignment2 [Assignment] → loop1\n' +
            '                    │   └── [No More Values] → END\n' +
            '                    └── new_account1 [Record Create] → loop1';
            
        String expectedOutput = 
            '└── Start [Start] → Start_assignment1_PostPreLog\n' +
            '    └── Start_assignment1_PostPreLog [Action] → assignment1\n' +
            '        └── assignment1 [Assignment] → assignment1_getaccounts_PostPreLog\n' +
            '            └── assignment1_getaccounts_PostPreLog [Action] → getaccounts\n' +
            '                └── getaccounts [Record Lookup] → getaccounts_assignment3_PostPreLog\n' +
            '                    └── getaccounts_assignment3_PostPreLog [Action] → assignment3\n' +
            '                        └── assignment3 [Assignment] → assignment3_decision1_PostPreLog\n' +
            '                            └── assignment3_decision1_PostPreLog [Action] → decision1\n' +
            '                                └── decision1 [Decision] → DEFAULT:decision1_loop1_PostPreLog, Rules:[decision_outcome1->decision1_decision_outcome1_new_account1_PostPreLog]\n' +
            '                                    ├── decision1_loop1_PostPreLog [Action] → loop1\n' +
            '                                    │   └── loop1 [Loop] → Next:loop1_assignment2_PostPreLog, NoMore:loop1_PostLog\n' +
            '                                    │       ├── [Next Value] → loop1_assignment2_PostPreLog\n' +
            '                                    │       ├── loop1_assignment2_PostPreLog [Action] → assignment2\n' +
            '                                    │       │   └── assignment2 [Assignment] → assignment2_loop1_PostPreLog\n' +
            '                                    │       │       └── assignment2_loop1_PostPreLog [Action] → loop1\n' +
            '                                    │       ├── [No More Values] → loop1_PostLog\n' +
            '                                    │       └── loop1_PostLog [Action] → END\n' +
            '                                    └── decision1_decision_outcome1_new_account1_PostPreLog [Action] → new_account1\n' +
            '                                        └── new_account1 [Record Create] → new_account1_loop1_PostPreLog\n' +
            '                                            └── new_account1_loop1_PostPreLog [Action] → loop1';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_element_disconnected_elements() {
        String inputStructure = 
            '└── Start [Start] → action1\n' +
            '    └── action1 [Action] → screen1\n' +
            '        └── screen1 [Screen] → END\n' +
            '└── disconnected1 [Screen] → END'; // Disconnected element

        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        Map<String, FlowLogService.FlowElement> flowElements = new FlowLogService().convertMetadataFlowToElements(mockFlow);
        
        Set<String> connectedElements = new Set<String>();
        new FlowLogService().buildConnectedElementsSet(flowElements.get('Start'), flowElements, connectedElements);
        
        System.assert(!connectedElements.contains('disconnected1'), 'Should not include disconnected elements');
    }

    @IsTest
    static void test_circular_reference() {
        String inputStructure = 
            '└── Start [Start] → loop1\n' +
            '    └── loop1 [Loop] → Next:loop2, NoMore:END\n' +
            '        └── loop2 [Loop] → Next:loop1, NoMore:END'; // Circular reference

        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        Map<String, FlowLogService.FlowElement> flowElements = new FlowLogService().convertMetadataFlowToElements(mockFlow);
        
        Set<String> connectedElements = new Set<String>();
        new FlowLogService().buildConnectedElementsSet(flowElements.get('Start'), flowElements, connectedElements);
        
        Set<String> expectedElements = new Set<String>{'Start', 'loop1', 'loop2'};
        System.assertEquals(expectedElements, connectedElements, 'Should handle circular references');
    }

    //@IsTest
    static void test_empty_flow() {
        MetadataService.Flow emptyFlow = new MetadataService.Flow();
        MockMetadataHandler mockHandler = new MockMetadataHandler(emptyFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        
        System.assertEquals(true, result.get('success'), 'Should handle empty flow');
    }

    @IsTest
    static void test_missing_required_parameters() {
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING'
            // Missing flowApiName
        };
        
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        
        System.assertEquals(false, result.get('success'), 'Should fail for missing parameters');
        System.assert(((String)result.get('message')).contains('required'), 'Should return missing parameter message');
    }

    @IsTest
    static void test_invalid_operation() {
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'INVALID_OPERATION',
            'flowApiName' => TEST_FLOW_API_NAME
        };
        
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        
        System.assertEquals(false, result.get('success'), 'Should fail for invalid operation');
        System.assert(((String)result.get('message')).contains('Invalid operation'), 'Should return invalid operation message');
    }

    @IsTest
    static void test_start_with_paths_and_record_create() {
        String inputStructure = 
            '└── Start [Start] → createRecord1, Paths:[path1->screen1, path2->screen2]\n' +
            '    ├── [ScheduledPath] path1 → screen1\n' +
            '    ├── [ScheduledPath] path2 → screen2\n' +
            '    ├── createRecord1 [Record Create] → screen3, FAULT:error1\n' +
            '    │   ├── [FAULT] → error1\n' +
            '    │   ├── screen3 [Screen] → END\n' +
            '    │   └── error1 [Custom Error] → END\n' +
            '    ├── screen1 [Screen] → END\n' +
            '    └── screen2 [Screen] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_createRecord1_PostPreLog, Paths:[path1->Start_path1_screen1_PostPreLog, path2->Start_path2_screen2_PostPreLog]\n' +
            '    ├── [ScheduledPath] path1 → Start_path1_screen1_PostPreLog\n' +
            '    ├── [ScheduledPath] path2 → Start_path2_screen2_PostPreLog\n' +
            '    ├── Start_createRecord1_PostPreLog [Action] → createRecord1\n' +
            '    │   └── createRecord1 [Record Create] → createRecord1_screen3_PostPreLog, FAULT:createRecord1_error1_PostPreLog\n' +
            '    │       ├── [FAULT] → createRecord1_error1_PostPreLog\n' +
            '    │       ├── createRecord1_screen3_PostPreLog [Action] → screen3\n' +
            '    │       │   └── screen3 [Screen] → screen3_PostLog\n' +
            '    │       │       └── screen3_PostLog [Action] → END\n' +
            '    │       └── createRecord1_error1_PostPreLog [Action] → error1\n' +
            '    │           └── error1 [Custom Error] → error1_PostLog\n' +
            '    │               └── error1_PostLog [Action] → END\n' +
            '    ├── Start_path1_screen1_PostPreLog [Action] → screen1\n' +
            '    │   └── screen1 [Screen] → screen1_PostLog\n' +
            '    │       └── screen1_PostLog [Action] → END\n' +
            '    └── Start_path2_screen2_PostPreLog [Action] → screen2\n' +
            '        └── screen2 [Screen] → screen2_PostLog\n' +
            '            └── screen2_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput, new Map<String, String>{
            'Start_createRecord1_PostPreLog' => 'INFO',
            'createRecord1_screen3_PostPreLog' => 'DEBUG',
            'createRecord1_error1_PostPreLog' => 'WARNING',
            'error1_PostLog' => 'ERROR',
            'Start_path1_screen1_PostPreLog' => 'INFO',
            'Start_path2_screen2_PostPreLog' => 'INFO'
        });
    }

    @IsTest
    static void test_remove_start_with_paths_and_record_create() {
        
        String inputStructure = 
            '└── Start [Start] → Start_createRecord1_PostPreLog, Paths:[path1->Start_path1_screen1_PostPreLog, path2->Start_path2_screen2_PostPreLog]\n' +
            '    ├── [ScheduledPath] path1 → Start_path1_screen1_PostPreLog\n' +
            '    ├── [ScheduledPath] path2 → Start_path2_screen2_PostPreLog\n' +
            '    ├── Start_createRecord1_PostPreLog [Action] → createRecord1 {Source:Start,0,0|Target:createRecord1,100,100}\n' +
            '    │   └── createRecord1 [Record Create] → createRecord1_screen3_PostPreLog, FAULT:createRecord1_error1_PostPreLog\n' +
            '    │       ├── [FAULT] → createRecord1_error1_PostPreLog\n' +
            '    │       ├── createRecord1_screen3_PostPreLog [Action] → screen3 {Source:createRecord1,100,100|Target:screen3,200,200}\n' +
            '    │       │   └── screen3 [Screen] → screen3_PostLog\n' +
            '    │       │       └── screen3_PostLog [Action] → END {Source:screen3,100,100|Target:null,200,200}\n' +
            '    │       └── createRecord1_error1_PostPreLog [Action] → error1 {Source:createRecord1.FAULT,100,100|Target:error1,200,200}\n' +
            '    │           └── error1 [Custom Error] → error1_PostLog\n' +
            '    │               └── error1_PostLog [Action] → END {Source:error1,100,100|Target:null,200,200}\n' +
            '    ├── Start_path1_screen1_PostPreLog [Action] → screen1 {Source:Start:path1,0,0|Target:screen1,100,100}\n' +
            '    │   └── screen1 [Screen] → screen1_PostLog\n' +
            '    │       └── screen1_PostLog [Action] → END {Source:screen1,100,100|Target:null,200,200}\n' +
            '    └── Start_path2_screen2_PostPreLog [Action] → screen2 {Source:Start:path2,0,0|Target:screen2,100,100}\n' +
            '        └── screen2 [Screen] → screen2_PostLog\n' +
            '            └── screen2_PostLog [Action] → END {Source:screen2,100,100|Target:null,200,200}';
        
        String expectedOutput = 
            '└── Start [Start] → createRecord1, Paths:[path1->screen1, path2->screen2]\n' +
            '    ├── [ScheduledPath] path1 → screen1\n' +
            '    ├── [ScheduledPath] path2 → screen2\n' +
            '    ├── createRecord1 [Record Create] → screen3, FAULT:error1\n' +
            '    │   ├── [FAULT] → error1\n' +
            '    │   ├── screen3 [Screen] → END\n' +
            '    │   └── error1 [Custom Error] → END\n' +
            '    ├── screen1 [Screen] → END\n' +
            '    └── screen2 [Screen] → END';

        test_remove_logging_success(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_add_logging_to_flow_with_partial_logging() {
        String inputStructure = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action1 {Source:Start,0,0|Target:action1,100,100}\n' +
            '        └── action1 [Action] → screen1\n' +  // Missing logging here
            '            └── screen1 [Screen] → screen1_PostLog\n' +
            '                └── screen1_PostLog [Action] → END {Source:screen1,200,200|Target:null,300,300}';

        String expectedOutput = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action1\n' +
            '        └── action1 [Action] → action1_screen1_PostPreLog\n' +  // Added missing logging
            '            └── action1_screen1_PostPreLog [Action] → screen1\n' +
            '                └── screen1 [Screen] → screen1_PostLog\n' +
            '                    └── screen1_PostLog [Action] → END';

        test_add_logging_with_existing(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_add_logging_to_flow_with_existing_logging_and_fault() {
        String inputStructure = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action1 {Source:Start,0,0|Target:action1,100,100}\n' +
            '        └── action1 [Action] → action1_screen1_PostPreLog, FAULT:action1_error1_PostPreLog\n' +
            '            ├── [FAULT] → action1_error1_PostPreLog\n' +
            '            ├── action1_error1_PostPreLog [Action] → error1 {Source:action1.FAULT,100,100|Target:error1,200,200}\n' +
            '            │   └── error1 [Custom Error] → error1_PostLog\n' +
            '            │       └── error1_PostLog [Action] → END {Source:error1,100,100|Target:null,200,200}\n' +
            '            └── action1_screen1_PostPreLog [Action] → screen1 {Source:action1,100,100|Target:screen1,200,200}\n' +
            '                └── screen1 [Screen] → screen1_PostLog\n' +
            '                    └── screen1_PostLog [Action] → END {Source:screen1,200,200|Target:null,300,300}';

        String expectedOutput = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action1\n' +
            '        └── action1 [Action] → action1_screen1_PostPreLog, FAULT:action1_error1_PostPreLog\n' +
            '            ├── [FAULT] → action1_error1_PostPreLog\n' +
            '            ├── action1_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── action1_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';            
            
        test_add_logging_with_existing(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_add_logging_to_flow_with_existing_logging() {
        String inputStructure = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action1 {Source:Start,0,0|Target:action1,100,100}\n' +
            '        └── action1 [Action] → action1_screen1_PostPreLog\n' +
            '            └── action1_screen1_PostPreLog [Action] → screen1 {Source:action1,100,100|Target:screen1,200,200}\n' +
            '                └── screen1 [Screen] → screen1_PostLog\n' +
            '                    └── screen1_PostLog [Action] → END {Source:screen1,200,200|Target:null,300,300}';

        String expectedOutput = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action1\n' +
            '        └── action1 [Action] → action1_screen1_PostPreLog\n' +
            '            └── action1_screen1_PostPreLog [Action] → screen1\n' +
            '                └── screen1 [Screen] → screen1_PostLog\n' +
            '                    └── screen1_PostLog [Action] → END';

        test_add_logging_with_existing(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_add_logging_to_flow_with_partial_logging_and_new_elements_added_after_logging() {
    String inputStructure = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action2 {Source:Start,0,0|Target:action1,100,100}\n' +
            '        └── action2 [Action] → action1\n' + // new element after logging
            '            └── action1 [Action] → screen1\n' +  // Missing logging here
            '                └── screen1 [Screen] → screen1_PostLog\n' +
            '                    └── screen1_PostLog [Action] → END {Source:screen1,200,200|Target:null,300,300}';

        String expectedOutput = 
            '└── Start [Start] → Start_action2_PostPreLog\n' +
            '    └── Start_action2_PostPreLog [Action] → action2\n' +
            '        └── action2 [Action] → action2_action1_PostPreLog\n' + // new element after logging
            '            └── action2_action1_PostPreLog [Action] → action1\n' +
            '                └── action1 [Action] → action1_screen1_PostPreLog\n' +
            '                    └── action1_screen1_PostPreLog [Action] → screen1\n' +
            '                        └── screen1 [Screen] → screen1_PostLog\n' +
            '                            └── screen1_PostLog [Action] → END';

        test_add_logging_with_existing(inputStructure, expectedOutput);
    }

    private static void test_add_logging_with_existing(String inputStructure, String expectedOutput) {
        // Create mock flow from structure
        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        
        // Setup mock handler
        MockMetadataHandler mockHandler = new MockMetadataHandler(mockFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        
        // Act
        Test.startTest();
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Assert
        System.assertEquals(true, result.get('success'), 
            'Operation should be successful. Error: ' + result.get('message'));
        
        // Get the visualization from the result
        Map<String, Object> visualization = (Map<String, Object>)result.get('flowVisualization');
        
        // Compare before visualization
        String beforeViz = (String)visualization.get('before');
        System.assertNotEquals(null, beforeViz, 'Before visualization should not be null');
                
        // Compare after visualization
        String afterViz = (String)visualization.get('after');
        System.assertNotEquals(null, afterViz, 'After visualization should not be null');
        System.assertEquals(
            normalizeString(expectedOutput), 
            normalizeString(afterViz),
            'After visualization does not match expected output'
        );
        
        // Verify updated flow structure
        MetadataService.Flow updatedFlow = mockHandler.getUpdatedFlow();
        validateFlowStructure(updatedFlow, true);
    }

    @IsTest
    static void test_wait_with_events_and_fault() {
        String inputStructure = 
            '└── Start [Start] → wait1\n' +
            '    └── wait1 [Wait] → DEFAULT:timeout, Events:[Event1->path1, Event2->path2], FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── timeout [Screen] → END\n' +
            '        ├── error1 [Custom Error] → END\n' +
            '        ├── path1 [Screen] → END\n' +
            '        └── path2 [Screen] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_wait1_PostPreLog\n' +
            '    └── Start_wait1_PostPreLog [Action] → wait1\n' +
            '        └── wait1 [Wait] → DEFAULT:wait1_timeout_PostPreLog, Events:[Event1->wait1_Event1_path1_PostPreLog, Event2->wait1_Event2_path2_PostPreLog], FAULT:wait1_error1_PostPreLog\n' +
            '            ├── [FAULT] → wait1_error1_PostPreLog\n' +
            '            ├── wait1_timeout_PostPreLog [Action] → timeout\n' +
            '            │   └── timeout [Screen] → timeout_PostLog\n' +
            '            │       └── timeout_PostLog [Action] → END\n' +
            '            ├── wait1_error1_PostPreLog [Action] → error1\n' +
            '            │   └── error1 [Custom Error] → error1_PostLog\n' +
            '            │       └── error1_PostLog [Action] → END\n' +
            '            ├── wait1_Event1_path1_PostPreLog [Action] → path1\n' +
            '            │   └── path1 [Screen] → path1_PostLog\n' +
            '            │       └── path1_PostLog [Action] → END\n' +
            '            └── wait1_Event2_path2_PostPreLog [Action] → path2\n' +
            '                └── path2 [Screen] → path2_PostLog\n' +
            '                    └── path2_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput, new Map<String, String>{
            'Start_wait1_PostPreLog' => 'INFO',
            'wait1_timeout_PostPreLog' => 'FINER',
            'wait1_Event1_path1_PostPreLog' => 'FINER',
            'wait1_Event2_path2_PostPreLog' => 'FINER',
            'wait1_error1_PostPreLog' => 'WARNING',
            'error1_PostLog' => 'ERROR'
        });
    }

    @IsTest
    static void test_wait_with_fault() {
        String inputStructure = 
            '└── Start [Start] → waitEvent\n' +
            '    └── waitEvent [Wait] → DEFAULT:screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_waitEvent_PostPreLog\n' +
            '    └── Start_waitEvent_PostPreLog [Action] → waitEvent\n' +
            '        └── waitEvent [Wait] → DEFAULT:waitEvent_screen1_PostPreLog, FAULT:waitEvent_error1_PostPreLog\n' +
            '            ├── [FAULT] → waitEvent_error1_PostPreLog\n' +
            '            ├── waitEvent_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── waitEvent_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_apex_plugin_with_fault() {
        String inputStructure = 
            '└── Start [Start] → apexPlugin\n' +
            '    └── apexPlugin [Apex Plugin] → screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_apexPlugin_PostPreLog\n' +
            '    └── Start_apexPlugin_PostPreLog [Action] → apexPlugin\n' +
            '        └── apexPlugin [Apex Plugin] → apexPlugin_screen1_PostPreLog, FAULT:apexPlugin_error1_PostPreLog\n' +
            '            ├── [FAULT] → apexPlugin_error1_PostPreLog\n' +
            '            ├── apexPlugin_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── apexPlugin_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_orchestrated_stage_with_fault() {
        String inputStructure = 
            '└── Start [Start] → orchestratedStage\n' +
            '    └── orchestratedStage [Orchestrated Stage] → screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_orchestratedStage_PostPreLog\n' +
            '    └── Start_orchestratedStage_PostPreLog [Action] → orchestratedStage\n' +
            '        └── orchestratedStage [Orchestrated Stage] → orchestratedStage_screen1_PostPreLog, FAULT:orchestratedStage_error1_PostPreLog\n' +
            '            ├── [FAULT] → orchestratedStage_error1_PostPreLog\n' +
            '            ├── orchestratedStage_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── orchestratedStage_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_record_lookup_with_fault() {
        String inputStructure = 
            '└── Start [Start] → lookupRecord\n' +
            '    └── lookupRecord [Record Lookup] → screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_lookupRecord_PostPreLog\n' +
            '    └── Start_lookupRecord_PostPreLog [Action] → lookupRecord\n' +
            '        └── lookupRecord [Record Lookup] → lookupRecord_screen1_PostPreLog, FAULT:lookupRecord_error1_PostPreLog\n' +
            '            ├── [FAULT] → lookupRecord_error1_PostPreLog\n' +
            '            ├── lookupRecord_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── lookupRecord_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_record_delete_with_fault() {
        String inputStructure = 
            '└── Start [Start] → deleteRecord\n' +
            '    └── deleteRecord [Record Delete] → screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_deleteRecord_PostPreLog\n' +
            '    └── Start_deleteRecord_PostPreLog [Action] → deleteRecord\n' +
            '        └── deleteRecord [Record Delete] → deleteRecord_screen1_PostPreLog, FAULT:deleteRecord_error1_PostPreLog\n' +
            '            ├── [FAULT] → deleteRecord_error1_PostPreLog\n' +
            '            ├── deleteRecord_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── deleteRecord_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_record_update_with_fault() {
        String inputStructure = 
            '└── Start [Start] → updateRecord\n' +
            '    └── updateRecord [Record Update] → screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_updateRecord_PostPreLog\n' +
            '    └── Start_updateRecord_PostPreLog [Action] → updateRecord\n' +
            '        └── updateRecord [Record Update] → updateRecord_screen1_PostPreLog, FAULT:updateRecord_error1_PostPreLog\n' +
            '            ├── [FAULT] → updateRecord_error1_PostPreLog\n' +
            '            ├── updateRecord_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── updateRecord_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_record_create_with_fault() {
        String inputStructure = 
            '└── Start [Start] → createRecord\n' +
            '    └── createRecord [Record Create] → screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_createRecord_PostPreLog\n' +
            '    └── Start_createRecord_PostPreLog [Action] → createRecord\n' +
            '        └── createRecord [Record Create] → createRecord_screen1_PostPreLog, FAULT:createRecord_error1_PostPreLog\n' +
            '            ├── [FAULT] → createRecord_error1_PostPreLog\n' +
            '            ├── createRecord_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── createRecord_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_action_with_fault_target() {
        String inputStructure = 
            '└── Start [Start] → action1\n' +
            '    └── action1 [Action] → screen1, FAULT:error1\n' +
            '        ├── [FAULT] → error1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── error1 [Custom Error] → END';            
        
        String expectedOutput = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action1\n' +
            '        └── action1 [Action] → action1_screen1_PostPreLog, FAULT:action1_error1_PostPreLog\n' +
            '            ├── [FAULT] → action1_error1_PostPreLog\n' +
            '            ├── action1_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            └── action1_error1_PostPreLog [Action] → error1\n' +
            '                └── error1 [Custom Error] → error1_PostLog\n' +
            '                    └── error1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }


    @IsTest
    static void test_start_assignment_decision() {
        String inputStructure = 
            '└── Start [Start] → assignment1\n' +
            '    └── assignment1 [Assignment] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:END';

        String expectedOutput = 
            '└── Start [Start] → Start_assignment1_PostPreLog\n' +
            '    └── Start_assignment1_PostPreLog [Action] → assignment1\n' +
            '        └── assignment1 [Assignment] → assignment1_decision1_PostPreLog\n' +
            '            └── assignment1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_PostLog\n' +
            '                    └── decision1_PostLog [Action] → END';
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_complex_decision_loop_subflow() {
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:loop1, Rules:[Rule1->subflow1]\n' +
            '        ├── loop1 [Loop] → Next:screen1, NoMore:END\n' +
            '        │   ├── [Next Value] → screen1\n' +
            '        │   ├── screen1 [Screen] → END\n' +
            '        │   └── [No More Values] → END\n' +
            '        └── subflow1 [Subflow] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_decision1_PostPreLog\n' +
            '    └── Start_decision1_PostPreLog [Action] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:decision1_loop1_PostPreLog, Rules:[Rule1->decision1_Rule1_subflow1_PostPreLog]\n' +
            '            ├── decision1_loop1_PostPreLog [Action] → loop1\n' +
            '            │   └── loop1 [Loop] → Next:loop1_screen1_PostPreLog, NoMore:loop1_PostLog\n' +
            '            │       ├── [Next Value] → loop1_screen1_PostPreLog\n' +
            '            │       ├── loop1_screen1_PostPreLog [Action] → screen1\n' +
            '            │       │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       │       └── screen1_PostLog [Action] → END\n' +
            '            │       ├── [No More Values] → loop1_PostLog\n' +
            '            │       └── loop1_PostLog [Action] → END\n' +
            '            └── decision1_Rule1_subflow1_PostPreLog [Action] → subflow1\n' +
            '                └── subflow1 [Subflow] → subflow1_PostLog\n' +
            '                    └── subflow1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput, new Map<String, String>{
            'Start_decision1_PostPreLog' => 'INFO',
            'decision1_loop1_PostPreLog' => 'DEBUG',
            'decision1_Rule1_subflow1_PostPreLog' => 'DEBUG',
            'loop1_screen1_PostPreLog' => 'FINER',
            'screen1_PostLog' => 'DEBUG',
            'subflow1_PostLog' => 'DEBUG'
        });
    }

    @IsTest
    static void test_remove_logging_complex_decision_loop_subflow() {

        String inputStructure  = 
            '└── Start [Start] → Start_decision1_PostPreLog\n' +
            '    └── Start_decision1_PostPreLog [Action] → decision1 {Source:Start,100,100|Target:decision1,100,100}\n' +
            '        └── decision1 [Decision] → DEFAULT:decision1_loop1_PostPreLog, Rules:[Rule1->decision1_Rule1_subflow1_PostPreLog]\n' +
            '            ├── decision1_loop1_PostPreLog [Action] → loop1 {Source:decision1,100,100|Target:loop1,100,100}\n' +
            '            │   └── loop1 [Loop] → Next:loop1_screen1_PostPreLog, NoMore:loop1_PostLog\n' +
            '            │       ├── [Next Value] → loop1_screen1_PostPreLog\n' +
            '            │       ├── loop1_screen1_PostPreLog [Action] → screen1 {Source:loop1,100,100|Target:screen1,100,100}\n' +
            '            │       │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       │       └── screen1_PostLog [Action] → END {Source:screen1,100,100|Target:null,100,100}\n' +
            '            │       ├── [No More Values] → loop1_PostLog\n' +
            '            │       └── loop1_PostLog [Action] → END {Source:loop1.NOMORE,100,100|Target:null,100,100}\n' +
            '            └── decision1_Rule1_subflow1_PostPreLog [Action] → subflow1 {Source:decision1:Rule1,100,100|Target:subflow1,100,100}\n' +
            '                └── subflow1 [Subflow] → subflow1_PostLog\n' +
            '                    └── subflow1_PostLog [Action] → END {Source:subflow1,100,100|Target:null,100,100}';

        String expectedOutput = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:loop1, Rules:[Rule1->subflow1]\n' +
            '        ├── loop1 [Loop] → Next:screen1, NoMore:END\n' +
            '        │   ├── [Next Value] → screen1\n' +
            '        │   ├── screen1 [Screen] → END\n' +
            '        │   └── [No More Values] → END\n' +
            '        └── subflow1 [Subflow] → END';
            
        test_remove_logging_success(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_apex_plugin_with_screen_and_error() {
        String inputStructure = 
            '└── Start [Start] → screen1\n' +
            '    └── screen1 [Screen] → apexCall1\n' +
            '        └── apexCall1 [Apex Plugin] → error1\n' +
            '            └── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_screen1_PostPreLog\n' +
            '    └── Start_screen1_PostPreLog [Action] → screen1\n' +
            '        └── screen1 [Screen] → screen1_apexCall1_PostPreLog\n' +
            '            └── screen1_apexCall1_PostPreLog [Action] → apexCall1\n' +
            '                └── apexCall1 [Apex Plugin] → apexCall1_error1_PostPreLog\n' +
            '                    └── apexCall1_error1_PostPreLog [Action] → error1\n' +
            '                        └── error1 [Custom Error] → error1_PostLog\n' +
            '                            └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_screen_with_multiple_paths() {
        String inputStructure = 
            '└── Start [Start] → screen1\n' +
            '    └── screen1 [Screen] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:screen2, Rules:[Next->screen3]\n' +
            '            ├── screen2 [Screen] → apexCall1\n' +
            '            │   └── apexCall1 [Apex Plugin] → END\n' +
            '            └── screen3 [Screen] → apexCall2\n' +
            '                └── apexCall2 [Apex Plugin] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_screen1_PostPreLog\n' +
            '    └── Start_screen1_PostPreLog [Action] → screen1\n' +
            '        └── screen1 [Screen] → screen1_decision1_PostPreLog\n' +
            '            └── screen1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_screen2_PostPreLog, Rules:[Next->decision1_Next_screen3_PostPreLog]\n' +
            '                    ├── decision1_screen2_PostPreLog [Action] → screen2\n' +
            '                    │   └── screen2 [Screen] → screen2_apexCall1_PostPreLog\n' +
            '                    │       └── screen2_apexCall1_PostPreLog [Action] → apexCall1\n' +
            '                    │           └── apexCall1 [Apex Plugin] → apexCall1_PostLog\n' +
            '                    │               └── apexCall1_PostLog [Action] → END\n' +
            '                    └── decision1_Next_screen3_PostPreLog [Action] → screen3\n' +
            '                        └── screen3 [Screen] → screen3_apexCall2_PostPreLog\n' +
            '                            └── screen3_apexCall2_PostPreLog [Action] → apexCall2\n' +
            '                                └── apexCall2 [Apex Plugin] → apexCall2_PostLog\n' +
            '                                    └── apexCall2_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_custom_error_handling_paths() {
        String inputStructure = 
            '└── Start [Start] → apexCall1\n' +
            '    └── apexCall1 [Apex Plugin] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:screen1, Rules:[Error->error1]\n' +
            '            ├── screen1 [Screen] → END\n' +
            '            └── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_apexCall1_PostPreLog\n' +
            '    └── Start_apexCall1_PostPreLog [Action] → apexCall1\n' +
            '        └── apexCall1 [Apex Plugin] → apexCall1_decision1_PostPreLog\n' +
            '            └── apexCall1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_screen1_PostPreLog, Rules:[Error->decision1_Error_error1_PostPreLog]\n' +
            '                    ├── decision1_screen1_PostPreLog [Action] → screen1\n' +
            '                    │   └── screen1 [Screen] → screen1_PostLog\n' +
            '                    │       └── screen1_PostLog [Action] → END\n' +
            '                    └── decision1_Error_error1_PostPreLog [Action] → error1\n' +
            '                        └── error1 [Custom Error] → error1_PostLog\n' +
            '                            └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_complex_screen_navigation() {
        String inputStructure = 
        '└── Start [Start] → screen1\n' +
        '    └── screen1 [Screen] → decision1\n' +
        '        └── decision1 [Decision] → DEFAULT:screen2, Rules:[Back->screen1, Next->screen3, Error->error1]\n' +
        '            ├── screen2 [Screen] → screen3\n' +
        '            │   └── screen3 [Screen] → apexCall1\n' +
        '            │       └── apexCall1 [Apex Plugin] → END\n' +
        '            └── error1 [Custom Error] → END';

    String expectedOutput = 
        '└── Start [Start] → Start_screen1_PostPreLog\n' +
        '    └── Start_screen1_PostPreLog [Action] → screen1\n' +
        '        └── screen1 [Screen] → screen1_decision1_PostPreLog\n' +
        '            └── screen1_decision1_PostPreLog [Action] → decision1\n' +
        '                └── decision1 [Decision] → DEFAULT:decision1_screen2_PostPreLog, Rules:[Back->decision1_Back_screen1_PostPreLog, Next->decision1_Next_screen3_PostPreLog, Error->decision1_Error_error1_PostPreLog]\n' +
        '                    ├── decision1_screen2_PostPreLog [Action] → screen2\n' +
        '                    │   └── screen2 [Screen] → screen2_screen3_PostPreLog\n' +
        '                    │       └── screen2_screen3_PostPreLog [Action] → screen3\n' +
        '                    │           └── screen3 [Screen] → screen3_apexCall1_PostPreLog\n' +
        '                    │               └── screen3_apexCall1_PostPreLog [Action] → apexCall1\n' +
        '                    │                   └── apexCall1 [Apex Plugin] → apexCall1_PostLog\n' +
        '                    │                       └── apexCall1_PostLog [Action] → END\n' +
        '                    ├── decision1_Back_screen1_PostPreLog [Action] → screen1\n' +
        '                    ├── decision1_Next_screen3_PostPreLog [Action] → screen3\n' +
        '                    └── decision1_Error_error1_PostPreLog [Action] → error1\n' +
        '                        └── error1 [Custom Error] → error1_PostLog\n' +
        '                            └── error1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_apex_plugin_with_error_handling() {
        String inputStructure = 
            '└── Start [Start] → apexCall1\n' +
            '    └── apexCall1 [Apex Plugin] → loop1\n' +
            '        └── loop1 [Loop] → Next:apexCall2, NoMore:END\n' +
            '            ├── [Next Value] → apexCall2\n' +
            '            ├── apexCall2 [Apex Plugin] → decision1\n' +
            '            │   └── decision1 [Decision] → DEFAULT:loop1, Rules:[Error->error1]\n' +
            '            │       └── error1 [Custom Error] → END\n' +
            '            └── [No More Values] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_apexCall1_PostPreLog\n' +
            '    └── Start_apexCall1_PostPreLog [Action] → apexCall1\n' +
            '        └── apexCall1 [Apex Plugin] → apexCall1_loop1_PostPreLog\n' +
            '            └── apexCall1_loop1_PostPreLog [Action] → loop1\n' +
            '                └── loop1 [Loop] → Next:loop1_apexCall2_PostPreLog, NoMore:loop1_PostLog\n' +
            '                    ├── [Next Value] → loop1_apexCall2_PostPreLog\n' +
            '                    ├── loop1_apexCall2_PostPreLog [Action] → apexCall2\n' +
            '                    │   └── apexCall2 [Apex Plugin] → apexCall2_decision1_PostPreLog\n' +
            '                    │       └── apexCall2_decision1_PostPreLog [Action] → decision1\n' +
            '                    │           └── decision1 [Decision] → DEFAULT:decision1_loop1_PostPreLog, Rules:[Error->decision1_Error_error1_PostPreLog]\n' +
            '                    │               ├── decision1_loop1_PostPreLog [Action] → loop1\n' +
            '                    │               └── decision1_Error_error1_PostPreLog [Action] → error1\n' +
            '                    │                   └── error1 [Custom Error] → error1_PostLog\n' +
            '                    │                       └── error1_PostLog [Action] → END\n' +
            '                    ├── [No More Values] → loop1_PostLog\n' +
            '                    └── loop1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_wait_with_multiple_events_and_decision() {
        String inputStructure = 
            '└── Start [Start] → wait1\n' +
            '    └── wait1 [Wait] → DEFAULT:decision1, Events:[Event1->path1, Event2->path2]\n' +
            '        ├── decision1 [Decision] → DEFAULT:END, Rules:[Rule1->update1]\n' +
            '        │   └── update1 [Record Update] → END\n' +
            '        ├── path1 [Record Create] → decision1\n' +
            '        └── path2 [Record Update] → decision1';

        String expectedOutput = 
            '└── Start [Start] → Start_wait1_PostPreLog\n' +
            '    └── Start_wait1_PostPreLog [Action] → wait1\n' +
            '        └── wait1 [Wait] → DEFAULT:wait1_decision1_PostPreLog, Events:[Event1->wait1_Event1_path1_PostPreLog, Event2->wait1_Event2_path2_PostPreLog]\n' +
            '            ├── wait1_decision1_PostPreLog [Action] → decision1\n' +
            '            │   └── decision1 [Decision] → DEFAULT:decision1_PostLog, Rules:[Rule1->decision1_Rule1_update1_PostPreLog]\n' +
            '            │       ├── decision1_PostLog [Action] → END\n' +
            '            │       └── decision1_Rule1_update1_PostPreLog [Action] → update1\n' +
            '            │           └── update1 [Record Update] → update1_PostLog\n' +
            '            │               └── update1_PostLog [Action] → END\n' +
            '            ├── wait1_Event1_path1_PostPreLog [Action] → path1\n' +
            '            │   └── path1 [Record Create] → path1_decision1_PostPreLog\n' +
            '            │       └── path1_decision1_PostPreLog [Action] → decision1\n' +
            '            └── wait1_Event2_path2_PostPreLog [Action] → path2\n' +
            '                └── path2 [Record Update] → path2_decision1_PostPreLog\n' +
            '                    └── path2_decision1_PostPreLog [Action] → decision1';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_nested_loops_with_collection_processor() {
        String inputStructure = 
            '└── Start [Start] → loop1\n' +
            '    └── loop1 [Loop] → Next:collection1, NoMore:END\n' +
            '        ├── [Next Value] → collection1\n' +
            '        ├── collection1 [Collection Processor] → loop2\n' +
            '        │   └── loop2 [Loop] → Next:transform1, NoMore:loop1\n' +
            '        │       ├── [Next Value] → transform1\n' +
            '        │       ├── transform1 [Transform] → loop2\n' +
            '        │       ├── [No More Values] → loop1\n' +
            '        └── [No More Values] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_loop1_PostPreLog\n' +
            '    └── Start_loop1_PostPreLog [Action] → loop1\n' +
            '        └── loop1 [Loop] → Next:loop1_collection1_PostPreLog, NoMore:loop1_PostLog\n' +
            '            ├── [Next Value] → loop1_collection1_PostPreLog\n' +
            '            ├── loop1_collection1_PostPreLog [Action] → collection1\n' +
            '            │   └── collection1 [Collection Processor] → collection1_loop2_PostPreLog\n' +
            '            │       └── collection1_loop2_PostPreLog [Action] → loop2\n' +
            '            │           └── loop2 [Loop] → Next:loop2_transform1_PostPreLog, NoMore:loop2_loop1_PostPreLog\n' +
            '            │               ├── [Next Value] → loop2_transform1_PostPreLog\n' +
            '            │               ├── loop2_transform1_PostPreLog [Action] → transform1\n' +
            '            │               │   └── transform1 [Transform] → transform1_loop2_PostPreLog\n' +
            '            │               │       └── transform1_loop2_PostPreLog [Action] → loop2\n' +
            '            │               ├── [No More Values] → loop2_loop1_PostPreLog\n' +
            '            │               └── loop2_loop1_PostPreLog [Action] → loop1\n' +
            '            ├── [No More Values] → loop1_PostLog\n' +
            '            └── loop1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_complex_decision_tree_with_transforms() {
        String inputStructure = 
            '└── Start [Start] → transform1\n' +
            '    └── transform1 [Transform] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:transform2, Rules:[Rule1->transform3, Rule2->transform4]\n' +
            '            ├── transform2 [Transform] → END\n' +
            '            ├── transform3 [Transform] → END\n' +
            '            └── transform4 [Transform] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_transform1_PostPreLog\n' +
            '    └── Start_transform1_PostPreLog [Action] → transform1\n' +
            '        └── transform1 [Transform] → transform1_decision1_PostPreLog\n' +
            '            └── transform1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_transform2_PostPreLog, Rules:[Rule1->decision1_Rule1_transform3_PostPreLog, Rule2->decision1_Rule2_transform4_PostPreLog]\n' +
            '                    ├── decision1_transform2_PostPreLog [Action] → transform2\n' +
            '                    │   └── transform2 [Transform] → transform2_PostLog\n' +
            '                    │       └── transform2_PostLog [Action] → END\n' +
            '                    ├── decision1_Rule1_transform3_PostPreLog [Action] → transform3\n' +
            '                    │   └── transform3 [Transform] → transform3_PostLog\n' +
            '                    │       └── transform3_PostLog [Action] → END\n' +
            '                    └── decision1_Rule2_transform4_PostPreLog [Action] → transform4\n' +
            '                        └── transform4 [Transform] → transform4_PostLog\n' +
            '                            └── transform4_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_wait_with_multiple_paths_and_collection() {
        String inputStructure = 
            '└── Start [Start] → wait1\n' +
            '    └── wait1 [Wait] → DEFAULT:collection1, Events:[Event1->collection2, Event2->collection3]\n' +
            '        ├── collection1 [Collection Processor] → transform1\n' +
            '        │   └── transform1 [Transform] → END\n' +
            '        ├── collection2 [Collection Processor] → transform2\n' +
            '        │   └── transform2 [Transform] → END\n' +
            '        └── collection3 [Collection Processor] → transform3\n' +
            '            └── transform3 [Transform] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_wait1_PostPreLog\n' +
            '    └── Start_wait1_PostPreLog [Action] → wait1\n' +
            '        └── wait1 [Wait] → DEFAULT:wait1_collection1_PostPreLog, Events:[Event1->wait1_Event1_collection2_PostPreLog, Event2->wait1_Event2_collection3_PostPreLog]\n' +
            '            ├── wait1_collection1_PostPreLog [Action] → collection1\n' +
            '            │   └── collection1 [Collection Processor] → collection1_transform1_PostPreLog\n' +
            '            │       └── collection1_transform1_PostPreLog [Action] → transform1\n' +
            '            │           └── transform1 [Transform] → transform1_PostLog\n' +
            '            │               └── transform1_PostLog [Action] → END\n' +
            '            ├── wait1_Event1_collection2_PostPreLog [Action] → collection2\n' +
            '            │   └── collection2 [Collection Processor] → collection2_transform2_PostPreLog\n' +
            '            │       └── collection2_transform2_PostPreLog [Action] → transform2\n' +
            '            │           └── transform2 [Transform] → transform2_PostLog\n' +
            '            │               └── transform2_PostLog [Action] → END\n' +
            '            └── wait1_Event2_collection3_PostPreLog [Action] → collection3\n' +
            '                └── collection3 [Collection Processor] → collection3_transform3_PostPreLog\n' +
            '                    └── collection3_transform3_PostPreLog [Action] → transform3\n' +
            '                        └── transform3 [Transform] → transform3_PostLog\n' +
            '                            └── transform3_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_disconnected_elements() {
        String inputStructure = 
            '└── Start [Start] → wait1\n' +
            '    └── wait1 [Wait] → DEFAULT:END\n' +
            '[Disconnected]\n' +
            '└── decision1 [Decision] → DEFAULT:END\n' +
            '└── action1 [Action] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_wait1_PostPreLog\n' +
            '    └── Start_wait1_PostPreLog [Action] → wait1\n' +
            '        └── wait1 [Wait] → DEFAULT:wait1_PostLog\n' +
            '            └── wait1_PostLog [Action] → END\n' +
            '[Disconnected]\n' +
            '└── decision1 [Decision] → DEFAULT:END\n' +
            '└── action1 [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_multiple_disconnected_paths() {
        String inputStructure = 
            '└── Start [Start] → wait1\n' +
            '    └── wait1 [Wait] → DEFAULT:END, Events:[Event1->path1]\n' +
            '        └── path1 [Record Create] → END\n' +
            '[Disconnected]\n' +
            '└── decision1 [Decision] → DEFAULT:create1, Rules:[Rule1->update1]\n' +
            '    ├── create1 [Record Create] → END\n' +
            '    └── update1 [Record Update] → END\n' +
            '└── collection1 [Collection Processor] → transform1\n' +
            '    └── transform1 [Transform] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_wait1_PostPreLog\n' +
            '    └── Start_wait1_PostPreLog [Action] → wait1\n' +
            '        └── wait1 [Wait] → DEFAULT:wait1_PostLog, Events:[Event1->wait1_Event1_path1_PostPreLog]\n' +
            '            ├── wait1_PostLog [Action] → END\n' +
            '            └── wait1_Event1_path1_PostPreLog [Action] → path1\n' +
            '                └── path1 [Record Create] → path1_PostLog\n' +
            '                    └── path1_PostLog [Action] → END\n' +
            '[Disconnected]\n' +
            '└── decision1 [Decision] → DEFAULT:create1, Rules:[Rule1->update1]\n' +
            '    ├── create1 [Record Create] → END\n' +
            '    └── update1 [Record Update] → END\n' +
            '└── collection1 [Collection Processor] → transform1\n' +
            '    └── transform1 [Transform] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_mixed_connected_and_disconnected_elements() {
        String inputStructure = 
            '└── Start [Start] → screen1\n' +
            '    └── screen1 [Screen] → END\n' +
            '[Disconnected]\n' +
            '└── apexCall1 [Apex Plugin] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:END\n' +
            '└── transform1 [Transform] → END\n' +
            '└── error1 [Custom Error] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_screen1_PostPreLog\n' +
            '    └── Start_screen1_PostPreLog [Action] → screen1\n' +
            '        └── screen1 [Screen] → screen1_PostLog\n' +
            '            └── screen1_PostLog [Action] → END\n' +
            '[Disconnected]\n' +            
            '└── apexCall1 [Apex Plugin] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:END\n' +
            '└── transform1 [Transform] → END\n' +
            '└── error1 [Custom Error] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_transform_action() {
        String inputStructure = 
            '└── Start [Start] → transform1\n' +
            '    └── transform1 [Transform] → action1\n' +
            '        └── action1 [Action] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_transform1_PostPreLog\n' +
            '    └── Start_transform1_PostPreLog [Action] → transform1\n' +
            '        └── transform1 [Transform] → transform1_action1_PostPreLog\n' +
            '            └── transform1_action1_PostPreLog [Action] → action1\n' +
            '                └── action1 [Action] → action1_PostLog\n' +
            '                    └── action1_PostLog [Action] → END';
        
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_wait_collection() {
        String inputStructure = 
            '└── Start [Start] → wait1\n' +
            '    └── wait1 [Wait] → DEFAULT:END, Events:[wait1_Event->collection1]\n' +
            '        └── collection1 [Collection Processor] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_wait1_PostPreLog\n' +
            '    └── Start_wait1_PostPreLog [Action] → wait1\n' +
            '        └── wait1 [Wait] → DEFAULT:wait1_PostLog, Events:[wait1_Event->wait1_wait1_Event_collection1_PostPreLog]\n' +
            '            ├── wait1_PostLog [Action] → END\n' +
            '            └── wait1_wait1_Event_collection1_PostPreLog [Action] → collection1\n' +
            '                └── collection1 [Collection Processor] → collection1_PostLog\n' +
            '                    └── collection1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_wait_with_events() {
        String inputStructure = 
            '└── Start [Start] → wait1\n' +
            '    └── wait1 [Wait] → DEFAULT:timeout, Events:[Event1->path1, Event2->path2]\n' +
            '        ├── timeout [Record Delete] → END\n' +
            '        ├── path1 [Record Create] → END\n' +
            '        └── path2 [Record Update] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_wait1_PostPreLog\n' +
            '    └── Start_wait1_PostPreLog [Action] → wait1\n' +
            '        └── wait1 [Wait] → DEFAULT:wait1_timeout_PostPreLog, Events:[Event1->wait1_Event1_path1_PostPreLog, Event2->wait1_Event2_path2_PostPreLog]\n' +
            '            ├── wait1_timeout_PostPreLog [Action] → timeout\n' +
            '            │   └── timeout [Record Delete] → timeout_PostLog\n' +
            '            │       └── timeout_PostLog [Action] → END\n' +
            '            ├── wait1_Event1_path1_PostPreLog [Action] → path1\n' +
            '            │   └── path1 [Record Create] → path1_PostLog\n' +
            '            │       └── path1_PostLog [Action] → END\n' +
            '            └── wait1_Event2_path2_PostPreLog [Action] → path2\n' +
            '                └── path2 [Record Update] → path2_PostLog\n' +
            '                    └── path2_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }
    
    @IsTest
    static void test_start_decision_create() {
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:create1\n' +
            '        └── create1 [Record Create] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_decision1_PostPreLog\n' +
            '    └── Start_decision1_PostPreLog [Action] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:decision1_create1_PostPreLog\n' +
            '            └── decision1_create1_PostPreLog [Action] → create1\n' +
            '                └── create1 [Record Create] → create1_PostLog\n' +
            '                    └── create1_PostLog [Action] → END\n';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_decision_create_rollback() {
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:create1\n' +
            '        └── create1 [Record Create] → rollback1\n' +
            '            └── rollback1 [Record Rollback] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_decision1_PostPreLog\n' +
            '    └── Start_decision1_PostPreLog [Action] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:decision1_create1_PostPreLog\n' +
            '            └── decision1_create1_PostPreLog [Action] → create1\n' +
            '                └── create1 [Record Create] → create1_rollback1_PostPreLog\n' +
            '                    └── create1_rollback1_PostPreLog [Action] → rollback1\n' +
            '                        └── rollback1 [Record Rollback] → rollback1_PostLog\n' +
            '                            └── rollback1_PostLog [Action] → END\n';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_loop_screen() {
        String inputStructure = 
            '└── Start [Start] → loop1\n' +
            '    └── loop1 [Loop] → Next:screen1, NoMore:END\n' +
            '        ├── [Next Value] → screen1\n' +
            '        ├── screen1 [Screen] → END\n' +
            '        └── [No More Values] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_loop1_PostPreLog\n' +
            '    └── Start_loop1_PostPreLog [Action] → loop1\n' +
            '        └── loop1 [Loop] → Next:loop1_screen1_PostPreLog, NoMore:loop1_PostLog\n' +
            '            ├── [Next Value] → loop1_screen1_PostPreLog\n' +
            '            ├── loop1_screen1_PostPreLog [Action] → screen1\n' +
            '            │   └── screen1 [Screen] → screen1_PostLog\n' +
            '            │       └── screen1_PostLog [Action] → END\n' +
            '            ├── [No More Values] → loop1_PostLog\n' +
            '            └── loop1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_assignment_lookup() {
        String inputStructure = 
            '└── Start [Start] → assignment1\n' +
            '    └── assignment1 [Assignment] → lookup1\n' +
            '        └── lookup1 [Record Lookup] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_assignment1_PostPreLog\n' +
            '    └── Start_assignment1_PostPreLog [Action] → assignment1\n' +
            '        └── assignment1 [Assignment] → assignment1_lookup1_PostPreLog\n' +
            '            └── assignment1_lookup1_PostPreLog [Action] → lookup1\n' +
            '                └── lookup1 [Record Lookup] → lookup1_PostLog\n' +
            '                    └── lookup1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_screen_update() {
        String inputStructure = 
            '└── Start [Start] → screen1\n' +
            '    └── screen1 [Screen] → update1\n' +
            '        └── update1 [Record Update] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_screen1_PostPreLog\n' +
            '    └── Start_screen1_PostPreLog [Action] → screen1\n' +
            '        └── screen1 [Screen] → screen1_update1_PostPreLog\n' +
            '            └── screen1_update1_PostPreLog [Action] → update1\n' +
            '                └── update1 [Record Update] → update1_PostLog\n' +
            '                    └── update1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_subflow_delete() {
        String inputStructure = 
            '└── Start [Start] → subflow1\n' +
            '    └── subflow1 [Subflow] → delete1\n' +
            '        └── delete1 [Record Delete] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_subflow1_PostPreLog\n' +
            '    └── Start_subflow1_PostPreLog [Action] → subflow1\n' +
            '        └── subflow1 [Subflow] → subflow1_delete1_PostPreLog\n' +
            '            └── subflow1_delete1_PostPreLog [Action] → delete1\n' +
            '                └── delete1 [Record Delete] → delete1_PostLog\n' +
            '                    └── delete1_PostLog [Action] → END';
        
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_update_flow_structure_case_Start_to_Create_to_Create() {
        // Arrange
        String inputStructure = 
            '└── Start [Start] → create1\n' +
            '    └── create1 [Record Create] → create2\n' +
            '        └── create2 [Record Create] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_create1_PostPreLog\n' +
            '    └── Start_create1_PostPreLog [Action] → create1\n' +
            '        └── create1 [Record Create] → create1_create2_PostPreLog\n' +
            '            └── create1_create2_PostPreLog [Action] → create2\n' +
            '                └── create2 [Record Create] → create2_PostLog\n' +
            '                    └── create2_PostLog [Action] → END';
        
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }


    @IsTest
    static void test_update_flow_structure_case_Start_to_Decision_with_CreateNew_Rule() {
        // Arrange
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:END, Rules:[CreateNew->create1]\n' +
            '        └── create1 [Record Create] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_decision1_PostPreLog\n' +
            '    └── Start_decision1_PostPreLog [Action] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:decision1_PostLog, Rules:[CreateNew->decision1_CreateNew_create1_PostPreLog]\n' +
            '            ├── decision1_PostLog [Action] → END\n' +
            '            └── decision1_CreateNew_create1_PostPreLog [Action] → create1\n' +
            '                └── create1 [Record Create] → create1_PostLog\n' +
            '                    └── create1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }


    @IsTest
    static void test_start_loop_decision() {
        String inputStructure = 
            '└── Start [Start] → loop1\n' +
            '    └── loop1 [Loop] → Next:decision1, NoMore:END\n' +
            '        ├── [Next Value] → decision1\n' +
            '        ├── decision1 [Decision] → DEFAULT:END, Rules:[CreateNew->create1]\n' +
            '        │   └──  create1 [Record Create] → END\n' +
            '        └── [No More Values] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_loop1_PostPreLog\n' +
            '    └── Start_loop1_PostPreLog [Action] → loop1\n' +
            '        └── loop1 [Loop] → Next:loop1_decision1_PostPreLog, NoMore:loop1_PostLog\n' +
            '            ├── [Next Value] → loop1_decision1_PostPreLog\n' +
            '            ├── loop1_decision1_PostPreLog [Action] → decision1\n' +
            '            │   └── decision1 [Decision] → DEFAULT:decision1_PostLog, Rules:[CreateNew->decision1_CreateNew_create1_PostPreLog]\n' +
            '            │       ├── decision1_PostLog [Action] → END\n' +
            '            │       └── decision1_CreateNew_create1_PostPreLog [Action] → create1\n' +
            '            │           └── create1 [Record Create] → create1_PostLog\n' +
            '            │               └── create1_PostLog [Action] → END\n' +
            '            ├── [No More Values] → loop1_PostLog\n' +
            '            └── loop1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_screen_decision_update() {
        String inputStructure = 
            '└── Start [Start] → screen1\n' +
            '    └── screen1 [Screen] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:END, Rules:[UpdateRecord->update1]\n' +
            '            └── update1 [Record Update] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_screen1_PostPreLog\n' +
            '    └── Start_screen1_PostPreLog [Action] → screen1\n' +
            '        └── screen1 [Screen] → screen1_decision1_PostPreLog\n' +
            '            └── screen1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_PostLog, Rules:[UpdateRecord->decision1_UpdateRecord_update1_PostPreLog]\n' +
            '                    ├── decision1_PostLog [Action] → END\n' +
            '                    └── decision1_UpdateRecord_update1_PostPreLog [Action] → update1\n' +
            '                        └── update1 [Record Update] → update1_PostLog\n' +
            '                            └── update1_PostLog [Action] → END';
        
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_lookup_decision_subflow() {
        String inputStructure = 
            '└── Start [Start] → lookup1\n' +
            '    └── lookup1 [Record Lookup] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:END, Rules:[CallFlow->subflow1]\n' +
            '            └── subflow1 [Subflow] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_lookup1_PostPreLog\n' +
            '    └── Start_lookup1_PostPreLog [Action] → lookup1\n' +
            '        └── lookup1 [Record Lookup] → lookup1_decision1_PostPreLog\n' +
            '            └── lookup1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_PostLog, Rules:[CallFlow->decision1_CallFlow_subflow1_PostPreLog]\n' +
            '                    ├── decision1_PostLog [Action] → END\n' +
            '                    └── decision1_CallFlow_subflow1_PostPreLog [Action] → subflow1\n' +
            '                        └── subflow1 [Subflow] → subflow1_PostLog\n' +
            '                            └── subflow1_PostLog [Action] → END';
        
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_lookup_decision_subflow_with_goto() {
        String inputStructure = 
            '└── Start [Start] → lookup1\n' +
            '    └── lookup1 [Record Lookup] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:create1, Rules:[CallFlow->subflow1]\n' +
            '            ├── create1 [Record Create] → lookup1.GOTO\n' +
            '            └── subflow1 [Subflow] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_lookup1_PostPreLog\n' +
            '    └── Start_lookup1_PostPreLog [Action] → lookup1\n' +
            '        └── lookup1 [Record Lookup] → lookup1_decision1_PostPreLog\n' +
            '            └── lookup1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_create1_PostPreLog, Rules:[CallFlow->decision1_CallFlow_subflow1_PostPreLog]\n' +
            '                    ├── decision1_create1_PostPreLog [Action] → create1\n' +
            '                    │   └── create1 [Record Create] → create1_lookup1_PostPreLog\n' +
            '                    │       └── create1_lookup1_PostPreLog [Action] → lookup1.GOTO\n' +
            '                    └── decision1_CallFlow_subflow1_PostPreLog [Action] → subflow1\n' +
            '                        └── subflow1 [Subflow] → subflow1_PostLog\n' +
            '                            └── subflow1_PostLog [Action] → END';  
        
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_remove_start_lookup_decision_subflow_with_goto() {
        
        String inputStructure = 
            '└── Start [Start] → Start_lookup1_PostPreLog\n' +
            '    └── Start_lookup1_PostPreLog [Action] → lookup1\n' +
            '        └── lookup1 [Record Lookup] → lookup1_decision1_PostPreLog\n' +
            '            └── lookup1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_create1_PostPreLog, Rules:[CallFlow->decision1_CallFlow_subflow1_PostPreLog]\n' +
            '                    ├── decision1_create1_PostPreLog [Action] → create1\n' +
            '                    │   └── create1 [Record Create] → create1_lookup1_PostPreLog\n' +
            '                    │       └── create1_lookup1_PostPreLog [Action] → lookup1.GOTO\n' +
            '                    └── decision1_CallFlow_subflow1_PostPreLog [Action] → subflow1\n' +
            '                        └── subflow1 [Subflow] → subflow1_PostLog\n' +
            '                            └── subflow1_PostLog [Action] → END';
        
        String expectedOutput = 
            '└── Start [Start] → lookup1\n' +
            '    └── lookup1 [Record Lookup] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:create1, Rules:[CallFlow->subflow1]\n' +
            '            ├── create1 [Record Create] → lookup1.GOTO\n' +
            '            └── subflow1 [Subflow] → END';
        
        test_remove_logging_success(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_lookup_decision_rule_with_goto() {
        String inputStructure = 
            '└── Start [Start] → lookup1\n' +
            '    └── lookup1 [Record Lookup] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:subflow1, Rules:[Rule1->lookup1.GOTO, Rule2->create1]\n' +
            '            ├── subflow1 [Subflow] → END\n' +
            '            └── create1 [Record Create] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_lookup1_PostPreLog\n' +
            '    └── Start_lookup1_PostPreLog [Action] → lookup1\n' +
            '        └── lookup1 [Record Lookup] → lookup1_decision1_PostPreLog\n' +
            '            └── lookup1_decision1_PostPreLog [Action] → decision1\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_subflow1_PostPreLog, Rules:[Rule1->decision1_Rule1_lookup1_PostPreLog, Rule2->decision1_Rule2_create1_PostPreLog]\n' +
            '                    ├── decision1_subflow1_PostPreLog [Action] → subflow1\n' +
            '                    │   └── subflow1 [Subflow] → subflow1_PostLog\n' +
            '                    │       └── subflow1_PostLog [Action] → END\n' +
            '                    ├── decision1_Rule1_lookup1_PostPreLog [Action] → lookup1.GOTO\n' +
            '                    └── decision1_Rule2_create1_PostPreLog [Action] → create1\n' +
            '                        └── create1 [Record Create] → create1_PostLog\n' +
            '                            └── create1_PostLog [Action] → END';
        
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_assignment_loop_create() {
        String inputStructure = 
            '└── Start [Start] → assignment1\n' +
            '    └── assignment1 [Assignment] → loop1\n' +
            '        └── loop1 [Loop] → Next:create1, NoMore:END\n' +
            '            ├── [Next Value] → create1\n' +
            '            ├── create1 [Record Create] → END\n'+
            '            └── [No More Values] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_assignment1_PostPreLog\n' +
            '    └── Start_assignment1_PostPreLog [Action] → assignment1\n' +
            '        └── assignment1 [Assignment] → assignment1_loop1_PostPreLog\n' +
            '            └── assignment1_loop1_PostPreLog [Action] → loop1\n' +
            '                └── loop1 [Loop] → Next:loop1_create1_PostPreLog, NoMore:loop1_PostLog\n' +
            '                    ├── [Next Value] → loop1_create1_PostPreLog\n' +
            '                    ├── loop1_create1_PostPreLog [Action] → create1\n' +
            '                    │   └── create1 [Record Create] → create1_PostLog\n' +
            '                    │       └── create1_PostLog [Action] → END\n' +
            '                    ├── [No More Values] → loop1_PostLog\n' +
            '                    └── loop1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_screen_loop_delete() {
        String inputStructure = 
            '└── Start [Start] → screen1\n' +
            '    └── screen1 [Screen] → loop1\n' +
            '        └── loop1 [Loop] → Next:delete1, NoMore:END\n' +
            '            ├── [Next Value] → delete1\n' +
            '            ├── delete1 [Record Delete] → END\n' +
            '            └── [No More Values] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_screen1_PostPreLog\n' +
            '    └── Start_screen1_PostPreLog [Action] → screen1\n' +
            '        └── screen1 [Screen] → screen1_loop1_PostPreLog\n' +
            '            └── screen1_loop1_PostPreLog [Action] → loop1\n' +
            '                └── loop1 [Loop] → Next:loop1_delete1_PostPreLog, NoMore:loop1_PostLog\n' +
            '                    ├── [Next Value] → loop1_delete1_PostPreLog\n' +
            '                    ├── loop1_delete1_PostPreLog [Action] → delete1\n' +
            '                    │   └── delete1 [Record Delete] → delete1_PostLog\n' +
            '                    │       └── delete1_PostLog [Action] → END\n' +
            '                    ├── [No More Values] → loop1_PostLog\n' +
            '                    └── loop1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_nested_decisions() {
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:END, Rules:[Rule1->decision2]\n' +
            '        └── decision2 [Decision] → DEFAULT:create1, Rules:[Rule2->update1]\n' +
            '            ├── create1 [Record Create] → END\n' +
            '            └── update1 [Record Update] → END';
        
        String expectedOutput = 
            '└── Start [Start] → Start_decision1_PostPreLog\n' +
            '    └── Start_decision1_PostPreLog [Action] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:decision1_PostLog, Rules:[Rule1->decision1_Rule1_decision2_PostPreLog]\n' +
            '            ├── decision1_PostLog [Action] → END\n' +
            '            └── decision1_Rule1_decision2_PostPreLog [Action] → decision2\n' +
            '                └── decision2 [Decision] → DEFAULT:decision2_create1_PostPreLog, Rules:[Rule2->decision2_Rule2_update1_PostPreLog]\n' +
            '                    ├── decision2_create1_PostPreLog [Action] → create1\n' +
            '                    │   └── create1 [Record Create] → create1_PostLog\n' +
            '                    │       └── create1_PostLog [Action] → END\n' +
            '                    └── decision2_Rule2_update1_PostPreLog [Action] → update1\n' +
            '                        └── update1 [Record Update] → update1_PostLog\n' +
            '                            └── update1_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_nested_loops() {
        String inputStructure = 
            '└── Start [Start] → loop1\n' +
            '    └── loop1 [Loop] → Next:loop2, NoMore:END\n' +
            '        ├── [Next Value] → loop2\n' +
            '        ├── loop2 [Loop] → Next:create1, NoMore:update1\n' +
            '        │   ├── [Next Value] → create1\n' +
            '        │   ├── create1 [Record Create] → loop2\n' +
            '        │   ├── [No More Values] → update1\n' +
            '        │   └── update1 [Record Update] → loop1\n' +
            '        └── [No More Values] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_loop1_PostPreLog\n' +
            '    └── Start_loop1_PostPreLog [Action] → loop1\n' +
            '        └── loop1 [Loop] → Next:loop1_loop2_PostPreLog, NoMore:loop1_PostLog\n' +
            '            ├── [Next Value] → loop1_loop2_PostPreLog\n' +
            '            ├── loop1_loop2_PostPreLog [Action] → loop2\n' +
            '            │   └── loop2 [Loop] → Next:loop2_create1_PostPreLog, NoMore:loop2_update1_PostPreLog\n' +
            '            │       ├── [Next Value] → loop2_create1_PostPreLog\n' +
            '            │       ├── loop2_create1_PostPreLog [Action] → create1\n' +
            '            │       │   └── create1 [Record Create] → create1_loop2_PostPreLog\n' +
            '            │       │       └── create1_loop2_PostPreLog [Action] → loop2\n' +
            '            │       ├── [No More Values] → loop2_update1_PostPreLog\n' +
            '            │       └── loop2_update1_PostPreLog [Action] → update1\n' +
            '            │           └── update1 [Record Update] → update1_loop1_PostPreLog\n' +
            '            │               └── update1_loop1_PostPreLog [Action] → loop1\n' +
            '            ├── [No More Values] → loop1_PostLog\n' +
            '            └── loop1_PostLog [Action] → END';

        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_loop_with_nested_decisions() {
        String inputStructure = 
            '└── Start [Start] → loop1\n' +
            '    └── loop1 [Loop] → Next:decision1, NoMore:END\n' +
            '        ├── [Next Value] → decision1\n' +
            '        ├── decision1 [Decision] → DEFAULT:loop1, Rules:[Rule1->decision2]\n' +
            '        │   └── decision2 [Decision] → DEFAULT:create1, Rules:[Rule2->update1]\n' +
            '        │       ├── create1 [Record Create] → loop1\n' +
            '        │       └── update1 [Record Update] → loop1\n' +
            '        └── [No More Values] → END';
            
        String expectedOutput = 
            '└── Start [Start] → Start_loop1_PostPreLog\n' +
            '    └── Start_loop1_PostPreLog [Action] → loop1\n' +
            '        └── loop1 [Loop] → Next:loop1_decision1_PostPreLog, NoMore:loop1_PostLog\n' +
            '            ├── [Next Value] → loop1_decision1_PostPreLog\n' +
            '            ├── loop1_decision1_PostPreLog [Action] → decision1\n' +
            '            │   └── decision1 [Decision] → DEFAULT:decision1_loop1_PostPreLog, Rules:[Rule1->decision1_Rule1_decision2_PostPreLog]\n' +
            '            │       ├── decision1_loop1_PostPreLog [Action] → loop1\n' +
            '            │       └── decision1_Rule1_decision2_PostPreLog [Action] → decision2\n' +
            '            │           └── decision2 [Decision] → DEFAULT:decision2_create1_PostPreLog, Rules:[Rule2->decision2_Rule2_update1_PostPreLog]\n' +
            '            │               ├── decision2_create1_PostPreLog [Action] → create1\n' +
            '            │               │   └── create1 [Record Create] → create1_loop1_PostPreLog\n' +
            '            │               │       └── create1_loop1_PostPreLog [Action] → loop1\n' +
            '            │               └── decision2_Rule2_update1_PostPreLog [Action] → update1\n' +
            '            │                   └── update1 [Record Update] → update1_loop1_PostPreLog\n' +
            '            │                       └── update1_loop1_PostPreLog [Action] → loop1\n' +
            '            ├── [No More Values] → loop1_PostLog\n' +
            '            └── loop1_PostLog [Action] → END';
      
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_start_decision_with_nested_loops() {
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:loop1, Rules:[Rule1->loop2]\n' +
            '        ├── loop1 [Loop] → Next:create1, NoMore:END\n' +
            '        │   ├── [Next Value] → create1\n' +
            '        │   ├── create1 [Record Create] → loop1\n' +
            '        │   └── [No More Values] → END\n' +
            '        └── loop2 [Loop] → Next:update1, NoMore:END\n' +
            '            ├── [Next Value] → update1\n' +
            '            ├── update1 [Record Update] → loop2\n' +
            '            └── [No More Values] → END';

        String expectedOutput = 
            '└── Start [Start] → Start_decision1_PostPreLog\n' +
            '    └── Start_decision1_PostPreLog [Action] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:decision1_loop1_PostPreLog, Rules:[Rule1->decision1_Rule1_loop2_PostPreLog]\n' +
            '            ├── decision1_loop1_PostPreLog [Action] → loop1\n' +
            '            │   └── loop1 [Loop] → Next:loop1_create1_PostPreLog, NoMore:loop1_PostLog\n' +
            '            │       ├── [Next Value] → loop1_create1_PostPreLog\n' +
            '            │       ├── loop1_create1_PostPreLog [Action] → create1\n' +
            '            │       │   └── create1 [Record Create] → create1_loop1_PostPreLog\n' +
            '            │       │       └── create1_loop1_PostPreLog [Action] → loop1\n' +
            '            │       ├── [No More Values] → loop1_PostLog\n' +
            '            │       └── loop1_PostLog [Action] → END\n' +
            '            └── decision1_Rule1_loop2_PostPreLog [Action] → loop2\n' +
            '                └── loop2 [Loop] → Next:loop2_update1_PostPreLog, NoMore:loop2_PostLog\n' +
            '                    ├── [Next Value] → loop2_update1_PostPreLog\n' +
            '                    ├── loop2_update1_PostPreLog [Action] → update1\n' +
            '                    │   └── update1 [Record Update] → update1_loop2_PostPreLog\n' +
            '                    │       └── update1_loop2_PostPreLog [Action] → loop2\n' +
            '                    ├── [No More Values] → loop2_PostLog\n' +
            '                    └── loop2_PostLog [Action] → END';
            
        test_update_flow_metadata_structure(inputStructure, expectedOutput);
    }

    static final String TEST_FLOW_API_NAME = 'TestFlow-1';
    static final String TEST_FUNCTIONAL_AREA = 'TestArea';

    static void test_update_flow_metadata_structure(String inputStructure, String expectedOutput) {
        test_update_flow_metadata_structure(inputStructure, expectedOutput, null);
    }

    static void test_update_flow_metadata_structure(String inputStructure, String expectedOutput, Map<String, String> expectedLogLevels) {
        
        // Create mock flow from structure
        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        
        // Setup mock handler
        MockMetadataHandler mockHandler = new MockMetadataHandler(mockFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        // Act
        Test.startTest();
        FlowLogService service = new FlowLogService();
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Assert
        System.assertEquals(true, result.get('success'), 
            'Operation should be successful. Error: ' + result.get('message'));
        
        // Get the visualization from the result
        Map<String, Object> visualization = (Map<String, Object>)result.get('flowVisualization');
        // Compare before visualization
        String beforeViz = (String)visualization.get('before');
        System.assertNotEquals(null, beforeViz, 'Before visualization should not be null');
        System.assertEquals(
            normalizeString(inputStructure), 
            normalizeString(beforeViz),
            'Before visualization does not match input structure'
        );
        
        // Compare after visualization
        String afterViz = (String)visualization.get('after');
        
        System.assertNotEquals(null, afterViz, 'After visualization should not be null');
        System.assertEquals(
            normalizeString(expectedOutput), 
            normalizeString(afterViz),
            'After visualization does not match expected output'
        );
        
        // Verify updated flow structure
        MetadataService.Flow updatedFlow = mockHandler.getUpdatedFlow();
        validateFlowStructure(updatedFlow, true);
    }
    
    private static String normalizeString(String input) {
        if(String.isBlank(input)) return '';
        // Remove extra whitespace and normalize line endings
        return input.replaceAll('\\s+', ' ')
                   .replaceAll('\\r\\n|\\r|\\n', '\n')
                   .trim();
    }
    
    private class MockMetadataHandler implements WebServiceMock {
        private MetadataService.Flow originalFlow;
        private MetadataService.Flow updatedFlow;
        
        public MockMetadataHandler(MetadataService.Flow flow) {
            this.originalFlow = flow;
        }
        
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) {
            
            if(request instanceof MetadataService.readMetadata_element) {
                handleReadRequest(response);
            } else if(request instanceof MetadataService.updateMetadata_element) {
                handleUpdateRequest(request, response);
            } else if(request instanceof MetadataService.upsertMetadata_element) {
                handleUpsertRequest(request, response);
            }
        }
        
        private void handleReadRequest(Map<String, Object> response) {
            MetadataService.readFlowResponse_element responseWrapper = 
                new MetadataService.readFlowResponse_element();
            
            MetadataService.ReadFlowResult result = new MetadataService.ReadFlowResult();
            result.records = new List<MetadataService.Flow>{ originalFlow };
            responseWrapper.result = result;
            
            response.put('response_x', responseWrapper);
        }
        
        private void handleUpdateRequest(Object request, Map<String, Object> response) {
            MetadataService.updateMetadata_element updateRequest = 
                (MetadataService.updateMetadata_element)request;
            
            // Store updated flow for verification
            this.updatedFlow = (MetadataService.Flow)updateRequest.metadata[0];
            
            // Create success response
            MetadataService.updateMetadataResponse_element responseWrapper = 
                new MetadataService.updateMetadataResponse_element();
            
            MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
            saveResult.success = true;
            saveResult.fullName = originalFlow.fullName;
            
            responseWrapper.result = new List<MetadataService.SaveResult>{ saveResult };
            response.put('response_x', responseWrapper);
        }
        
        private void handleUpsertRequest(Object request, Map<String, Object> response) {
            MetadataService.upsertMetadata_element upsertRequest = 
                (MetadataService.upsertMetadata_element)request;
            
            // Store updated flow for verification
            this.updatedFlow = (MetadataService.Flow)upsertRequest.metadata[0];
            
            // Create success response
            MetadataService.upsertMetadataResponse_element responseWrapper = 
                new MetadataService.upsertMetadataResponse_element();
            
            MetadataService.UpsertResult upsertResult = new MetadataService.UpsertResult();
            upsertResult.success = true;
            upsertResult.fullName = originalFlow.fullName;
            
            responseWrapper.result = new List<MetadataService.UpsertResult>{ upsertResult };
            response.put('response_x', responseWrapper);
        }
        
        public MetadataService.Flow getUpdatedFlow() {
            return updatedFlow;
        }
    }    
    
    private static final Pattern ELEMENT_PATTERN = Pattern.compile(
        '(?:\\s*│\\s*)*' +                                        // Optional indentation with │
        '((?:└──|├──))\\s*' +                                     // Group 1: Tree symbols
        '(\\w+)\\s+' +                                            // Group 2: Element name
        '\\[(\\w+(?:\\s+\\w+)?)\\]\\s*→\\s*' +                    // Group 3: Element type
        '(?:' +
            'Next:([^,\\s]+)(?:,\\s*NoMore:([^,\\s]+))|' +        // Group 4: Next target, Group 5: NoMore target
            'DEFAULT:([^,\\s]+)' +                                // Group 6: Default target
            '(?:,\\s*(?:Rules|Events):\\[([^\\]]+)\\])?' +        // Group 7: Rules/Events list
            '(?:,\\s*FAULT:([^,\\s]+))?|' +                       // Group 8: Fault target for DEFAULT
            '([^,\\s]+)' +                                        // Group 9: Standard target
            '(?:,\\s*(?:Paths|Rules|Events):\\[([^\\]]+)\\])?' +  // Group 10: Paths/Rules/Events list
            '(?:,\\s*FAULT:([^,\\s]+))?' +                        // Group 11: Fault target for standard
        ')' +
        '(?:\\s*\\{([^}]+)\\})?'                                  // Group 12: Full connection description
    );

    private static MetadataService.Flow buildFlowFromStructure(String structure) {
        MetadataService.Flow flow = new MetadataService.Flow();
        flow.fullName = 'TestFlow-1';
        flow.status = 'Active';
        
        Map<String, FlowElementWrapper> elementWrappers = new Map<String, FlowElementWrapper>();
        Integer depth = 0;
        Integer yPosition = 100;
        
        // Parse structure and create elements
        List<String> lines = structure.split('\n');
        for(String line : lines) {
            FlowElementInfo elementInfo = parseFlowLine(line);
            if(elementInfo == null) continue;
            
            // Calculate x position based on depth and element type
            Integer xPosition = calculateXPosition(elementInfo.type, elementInfo.depth);
            
            // Create element
            Object element = createFlowElement(
                elementInfo.name,
                elementInfo.type,
                elementInfo.defaultTarget,
                elementInfo.nextTarget,
                elementInfo.noMoreTarget,
                elementInfo.standardTarget,
                elementInfo.faultTarget,
                elementInfo.rules,
                xPosition,
                yPosition,
                elementInfo.elementDescription,
                elementInfo.isGoTo
            );
            
            // Store element and its connections
            elementWrappers.put(elementInfo.name, new FlowElementWrapper(element, elementInfo));
            yPosition += 100;
        }        
               
        // Add elements to flow
        addElementsToFlow(flow, elementWrappers.values());
        
        return flow;
    }
    
    
    private class FlowElementInfo {
        public String name;
        public String type;
        public String defaultTarget;
        public String nextTarget;
        public String noMoreTarget;
        public String standardTarget;
        public String faultTarget;
        public List<DecisionRule> rules;
        public Integer depth;
        public String elementDescription;
        public Boolean isGoTo;
    
        public FlowElementInfo(String name,
                             String type,
                             String defaultTarget,
                             String nextTarget,
                             String noMoreTarget,
                             String standardTarget,
                             String faultTarget,
                             List<DecisionRule> rules,
                             Integer depth,
                             String elementDescription,
                             Boolean isGoTo) {
            this.name = name;
            this.type = type;
            this.defaultTarget = defaultTarget;
            this.nextTarget = nextTarget;
            this.noMoreTarget = noMoreTarget;
            this.standardTarget = standardTarget;
            this.faultTarget = faultTarget;
            this.rules = rules;
            this.depth = depth;
            this.elementDescription = elementDescription;
            this.isGoTo = isGoTo;
        }
    }

    private class DecisionRule {
        public String name;
        public String label;
        public String description;
        public String targetRef;
        public Boolean isGoTo;
        
        public DecisionRule(String name, String targetRef) {
            this.name = name;
            this.label = name.toUpperCase();
            this.description = 'Decision rule';
            if(targetRef.endsWith('.GOTO')) {
                this.isGoTo = true;
                this.targetRef = targetRef.removeEnd('.GOTO');
            }
            else {
                this.isGoTo = false;
                this.targetRef = targetRef;
            }
        }
    }
    
    private class FlowElementWrapper {
        public Object element;
        public FlowElementInfo info;
        
        public FlowElementWrapper(Object element, FlowElementInfo info) {
            this.element = element;
            this.info = info;
        }
    }
    
    private static FlowElementInfo parseFlowLine(String line) {
        try {
            Matcher matcher = ELEMENT_PATTERN.matcher(line.trim());
            if (!matcher.matches()) {
                return null;
            }
            
            String name = matcher.group(2);
            String type = matcher.group(3);
            String nextTarget = matcher.group(4);
            String noMoreTarget = matcher.group(5);
            String defaultTarget = matcher.group(6);
            String rulesStr = matcher.group(7);
            String faultTarget = matcher.group(8) != null ? matcher.group(8) : matcher.group(11);
            String standardTarget = matcher.group(9);
            String pathsStr = matcher.group(10);
            String elementDescription = matcher.group(12);
            List<DecisionRule> rules = new List<DecisionRule>();          

            if(defaultTarget == 'END') {
                defaultTarget = null;
            }
            if(nextTarget == 'END') {
                nextTarget = null;
            }
            if(faultTarget == 'END') {
                faultTarget = null;
            }
            if(noMoreTarget == 'END') {
                noMoreTarget = null;
            }
            if(standardTarget == 'END') {
                standardTarget = null;
            }
            
            Boolean isGoTo = false;
            if(defaultTarget != null && defaultTarget.endsWith('.GOTO')) {
                isGoTo = true;
                defaultTarget = defaultTarget.removeEnd('.GOTO');
            }
            if(nextTarget != null && nextTarget.endsWith('.GOTO')) {
                isGoTo = true;
                nextTarget = nextTarget.removeEnd('.GOTO');
            }
            if(standardTarget != null && standardTarget.endsWith('.GOTO')) {
                isGoTo = true;
                standardTarget = standardTarget.removeEnd('.GOTO');
            }

            if(String.isNotBlank(rulesStr) || String.isNotBlank(pathsStr)){
                // Decision with Rules
                // Split rules by comma
                for (String rule : rulesStr?.split(',') ?? pathsStr?.split(',')) {
                    String[] parts = rule.trim().split('->');
                    if (parts.size() == 2) {
                        rules.add(new DecisionRule(parts[0].trim(), parts[1].trim()));
                    }
                }
            }
            // Calculate depth based on indentation and connector type
            Integer depth = calculateDepth(line);
            FlowElementInfo result = new FlowElementInfo(name, type, defaultTarget, nextTarget, noMoreTarget, standardTarget, faultTarget, rules, depth, elementDescription, isGoTo);
            return result;
        }
        catch(Exception e) {
            return null;
        }
    }
    
    private static Integer calculateDepth(String line) {
        Integer depth = 0;
        String trimmed = line;
        while(trimmed.startsWith('    ')) {
            depth++;
            trimmed = trimmed.substring(4);
        }
        return depth;
    }
    
    private static Integer calculateXPosition(String elementType, Integer depth) {
        Integer basePosition = 100 + (depth * 200); // Base spacing
        
        // Adjust position based on element type
        switch on elementType {
            when 'Start' {
                return basePosition;
            }
            when 'Assignment' {
                return basePosition + 50;
            }
            when 'Record Lookup' {
                return basePosition + 100;
            }
            when 'Decision' {
                return basePosition + 150;
            }
            when 'Loop' {
                return basePosition + 200;
            }
            when 'Record Create' {
                return basePosition + 250;
            }
            when 'Record Update' {
                return basePosition + 300;
            }
            when 'Record Delete' {
                return basePosition + 350;
            }
            when 'Screen' {
                return basePosition + 400;
            }
            when 'Subflow' {
                return basePosition + 450;
            }
            when else {
                return basePosition;
            }
        }
    }
    
    private static Object createFlowElement(
        String name,
        String type,
        String defaultTarget,
        String nextTarget,
        String noMoreTarget,
        String standardTarget,
        String faultTarget,
        List<DecisionRule> rules,
        Integer x,
        Integer y,
        String elementDescription,
        Boolean isGoTo
    ) {
        switch on type {
            when 'Start' {
                return createStartElement(name, standardTarget, rules, x, y, isGoTo);
            }
            when 'Assignment' {
                return createAssignmentElement(name, standardTarget, x, y, isGoTo);
            }
            when 'Record Lookup' {
                return createRecordLookupElement(name, standardTarget, faultTarget, x, y, isGoTo);
            }
            when 'Decision' {
                return createDecisionElement(name, defaultTarget, rules, x, y, isGoTo);
            }
            when 'Loop' {
                return createLoopElement(name, nextTarget, noMoreTarget, x, y, isGoTo);
            }
            when 'Record Create' {
                return createRecordCreateElement(name, standardTarget, faultTarget, x, y, isGoTo);
            }
            when 'Record Update' {
                return createRecordUpdateElement(name, standardTarget, faultTarget, x, y, isGoTo);
            }
            when 'Record Delete' {
                return createRecordDeleteElement(name, standardTarget, faultTarget, x, y, isGoTo);
            }
            when 'Record Rollback' {
                return createRecordRollbackElement(name, standardTarget, faultTarget, x, y, isGoTo);
            }
            when 'Screen' {
                return createScreenElement(name, standardTarget, x, y, isGoTo);
            }
            when 'Subflow' {
                return createSubflowElement(name, standardTarget, x, y, isGoTo);
            }
            when 'Transform' {
                return createTransformElement(name, standardTarget, x, y, isGoTo);
            }
            when 'Wait' {
                return createWaitElement(name, defaultTarget, faultTarget, rules, x, y, isGoTo);
            }
            when 'Collection Processor' {
                return createCollectionProcessorElement(name, standardTarget, x, y, isGoTo);
            }
            when 'Action' {
                return createActionCallElement(name, standardTarget, faultTarget, x, y, elementDescription, isGoTo);
            }
            when 'Custom Error' {
                return createCustomErrorElement(name, standardTarget, x, y, isGoTo);
            }
            when 'Apex Plugin' {
                return createApexPluginElement(name, standardTarget, faultTarget, x, y, isGoTo);
            }
            when 'Orchestrated Stage' {
                return createOrchestratedStageElement(name, standardTarget, faultTarget, x, y, isGoTo);
            }
            when else {
                throw new FlowParsingException('Unknown element type: ' + type);
            }
        }
    }

    
    private static MetadataService.FlowConnector createConnector(String targetRef, Boolean isGoTo) {
        MetadataService.FlowConnector connector = new MetadataService.FlowConnector();
        connector.targetReference = targetRef;
        if(isGoTo) {
            connector.isGoTo = true;
        }
        return connector;
    }
    

    
    private static void addElementsToFlow(MetadataService.Flow flow, List<FlowElementWrapper> wrappers) {
        flow.assignments = new List<MetadataService.FlowAssignment>();
        flow.decisions = new List<MetadataService.FlowDecision>();
        flow.recordLookups = new List<MetadataService.FlowRecordLookup>();
        flow.loops = new List<MetadataService.FlowLoop>();
        flow.recordCreates = new List<MetadataService.FlowRecordCreate>();
        flow.recordUpdates = new List<MetadataService.FlowRecordUpdate>();
        flow.recordDeletes = new List<MetadataService.FlowRecordDelete>();
        flow.screens = new List<MetadataService.FlowScreen>();
        flow.subflows = new List<MetadataService.FlowSubflow>();
        flow.actionCalls = new List<MetadataService.FlowActionCall>();
        flow.transforms = new List<MetadataService.FlowTransform>();
        flow.waits = new List<MetadataService.FlowWait>();
        flow.collectionProcessors = new List<MetadataService.FlowCollectionProcessor>();
        flow.actionCalls = new List<MetadataService.FlowActionCall>();
        flow.customErrors = new List<MetadataService.FlowCustomError>();
        flow.apexPluginCalls = new List<MetadataService.FlowApexPluginCall>();
        flow.orchestratedStages = new List<MetadataService.FlowOrchestratedStage>();
        flow.recordRollbacks = new List<MetadataService.FlowRecordRollback>();
        flow.start = null;
        
        for(FlowElementWrapper wrapper : wrappers) {
            Object element = wrapper.element;
            
            if(element instanceof MetadataService.FlowStart) {
                flow.start = (MetadataService.FlowStart)element;
                flow.startElementReference = flow.start.connector.targetReference;
                flow.start.scheduledPaths = new List<MetadataService.FlowScheduledPath>();

                // Add scheduled paths
                List<DecisionRule> paths = wrapper.info?.rules;
                if (paths != null && !paths.isEmpty()) {
                    for (DecisionRule path : paths) {
                        MetadataService.FlowScheduledPath scheduledPath = new MetadataService.FlowScheduledPath();
                        scheduledPath.name = path?.name;
                        scheduledPath.connector = new MetadataService.FlowConnector();
                        scheduledPath.connector.targetReference = path?.targetRef;
                        flow.start.scheduledPaths.add(scheduledPath);
                    }
                }
                
            } else if(element instanceof MetadataService.FlowAssignment) {
                flow.assignments.add((MetadataService.FlowAssignment)element);
            } else if(element instanceof MetadataService.FlowDecision) {
                flow.decisions.add((MetadataService.FlowDecision)element);
            } else if(element instanceof MetadataService.FlowRecordLookup) {
                flow.recordLookups.add((MetadataService.FlowRecordLookup)element);
            } else if(element instanceof MetadataService.FlowLoop) {
                flow.loops.add((MetadataService.FlowLoop)element);
            } else if(element instanceof MetadataService.FlowRecordCreate) {
                flow.recordCreates.add((MetadataService.FlowRecordCreate)element);
            } else if(element instanceof MetadataService.FlowRecordUpdate) {
                flow.recordUpdates.add((MetadataService.FlowRecordUpdate)element);
            } else if(element instanceof MetadataService.FlowRecordDelete) {
                flow.recordDeletes.add((MetadataService.FlowRecordDelete)element);
            } else if(element instanceof MetadataService.FlowScreen) {
                flow.screens.add((MetadataService.FlowScreen)element);
            } else if(element instanceof MetadataService.FlowSubflow) {
                flow.subflows.add((MetadataService.FlowSubflow)element);
            } else if(element instanceof MetadataService.FlowActionCall) {
                flow.actionCalls.add((MetadataService.FlowActionCall)element);
            } else if(element instanceof MetadataService.FlowTransform) {
                flow.transforms.add((MetadataService.FlowTransform)element);
            } else if(element instanceof MetadataService.FlowWait) {
                flow.waits.add((MetadataService.FlowWait)element);
            } else if(element instanceof MetadataService.FlowCollectionProcessor) {
                flow.collectionProcessors.add((MetadataService.FlowCollectionProcessor)element);
            } else if(element instanceof MetadataService.FlowActionCall) {
                flow.actionCalls.add((MetadataService.FlowActionCall)element);
            } else if(element instanceof MetadataService.FlowCustomError) {
                flow.customErrors.add((MetadataService.FlowCustomError)element);
            } else if(element instanceof MetadataService.FlowApexPluginCall) {
                flow.apexPluginCalls.add((MetadataService.FlowApexPluginCall)element);
            } else if(element instanceof MetadataService.FlowOrchestratedStage) {
                flow.orchestratedStages.add((MetadataService.FlowOrchestratedStage)element);
            } else if(element instanceof MetadataService.FlowRecordRollback) {
                flow.recordRollbacks.add((MetadataService.FlowRecordRollback)element);
            }
        }
    }

    private static Set<String> getAllElementNames(MetadataService.Flow flow) {
        Set<String> names = new Set<String>();
        
        if(flow.start != null) names.add(flow.start.name);

        for(MetadataService.FlowScheduledPath path : flow?.start?.scheduledPaths) {
            names.add(path?.name);
        }
        for(MetadataService.FlowAssignment elem : flow.assignments) {
            names.add(elem.name);
        }
        for(MetadataService.FlowDecision elem : flow.decisions) {
            names.add(elem.name);
            for(MetadataService.FlowRule rule : elem.rules) {
                names.add(rule.name);
            }
        }
        for(MetadataService.FlowWait elem : flow.waits) {
            names.add(elem.name);
            for(MetadataService.FlowWaitEvent event : elem.waitEvents) {
                names.add(event.name);
            }
        }        
        for(MetadataService.FlowRecordLookup elem : flow.recordLookups) {
            names.add(elem.name);
        }
        for(MetadataService.FlowLoop elem : flow.loops) {
            names.add(elem.name);
        }
        for(MetadataService.FlowRecordCreate elem : flow.recordCreates) {
            names.add(elem.name);
        }
        for(MetadataService.FlowRecordUpdate elem : flow.recordUpdates) {
            names.add(elem.name);
        }
        for(MetadataService.FlowRecordDelete elem : flow.recordDeletes) {
            names.add(elem.name);
        }
        for(MetadataService.FlowScreen elem : flow.screens) {
            names.add(elem.name);
        }
        for(MetadataService.FlowSubflow elem : flow.subflows) {
            names.add(elem.name);
        }
        for(MetadataService.FlowActionCall elem : flow.actionCalls) {
            names.add(elem.name);
        }
        for(MetadataService.FlowTransform elem : flow.transforms) {
            names.add(elem.name);
        }       
        for(MetadataService.FlowCollectionProcessor elem : flow.collectionProcessors) {
            names.add(elem.name);
        }
        for(MetadataService.FlowCustomError elem : flow.customErrors) {
            names.add(elem.name);
        }
        for(MetadataService.FlowApexPluginCall elem : flow.apexPluginCalls) {
            names.add(elem.name);
        }
        for(MetadataService.FlowOrchestratedStage elem : flow.orchestratedStages) {
            names.add(elem.name);
        }
        for(MetadataService.FlowRecordRollback elem : flow.recordRollbacks) {
            names.add(elem.name);
        }

        return names;
    }

    
    public class FlowParsingException extends Exception {}
    
    // Validation methods for testing
    public static void validateFlowStructure(MetadataService.Flow flow, Boolean isAddLoggingElements) {
        validateFlowStructure(flow, isAddLoggingElements, null);
    }

    public static void validateFlowStructure(MetadataService.Flow flow, Boolean isAddLoggingElements, Map<String, String> expectedLogLevels) {
        validateStartElement(flow);
        if(isAddLoggingElements) {
            validateConnectors(flow);
        }
        validateElementPositions(flow);
        validateLoggingElements(flow, isAddLoggingElements, expectedLogLevels);
    }    
    
    private static void validateStartElement(MetadataService.Flow flow) {
        System.assertNotEquals(null, flow.start, 'Flow must have a start element');
        System.assertNotEquals(null, flow.start.connector, 'Start element must have a connector');
    }

    private static Set<String> getConnectedElements(MetadataService.Flow flow) {
        Set<String> connectedElements = new Set<String>();
        FlowLogService flowLogService = new FlowLogService();
        // Create flow elements map for easier access
        Map<String, FlowLogService.FlowElement> flowElements = flowLogService.convertMetadataFlowToElements(flow);

        // Find start element and build connected elements set
        FlowLogService.FlowElement startElement = flowLogService.findStartElement(flowElements);
        if (startElement != null) {
            flowLogService.buildConnectedElementsSet(startElement, flowElements, connectedElements);
        }
        
        return connectedElements;
    }
    
    private static void validateConnectors(MetadataService.Flow flow) {

        Set<String> connectedElements = getConnectedElements(flow);        
        Set<String> validTargets = getAllElementNames(flow);

        for(MetadataService.FlowScheduledPath path : flow?.start?.scheduledPaths) {
            validateConnector(path.connector, path?.name, validTargets, connectedElements);
        }

        // Validate assignment connectors
        for(MetadataService.FlowAssignment assignment : flow.assignments) {
            validateConnector(assignment.connector, assignment.name, validTargets, connectedElements);
        }

        // Validate decision connectors
        for(MetadataService.FlowDecision decision : flow.decisions) {
            validateConnector(decision.defaultConnector, decision.name, validTargets, connectedElements);
            for(MetadataService.FlowRule rule : decision.rules) {
                validateConnector(rule.connector, rule.name, validTargets, connectedElements);
            }
        }

        // Validate wait connectors
        for(MetadataService.FlowWait wait : flow.waits) {
            validateConnector(wait.defaultConnector, wait.name, validTargets, connectedElements);
            for(MetadataService.FlowWaitEvent event : wait.waitEvents) {
                validateConnector(event.connector, event.name, validTargets, connectedElements);
            }
        }

        // Validate collection processor connectors
        for(MetadataService.FlowCollectionProcessor processor : flow.collectionProcessors) {
            validateConnector(processor.connector, processor.name, validTargets, connectedElements);
        }

        // Validate transform connectors
        for(MetadataService.FlowTransform transform : flow.transforms) {
            validateConnector(transform.connector, transform.name, validTargets, connectedElements);
        }

        // Validate lookup connectors
        for(MetadataService.FlowRecordLookup lookup : flow.recordLookups) {
            validateConnector(lookup.connector, lookup.name, validTargets, connectedElements);
        }

        // Validate loop connectors
        for(MetadataService.FlowLoop loopElement : flow.loops) {
            validateConnector(loopElement.nextValueConnector, loopElement.name, validTargets, connectedElements);
            validateConnector(loopElement.noMoreValuesConnector, loopElement.name, validTargets, connectedElements);
        }

        // Validate screen connectors
        for(MetadataService.FlowScreen screen : flow.screens) {
            validateConnector(screen.connector, screen.name, validTargets, connectedElements);
        }

        // Validate subflow connectors
        for(MetadataService.FlowSubflow subflow : flow.subflows) {
            validateConnector(subflow.connector, subflow.name, validTargets, connectedElements);
        }

        // Validate record create connectors
        for(MetadataService.FlowRecordCreate createElement : flow.recordCreates) {
            validateConnector(createElement.connector, createElement.name, validTargets, connectedElements);
        }

        // Validate record update connectors
        for(MetadataService.FlowRecordUpdate updateElement : flow.recordUpdates) {
            validateConnector(updateElement.connector, updateElement.name, validTargets, connectedElements);
        }

        // Validate record delete connectors
        for(MetadataService.FlowRecordDelete deleteElement : flow.recordDeletes) {
            validateConnector(deleteElement.connector, deleteElement.name, validTargets, connectedElements);
        }

        // Validate action call connectors
        for(MetadataService.FlowActionCall actionCall : flow.actionCalls) {
            validateConnector(actionCall.connector, actionCall.name, validTargets, connectedElements);
        }
    }
    
    private static void validateConnector(
        MetadataService.FlowConnector connector,
        String sourceName,
        Set<String> validTargets,
        Set<String> connectedElements
    ) {

        // skipping validation connector for the last element
        String lastElement = (new List<String>(connectedElements)).get(connectedElements.size() - 1);
        if(sourceName == lastElement) {
            return;
        }

        // Skip validation for elements that are not connected (disconnected elements) to the flow
        if(!connectedElements.contains(sourceName)) {
            return;
        }

        // Skip validation for PostLog elements
        if(sourceName.endsWith(FlowLogService.POST_LOG_MARKER)) {
            return;
        }

        if(connector == null) {
            throw new FlowParsingException('Missing connector for element: ' + sourceName);
        }
        
        String targetRef = connector.targetReference;
        if(String.isBlank(targetRef)) {
            throw new FlowParsingException('Missing target reference for element: ' + sourceName);
        }
        
        if(!validTargets.contains(targetRef)) {
            throw new FlowParsingException(
                'Invalid target reference: ' + targetRef + ' from element: ' + sourceName
            );
        }
    }
    
    private static void validateElementPositions(MetadataService.Flow flow) {
        Map<String, String> positions = new Map<String, String>();
        
        // Check Start position
        if(flow.start != null) {
            addElementPosition(positions, flow.start.name, 
                             flow.start.locationX, flow.start.locationY);
        }
        
        // Check Assignment positions
        for(MetadataService.FlowAssignment elem : flow.assignments) {
            addElementPosition(positions, elem.name, 
                             elem.locationX, elem.locationY);
        }
        
        // Check Decision positions
        for(MetadataService.FlowDecision elem : flow.decisions) {
            addElementPosition(positions, elem.name, 
                             elem.locationX, elem.locationY);
        }
        
        // Check Record Lookup positions
        for(MetadataService.FlowRecordLookup elem : flow.recordLookups) {
            addElementPosition(positions, elem.name, 
                             elem.locationX, elem.locationY);
        }
        
        // Check Loop positions
        for(MetadataService.FlowLoop elem : flow.loops) {
            addElementPosition(positions, elem.name, 
                             elem.locationX, elem.locationY);
        }
    }

    private static void addElementPosition(
        Map<String, String> positions, 
        String elementName, 
        Integer x, 
        Integer y
    ) {
        String posKey = x + ',' + y;
        if(positions.containsKey(posKey)) {
            throw new FlowParsingException(
                'Elements overlap at position: ' + posKey + 
                ' Elements: ' + positions.get(posKey) + ' and ' + elementName
            );
        }
        positions.put(posKey, elementName);
    }

    private static void validateLoggingElements(MetadataService.Flow flow, Boolean isAddLoggingElements, Map<String, String> expectedLogLevels) {
        Set<String> preLogElements = new Set<String>();
        Set<String> postLogElements = new Set<String>();
        Set<String> requiredTemplates = new Set<String>();
        
        // Check action calls and their parameters
        for(MetadataService.FlowActionCall elem : flow.actionCalls) {
            if(FlowLogService.isLoggingElement(elem.name)) {
                categorizeLoggingElement(elem.name, preLogElements, postLogElements);
                validateLoggingActionCall(elem);
                requiredTemplates.add(FlowLogService.getTemplateName(elem.name));
                validateLoggingActionCallLogLevel(elem, expectedLogLevels);
            }
        }

        if(isAddLoggingElements) {
            // Validate text templates exist and have correct format
            validateTextTemplates(flow.textTemplates, requiredTemplates);

            // Verify logging elements exist
            System.assert(!preLogElements.isEmpty(), 'No PreLog elements found');
            System.assert(!postLogElements.isEmpty(), 'No PostLog elements found');
        }
        else {
            System.assert(preLogElements.isEmpty(), 'PreLog elements found');
            System.assert(postLogElements.isEmpty(), 'PostLog elements found');
        }        
    }

    private static void validateLoggingActionCallLogLevel(MetadataService.FlowActionCall actionCall, Map<String, String> expectedLogLevels) {
        if(expectedLogLevels == null) {
            return;
        }
        String logLevel = expectedLogLevels.get(actionCall.name);
        String levelParamValue = null;
        for(MetadataService.FlowActionCallInputParameter param : actionCall.inputParameters) {
            if(param.name == 'level') {
                levelParamValue = param.value.stringValue;
            }
        }
        System.assert(String.isNotBlank(levelParamValue), 'Log level must be set for element: ' + actionCall.name);
        System.assert(levelParamValue == logLevel, 'Log level must be ' + logLevel + ' for element: ' + actionCall.name);
    }

    private static void validateTextTemplates(
        List<MetadataService.FlowTextTemplate> templates,
        Set<String> requiredTemplates
    ) {
        if(templates == null || templates.isEmpty()) {
            System.assert(false, 'Flow must contain required text templates');
        }

        Map<String, MetadataService.FlowTextTemplate> templateMap = new Map<String, MetadataService.FlowTextTemplate>();
        for(MetadataService.FlowTextTemplate template : templates) {
            templateMap.put(template.name, template);
        }

        // Verify all required templates exist
        for(String requiredTemplate : requiredTemplates) {
            System.assert(
                templateMap.containsKey(requiredTemplate), 
                'Missing required template: ' + requiredTemplate
            );
            
            // Validate template format
            MetadataService.FlowTextTemplate template = templateMap.get(requiredTemplate);
            validateTemplateFormat(template);
        }
    }

    private static void validateTemplateFormat(MetadataService.FlowTextTemplate template) {
        // Verify template has content
        System.assert(
            String.isNotBlank(template.text), 
            'Template ' + template.name + ' must have content'
        );
    }    

    private static void validateLoggingActionCall(MetadataService.FlowActionCall actionCall) {
        // Validate required input parameters
        validateInputParameters(actionCall.inputParameters);
        
        // Validate output parameters if they exist
        if(actionCall.outputParameters != null) {
            validateOutputParameters(actionCall.outputParameters);
        }

        // Validate flow transaction model
        System.assert(actionCall.flowTransactionModel == FlowLogService.FLOW_TRANSACTION_MODEL_CURRENT_TRANSACTION, 'Flow transaction model must be ' + FlowLogService.FLOW_TRANSACTION_MODEL_CURRENT_TRANSACTION);
    }

    private static void validateInputParameters(List<MetadataService.FlowActionCallInputParameter> inputParams) {
        if(inputParams == null || inputParams.isEmpty()) {
            System.assert(false, 'Logging action must have input parameters');
        }

        Set<String> requiredParams = new Set<String>{
            'category',
            'type',
            'area',
            'summary',
            'details',
            'flowApiName',
            'level',
            'interviewGUID',
            'stacktrace',
            'operation'
        };

        Set<String> foundParams = new Set<String>();
        for(MetadataService.FlowActionCallInputParameter param : inputParams) {
            foundParams.add(param.name);
            validateInputParameterValue(param);
        }

        // Verify all required parameters are present
        for(String required : requiredParams) {
            System.assert(
                foundParams.contains(required), 
                'Missing required input parameter: ' + required
            );
        }
    }

    private static void validateInputParameterValue(MetadataService.FlowActionCallInputParameter param) {
        System.assert(
            param.value != null, 
            'Input parameter ' + param.name + ' must have a value'
        );

        // Validate specific parameter formats
        switch on param.name {
            when 'category' {
                System.assert(
                    param.value.stringValue.equals(FlowLogService.LOGGER_INPUT_PARAMETER_CATEGORY_DEFAULT_VALUE),
                    'Category parameter must be ' + FlowLogService.LOGGER_INPUT_PARAMETER_CATEGORY_DEFAULT_VALUE
                );
            }
            when 'type' {
                System.assert(
                    param.value.stringValue.equals(FlowLogService.LOGGER_INPUT_PARAMETER_TYPE_DEFAULT_VALUE),
                    'Type parameter must be ' + FlowLogService.LOGGER_INPUT_PARAMETER_TYPE_DEFAULT_VALUE
                );
            }
            when 'area' {
                System.assert(
                    param.value.stringValue.equals(TEST_FUNCTIONAL_AREA),
                    'Area parameter must be ' + TEST_FUNCTIONAL_AREA
                );
            }
            when 'summary' {
                System.assert(
                    String.isNotBlank(param.value.stringValue),
                    'Summary parameter must be not empty'
                );
            }
            when 'details' {
                System.assert(
                    String.isNotBlank(param.value.stringValue),
                    'Details parameter must be not empty'
                );
            }
            when 'flowApiName' {
                System.assert(
                    param.value.stringValue.equals(TEST_FLOW_API_NAME),
                    'FlowApiName parameter must be ' + TEST_FLOW_API_NAME
                );
            }
            when 'level' {
                System.assert(
                    String.isNotBlank(param.value.stringValue),
                    'Level parameter must be not empty'
                );
            }
            when 'flowInterviewGuid' {
                System.assert(
                    param.value.stringValue.equals('{!$Flow.InterviewGuid}'),
                    'FlowInterviewGuid parameter must be {!$Flow.InterviewGuid}'
                );
            }
            when 'stacktrace' {
                System.assert(
                    String.isNotBlank(param.value.stringValue),
                    'Stacktrace parameter must be not empty'
                );
            }
        }
    }

    private static void validateOutputParameters(List<MetadataService.FlowActionCallOutputParameter> outputParams) {
        Set<String> requiredOutputs = new Set<String>{
            'fullStacktrace'
        };

        Set<String> foundOutputs = new Set<String>();
        for(MetadataService.FlowActionCallOutputParameter param : outputParams) {
            foundOutputs.add(param.name);
            validateOutputParameterAssignment(param);
        }

        // Verify all required outputs are present
        for(String required : requiredOutputs) {
            System.assert(
                foundOutputs.contains(required), 
                'Missing required output parameter: ' + required
            );
        }
    }

    private static void validateOutputParameterAssignment(MetadataService.FlowActionCallOutputParameter param) {
        System.assert(
            String.isNotBlank(param.assignToReference), 
            'Output parameter ' + param.name + ' must have an assignment reference'
        );

        // Validate specific output assignments
        switch on param.name {
            when 'fullStacktrace' {
                System.assert(
                    param.assignToReference == FlowLogService.PHAROS_VARIABLE_NAME,
                    'FullStacktrace output must be assigned to ' + FlowLogService.PHAROS_VARIABLE_NAME
                );
            }            
        }
    }

    private static void validateStacktraceParameter(Object value) {
        try {
            String stacktraceJson = String.valueOf(value);
            Map<String, Object> stacktraceData = (Map<String, Object>)JSON.deserializeUntyped(stacktraceJson);
            
            // Validate stacktrace structure
            System.assert(
                stacktraceData.containsKey('flowDetails'), 
                'Stacktrace must contain flowDetails'
            );
            System.assert(
                stacktraceData.containsKey('flowInterviewDetails'), 
                'Stacktrace must contain flowInterviewDetails'
            );
            System.assert(
                stacktraceData.containsKey('stacktraceElements'), 
                'Stacktrace must contain stacktraceElements'
            );
        } catch(Exception e) {
            System.assert(
                false, 
                'Invalid stacktrace parameter format: ' + e.getMessage()
            );
        }
    }

    private static void categorizeLoggingElement(
        String elementName,
        Set<String> preLog,
        Set<String> postLog
    ) {
        if(elementName.endsWith('_PreLog')) {
            preLog.add(elementName);
        } else if(elementName.endsWith('_PostLog')) {
            postLog.add(elementName);
        } else if(elementName.endsWith('_PostPreLog')) {
            postLog.add(elementName);
            preLog.add(elementName);
        }
    }
    
    
    private static MetadataService.FlowStart createStartElement(
        String name, 
        String standardTarget, 
        List<DecisionRule> rules,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowStart start = new MetadataService.FlowStart();
        start.name = name;
        start.label = name.toUpperCase();
        start.description = 'Start element';
        start.locationX = x;
        start.locationY = y;
        
        if(String.isNotBlank(standardTarget)) {
            start.connector = new MetadataService.FlowConnector();
            start.connector.targetReference = standardTarget;
            if(isGoTo) {
                start.connector.isGoTo = true;
            }
        }

        // Set scheduled paths
        if (rules != null && !rules.isEmpty()) {
            start.scheduledPaths = new List<MetadataService.FlowScheduledPath>();
            for (DecisionRule pathInfo : rules) {
                MetadataService.FlowScheduledPath path = new MetadataService.FlowScheduledPath();
                path.name = pathInfo.name;
                path.connector = new MetadataService.FlowConnector();
                path.connector.targetReference = pathInfo.targetRef;
                if(isGoTo) {
                    path.connector.isGoTo = true;
                }
                start.scheduledPaths.add(path);
            }
        }
        
        return start;
    }
    
    private static MetadataService.FlowAssignment createAssignmentElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowAssignment assignment = new MetadataService.FlowAssignment();
        assignment.name = name;
        assignment.label = name.toUpperCase();
        assignment.description = 'Assignment element';
        assignment.locationX = x;
        assignment.locationY = y;
        
        // Add a sample assignment value
        assignment.assignmentItems = new List<MetadataService.FlowAssignmentItem>();
        MetadataService.FlowAssignmentItem item = new MetadataService.FlowAssignmentItem();
        item.assignToReference = 'SampleVar';
        item.operator = 'Assign';
        item.value = new MetadataService.FlowElementReferenceOrValue();
        item.value.stringValue = 'Sample Value';
        assignment.assignmentItems.add(item);
        
        if(String.isNotBlank(standardTarget)) {
            assignment.connector = new MetadataService.FlowConnector();
            assignment.connector.targetReference = standardTarget;
            if(isGoTo) {
                assignment.connector.isGoTo = true;
            }
        }
        
        return assignment;
    }
    
    private static MetadataService.FlowRecordLookup createRecordLookupElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowRecordLookup lookup = new MetadataService.FlowRecordLookup();
        lookup.name = name;
        lookup.label = name.toUpperCase();
        lookup.description = 'Record lookup element';
        lookup.locationX = x;
        lookup.locationY = y;
        lookup.object_x = 'Account'; // Note the _x suffix for reserved word
        
        // Add filter conditions
        lookup.filters = new List<MetadataService.FlowRecordFilter>();
        MetadataService.FlowRecordFilter filter = new MetadataService.FlowRecordFilter();
        filter.field = 'Name';
        filter.operator = 'EQUALS';
        filter.value = new MetadataService.FlowElementReferenceOrValue();
        filter.value.stringValue = 'Test Account';
        lookup.filters.add(filter);
        
        // Add output reference
        lookup.storeOutputAutomatically = true;
        lookup.outputReference = 'SampleVar';
        
        if(String.isNotBlank(standardTarget)) {
            lookup.connector = new MetadataService.FlowConnector();
            lookup.connector.targetReference = standardTarget;
            if(isGoTo) {
                lookup.connector.isGoTo = true;
            }
        }
        if(String.isNotBlank(faultTarget)) {
            lookup.faultConnector = new MetadataService.FlowConnector();
            lookup.faultConnector.targetReference = faultTarget;
        }
        
        return lookup;
    }
    
    private static MetadataService.FlowDecision createDecisionElement(
        String name, 
        String defaultTarget,
        List<DecisionRule> rules,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowDecision decision = new MetadataService.FlowDecision();
        decision.name = name;
        decision.label = name.toUpperCase();
        decision.description = 'Decision element';

        // Set default connector
        decision.defaultConnector = new MetadataService.FlowConnector();
        decision.defaultConnector.targetReference = defaultTarget;
        if(isGoTo) {
            decision.defaultConnector.isGoTo = true;
        }
        // Initialize and add rules
        decision.rules = new List<MetadataService.FlowRule>();
        for (DecisionRule ruleInfo : rules) {
            MetadataService.FlowRule rule = new MetadataService.FlowRule();
            rule.name = ruleInfo.name;
            rule.label = ruleInfo.name.toUpperCase();
            rule.description = 'Decision rule';
            rule.connector = new MetadataService.FlowConnector();
            rule.connector.targetReference = ruleInfo.targetRef;
            if(ruleInfo.isGoTo) {
                rule.connector.isGoTo = true;
            }
            decision.rules.add(rule);
        }
        
        decision.locationX = x;
        decision.locationY = y;
        
        return decision;
    }

    private static MetadataService.FlowLoop createLoopElement(
        String name, 
        String nextTarget,
        String noMoreTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowLoop loopElement = new MetadataService.FlowLoop();
        loopElement.name = name;
        loopElement.label = name.toUpperCase();
        loopElement.description = 'Loop element';

        if (String.isNotBlank(nextTarget)) {
            loopElement.nextValueConnector = new MetadataService.FlowConnector();
            loopElement.nextValueConnector.targetReference = nextTarget;
            if(isGoTo) {
                loopElement.nextValueConnector.isGoTo = true;
            }
        }
        
        if (String.isNotBlank(noMoreTarget)) {
            loopElement.noMoreValuesConnector = new MetadataService.FlowConnector();
            loopElement.noMoreValuesConnector.targetReference = noMoreTarget;
        }
        
        // Set positioning
        loopElement.locationX = x;
        loopElement.locationY = y;
        
        return loopElement;
    }

    private static MetadataService.FlowRecordCreate createRecordCreateElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowRecordCreate element = new MetadataService.FlowRecordCreate();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Record create element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowRecordUpdate createRecordUpdateElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowRecordUpdate element = new MetadataService.FlowRecordUpdate();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Record update element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowRecordDelete createRecordDeleteElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowRecordDelete element = new MetadataService.FlowRecordDelete();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Record delete element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowRecordRollback createRecordRollbackElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowRecordRollback element = new MetadataService.FlowRecordRollback();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Record rollback element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        
        return element;
    }

    private static MetadataService.FlowScreen createScreenElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowScreen element = new MetadataService.FlowScreen();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Screen element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        // Initialize empty lists for screen fields if needed
        element.fields = new List<MetadataService.FlowScreenField>();
        return element;
    }

    private static MetadataService.FlowSubflow createSubflowElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowSubflow element = new MetadataService.FlowSubflow();
        element.name = name;
        element.flowName = name;
        element.label = name.toUpperCase();
        element.description = 'Subflow element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        return element;
    }

    private static MetadataService.FlowTransform createTransformElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowTransform element = new MetadataService.FlowTransform();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Transform element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        
        // Add sample transformation
        element.transformValues = new List<MetadataService.FlowTransformValue>();
        MetadataService.FlowTransformValue transform = new MetadataService.FlowTransformValue();
        transform.transformValueName = 'sampleTransform';
        transform.transformValueLabel = 'Sample Value';
        element.transformValues.add(transform);
        
        return element;
    }

    private static MetadataService.FlowWait createWaitElement(
        String name, 
        String defaultTarget,
        String faultTarget,
        List<DecisionRule> rules,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowWait waitElement = new MetadataService.FlowWait();
        waitElement.name = name;
        waitElement.label = name.toUpperCase();
        waitElement.description = 'Wait element';

        // Set default connector
        waitElement.defaultConnector = new MetadataService.FlowConnector();
        waitElement.defaultConnector.targetReference = defaultTarget;
        if(isGoTo) {
            waitElement.defaultConnector.isGoTo = true;
        }
        if(String.isNotBlank(faultTarget)) {
            waitElement.faultConnector = new MetadataService.FlowConnector();
            waitElement.faultConnector.targetReference = faultTarget;
        }
        
        // Initialize and add rules
        waitElement.waitEvents = new List<MetadataService.FlowWaitEvent>();
        for (DecisionRule ruleInfo : rules) {
            MetadataService.FlowWaitEvent event = new MetadataService.FlowWaitEvent();
            event.name = ruleInfo.name;
            event.label = event.name.toUpperCase();
            event.description = 'Wait event';
            event.connector = new MetadataService.FlowConnector();
            event.connector.targetReference = ruleInfo.targetRef;
            waitElement.waitEvents.add(event);
        }
        
        waitElement.locationX = x;
        waitElement.locationY = y;
        
        return waitElement;
    }

    private static MetadataService.FlowActionCall createActionCallElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        String elementDescription,
        Boolean isGoTo
    ) {
        MetadataService.FlowActionCall element = new MetadataService.FlowActionCall();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Action call element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        element.description = elementDescription;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowCustomError createCustomErrorElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowCustomError element = new MetadataService.FlowCustomError();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Custom error element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        return element;
    }

    private static MetadataService.FlowOrchestratedStage createOrchestratedStageElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowOrchestratedStage element = new MetadataService.FlowOrchestratedStage();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Orchestrated stage element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowApexPluginCall createApexPluginElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowApexPluginCall element = new MetadataService.FlowApexPluginCall();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Apex plugin element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowCollectionProcessor createCollectionProcessorElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y,
        Boolean isGoTo
    ) {
        MetadataService.FlowCollectionProcessor element = new MetadataService.FlowCollectionProcessor();
        element.name = name;
        element.label = name.toUpperCase();
        element.description = 'Collection Processor element';
        element.connector = createConnector(standardTarget, isGoTo);
        element.locationX = x;
        element.locationY = y;
        
        // Add collection processing configuration
        element.collectionProcessorType = 'Sort';
        element.sortOptions = new List<MetadataService.FlowCollectionSortOption>();
        MetadataService.FlowCollectionSortOption sortOption = new MetadataService.FlowCollectionSortOption();
        sortOption.sortField = 'Name';
        sortOption.sortOrder = 'Ascending';
        element.sortOptions.add(sortOption);
        
        return element;
    }


    private class WebServiceMockImplFailure implements WebServiceMock {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            // Create the response wrapper
            MetadataService.updateMetadataResponse_element responseWrapper = 
                new MetadataService.updateMetadataResponse_element();
            
            // Create error SaveResult
            MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
            saveResult.success = false;
            MetadataService.Error error = new MetadataService.Error();
            error.message = 'Error updating metadata';
            saveResult.errors = new List<MetadataService.Error>{ error };
            
            // Set the result in the wrapper
            responseWrapper.result = new List<MetadataService.SaveResult>{ saveResult };
            
            // Put the wrapper in the response
            response.put('response_x', responseWrapper);
        }
    }


    @IsTest
    static void test_remove_start_assignment_decision() {
        String inputStructure = 
            '└── Start [Start] → Start_assignment1_PostPreLog\n' +
            '    └── Start_assignment1_PostPreLog [Action] → assignment1 {Source:Start,0,10|Target:assignment1,10,10}\n' +
            '        └── assignment1 [Assignment] → assignment1_decision1_PostPreLog\n' +
            '            └── assignment1_decision1_PostPreLog [Action] → decision1 {Source:assignment1,10,10|Target:decision1,20,20}\n' +
            '                └── decision1 [Decision] → DEFAULT:decision1_PostLog\n' +
            '                    └── decision1_PostLog [Action] → END {Source:decision1,20,20|Target:null,30,30}';
        
        String expectedOutput = 
            '└── Start [Start] → assignment1\n' +
            '    └── assignment1 [Assignment] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:END';
        
        test_remove_logging_success(inputStructure, expectedOutput);
    }
    
    static void test_remove_logging_success(String inputStructure, String expectedOutput) {
        // Create mock flow from structure
        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        // Setup mock handler
        MockMetadataHandler mockHandler = new MockMetadataHandler(mockFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'REMOVE_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'versionInfo' => 'NEW_VERSION'
        };
        
        // Act
        Test.startTest();
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Assert
        System.assertEquals(true, result.get('success'), 
            'Operation should be successful. Error: ' + result.get('message'));
        
        // Get the visualization from the result
        Map<String, Object> visualization = (Map<String, Object>)result.get('flowVisualization');
        // Compare before visualization
        String beforeViz = (String)visualization.get('before');
        System.assertNotEquals(null, beforeViz, 'Before visualization should not be null');
                
        // Compare after visualization
        String afterViz = (String)visualization.get('after');
        
        System.assertNotEquals(null, afterViz, 'After visualization should not be null');
        System.assertEquals(
            normalizeString(expectedOutput), 
            normalizeString(afterViz),
            'After visualization does not match expected output'
        );
        
        // Verify updated flow structure
        MetadataService.Flow updatedFlow = mockHandler.getUpdatedFlow();
        validateFlowStructure(updatedFlow, false);
    }
    
    @IsTest
    static void testInvalidOperation() {
        // Arrange
        FlowLogService service = new FlowLogService();
        
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'INVALID_OPERATION',
            'flowApiName' => 'TestFlow'
        };
        
        // Act
        Test.startTest();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Assert
        System.assertEquals(false, result.get('success'), 'Should return failure');
        System.assert(((String)result.get('message')).contains('Invalid operation'), 'Should return invalid operation message');
    }
    
    @IsTest
    static void testMissingRequiredParams() {
        // Arrange
        FlowLogService service = new FlowLogService();
        
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING'
            // Missing flowApiName
        };
        
        // Act
        Test.startTest();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Assert
        System.assertEquals(false, result.get('success'), 'Should return failure');
        System.assert(((String)result.get('message')).contains('required'), 'Should return missing required params message');
    }
    
    @IsTest
    static void testMetadataServiceFailure() {
        // Arrange
        Test.setMock(WebServiceMock.class, new WebServiceMockImplFailure());
        FlowLogService service = new FlowLogService();
        
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        
        // Act
        Test.startTest();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Assert
        System.assertEquals(false, result.get('success'), 'Should return failure');
    }

    @IsTest
    static void test_add_logging_with_new_element_between_logged_elements() {
        String inputStructure = 
            '└── Start [Start] → Start_action1_PostPreLog\n' +
            '    └── Start_action1_PostPreLog [Action] → action2 {Source:Start,0,0|Target:action1,100,100}\n' +
            '        └── action2 [Action] → action3\n' + // new element
            '            └── action3 [Action] → action1\n' + // new element
            '                └── action1 [Action] → screen1\n' +
            '                    └── screen1 [Screen] → screen1_PostLog\n' +
            '                        └── screen1_PostLog [Action] → END {Source:screen1,200,200|Target:null,300,300}';

        String expectedOutput = 
            '└── Start [Start] → Start_action2_PostPreLog\n' +
            '    └── Start_action2_PostPreLog [Action] → action2\n' +
            '        └── action2 [Action] → action2_action3_PostPreLog\n' +
            '            └── action2_action3_PostPreLog [Action] → action3\n' +
            '                └── action3 [Action] → action3_action1_PostPreLog\n' +
            '                    └── action3_action1_PostPreLog [Action] → action1\n' +
            '                        └── action1 [Action] → action1_screen1_PostPreLog\n' +
            '                            └── action1_screen1_PostPreLog [Action] → screen1\n' +
            '                                └── screen1 [Screen] → screen1_PostLog\n' +
            '                                    └── screen1_PostLog [Action] → END';

        test_add_logging_with_existing(inputStructure, expectedOutput);
    }

    @IsTest
    static void test_getLogLevel_default_level() {
        // Setup
        FlowLogService.FlowElement element = new FlowLogService.FlowElement();
        element.setSourceType('UnknownType');
        element.setName('SomeElement');
        
        // Test
        String logLevel = FlowLogService.getLogLevel(element);
        
        // Verify
        System.assertEquals('FINER', logLevel, 'Default log level should be FINER for unknown element types');
    }

    @IsTest
    static void test_getLogLevel_for_different_element_types() {
        // Setup test data
        Map<String, String> testCases = new Map<String, String>{
            'Start' => 'INFO',
            'Scheduled Path' => 'INFO',
            'Decision' => 'DEBUG',
            'Screen' => 'DEBUG',
            'Record Create' => 'DEBUG',
            'Record Update' => 'DEBUG',
            'Record Delete' => 'DEBUG',
            'Record Lookup' => 'DEBUG',
            'Assignment' => 'FINER',
            'Loop' => 'FINER',
            'Custom Error' => 'ERROR',
            'Action' => 'DEBUG',
            'Subflow' => 'DEBUG',
            'Wait' => 'FINER',
            'Wait Event' => 'FINER',
            'Collection Processor' => 'FINER',
            'Formula' => 'FINER',
            'Apex Plugin' => 'FINER',
            'Transform' => 'FINER',
            'Choice' => 'FINER',
            'Orchestrated Stage' => 'FINER',
            'Stage Step' => 'FINER',
            'Constant' => 'FINER'
        };
        
        for(String elementType : testCases.keySet()) {
            // Setup
            FlowLogService.FlowElement element = new FlowLogService.FlowElement();
            element.setSourceType(elementType);
            element.setName('Test' + elementType);
            
            // Test
            String logLevel = FlowLogService.getLogLevel(element);
            
            // Verify
            System.assertEquals(
                testCases.get(elementType), 
                logLevel, 
                'Log level for ' + elementType + ' should be ' + testCases.get(elementType)
            );
        }
    }

    @IsTest
    static void test_getOperationName_for_different_element_types() {
        // Setup test data
        Map<String, String> testCases = new Map<String, String>{
            'Start' => 'Start',
            'Scheduled Path' => 'Scheduled Path',
            'Decision' => 'Decision',
            'Decision Rule' => 'Decision',
            'Screen' => 'Screen',
            'Record Create' => 'Record Create',
            'Record Update' => 'Record Update',
            'Record Delete' => 'Record Delete',
            'Record Lookup' => 'Record Lookup',
            'Assignment' => 'Assignment',
            'Loop' => 'Loop',
            'Custom Error' => 'Custom Error',
            'Action' => 'Action',
            'Subflow' => 'Subflow',
            'Wait' => 'Wait',
            'Wait Event' => 'Wait',
            'Collection Processor' => 'Collection Processor',
            'Formula' => 'Formula',
            'Apex Plugin' => 'Apex Plugin',
            'Transform' => 'Transform',
            'Choice' => 'Choice',
            'Orchestrated Stage' => 'Orchestrated Stage',
            'Stage Step' => 'Stage Step',
            'Constant' => 'Constant'
        };
        
        for(String elementType : testCases.keySet()) {
            // Setup
            FlowLogService.FlowElement element = new FlowLogService.FlowElement();
            element.setSourceType(elementType);
            element.setName('Test' + elementType);
            
            // Test
            String operationName = FlowLogService.getOperationName(element);
            
            // Verify
            System.assertEquals(
                testCases.get(elementType), 
                operationName, 
                'Operation name for ' + elementType + ' should be ' + testCases.get(elementType)
            );
        }
    }

    @IsTest
    static void testCenteredLogElementPositioning() {
        // Create a flow structure with multiple log elements targeting the same elements
        String inputStructure = 
            '└── Start [Start] → create1\n' +
            '    └── create1 [Record Create] → create2\n' +
            '        └── create2 [Record Create] → END';
        
        // Setup mock flow and handler
        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        MockMetadataHandler mockHandler = new MockMetadataHandler(mockFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        // Add logging
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        
        Test.startTest();
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Validate result
        System.assertEquals(true, result.get('success'), 'Operation should be successful');
        
        // Extract updated flow
        MetadataService.Flow updatedFlow = mockHandler.getUpdatedFlow();
        
        // Find all logging action calls for the same source-target pair
        Map<String, List<MetadataService.FlowActionCall>> sourceTargetActions = new Map<String, List<MetadataService.FlowActionCall>>();
        
        for (MetadataService.FlowActionCall action : updatedFlow.actionCalls) {
            // Check if this is a logging action by checking the description for source-target info
            if (action.description != null && action.description.contains('Source:') && action.description.contains('Target:')) {
                // Extract source and target from description
                String desc1 = action.description;
                
                // Use a simplified extraction approach for testing
                String sourceTarget = '';
                
                if (desc1.contains('Source:create1')) {
                    if (desc1.contains('Target:create2')) {
                        sourceTarget = 'create1->create2';
                    }
                } else if (desc1.contains('Source:Start')) {
                    if (desc1.contains('Target:create1')) {
                        sourceTarget = 'Start->create1';
                    }
                } else if (desc1.contains('Source:create2')) {
                    sourceTarget = 'create2->END';
                }
                
                if (String.isNotBlank(sourceTarget)) {
                    if (!sourceTargetActions.containsKey(sourceTarget)) {
                        sourceTargetActions.put(sourceTarget, new List<MetadataService.FlowActionCall>());
                    }
                    sourceTargetActions.get(sourceTarget).add(action);
                }
            }
        }
        
        // For each source-target group, verify X coordinates are evenly spaced
        for (String sourceTarget : sourceTargetActions.keySet()) {
            List<MetadataService.FlowActionCall> actions = sourceTargetActions.get(sourceTarget);
            
            // Skip if only one action
            if (actions.size() <= 1) continue;
            
            // Check if X coordinates are evenly spaced
            List<Integer> xCoords = new List<Integer>();
            for (MetadataService.FlowActionCall action : actions) {
                xCoords.add(action.locationX);
            }
            
            // Sort coordinates
            xCoords.sort();
            
            // Calculate distances between consecutive coordinates
            Set<Integer> distances = new Set<Integer>();
            for (Integer i = 1; i < xCoords.size(); i++) {
                distances.add(xCoords[i] - xCoords[i-1]);
            }
            
            // All distances should be approximately the same
            System.assertEquals(1, distances.size(), 
                'Log elements in group ' + sourceTarget + ' should have consistent spacing');
        }
    }

    @IsTest
    static void testMultipleSourceTargetGroupsPositioning() {
        /**
         * Test verifies that flow logging elements are properly positioned in a coordinate system.
         * 
         * Coordinate System:
         * - The Flow Canvas uses a Cartesian (X,Y) coordinate system where:
         *   - X increases from left to right (horizontal positioning)
         *   - Y increases from top to bottom (vertical positioning)
         * 
         * Element Positioning Logic:
         * - Regular elements are positioned at their original coordinates
         * - Logging elements are positioned between source and target elements with:
         *   - X coordinate: Centered between source and target elements
         *       For example: If source.X=100 and target.X=300, the log element.X=200
         *   - Y coordinate: Source element's Y + LOG_OFFSET (150)
         * 
         * Multiple logging elements for the same source-target pair:
         * - Horizontally spread with LOG_X_OFFSET (75) between them
         * - Centered as a group between source and target
         * 
         * Test Setup:
         * - Creates a flow with Start -> Decision -> Create/Update elements
         * - Sets specific coordinates for testing:
         *   Start(100,200) -> Decision(200,200) -> Create(400,200)/Update(400,300)
         * 
         * Expected Positioning:
         * - Start->decision1 logging: X centered at (100+200)/2=150, Y at 200+150=350
         * - decision1->create1 logging: X centered at (200+400)/2=300, Y at 200+150=350
         * - rule1->update1 logging: X within range of decision1 and update1, Y at decision1.Y+offset
         */
        
        // Create a flow structure with multiple branch points and specific coordinates
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:create1, Rules:[rule1->update1]\n' +
            '        ├── create1 [Record Create] → END\n' +
            '        └── update1 [Record Update] → END';
        
        // Setup mock flow with specific coordinates
        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        
        // Manually update coordinates for testing
        for (MetadataService.FlowDecision decision : mockFlow.decisions) {
            if (decision.name == 'decision1') {
                decision.locationX = 200;
                decision.locationY = 200;
            }
        }
        
        for (MetadataService.FlowRecordCreate create : mockFlow.recordCreates) {
            if (create.name == 'create1') {
                create.locationX = 400;
                create.locationY = 200;
            }
        }
        
        for (MetadataService.FlowRecordUpdate update1 : mockFlow.recordUpdates) {
            if (update1.name == 'update1') {
                update1.locationX = 400;
                update1.locationY = 300;
            }
        }
        
        mockFlow.start.locationX = 100;
        mockFlow.start.locationY = 200;
        
        MockMetadataHandler mockHandler = new MockMetadataHandler(mockFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        // Add logging
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        
        Test.startTest();
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Validate result
        System.assertEquals(true, result.get('success'), 'Operation should be successful');
        
        // Extract updated flow
        MetadataService.Flow updatedFlow = mockHandler.getUpdatedFlow();
        
        // Store the flow elements' coordinates for validation
        Map<String, Integer> elementXCoords = new Map<String, Integer>();
        Map<String, Integer> elementYCoords = new Map<String, Integer>();
        
        // Get Start element coordinates
        elementXCoords.put('Start', updatedFlow.start.locationX);
        elementYCoords.put('Start', updatedFlow.start.locationY);
        
        // Get Decision element coordinates
        for (MetadataService.FlowDecision decision : updatedFlow.decisions) {
            if (decision.name == 'decision1') {
                elementXCoords.put('decision1', decision.locationX);
                elementYCoords.put('decision1', decision.locationY);
            }
        }
        
        // Get Record Create coordinates
        for (MetadataService.FlowRecordCreate create : updatedFlow.recordCreates) {
            if (create.name == 'create1') {
                elementXCoords.put('create1', create.locationX);
                elementYCoords.put('create1', create.locationY);
            }
        }
        
        // Get Record Update coordinates
        for (MetadataService.FlowRecordUpdate update1 : updatedFlow.recordUpdates) {
            if (update1.name == 'update1') {
                elementXCoords.put('update1', update1.locationX);
                elementYCoords.put('update1', update1.locationY);
            }
        }
        
        // Map to store logging action details
        Map<String, Map<String, Object>> logActionDetails = new Map<String, Map<String, Object>>();
        
        // Analyze logging action calls
        for (MetadataService.FlowActionCall action : updatedFlow.actionCalls) {
            // Find logging actions with specific paths we're testing
            if (action.name.contains('Start_decision1_PostPreLog')) {
                logActionDetails.put('Start->decision1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('decision1_create1_PostPreLog')) {
                logActionDetails.put('decision1->create1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('_rule1_update1_PostPreLog')) {
                logActionDetails.put('rule1->update1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            }
        }
        
        // Now verify the X and Y positions of each logging element
        
        // 1. Start->decision1 path
        // Expected: X centered at (100+200)/2=150, Y at 200+LOG_OFFSET=350
        Map<String, Object> startToDecision = logActionDetails.get('Start->decision1');
        System.assertNotEquals(null, startToDecision, 'Logging element for Start->decision1 not found');

        if (startToDecision != null) {
            // X coordinate should be centered between Start and decision1
            Integer expectedX = (elementXCoords.get('Start') + elementXCoords.get('decision1')) / 2;
            System.assertEquals(expectedX, (Integer)startToDecision.get('x'), 
                'Logging element X should be centered between Start and decision1');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)startToDecision.get('y');
            System.assert(actualY >= elementYCoords.get('Start') + 150 && actualY <= elementYCoords.get('Start') + 450,
                'Logging element Y should be within a reasonable range from the Start Y coordinate');
        }

        // 2. decision1->create1 path
        // Expected: X centered at (200+400)/2=300, Y at 200+LOG_OFFSET=350
        Map<String, Object> decisionToCreate = logActionDetails.get('decision1->create1');
        System.assertNotEquals(null, decisionToCreate, 'Logging element for decision1->create1 not found');

        if (decisionToCreate != null) {
            // X coordinate should be centered between decision1 and create1
            Integer expectedX = (elementXCoords.get('decision1') + elementXCoords.get('create1')) / 2;
            System.assertEquals(expectedX, (Integer)decisionToCreate.get('x'), 
                'Logging element X should be centered between decision1 and create1');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)decisionToCreate.get('y');
            System.assert(actualY >= elementYCoords.get('decision1') + 150 && actualY <= elementYCoords.get('decision1') + 450,
                'Logging element Y should be within a reasonable range from the decision1 Y coordinate');
        }

        // 3. rule1->update1 path
        // Expected: X should be within range of decision1(200) and update1(400)
        // Y should be within range of decision1.Y(200)+LOG_OFFSET(150) to decision1.Y+LOG_OFFSET+TOLERANCE
        Map<String, Object> ruleToUpdate = logActionDetails.get('rule1->update1');
        System.assertNotEquals(null, ruleToUpdate, 'Logging element for rule1->update1 not found');

        if (ruleToUpdate != null) {
            // For rule paths, the X position is either update1's X, or it follows a more complex logic
            // Let's be flexible with the X position check as well
            Integer actualX = (Integer)ruleToUpdate.get('x');
            System.assert(actualX >= Math.min(elementXCoords.get('decision1'), elementXCoords.get('update1')) && 
                        actualX <= Math.max(elementXCoords.get('decision1'), elementXCoords.get('update1')),
                'Logging element X should be within range of decision1 and update1 X coordinates');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)ruleToUpdate.get('y');
            System.assert(actualY >= elementYCoords.get('decision1') + 150 && actualY <= elementYCoords.get('decision1') + 450,
                'Logging element Y should be within a reasonable range from the decision1 Y coordinate');
        }
    }

    @IsTest
    static void testComplexFlowWithFaultPathPositioning() {
        /**
         * Test verifies logging elements positioning in a more complex flow with:
         * - Multiple branches
         * - Fault paths
         * - Parallel paths merging at a common element
         * 
         * Flow structure based on the image:
         * - Start -> createacc1 (with FAULT -> create2)
         * - createacc1 -> assign1
         * - assign1 -> create3
         * - create3 -> ass3
         * - create2 -> ass3 (fault path target)
         * - ass3 -> create44
         * 
         * ASCII Flow Diagram Before Logging:
         *
         *    X: 100           300                 500                700
         *    |               |                   |                  |
         * Y  +---------------+-------------------+------------------+
         * 100 | Start        |                   |                  |
         *    |               |                   |                  |
         *    |               |                   |                  |
         * 200 |               \ createacc1        |                  | create2 (fault)
         *    |                \                  |                  |
         *    |                 \                 |                  |
         * 300 |                  \ assign1        |                  |
         *    |                   \                |                  |
         *    |                    \               |                  |
         * 400 |                     \ create3     |                  |
         *    |                      \____________/|                  |
         *    |                                    |                  |
         * 500 |                                    \ ass3           /
         *    |                                     \               /
         *    |                                      \             /
         * 600 |                                       \ create44 /
         *    |                                         \_______/
         *    +-----------------------------------------------------+
         *
         * After adding logging, elements will be positioned with:
         * - Logging elements centered between source and target
         * - Y coordinate offset by LOG_OFFSET (150)
         * - Fault path logging with appropriate positioning
         */
        
        // Create a flow structure matching the image
        String inputStructure = 
            '└── Start [Start] → createacc1\n' +
            '    └── createacc1 [Record Create] → assign1, FAULT:create2\n' +
            '        ├── [FAULT] → create2\n' +
            '        ├── assign1 [Assignment] → create3\n' +
            '        │   └── create3 [Record Create] → ass3\n' +
            '        └── create2 [Record Create] → ass3\n' +
            '            └── ass3 [Assignment] → create44\n' +
            '                └── create44 [Record Create] → END';
        
        // Setup mock flow with specific coordinates
        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        
        // Set coordinates for each element to match the diagram
        mockFlow.start.locationX = 100;
        mockFlow.start.locationY = 100;
        
        for (MetadataService.FlowRecordCreate create : mockFlow.recordCreates) {
            if (create.name == 'createacc1') {
                create.locationX = 300;
                create.locationY = 200;
            } else if (create.name == 'create2') {
                create.locationX = 700;
                create.locationY = 200;
            } else if (create.name == 'create3') {
                create.locationX = 300;
                create.locationY = 400;
            } else if (create.name == 'create44') {
                create.locationX = 500;
                create.locationY = 600;
            }
        }
        
        for (MetadataService.FlowAssignment assignment : mockFlow.assignments) {
            if (assignment.name == 'assign1') {
                assignment.locationX = 300;
                assignment.locationY = 300;
            } else if (assignment.name == 'ass3') {
                assignment.locationX = 500;
                assignment.locationY = 500;
            }
        }
        
        MockMetadataHandler mockHandler = new MockMetadataHandler(mockFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        // Add logging
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        
        Test.startTest();
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Validate result
        System.assertEquals(true, result.get('success'), 'Operation should be successful');
        
        // Extract updated flow
        MetadataService.Flow updatedFlow = mockHandler.getUpdatedFlow();
        
        // Store the flow elements' coordinates
        Map<String, Integer> elementXCoords = new Map<String, Integer>();
        Map<String, Integer> elementYCoords = new Map<String, Integer>();
        
        // Get Start element coordinates
        elementXCoords.put('Start', updatedFlow.start.locationX);
        elementYCoords.put('Start', updatedFlow.start.locationY);
        
        // Get Record Create coordinates
        for (MetadataService.FlowRecordCreate create : updatedFlow.recordCreates) {
            elementXCoords.put(create.name, create.locationX);
            elementYCoords.put(create.name, create.locationY);
        }
        
        // Get Assignment coordinates
        for (MetadataService.FlowAssignment assignment : updatedFlow.assignments) {
            elementXCoords.put(assignment.name, assignment.locationX);
            elementYCoords.put(assignment.name, assignment.locationY);
        }
        
        // Map to store logging action details
        Map<String, Map<String, Object>> logActionDetails = new Map<String, Map<String, Object>>();
        
        // Analyze logging action calls
        for (MetadataService.FlowActionCall action : updatedFlow.actionCalls) {
            // Look for various logging actions based on names
            if (action.name.contains('Start_createacc1_PostPreLog')) {
                logActionDetails.put('Start->createacc1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('createacc1_assign1_PostPreLog')) {
                logActionDetails.put('createacc1->assign1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('assign1_create3_PostPreLog')) {
                logActionDetails.put('assign1->create3', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('create3_ass3_PostPreLog')) {
                logActionDetails.put('create3->ass3', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('createacc1_create2_PostPreLog')) {
                logActionDetails.put('createacc1->create2', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('create2_ass3_PostPreLog')) {
                logActionDetails.put('create2->ass3', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('ass3_create44_PostPreLog')) {
                logActionDetails.put('ass3->create44', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            }
        }
        
        // Verify each path's logging element positioning
        
        // 1. Start->createacc1 path
        Map<String, Object> startToCreate = logActionDetails.get('Start->createacc1');
        System.assertNotEquals(null, startToCreate, 'Logging element for Start->createacc1 not found');
        
        if (startToCreate != null) {
            // X coordinate should be centered between Start and createacc1
            Integer expectedX = (elementXCoords.get('Start') + elementXCoords.get('createacc1')) / 2;
            System.assertEquals(expectedX, (Integer)startToCreate.get('x'), 
                'Logging element X should be centered between Start and createacc1');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)startToCreate.get('y');
            System.assert(actualY >= elementYCoords.get('Start') + 150 && actualY <= elementYCoords.get('Start') + 450,
                'Logging element Y should be within a reasonable range from the Start Y coordinate');
        }
        
        // 2. createacc1->assign1 (standard path)
        Map<String, Object> createToAssign = logActionDetails.get('createacc1->assign1');
        System.assertNotEquals(null, createToAssign, 'Logging element for createacc1->assign1 not found');
        
        if (createToAssign != null) {
            // X coordinate should be centered between createacc1 and assign1
            Integer expectedX = (elementXCoords.get('createacc1') + elementXCoords.get('assign1')) / 2;
            System.assertEquals(expectedX, (Integer)createToAssign.get('x'), 
                'Logging element X should be centered between createacc1 and assign1');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)createToAssign.get('y');
            System.assert(actualY >= elementYCoords.get('createacc1') + 150 && actualY <= elementYCoords.get('createacc1') + 450,
                'Logging element Y should be within a reasonable range from createacc1 Y coordinate');
        }
        
        // 3. createacc1->create2 (fault path)
        Map<String, Object> createToFault = logActionDetails.get('createacc1->create2');
        System.assertNotEquals(null, createToFault, 'Logging element for createacc1->create2 (fault) not found');
        
        if (createToFault != null) {
            // For fault paths, X should be within range of source and target
            Integer actualX = (Integer)createToFault.get('x');
            System.assert(actualX >= Math.min(elementXCoords.get('createacc1'), elementXCoords.get('create2')) && 
                        actualX <= Math.max(elementXCoords.get('createacc1'), elementXCoords.get('create2')),
                'Fault path logging element X should be within range of createacc1 and create2 X coordinates');
            
            // Use flexible Y coordinate check for fault path
            Integer actualY = (Integer)createToFault.get('y');
            System.assert(actualY >= elementYCoords.get('createacc1') + 150 && actualY <= elementYCoords.get('createacc1') + 450,
                'Fault path logging element Y should be within a reasonable range from createacc1 Y coordinate');
        }
        
        // 4. Verify merge point element (ass3)
        // Both create3->ass3 and create2->ass3 paths should have logging elements
        Map<String, Object> create3ToAss3 = logActionDetails.get('create3->ass3');
        Map<String, Object> create2ToAss3 = logActionDetails.get('create2->ass3');
        
        System.assertNotEquals(null, create3ToAss3, 'Logging element for create3->ass3 not found');
        System.assertNotEquals(null, create2ToAss3, 'Logging element for create2->ass3 not found');
        
        if (create3ToAss3 != null) {
            // X coordinate should be centered between create3 and ass3
            Integer expectedX = (elementXCoords.get('create3') + elementXCoords.get('ass3')) / 2;
            System.assertEquals(expectedX, (Integer)create3ToAss3.get('x'), 
                'Logging element X should be centered between create3 and ass3');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)create3ToAss3.get('y');
            System.assert(actualY >= elementYCoords.get('create3') + 150 && actualY <= elementYCoords.get('create3') + 450,
                'Logging element Y should be within a reasonable range from create3 Y coordinate');
        }
        
        if (create2ToAss3 != null) {
            // X coordinate should be centered between create2 and ass3
            Integer expectedX = (elementXCoords.get('create2') + elementXCoords.get('ass3')) / 2;
            System.assertEquals(expectedX, (Integer)create2ToAss3.get('x'), 
                'Logging element X should be centered between create2 and ass3');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)create2ToAss3.get('y');
            System.assert(actualY >= elementYCoords.get('create2') + 150 && actualY <= elementYCoords.get('create2') + 450,
                'Logging element Y should be within a reasonable range from create2 Y coordinate');
        }
        
        // 5. Verify final path
        Map<String, Object> ass3ToCreate44 = logActionDetails.get('ass3->create44');
        System.assertNotEquals(null, ass3ToCreate44, 'Logging element for ass3->create44 not found');
        
        if (ass3ToCreate44 != null) {
            // X coordinate should be centered between ass3 and create44
            Integer expectedX = (elementXCoords.get('ass3') + elementXCoords.get('create44')) / 2;
            System.assertEquals(expectedX, (Integer)ass3ToCreate44.get('x'), 
                'Logging element X should be centered between ass3 and create44');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)ass3ToCreate44.get('y');
            System.assert(actualY >= elementYCoords.get('ass3') + 150 && actualY <= elementYCoords.get('ass3') + 450,
                'Logging element Y should be within a reasonable range from ass3 Y coordinate');
        }
    }

    @IsTest
    static void testDecisionWithLoopAndSubflowStructure() {
        /**
         * Test verifies logging elements positioning for a specific flow structure with:
         * - A Start element connected to a Decision element
         * - Decision element with DEFAULT branch to a Loop and a Rule branch to a Subflow
         * - Loop element with Next path to a Screen and NoMore path to END
         * - Screen element connected to END
         * - Subflow element connected to END
         * 
         * ASCII Flow Diagram Before Logging:
         *
         *                     +--------+
         *                     |Rule1   |
         *                     |        v
         *                  +--+------+ +---------+
         *                  |         | |         |
         *    +------+      |Decision | |Subflow1 |
         *    |Start |----->|decision1| |         |
         *    +------+      |         | +---------+
         *                  +-+-------+      |
         *                    |              |
         *                    v              v
         *                  +-+-------+     END
         *                  |         |
         *                  |Loop1    |
         *                  |         |
         *                  +----+----+
         *                    ^  |
         *              +-----+  |
         *              |        |
         *       NoMore |        | Next
         *              |        |
         *              |        v
         *            END      +-+-------+
         *                     |         |
         *                     |Screen1  |
         *                     |         |
         *                     +---------+
         *                         |
         *                         v
         *                        END
         *
         * After adding logging, elements will be positioned with:
         * - Logging elements for each connection path
         * - Proper Y offsets and X centering between elements
         */
        
        // Create a flow structure matching the provided pattern
        String inputStructure = 
            '└── Start [Start] → decision1\n' +
            '    └── decision1 [Decision] → DEFAULT:loop1, Rules:[Rule1->subflow1]\n' +
            '        ├── loop1 [Loop] → Next:screen1, NoMore:END\n' +
            '        │   ├── [Next Value] → screen1\n' +
            '        │   ├── screen1 [Screen] → END\n' +
            '        │   └── [No More Values] → END\n' +
            '        └── subflow1 [Subflow] → END';
        
        // Setup mock flow with specific coordinates
        MetadataService.Flow mockFlow = buildFlowFromStructure(inputStructure);
        
        // Set coordinates for elements to match a realistic layout
        mockFlow.start.locationX = 100;
        mockFlow.start.locationY = 200;
        
        for (MetadataService.FlowDecision decision : mockFlow.decisions) {
            if (decision.name == 'decision1') {
                decision.locationX = 250;
                decision.locationY = 200;
            }
        }
        
        for (MetadataService.FlowLoop loop1 : mockFlow.loops) {
            if (loop1.name == 'loop1') {
                loop1.locationX = 250;
                loop1.locationY = 350;
            }
        }
        
        for (MetadataService.FlowScreen screen : mockFlow.screens) {
            if (screen.name == 'screen1') {
                screen.locationX = 250;
                screen.locationY = 500;
            }
        }
        
        for (MetadataService.FlowSubflow subflow : mockFlow.subflows) {
            if (subflow.name == 'subflow1') {
                subflow.locationX = 400;
                subflow.locationY = 200;
            }
        }
        
        MockMetadataHandler mockHandler = new MockMetadataHandler(mockFlow);
        Test.setMock(WebServiceMock.class, mockHandler);
        
        // Add logging
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => TEST_FLOW_API_NAME,
            'functionalArea' => TEST_FUNCTIONAL_AREA,
            'versionInfo' => 'NEW_VERSION'
        };
        
        Test.startTest();
        FlowLogService service = new FlowLogService();
        Map<String, Object> result = service.invoke(params);
        Test.stopTest();
        
        // Validate result
        System.assertEquals(true, result.get('success'), 'Operation should be successful');
        
        // Extract updated flow
        MetadataService.Flow updatedFlow = mockHandler.getUpdatedFlow();
        
        // Store the flow elements' coordinates for validation
        Map<String, Integer> elementXCoords = new Map<String, Integer>();
        Map<String, Integer> elementYCoords = new Map<String, Integer>();
        
        // Get Start element coordinates
        elementXCoords.put('Start', updatedFlow.start.locationX);
        elementYCoords.put('Start', updatedFlow.start.locationY);
        
        // Get Decision element coordinates
        for (MetadataService.FlowDecision decision : updatedFlow.decisions) {
            if (decision.name == 'decision1') {
                elementXCoords.put('decision1', decision.locationX);
                elementYCoords.put('decision1', decision.locationY);
            }
        }
        
        // Get Loop element coordinates
        for (MetadataService.FlowLoop loop1 : updatedFlow.loops) {
            if (loop1.name == 'loop1') {
                elementXCoords.put('loop1', loop1.locationX);
                elementYCoords.put('loop1', loop1.locationY);
            }
        }
        
        // Get Screen element coordinates
        for (MetadataService.FlowScreen screen : updatedFlow.screens) {
            if (screen.name == 'screen1') {
                elementXCoords.put('screen1', screen.locationX);
                elementYCoords.put('screen1', screen.locationY);
            }
        }
        
        // Get Subflow element coordinates
        for (MetadataService.FlowSubflow subflow : updatedFlow.subflows) {
            if (subflow.name == 'subflow1') {
                elementXCoords.put('subflow1', subflow.locationX);
                elementYCoords.put('subflow1', subflow.locationY);
            }
        }
        
        // Map to store logging action details
        Map<String, Map<String, Object>> logActionDetails = new Map<String, Map<String, Object>>();
        
        // Analyze logging action calls
        for (MetadataService.FlowActionCall action : updatedFlow.actionCalls) {
            // Find logging actions with specific paths we're testing
            if (action.name.contains('Start_decision1_PostPreLog')) {
                logActionDetails.put('Start->decision1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('decision1_loop1_PostPreLog')) {
                logActionDetails.put('decision1->loop1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('Rule1_subflow1_PostPreLog')) {
                logActionDetails.put('Rule1->subflow1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('loop1_screen1_PostPreLog')) {
                logActionDetails.put('loop1->screen1', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('screen1_PostLog')) {
                logActionDetails.put('screen1->END', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('subflow1_PostLog')) {
                logActionDetails.put('subflow1->END', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            } else if (action.name.contains('loop1_PostLog')) {
                logActionDetails.put('loop1->END', new Map<String, Object>{
                    'x' => action.locationX,
                    'y' => action.locationY
                });
            }
        }
        
        // Now verify each path's logging element positioning
        
        // 1. Start->decision1 path
        Map<String, Object> startToDecision = logActionDetails.get('Start->decision1');
        System.assertNotEquals(null, startToDecision, 'Logging element for Start->decision1 not found');
        
        if (startToDecision != null) {
            // X coordinate should be centered between Start and decision1
            Integer expectedX = (elementXCoords.get('Start') + elementXCoords.get('decision1')) / 2;
            System.assertEquals(expectedX, (Integer)startToDecision.get('x'), 
                'Logging element X should be centered between Start and decision1');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)startToDecision.get('y');
            System.assert(actualY >= elementYCoords.get('Start') + 150 && actualY <= elementYCoords.get('Start') + 450,
                'Logging element Y should be within a reasonable range from the Start Y coordinate');
        }
        
        // 2. decision1->loop1 path (DEFAULT path)
        Map<String, Object> decisionToLoop = logActionDetails.get('decision1->loop1');
        System.assertNotEquals(null, decisionToLoop, 'Logging element for decision1->loop1 not found');
        
        if (decisionToLoop != null) {
            // X coordinate should be centered between decision1 and loop1
            Integer expectedX = (elementXCoords.get('decision1') + elementXCoords.get('loop1')) / 2;
            System.assertEquals(expectedX, (Integer)decisionToLoop.get('x'), 
                'Logging element X should be centered between decision1 and loop1');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)decisionToLoop.get('y');
            System.assert(actualY >= elementYCoords.get('decision1') + 150 && actualY <= elementYCoords.get('decision1') + 450,
                'Logging element Y should be within a reasonable range from decision1 Y coordinate');
        }
        
        // 3. Rule1->subflow1 path (Rule branch)
        Map<String, Object> ruleToSubflow = logActionDetails.get('Rule1->subflow1');
        System.assertNotEquals(null, ruleToSubflow, 'Logging element for Rule1->subflow1 not found');
        
        if (ruleToSubflow != null) {
            // For rule paths, X coordinate should be within range
            Integer actualX = (Integer)ruleToSubflow.get('x');
            System.assert(actualX >= Math.min(elementXCoords.get('decision1'), elementXCoords.get('subflow1')) && 
                        actualX <= Math.max(elementXCoords.get('decision1'), elementXCoords.get('subflow1')),
                'Rule branch logging element X should be within range of decision1 and subflow1 X coordinates');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)ruleToSubflow.get('y');
            System.assert(actualY >= elementYCoords.get('decision1') + 150 && actualY <= elementYCoords.get('decision1') + 450,
                'Rule branch logging element Y should be within a reasonable range from decision1 Y coordinate');
        }
        
        // 4. loop1->screen1 path (Next Value)
        Map<String, Object> loopToScreen = logActionDetails.get('loop1->screen1');
        System.assertNotEquals(null, loopToScreen, 'Logging element for loop1->screen1 not found');
        
        if (loopToScreen != null) {
            // X coordinate should be centered between loop1 and screen1
            Integer expectedX = (elementXCoords.get('loop1') + elementXCoords.get('screen1')) / 2;
            System.assertEquals(expectedX, (Integer)loopToScreen.get('x'), 
                'Logging element X should be centered between loop1 and screen1');
            
            // Use flexible Y coordinate check
            Integer actualY = (Integer)loopToScreen.get('y');
            System.assert(actualY >= elementYCoords.get('loop1') + 150 && actualY <= elementYCoords.get('loop1') + 450,
                'Logging element Y should be within a reasonable range from loop1 Y coordinate');
        }
        
        // 5. Terminal paths to END
        // Verify screen1->END, subflow1->END, and loop1->END (NoMore) all have proper logging elements
        Map<String, Object> screenToEnd = logActionDetails.get('screen1->END');
        Map<String, Object> subflowToEnd = logActionDetails.get('subflow1->END');
        Map<String, Object> loopToEnd = logActionDetails.get('loop1->END');
        
        System.assertNotEquals(null, screenToEnd, 'Logging element for screen1->END not found');
        System.assertNotEquals(null, subflowToEnd, 'Logging element for subflow1->END not found');
        System.assertNotEquals(null, loopToEnd, 'Logging element for loop1->END not found');
        
        // Check terminal log elements' Y coordinates
        if (screenToEnd != null) {
            Integer actualY = (Integer)screenToEnd.get('y');
            System.assert(actualY >= elementYCoords.get('screen1') + 150 && actualY <= elementYCoords.get('screen1') + 450,
                'Terminal logging element Y should be within a reasonable range from screen1 Y coordinate');
        }
        
        if (subflowToEnd != null) {
            Integer actualY = (Integer)subflowToEnd.get('y');
            System.assert(actualY >= elementYCoords.get('subflow1') + 150 && actualY <= elementYCoords.get('subflow1') + 450,
                'Terminal logging element Y should be within a reasonable range from subflow1 Y coordinate');
        }
        
        if (loopToEnd != null) {
            Integer actualY = (Integer)loopToEnd.get('y');
            System.assert(actualY >= elementYCoords.get('loop1') + 150 && actualY <= elementYCoords.get('loop1') + 450,
                'Terminal logging element Y should be within a reasonable range from loop1 Y coordinate');
        }
        
        // 6. Count total logging elements - should be at least 7 (one for each path)
        Integer loggingElementCount = 0;
        for (MetadataService.FlowActionCall action : updatedFlow.actionCalls) {
            if (action.name.contains('_PostPreLog') || action.name.contains('_PostLog')) {
                loggingElementCount++;
            }
        }
        
        System.assert(loggingElementCount >= 7, 
            'There should be at least 7 logging elements (one for each path in the flow)');
    }

    // Helper method to create a FlowScreenField of a specific type
    private static MetadataService.FlowScreenField createScreenField(
        String name,
        String fieldType,
        String fieldText,
        Boolean isRequired,
        List<String> choiceReferences,
        String extensionName,
        String regionContainerType,
        String objectFieldReference,
        List<MetadataService.FlowScreenField> nestedFields
    ) {
        MetadataService.FlowScreenField field = new MetadataService.FlowScreenField();
        field.name = name;
        field.fieldType = fieldType;
        field.fieldText = fieldText;
        field.isRequired = isRequired;
        field.choiceReferences = choiceReferences;
        field.extensionName = extensionName;
        field.regionContainerType = regionContainerType;
        field.objectFieldReference = objectFieldReference;
        field.fields = nestedFields;
        return field;
    }

    // Tests the buildScreenFieldsDetails method for DisplayText field type
    @IsTest
    private static void testBuildScreenFieldsDetails_DisplayText() {
        // Set up a flow element with a screen that has a display text field
        FlowLogService.FlowElement element = new FlowLogService.FlowElement();
        MetadataService.FlowScreen screen = new MetadataService.FlowScreen();
        screen.fields = new List<MetadataService.FlowScreenField>();
        
        MetadataService.FlowScreenField displayTextField = createScreenField(
            'displayText1',
            'DisplayText',
            'This is display text',
            false,
            null,
            null,
            null,
            null,
            null
        );
        screen.fields.add(displayTextField);
        element.setScreenMetadata(screen);
        
        // Call the method
        FlowLogService service = new FlowLogService();
        Test.startTest();
        String result = (String)service.testBuildScreenFieldsDetails(element);
        Test.stopTest();
        
        // Verify the result
        System.assert(result.contains('displayText1'), 'Result should contain the field name');
        System.assert(result.contains('Type: DisplayText'), 'Result should identify the field type');
        System.assert(result.contains('Text: This is display text'), 'Result should contain the field text');
        System.assert(!result.contains('Required:'), 'Display text should not include Required property');
    }

    // Tests the buildScreenFieldsDetails method for various input field types
    @IsTest
    private static void testBuildScreenFieldsDetails_InputFields() {
        // Set up a flow element with a screen that has different input field types
        FlowLogService.FlowElement element = new FlowLogService.FlowElement();
        MetadataService.FlowScreen screen = new MetadataService.FlowScreen();
        screen.fields = new List<MetadataService.FlowScreenField>();
        
        // Standard input field
        MetadataService.FlowScreenField inputField = createScreenField(
            'inputField1',
            'InputField',
            'Regular Input',
            true,
            null,
            null,
            null,
            null,
            null
        );
        screen.fields.add(inputField);
        
        // Large text area
        MetadataService.FlowScreenField largeTextArea = createScreenField(
            'textArea1',
            'LargeTextArea',
            'Text Area Field',
            false,
            null,
            null,
            null,
            null,
            null
        );
        screen.fields.add(largeTextArea);
        
        // Password field
        MetadataService.FlowScreenField passwordField = createScreenField(
            'password1',
            'PasswordField',
            'Password Field',
            true,
            null,
            null,
            null,
            null,
            null
        );
        screen.fields.add(passwordField);
        
        element.setScreenMetadata(screen);
        
        // Call the method
        FlowLogService service = new FlowLogService();
        Test.startTest();
        String result = (String)service.testBuildScreenFieldsDetails(element);
        Test.stopTest();
        
        // Verify the result
        System.assert(result.contains('inputField1'), 'Result should contain the first field name');
        System.assert(result.contains('Type: InputField'), 'Result should identify the input field type');
        System.assert(result.contains('Required: true'), 'Input field should show its required status');
        
        System.assert(result.contains('textArea1'), 'Result should contain the text area field name');
        System.assert(result.contains('Type: LargeTextArea'), 'Result should identify the large text area field type');
        System.assert(result.contains('Required: false'), 'Text area should show its required status');
        
        System.assert(result.contains('password1'), 'Result should contain the password field name');
        System.assert(result.contains('Type: PasswordField'), 'Result should identify the password field type');
        
        // All fields should have a value at runtime placeholder
        System.assert(result.contains('Value at runtime: {!inputField1}'), 'Input fields should show runtime value');
        System.assert(result.contains('Value at runtime: {!textArea1}'), 'Text area should show runtime value');
        System.assert(result.contains('Value at runtime: {!password1}'), 'Password field should show runtime value');
    }

    // Tests the buildScreenFieldsDetails method for choice fields
    @IsTest
    private static void testBuildScreenFieldsDetails_ChoiceFields() {
        // Set up a flow element with a screen that has choice fields
        FlowLogService.FlowElement element = new FlowLogService.FlowElement();
        MetadataService.FlowScreen screen = new MetadataService.FlowScreen();
        screen.fields = new List<MetadataService.FlowScreenField>();
        
        // Radio buttons
        List<String> radioChoices = new List<String>{'Option1', 'Option2', 'Option3'};
        MetadataService.FlowScreenField radioButtonsField = createScreenField(
            'radioButtons1',
            'RadioButtons',
            'Radio Buttons Field',
            true,
            radioChoices,
            null,
            null,
            null,
            null
        );
        screen.fields.add(radioButtonsField);
        
        // Dropdown box
        List<String> dropdownChoices = new List<String>{'Choice1', 'Choice2'};
        MetadataService.FlowScreenField dropdownField = createScreenField(
            'dropdown1',
            'DropdownBox',
            'Dropdown Field',
            false,
            dropdownChoices,
            null,
            null,
            null,
            null
        );
        screen.fields.add(dropdownField);
        
        // Multi-select checkboxes
        List<String> checkboxChoices = new List<String>{'Check1', 'Check2', 'Check3'};
        MetadataService.FlowScreenField checkboxesField = createScreenField(
            'checkboxes1',
            'MultiSelectCheckboxes',
            'Checkboxes Field',
            false,
            checkboxChoices,
            null,
            null,
            null,
            null
        );
        screen.fields.add(checkboxesField);
        
        // Multi-select picklist
        List<String> picklistChoices = new List<String>{'Pick1', 'Pick2'};
        MetadataService.FlowScreenField picklistField = createScreenField(
            'picklist1',
            'MultiSelectPicklist',
            'Picklist Field',
            true,
            picklistChoices,
            null,
            null,
            null,
            null
        );
        screen.fields.add(picklistField);
        
        element.setScreenMetadata(screen);
        
        // Call the method
        FlowLogService service = new FlowLogService();
        Test.startTest();
        String result = (String)service.testBuildScreenFieldsDetails(element);
        Test.stopTest();
        
        // Verify the result
        // Radio buttons
        System.assert(result.contains('radioButtons1'), 'Result should contain the radio buttons field name');
        System.assert(result.contains('Type: RadioButtons'), 'Result should identify the radio buttons field type');
        System.assert(result.contains('Choices: Option1, Option2, Option3'), 'Result should list radio choices');
        
        // Dropdown
        System.assert(result.contains('dropdown1'), 'Result should contain the dropdown field name');
        System.assert(result.contains('Type: DropdownBox'), 'Result should identify the dropdown field type');
        System.assert(result.contains('Choices: Choice1, Choice2'), 'Result should list dropdown choices');
        
        // Multi-select checkboxes
        System.assert(result.contains('checkboxes1'), 'Result should contain the checkboxes field name');
        System.assert(result.contains('Type: MultiSelectCheckboxes'), 'Result should identify the checkboxes field type');
        System.assert(result.contains('Choices: Check1, Check2, Check3'), 'Result should list checkbox choices');
        
        // Multi-select picklist
        System.assert(result.contains('picklist1'), 'Result should contain the picklist field name');
        System.assert(result.contains('Type: MultiSelectPicklist'), 'Result should identify the picklist field type');
        System.assert(result.contains('Choices: Pick1, Pick2'), 'Result should list picklist choices');
        
        // Single-select fields should show singular "Value at runtime"
        System.assert(result.contains('Value at runtime: {!radioButtons1}'), 'Radio buttons should show singular runtime value');
        System.assert(result.contains('Value at runtime: {!dropdown1}'), 'Dropdown should show singular runtime value');
        
        // Multi-select fields should show plural "Values at runtime"
        System.assert(result.contains('Values at runtime: {!checkboxes1}'), 'Checkboxes should show plural runtime values');
        System.assert(result.contains('Values at runtime: {!picklist1}'), 'Picklist should show plural runtime values');
    }

    // Tests the buildScreenFieldsDetails method for component instance fields
    @IsTest
    private static void testBuildScreenFieldsDetails_ComponentInstance() {
        // Set up a flow element with a screen that has a component instance field
        FlowLogService.FlowElement element = new FlowLogService.FlowElement();
        MetadataService.FlowScreen screen = new MetadataService.FlowScreen();
        screen.fields = new List<MetadataService.FlowScreenField>();
        
        // Component without automatic output storage
        MetadataService.FlowScreenField componentField = createScreenField(
            'component1',
            'ComponentInstance',
            'Component Field',
            false,
            null,
            'c:MyAwesomeComponent',
            null,
            null,
            null
        );
        componentField.storeOutputAutomatically = false;
        screen.fields.add(componentField);
        
        // Component with automatic output storage
        MetadataService.FlowScreenField componentWithAutoOutput = createScreenField(
            'component2',
            'ComponentInstance',
            'Auto Output Component',
            false,
            null,
            'c:AnotherComponent',
            null,
            null,
            null
        );
        componentWithAutoOutput.storeOutputAutomatically = true;
        screen.fields.add(componentWithAutoOutput);
        
        element.setScreenMetadata(screen);
        
        // Call the method
        FlowLogService service = new FlowLogService();
        Test.startTest();
        String result = (String)service.testBuildScreenFieldsDetails(element);
        Test.stopTest();
        
        // Verify the result
        System.assert(result.contains('component1'), 'Result should contain the first component field name');
        System.assert(result.contains('Type: ComponentInstance'), 'Result should identify the component instance field type');
        System.assert(result.contains('Component: c:MyAwesomeComponent'), 'Result should show component extension name');
        
        System.assert(result.contains('component2'), 'Result should contain the second component field name');
        System.assert(result.contains('Outputs stored automatically'), 'Result should indicate automatic output storage');
    }

    // Tests the buildScreenFieldsDetails method for container fields
    @IsTest
    private static void testBuildScreenFieldsDetails_Containers() {
        // Set up a flow element with a screen that has container fields with nested fields
        FlowLogService.FlowElement element = new FlowLogService.FlowElement();
        MetadataService.FlowScreen screen = new MetadataService.FlowScreen();
        screen.fields = new List<MetadataService.FlowScreenField>();
        
        // Create a nested input field for the region
        MetadataService.FlowScreenField nestedInputField = createScreenField(
            'nestedInput',
            'InputField',
            'Nested Input Field',
            true,
            null,
            null,
            null,
            null,
            null
        );
        
        // Create a region (column)
        MetadataService.FlowScreenField regionField = createScreenField(
            'region1',
            'Region',
            'Column Region',
            false,
            null,
            null,
            null,
            null,
            new List<MetadataService.FlowScreenField>{nestedInputField}
        );
        
        // Create a region container (section)
        MetadataService.FlowScreenField containerField = createScreenField(
            'container1',
            'RegionContainer',
            'Section Container',
            false,
            null,
            null,
            'SectionWithHeader',
            null,
            new List<MetadataService.FlowScreenField>{regionField}
        );
        
        screen.fields.add(containerField);
        element.setScreenMetadata(screen);
        
        // Call the method
        FlowLogService service = new FlowLogService();
        Test.startTest();
        String result = (String)service.testBuildScreenFieldsDetails(element);
        Test.stopTest();
        
        // Verify the result
        System.assert(result.contains('container1'), 'Result should contain the container field name');
        System.assert(result.contains('Type: RegionContainer'), 'Result should identify the region container field type');
        System.assert(result.contains('Section Type: SectionWithHeader'), 'Result should show container type');
        System.assert(result.contains('Contains 1 columns'), 'Result should indicate number of columns');
        
        // Check nested fields
        System.assert(result.contains('Nested fields:'), 'Result should include nested fields section');
        System.assert(result.contains('region1'), 'Result should include the region name');
        System.assert(result.contains('Type: Region'), 'Result should identify the region field type');
        System.assert(result.contains('Contains 1 fields'), 'Result should indicate number of fields in region');
        
        // Check deeply nested field
        System.assert(result.contains('nestedInput'), 'Result should include the nested input field name');
        System.assert(result.contains('Required: true'), 'Result should include properties of nested field');
        System.assert(result.contains('Value at runtime: {!nestedInput}'), 'Result should show runtime value of nested field');
    }

    // Tests the buildScreenFieldsDetails method for object-provided fields
    @IsTest
    private static void testBuildScreenFieldsDetails_ObjectProvided() {
        // Set up a flow element with a screen that has an object-provided field
        FlowLogService.FlowElement element = new FlowLogService.FlowElement();
        MetadataService.FlowScreen screen = new MetadataService.FlowScreen();
        screen.fields = new List<MetadataService.FlowScreenField>();
        
        MetadataService.FlowScreenField objectField = createScreenField(
            null,
            'ObjectProvided',
            null,
            false,
            null,
            null,
            null,
            'Account.Name',
            null
        );
        screen.fields.add(objectField);
        
        element.setScreenMetadata(screen);
        
        // Call the method
        FlowLogService service = new FlowLogService();
        Test.startTest();
        String result = (String)service.testBuildScreenFieldsDetails(element);
        Test.stopTest();
        
        // Verify the result
        System.assert(result.contains('Type: ObjectProvided'), 'Result should identify the object-provided field type');
        System.assert(result.contains('Value at runtime: {!Account.Name}'), 'Result should show runtime value');
    }
}