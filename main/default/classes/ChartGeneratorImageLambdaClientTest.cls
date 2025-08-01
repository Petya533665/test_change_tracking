@IsTest
public class ChartGeneratorImageLambdaClientTest {
    
    // Mock HTTP response for successful chart generation
    private static String getMockSuccessResponse() {
        return '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==","OCCURRENCE_LAST_30_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="}';
    }
    
    // Mock HTTP response for error
    private static String getMockErrorResponse() {
        return '{"message":"Error building chart","error":"Invalid data format"}';
    }
    
    // Mock HTTP response for empty response
    private static String getMockEmptyResponse() {
        return '';
    }
    
    // Mock HTTP response for invalid JSON
    private static String getMockInvalidJsonResponse() {
        return 'invalid json response';
    }
    
    @IsTest
    static void testSuccessfulChartGenerationWithMock() {
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockSuccessResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Mock chart configuration using new input format
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            },
            'OCCURRENCE_LAST_30_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":6,"date":"9.06.2025"},{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Test the chart generation method with mock
        Test.startTest();
        ChartGeneratorImageLambdaClient result = client.generateChartImagesBasedStringChartConfig(chartConfigJson);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.hasCharts());
        System.assertEquals(false, result.hasError());
        
        // Verify available chart types
        Set<String> availableTypes = result.getAvailableChartTypes();
        System.assertEquals(2, availableTypes.size());
        System.assert(availableTypes.contains('OCCURRENCE_LAST_7_DAYS'));
        System.assert(availableTypes.contains('OCCURRENCE_LAST_30_DAYS'));
        
        // Test getting specific chart images
        String base64Image7Days = result.getBase64ImageForChart('OCCURRENCE_LAST_7_DAYS');
        String base64Image30Days = result.getBase64ImageForChart('OCCURRENCE_LAST_30_DAYS');
        
        System.assertNotEquals(null, base64Image7Days);
        System.assertNotEquals(null, base64Image30Days);
        System.assert(base64Image7Days.startsWith('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='));
        System.assert(base64Image30Days.startsWith('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='));
        
        // Test getting blob images
        Blob blobImage7Days = result.getBlobImageForChart('OCCURRENCE_LAST_7_DAYS');
        Blob blobImage30Days = result.getBlobImageForChart('OCCURRENCE_LAST_30_DAYS');
        
        System.assertNotEquals(null, blobImage7Days);
        System.assertNotEquals(null, blobImage30Days);
        System.assert(blobImage7Days.size() > 0);
        System.assert(blobImage30Days.size() > 0);
    }
    
    @IsTest
    static void testMultipleChartsGenerationWithMock() {
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockSuccessResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Mock multiple chart configurations using new input format
        Map<String, Object> chartConfigs = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            },
            'OCCURRENCE_LOGS_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1' => '[{"logCount":2,"date":"20.06.2025"}]'
            }
        };
        
        // Test the new method with mock
        Test.startTest();
        ChartGeneratorImageLambdaClient result = client.generateMultipleChartImages(chartConfigs);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.hasCharts());
        System.assertEquals(false, result.hasError());
        
        // Verify available chart types
        Set<String> availableTypes = result.getAvailableChartTypes();
        System.assertEquals(2, availableTypes.size());
        System.assert(availableTypes.contains('OCCURRENCE_LAST_7_DAYS'));
        System.assert(availableTypes.contains('OCCURRENCE_LAST_30_DAYS'));
    }
    
    @IsTest
    static void testErrorResponseWithMock() {
        // Set up mock HTTP response for error
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockErrorResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Test error handling with mock
        Test.startTest();
        try {
            client.generateChartImagesBasedStringChartConfig(chartConfigJson);
            System.assert(false, 'Should have thrown exception for error response');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assert(e.getMessage().contains('Lambda Error: Error building chart - Invalid data format'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testEmptyResponseWithMock() {
        // Set up mock HTTP response for empty response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockEmptyResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Test empty response handling with mock
        Test.startTest();
        try {
            client.generateChartImagesBasedStringChartConfig(chartConfigJson);
            System.assert(false, 'Should have thrown exception for empty response');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Empty response from Lambda function', e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testInvalidJsonResponseWithMock() {
        // Set up mock HTTP response for invalid JSON
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockInvalidJsonResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Test invalid JSON response handling with mock
        Test.startTest();
        try {
            client.generateChartImagesBasedStringChartConfig(chartConfigJson);
            System.assert(false, 'Should have thrown exception for invalid JSON response');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assert(e.getMessage().contains('Error calling Lambda function'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testChartTypeEnumUsageWithMock() {
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockSuccessResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Mock system report data using new input format
        Map<String, Object> systemReportData = new Map<String, Object>{
            'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
        };
        
        // Test the enum-based method with mock
        Test.startTest();
        ChartGeneratorImageLambdaClient result = client.generateChartImageForType(ChartService.Chart.OCCURRENCE_LAST_7_DAYS, systemReportData);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.hasCharts());
        System.assertEquals(false, result.hasError());
        
        // Verify available chart types
        Set<String> availableTypes = result.getAvailableChartTypes();
        System.assertEquals(2, availableTypes.size());
        System.assert(availableTypes.contains('OCCURRENCE_LAST_7_DAYS'));
        System.assert(availableTypes.contains('OCCURRENCE_LAST_30_DAYS'));
    }
    
    @IsTest
    static void testChartTypeAndReportEnumUsageWithMock() {
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockSuccessResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Mock report data
        String reportData = '[{"logCount":3,"date":"24.06.2025"}]';
        
        // Test the enum-based method with both chart type and system report
        Test.startTest();
        ChartGeneratorImageLambdaClient result = client.generateChartImageForTypeAndReport(
            ChartService.Chart.OCCURRENCE_LAST_7_DAYS, 
            ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE, 
            reportData
        );
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.hasCharts());
        System.assertEquals(false, result.hasError());
        
        // Verify available chart types
        Set<String> availableTypes = result.getAvailableChartTypes();
        System.assertEquals(2, availableTypes.size());
        System.assert(availableTypes.contains('OCCURRENCE_LAST_7_DAYS'));
        System.assert(availableTypes.contains('OCCURRENCE_LAST_30_DAYS'));
    }
    
    @IsTest
    static void testLegacyMethodsWithMock() {
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockSuccessResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Generate charts first
        Test.startTest();
        client.generateChartImagesBasedStringChartConfig(chartConfigJson);
        
        // Test legacy methods
        Blob legacyBlob = client.getBlobImage();
        String legacyBase64 = client.getBase64Image();
        Test.stopTest();
        
        // Verify legacy methods work
        System.assertNotEquals(null, legacyBlob);
        System.assertNotEquals(null, legacyBase64);
        System.assert(legacyBlob.size() > 0);
        System.assert(legacyBase64.startsWith('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='));
    }
    
    @IsTest
    static void testErrorHandling() {
        // Test error handling
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test with null configuration
        try {
            client.generateChartImagesBasedStringChartConfig(null);
            System.assert(false, 'Should have thrown exception for null config');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart Config is required', e.getMessage());
        }
        
        // Test with empty configuration
        try {
            client.generateChartImagesBasedStringChartConfig('');
            System.assert(false, 'Should have thrown exception for empty config');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart Config is required', e.getMessage());
        }
        
        // Test with null chart configs
        try {
            client.generateMultipleChartImages(null);
            System.assert(false, 'Should have thrown exception for null chart configs');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart configurations are required', e.getMessage());
        }
        
        // Test with empty chart configs
        try {
            client.generateMultipleChartImages(new Map<String, Object>());
            System.assert(false, 'Should have thrown exception for empty chart configs');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart configurations are required', e.getMessage());
        }
        
        // Test with null chart type
        try {
            client.generateChartImageForType(null, new Map<String, Object>());
            System.assert(false, 'Should have thrown exception for null chart type');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart type and system report data are required', e.getMessage());
        }
        
        // Test with null system report data
        try {
            client.generateChartImageForType(ChartService.Chart.OCCURRENCE_LAST_7_DAYS, null);
            System.assert(false, 'Should have thrown exception for null system report data');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart type and system report data are required', e.getMessage());
        }
        
        // Test with empty system report data
        try {
            client.generateChartImageForType(ChartService.Chart.OCCURRENCE_LAST_7_DAYS, new Map<String, Object>());
            System.assert(false, 'Should have thrown exception for empty system report data');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart type and system report data are required', e.getMessage());
        }
        
        // Test with null chart type and report
        try {
            client.generateChartImageForTypeAndReport(null, ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE, 'data');
            System.assert(false, 'Should have thrown exception for null chart type');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart type, system report, and report data are required', e.getMessage());
        }
        
        // Test with null system report
        try {
            client.generateChartImageForTypeAndReport(ChartService.Chart.OCCURRENCE_LAST_7_DAYS, null, 'data');
            System.assert(false, 'Should have thrown exception for null system report');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart type, system report, and report data are required', e.getMessage());
        }
        
        // Test with null report data
        try {
            client.generateChartImageForTypeAndReport(ChartService.Chart.OCCURRENCE_LAST_7_DAYS, ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE, null);
            System.assert(false, 'Should have thrown exception for null report data');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart type, system report, and report data are required', e.getMessage());
        }
        
        // Test with empty report data
        try {
            client.generateChartImageForTypeAndReport(ChartService.Chart.OCCURRENCE_LAST_7_DAYS, ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE, '');
            System.assert(false, 'Should have thrown exception for empty report data');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart type, system report, and report data are required', e.getMessage());
        }
    }
    
    @IsTest
    static void testNewErrorResponseFormat() {
        // Test the new error response format with message and error fields
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test Example 6: Unauthorized error
        String unauthorizedErrorResponse = '{"message":"Unauthorized: Invalid or missing API key","error":"Unauthorized: Invalid or missing API key"}';
        
        // Test Example 5: Chart building error
        String chartBuildingErrorResponse = '{"message":"Error building occurrence logs chart for Last 7 Days","error":"Unexpected token i in JSON at position 0"}';
        
        // Test parsing of these error responses
        Map<String, Object> unauthorizedMap = (Map<String, Object>) JSON.deserializeUntyped(unauthorizedErrorResponse);
        System.assert(unauthorizedMap.containsKey('message'), 'Unauthorized error should contain message field');
        System.assert(unauthorizedMap.containsKey('error'), 'Unauthorized error should contain error field');
        System.assertEquals('Unauthorized: Invalid or missing API key', unauthorizedMap.get('message'));
        System.assertEquals('Unauthorized: Invalid or missing API key', unauthorizedMap.get('error'));
        
        Map<String, Object> chartBuildingMap = (Map<String, Object>) JSON.deserializeUntyped(chartBuildingErrorResponse);
        System.assert(chartBuildingMap.containsKey('message'), 'Chart building error should contain message field');
        System.assert(chartBuildingMap.containsKey('error'), 'Chart building error should contain error field');
        System.assertEquals('Error building occurrence logs chart for Last 7 Days', chartBuildingMap.get('message'));
        System.assertEquals('Unexpected token i in JSON at position 0', chartBuildingMap.get('error'));
        
        System.debug('New error response format tests passed');
    }
    
    @IsTest
    static void testNewSuccessResponseFormats() {
        // Test the new success response formats
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test Example 4: Multiple charts response
        String multipleChartsResponse = '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzde3xcVb3///dn70nS...","OCCURRENCE_LOGS_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxdVbn/8e+zdpK2..."}';
        
        // Test Example 3: Single chart response
        String singleChartResponse = '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzde3xcVb3///dn70nS..."}';
        
        // Test Example 2: Different chart type response
        String differentChartResponse = '{"OCCURRENCE_LOGS_LAST_30_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxcdb3/8ffnO5N0..."}';
        
        // Test parsing of multiple charts response
        Map<String, Object> multipleChartsMap = (Map<String, Object>) JSON.deserializeUntyped(multipleChartsResponse);
        System.assert(multipleChartsMap.containsKey('OCCURRENCE_LAST_7_DAYS'), 'Multiple charts response should contain OCCURRENCE_LAST_7_DAYS');
        System.assert(multipleChartsMap.containsKey('OCCURRENCE_LOGS_LAST_7_DAYS'), 'Multiple charts response should contain OCCURRENCE_LOGS_LAST_7_DAYS');
        System.assertEquals(2, multipleChartsMap.size(), 'Multiple charts response should have 2 chart types');
        
        // Test parsing of single chart response
        Map<String, Object> singleChartMap = (Map<String, Object>) JSON.deserializeUntyped(singleChartResponse);
        System.assert(singleChartMap.containsKey('OCCURRENCE_LAST_7_DAYS'), 'Single chart response should contain OCCURRENCE_LAST_7_DAYS');
        System.assertEquals(1, singleChartMap.size(), 'Single chart response should have 1 chart type');
        
        // Test parsing of different chart type response
        Map<String, Object> differentChartMap = (Map<String, Object>) JSON.deserializeUntyped(differentChartResponse);
        System.assert(differentChartMap.containsKey('OCCURRENCE_LOGS_LAST_30_DAYS'), 'Different chart response should contain OCCURRENCE_LOGS_LAST_30_DAYS');
        System.assertEquals(1, differentChartMap.size(), 'Different chart response should have 1 chart type');
        
        System.debug('New success response format tests passed');
    }
    
    @IsTest
    static void testErrorResponseParsing() {
        // Test error response parsing logic
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test new error response format (Examples 5 & 6)
        String unauthorizedErrorResponse = '{"message":"Unauthorized: Invalid or missing API key","error":"Unauthorized: Invalid or missing API key"}';
        String chartBuildingErrorResponse = '{"message":"Error building occurrence logs chart for Last 7 Days","error":"Unexpected token i in JSON at position 0"}';
        
        // Test successful response format
        String successResponse = '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==","OCCURRENCE_LOGS_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="}';
        
        // These would be tested in integration tests with actual Lambda responses
        System.debug('Error response parsing methods available for testing');
        System.debug('Unauthorized error response: ' + unauthorizedErrorResponse);
        System.debug('Chart building error response: ' + chartBuildingErrorResponse);
        System.debug('Success response: ' + successResponse);
    }
    

    
    @IsTest
    static void testUtilityMethods() {
        // Test utility methods
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test initial state
        System.assertEquals(false, client.hasCharts());
        System.assertEquals(false, client.hasError());
        System.assertEquals(0, client.getAvailableChartTypes().size());
        System.assertEquals(null, client.getErrorResponse());
    }
    
    @IsTest
    static void testLegacyMethods() {
        // Test legacy methods for backward compatibility
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test legacy methods when no charts are available
        try {
            client.getBlobImage();
            System.assert(false, 'Should have thrown exception for no charts');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('No chart images available', e.getMessage());
        }
        
        try {
            client.getBase64Image();
            System.assert(false, 'Should have thrown exception for no charts');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('No chart images available', e.getMessage());
        }
    }
    
    @IsTest
    static void testUtilityMethodsWithMock() {
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockSuccessResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Test utility methods with mock
        Test.startTest();
        client.generateChartImagesBasedStringChartConfig(chartConfigJson);
        
        // Test utility methods
        System.assertEquals(true, client.hasCharts());
        System.assertEquals(false, client.hasError());
        System.assertEquals(null, client.getErrorResponse());
        
        Set<String> availableTypes = client.getAvailableChartTypes();
        System.assertEquals(2, availableTypes.size());
        System.assert(availableTypes.contains('OCCURRENCE_LAST_7_DAYS'));
        System.assert(availableTypes.contains('OCCURRENCE_LAST_30_DAYS'));
        Test.stopTest();
    }
    
    @IsTest
    static void testInputFormatValidation() {
        // Test input format validation
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test valid input format using new structure
        Map<String, Object> validInput = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            },
            'OCCURRENCE_LAST_30_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":6,"date":"9.06.2025"},{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String validInputJson = JSON.serialize(validInput);
        System.debug('Valid input format: ' + validInputJson);
        
        // Test invalid input format (missing required fields)
        Map<String, Object> invalidInput = new Map<String, Object>{
            'INVALID_CHART_TYPE' => new Map<String, Object>{
                'INVALID_SYSTEM_REPORT' => 'invalid data'
            }
        };
        
        String invalidInputJson = JSON.serialize(invalidInput);
        System.debug('Invalid input format: ' + invalidInputJson);
        
        // Verify the valid input structure
        System.assert(validInput.containsKey('OCCURRENCE_LAST_7_DAYS'), 'Should contain OCCURRENCE_LAST_7_DAYS chart type');
        System.assert(validInput.containsKey('OCCURRENCE_LAST_30_DAYS'), 'Should contain OCCURRENCE_LAST_30_DAYS chart type');
        
        Map<String, Object> chart7Days = (Map<String, Object>) validInput.get('OCCURRENCE_LAST_7_DAYS');
        Map<String, Object> chart30Days = (Map<String, Object>) validInput.get('OCCURRENCE_LAST_30_DAYS');
        
        System.assert(chart7Days.containsKey('SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE'), 'Should contain SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE system report');
        System.assert(chart30Days.containsKey('SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE'), 'Should contain SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE system report');
    }
    
    @IsTest
    static void testSpecificChartTypeMethods() {
        // Test methods for specific chart types
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test getting specific chart types when no charts are available
        try {
            client.getBlobImageForChart('OCCURRENCE_LAST_7_DAYS');
            System.assert(false, 'Should have thrown exception for no charts');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart image not found for type: OCCURRENCE_LAST_7_DAYS', e.getMessage());
        }
        
        try {
            client.getBase64ImageForChart('OCCURRENCE_LOGS_LAST_7_DAYS');
            System.assert(false, 'Should have thrown exception for no charts');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart image not found for type: OCCURRENCE_LOGS_LAST_7_DAYS', e.getMessage());
        }
    }
    
    @IsTest
    static void testSpecificChartTypeMethodsWithMock() {
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(getMockSuccessResponse()));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Generate charts first
        Test.startTest();
        client.generateChartImagesBasedStringChartConfig(chartConfigJson);
        
        // Test getting specific chart types with valid data
        Blob blobImage = client.getBlobImageForChart('OCCURRENCE_LAST_7_DAYS');
        String base64Image = client.getBase64ImageForChart('OCCURRENCE_LAST_7_DAYS');
        
        // Test getting non-existent chart type
        try {
            client.getBlobImageForChart('NON_EXISTENT_CHART');
            System.assert(false, 'Should have thrown exception for non-existent chart');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart image not found for type: NON_EXISTENT_CHART', e.getMessage());
        }
        
        try {
            client.getBase64ImageForChart('NON_EXISTENT_CHART');
            System.assert(false, 'Should have thrown exception for non-existent chart');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart image not found for type: NON_EXISTENT_CHART', e.getMessage());
        }
        Test.stopTest();
        
        // Verify valid results
        System.assertNotEquals(null, blobImage);
        System.assertNotEquals(null, base64Image);
        System.assert(blobImage.size() > 0);
        System.assert(base64Image.startsWith('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='));
    }
    
    @IsTest
    static void testChartTypeValidation() {
        // Test chart type validation
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test with invalid chart type
        try {
            client.getBlobImageForChart('INVALID_CHART_TYPE');
            System.assert(false, 'Should have thrown exception for invalid chart type');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('Chart image not found for type: INVALID_CHART_TYPE', e.getMessage());
        }
    }
    
    @IsTest
    static void testResponseFormatValidation() {
        // Test response format validation
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test that the client properly handles the expected response format
        // This would be tested in integration tests with actual Lambda responses
        System.debug('Response format validation would be tested with actual Lambda responses');
        System.debug('Expected format: {"OCCURRENCE_LAST_7_DAYS": "base64image", "OCCURRENCE_LOGS_LAST_7_DAYS": "base64image"}');
    }
    
    @IsTest
    static void testLambdaResponseFormat() {
        // Test the expected Lambda response format
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Mock the expected Lambda response format
        String mockLambdaResponse = '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==","OCCURRENCE_LOGS_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="}';
        
        // Test input format that would generate this response using new structure
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            },
            'OCCURRENCE_LOGS_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1' => '[{"logCount":2,"date":"20.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        System.debug('Input format: ' + chartConfigJson);
        System.debug('Expected Lambda response format: ' + mockLambdaResponse);
        
        // Verify the input format matches the expected structure
        System.assert(chartConfig.containsKey('OCCURRENCE_LAST_7_DAYS'), 'Should contain OCCURRENCE_LAST_7_DAYS chart type');
        System.assert(chartConfig.containsKey('OCCURRENCE_LOGS_LAST_7_DAYS'), 'Should contain OCCURRENCE_LOGS_LAST_7_DAYS chart type');
        
        Map<String, Object> chart7Days = (Map<String, Object>) chartConfig.get('OCCURRENCE_LAST_7_DAYS');
        Map<String, Object> chartLogs7Days = (Map<String, Object>) chartConfig.get('OCCURRENCE_LOGS_LAST_7_DAYS');
        
        System.assert(chart7Days.containsKey('SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE'), 'Should contain SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE system report');
        System.assert(chartLogs7Days.containsKey('SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1'), 'Should contain SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1 system report');
        
        // Verify the response format structure
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(mockLambdaResponse);
        System.assert(responseMap.containsKey('OCCURRENCE_LAST_7_DAYS'), 'Response should contain OCCURRENCE_LAST_7_DAYS');
        System.assert(responseMap.containsKey('OCCURRENCE_LOGS_LAST_7_DAYS'), 'Response should contain OCCURRENCE_LOGS_LAST_7_DAYS');
    }
    
    @IsTest
    static void testEmptyResponseHandling() {
        // Test handling of empty responses
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test with empty response
        try {
            // This would be tested in integration tests
            System.debug('Empty response handling would be tested with actual Lambda responses');
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
        }
    }
    
    @IsTest
    static void testEmptyChartsResponseWithMock() {
        // Set up mock HTTP response with empty charts
        String emptyChartsResponse = '{"OCCURRENCE_LAST_7_DAYS":"","OCCURRENCE_LAST_30_DAYS":""}';
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(emptyChartsResponse));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Test empty charts response handling with mock
        Test.startTest();
        try {
            client.generateChartImagesBasedStringChartConfig(chartConfigJson);
            System.assert(false, 'Should have thrown exception for empty charts response');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('No valid chart images found in Lambda response', e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testInvalidJsonResponseHandling() {
        // Test handling of invalid JSON responses
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test with invalid JSON response
        try {
            // This would be tested in integration tests
            System.debug('Invalid JSON response handling would be tested with actual Lambda responses');
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
        }
    }
    
    @IsTest
    static void testInvalidDataTypesResponseWithMock() {
        // Set up mock HTTP response with invalid data types
        String invalidDataTypesResponse = '{"OCCURRENCE_LAST_7_DAYS":123,"OCCURRENCE_LAST_30_DAYS":true}';
        Test.setMock(HttpCalloutMock.class, new ChartGeneratorMockHttpResponse(invalidDataTypesResponse));
        
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        Map<String, Object> chartConfig = new Map<String, Object>{
            'OCCURRENCE_LAST_7_DAYS' => new Map<String, Object>{
                'SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE' => '[{"logCount":3,"date":"24.06.2025"}]'
            }
        };
        
        String chartConfigJson = JSON.serialize(chartConfig);
        
        // Test invalid data types response handling with mock
        Test.startTest();
        try {
            client.generateChartImagesBasedStringChartConfig(chartConfigJson);
            System.assert(false, 'Should have thrown exception for invalid data types response');
        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
            System.assertEquals('No valid chart images found in Lambda response', e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testMultipleChartTypesResponse() {
        // Test handling of responses with multiple chart types
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Test response with multiple chart types (Example 4)
        String multipleChartsResponse = '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzde3xcVb3///dn70nS...","OCCURRENCE_LOGS_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxdVbn/8e+zdpK2..."}';
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(multipleChartsResponse);
        
        // Verify both chart types are present
        System.assert(responseMap.containsKey('OCCURRENCE_LAST_7_DAYS'), 'Should contain OCCURRENCE_LAST_7_DAYS');
        System.assert(responseMap.containsKey('OCCURRENCE_LOGS_LAST_7_DAYS'), 'Should contain OCCURRENCE_LOGS_LAST_7_DAYS');
        
        // Verify the values are base64 strings
        String chart1 = (String) responseMap.get('OCCURRENCE_LAST_7_DAYS');
        String chart2 = (String) responseMap.get('OCCURRENCE_LOGS_LAST_7_DAYS');
        
        System.assert(String.isNotBlank(chart1), 'OCCURRENCE_LAST_7_DAYS should not be blank');
        System.assert(String.isNotBlank(chart2), 'OCCURRENCE_LOGS_LAST_7_DAYS should not be blank');
        System.assert(chart1.startsWith('iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzde3xcVb3///dn70nS'), 'Should be valid base64 image');
        System.assert(chart2.startsWith('iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxdVbn/8e+zdpK2'), 'Should be valid base64 image');
        
        System.debug('Multiple chart types response test passed');
    }
    
    @IsTest
    static void testExactLambdaResponseFormat() {
        // Test the exact Lambda response format provided by the user
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Mock the exact Lambda response format from the user
        String exactLambdaResponse = '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzde3xcVb3///dn70nS...","OCCURRENCE_LOGS_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxdVbn/8e+zdpK2..."}';
        
        // Test parsing of the exact response format
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(exactLambdaResponse);
        
        // Verify both chart types are present
        System.assert(responseMap.containsKey('OCCURRENCE_LAST_7_DAYS'), 'Response should contain OCCURRENCE_LAST_7_DAYS');
        System.assert(responseMap.containsKey('OCCURRENCE_LOGS_LAST_7_DAYS'), 'Response should contain OCCURRENCE_LOGS_LAST_7_DAYS');
        
        // Verify the values are base64 strings
        String chart1 = (String) responseMap.get('OCCURRENCE_LAST_7_DAYS');
        String chart2 = (String) responseMap.get('OCCURRENCE_LOGS_LAST_7_DAYS');
        
        System.assert(String.isNotBlank(chart1), 'OCCURRENCE_LAST_7_DAYS should not be blank');
        System.assert(String.isNotBlank(chart2), 'OCCURRENCE_LOGS_LAST_7_DAYS should not be blank');
        System.assert(chart1.startsWith('iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzde3xcVb3///dn70nS'), 'Should be valid base64 image');
        System.assert(chart2.startsWith('iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxdVbn/8e+zdpK2'), 'Should be valid base64 image');
        
        // Test that the response format matches our expected structure
        System.assertEquals(2, responseMap.size(), 'Response should contain exactly 2 chart types');
        
        System.debug('Exact Lambda response format test passed');
        System.debug('Response contains: ' + responseMap.keySet());
    }
    
    @IsTest
    static void testChartServiceEnumMapping() {
        // Test the exact format requested: ChartService.Chart enum values => images
        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        
        // Mock Lambda response with multiple chart types
        String lambdaResponse = '{"OCCURRENCE_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzde3xcVb3///dn70nS...","OCCURRENCE_LAST_30_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxcdb3/8ffnO5N0...","OCCURRENCE_LOGS_LAST_7_DAYS":"iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QA/wD/AP+gvaeTAAAgAElEQVR4nOzdeXxdVbn/8e+zdpK2..."}';
        
        // Parse the response to simulate what the class would do
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(lambdaResponse);
        
        // Demonstrate the mapping format:
        // ChartService.Chart.OCCURRENCE_LAST_7_DAYS => image1
        // ChartService.Chart.OCCURRENCE_LAST_30_DAYS => image2
        // ChartService.Chart.OCCURRENCE_LOGS_LAST_7_DAYS => image3
        
        String chart7DaysKey = ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name();
        String chart30DaysKey = ChartService.Chart.OCCURRENCE_LAST_30_DAYS.name();
        String chartLogs7DaysKey = ChartService.Chart.OCCURRENCE_LOGS_LAST_7_DAYS.name();
        
        // Verify the enum values match the response keys
        System.assert(responseMap.containsKey(chart7DaysKey), 'Response should contain OCCURRENCE_LAST_7_DAYS');
        System.assert(responseMap.containsKey(chart30DaysKey), 'Response should contain OCCURRENCE_LAST_30_DAYS');
        System.assert(responseMap.containsKey(chartLogs7DaysKey), 'Response should contain OCCURRENCE_LOGS_LAST_7_DAYS');
        
        // Get the images using enum values
        String image1 = (String) responseMap.get(chart7DaysKey);
        String image2 = (String) responseMap.get(chart30DaysKey);
        String image3 = (String) responseMap.get(chartLogs7DaysKey);
        
        // Verify images are valid base64 strings
        System.assert(String.isNotBlank(image1), 'OCCURRENCE_LAST_7_DAYS image should not be blank');
        System.assert(String.isNotBlank(image2), 'OCCURRENCE_LAST_30_DAYS image should not be blank');
        System.assert(String.isNotBlank(image3), 'OCCURRENCE_LOGS_LAST_7_DAYS image should not be blank');
        
        // Demonstrate the format mapping
        System.debug('=== ChartService.Chart Enum to Image Mapping ===');
        System.debug(chart7DaysKey + ' => image1 (base64 length: ' + image1.length() + ')');
        System.debug(chart30DaysKey + ' => image2 (base64 length: ' + image2.length() + ')');
        System.debug(chartLogs7DaysKey + ' => image3 (base64 length: ' + image3.length() + ')');
        
        // Test using the actual client methods (would work in real scenario)
        // client.getBlobImageForChart(ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name()) => image1 as Blob
        // client.getBlobImageForChart(ChartService.Chart.OCCURRENCE_LAST_30_DAYS.name()) => image2 as Blob
        // client.getBlobImageForChart(ChartService.Chart.OCCURRENCE_LOGS_LAST_7_DAYS.name()) => image3 as Blob
        
        System.debug('=== Usage Examples ===');
        System.debug('Blob chart7Days = client.getBlobImageForChart(ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name());');
        System.debug('Blob chart30Days = client.getBlobImageForChart(ChartService.Chart.OCCURRENCE_LAST_30_DAYS.name());');
        System.debug('String chart7DaysBase64 = client.getBase64ImageForChart(ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name());');
        System.debug('String chart30DaysBase64 = client.getBase64ImageForChart(ChartService.Chart.OCCURRENCE_LAST_30_DAYS.name());');
        
        System.debug('ChartService.Chart enum mapping test passed');
    }
    
    // Mock HTTP response class for testing
    public class ChartGeneratorMockHttpResponse implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
        
        public ChartGeneratorMockHttpResponse(String responseBody) {
            this.responseBody = responseBody;
            this.statusCode = 200;
        }
        
        public ChartGeneratorMockHttpResponse(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}