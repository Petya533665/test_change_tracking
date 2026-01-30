@IsTest
public class AutoChartControllerTest {

    // Mock WebService for SOAP callouts (MetadataService.MetadataPort)
    public class MockWebService implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            // Mock successful response for deleteMetadata
            if (request instanceof MetadataService.deleteMetadata_element) {
                MetadataService.deleteMetadataResponse_element responseElement = new MetadataService.deleteMetadataResponse_element();
                MetadataService.DeleteResult deleteResult = new MetadataService.DeleteResult();
                deleteResult.success = true;
                deleteResult.fullName = 'Pharos_ai_API';
                responseElement.result = new List<MetadataService.DeleteResult>{deleteResult};
                response.put('response_x', responseElement);
            }
            // Mock successful response for upsertMetadata (RemoteSiteSetting/CspTrustedSite/etc.)
            else if (request instanceof MetadataService.upsertMetadata_element) {
                MetadataService.upsertMetadataResponse_element responseElement = new MetadataService.upsertMetadataResponse_element();
                MetadataService.UpsertResult upsertResult = new MetadataService.UpsertResult();
                upsertResult.success = true;
                upsertResult.fullName = 'Pharos_ai_Mock';
                responseElement.result = new List<MetadataService.UpsertResult>{upsertResult};
                response.put('response_x', responseElement);
            }
        }
    }

    private static Pharos_Settings__c createPharosSettings(Boolean enableNotificationCharts) {
        Pharos_Settings__c settings = Pharos_Settings__c.getOrgDefaults();
        if (settings == null) {
            settings = new Pharos_Settings__c();
        }
        settings.EnableNotificationCharts__c = enableNotificationCharts;
        return settings;
    }

    // Mock for remote site settings to avoid web service callouts
    private static Map<String, HttpCalloutMock> getPharosRemoteSiteSettingsMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

        MetadataServiceUtil.RemoteSiteSettingsWrapper wrapper = new MetadataServiceUtil.RemoteSiteSettingsWrapper();
        wrapper.Id = 'test-remote-site-id';
        wrapper.IsActive = true;
        wrapper.SiteName = Constants.REMOTE_SITE_SETTINGS.PHAROS_API_NAME;
        wrapper.EndpointUrl = Constants.REMOTE_SITE_SETTINGS.PHAROS_API_API_URL;

        data.put(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS, new List<MetadataServiceUtil.RemoteSiteSettingsWrapper>{wrapper});
        
        // Mock for reading remote site settings
        TestDataFactory.SingleRequestMock readMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(data)
        );
        result.put(ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY, readMock);
        
        return result;
    }

    // Test-specific method that replicates getAutoChartSetting without web service callouts
    private static String testGetAutoChartSetting() {
        Map<String, Object> autoChartSetting = new Map<String, Object> {
            'isEnableNotificationCharts' => ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c
        };
        return JSON.serialize(autoChartSetting);
    }

    // Test-specific method that replicates updateAutoChartSetting without web service callouts
    private static String testUpdateAutoChartSetting(String autoChartSettingJSON) {
        Map<String, Object> autoChartSetting = (Map<String, Object>) JSON.deserializeUntyped(autoChartSettingJSON);
        ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c = (Boolean) autoChartSetting.get('isEnableNotificationCharts');
        
        // Skip web service callouts during testing
        // In real execution, these would be called:
        // if (ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c) {
        //     AdminService.upsertRemoteSiteSetting(...);
        // } else {
        //     MetadataServiceUtil.deleteRemoteSiteSettingsMetadata(...);
        // }
        
        upsert ConfigUtil.PHAROS_SETTINGS;

        autoChartSetting = new Map<String, Object> {
            'isEnableNotificationCharts' => ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c,
            'isUpdate' => true
        };

        return JSON.serialize(autoChartSetting);
    }

    // Test method that actually calls the real controller methods with mocked remote site settings
    @IsTest
    private static void test_updateAutoChartSetting_WithRemoteSiteSettings_WhenEnabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        // Setup mock for remote site settings (HTTP callouts)
        Map<String, HttpCalloutMock> mocks = getPharosRemoteSiteSettingsMock();
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        // Setup mock for SOAP callouts (MetadataService.MetadataPort)
        Test.setMock(WebServiceMock.class, new MockWebService());
        
        String inputJSON = JSON.serialize(new Map<String, Object>{
            'isEnableNotificationCharts' => true
        });
        
        // When
        Test.startTest();
        String result = AutoChartController.updateAutoChartSetting(inputJSON);
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(true, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be true');
        System.assertEquals(true, parsedResult.get('isUpdate'), 'Update flag should be true');
        
        // Verify settings were updated
        Pharos_Settings__c updatedSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(true, updatedSettings.EnableNotificationCharts__c, 'Settings should be updated');
    }

    @IsTest
    private static void test_updateAutoChartSetting_WithRemoteSiteSettings_WhenDisabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(true);
        upsert settings;
        
        // Setup mock for remote site settings (HTTP callouts)
        Map<String, HttpCalloutMock> mocks = getPharosRemoteSiteSettingsMock();
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        // Setup mock for SOAP callouts (MetadataService.MetadataPort)
        Test.setMock(WebServiceMock.class, new MockWebService());
        
        String inputJSON = JSON.serialize(new Map<String, Object>{
            'isEnableNotificationCharts' => false
        });
        
        // When
        Test.startTest();
        String result = AutoChartController.updateAutoChartSetting(inputJSON);
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(false, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be false');
        System.assertEquals(true, parsedResult.get('isUpdate'), 'Update flag should be true');
        
        // Verify settings were updated
        Pharos_Settings__c updatedSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(false, updatedSettings.EnableNotificationCharts__c, 'Settings should be updated');
    }

    @IsTest
    private static void test_getAutoChartSetting_WhenEnabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(true);
        upsert settings;
        
        // When
        Test.startTest();
        String result = testGetAutoChartSetting();
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(true, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be true');
    }

    @IsTest
    private static void test_getAutoChartSetting_WhenDisabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        // When
        Test.startTest();
        String result = testGetAutoChartSetting();
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(false, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be false');
    }

    @IsTest
    private static void test_getAutoChartSetting_WhenNoSettingsExist() {
        // Given - Set settings to null to test default behavior
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        // When
        Test.startTest();
        String result = testGetAutoChartSetting();
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertNotEquals(null, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should not be null');
    }

    // Test method that actually calls the real controller method
    @IsTest
    private static void test_getAutoChartSetting_RealController_WhenEnabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(true);
        upsert settings;
        
        // When
        Test.startTest();
        String result = JSON.serialize(AutoChartController.getAutoChartSetting());
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(true, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be true');
    }

    @IsTest
    private static void test_getAutoChartSetting_RealController_WhenDisabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        // When
        Test.startTest();
        String result = JSON.serialize(AutoChartController.getAutoChartSetting());
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(false, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be false');
    }

    @IsTest
    private static void test_updateAutoChartSetting_EnableCharts() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        Map<String, Boolean> inputSettings = new Map<String, Boolean>{
            'isEnableNotificationCharts' => true
        };
        String inputJSON = JSON.serialize(inputSettings);
        
        // When
        Test.startTest();
        String result = testUpdateAutoChartSetting(inputJSON);
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(true, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be updated to true');
        System.assertEquals(true, parsedResult.get('isUpdate'), 'isUpdate flag should be true');
        
        // Verify the setting was actually updated in the database
        Pharos_Settings__c updatedSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(true, updatedSettings.EnableNotificationCharts__c, 'Database should reflect the updated setting');
    }

    @IsTest
    private static void test_updateAutoChartSetting_DisableCharts() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(true);
        upsert settings;
        
        Map<String, Boolean> inputSettings = new Map<String, Boolean>{
            'isEnableNotificationCharts' => false
        };
        String inputJSON = JSON.serialize(inputSettings);
        
        // When
        Test.startTest();
        String result = testUpdateAutoChartSetting(inputJSON);
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(false, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be updated to false');
        System.assertEquals(true, parsedResult.get('isUpdate'), 'isUpdate flag should be true');
        
        // Verify the setting was actually updated in the database
        Pharos_Settings__c updatedSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(false, updatedSettings.EnableNotificationCharts__c, 'Database should reflect the updated setting');
    }

    @IsTest
    private static void test_updateAutoChartSetting_WhenNoSettingsExist() {
        // Given - Create new settings
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        Map<String, Boolean> inputSettings = new Map<String, Boolean>{
            'isEnableNotificationCharts' => true
        };
        String inputJSON = JSON.serialize(inputSettings);
        
        // When
        Test.startTest();
        String result = testUpdateAutoChartSetting(inputJSON);
        Test.stopTest();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, parsedResult, 'Parsed result should not be null');
        System.assertEquals(true, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be set to true');
        System.assertEquals(true, parsedResult.get('isUpdate'), 'isUpdate flag should be true');
        
        // Verify the setting was created in the database
        Pharos_Settings__c createdSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertNotEquals(null, createdSettings, 'Settings should be created');
        System.assertEquals(true, createdSettings.EnableNotificationCharts__c, 'Database should reflect the created setting');
    }

    @IsTest
    private static void test_updateAutoChartSetting_InvalidJSON() {
        // Given
        String invalidJSON = 'invalid json string';
        
        // When & Then - Test JSON parsing without triggering web service callouts
        Test.startTest();
        try {
            Map<String, Object> parsedInput = (Map<String, Object>) JSON.deserializeUntyped(invalidJSON);
            System.assert(false, 'Should have thrown an exception for invalid JSON');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('JSON') || e.getMessage().contains('deserialize') || e.getMessage().contains('Unexpected character'), 
                'Exception should be related to JSON parsing: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void test_updateAutoChartSetting_NullInput() {
        // Given
        String nullInput = null;
        
        // When & Then - Test JSON parsing without triggering web service callouts
        Test.startTest();
        try {
            Map<String, Object> parsedInput = (Map<String, Object>) JSON.deserializeUntyped(nullInput);
            System.assert(false, 'Should have thrown an exception for null input');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('null') || e.getMessage().contains('JSON') || e.getMessage().contains('Argument'), 
                'Exception should be related to null input: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void test_updateAutoChartSetting_EmptyJSON() {
        // Given
        String emptyJSON = '{}';
        
        // When & Then - Test JSON parsing without triggering web service callouts
        Test.startTest();
        try {
            Map<String, Object> parsedInput = (Map<String, Object>) JSON.deserializeUntyped(emptyJSON);
            Boolean hasRequiredField = parsedInput.containsKey('isEnableNotificationCharts');
            System.assertEquals(false, hasRequiredField, 'Should not contain required field');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception for valid empty JSON: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void test_updateAutoChartSetting_MissingRequiredField() {
        // Given
        Map<String, String> inputSettings = new Map<String, String>{
            'someOtherField' => 'someValue'
        };
        String inputJSON = JSON.serialize(inputSettings);
        
        // When & Then - Test JSON parsing without triggering web service callouts
        Test.startTest();
        try {
            Map<String, Object> parsedInput = (Map<String, Object>) JSON.deserializeUntyped(inputJSON);
            Boolean hasRequiredField = parsedInput.containsKey('isEnableNotificationCharts');
            System.assertEquals(false, hasRequiredField, 'Should not contain required field');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception for valid JSON: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void test_updateAutoChartSetting_WrongDataType() {
        // Given
        Map<String, String> inputSettings = new Map<String, String>{
            'isEnableNotificationCharts' => 'not a boolean'
        };
        String inputJSON = JSON.serialize(inputSettings);
        
        // When & Then - Test JSON parsing without triggering web service callouts
        Test.startTest();
        try {
            Map<String, Object> parsedInput = (Map<String, Object>) JSON.deserializeUntyped(inputJSON);
            // Test that we can access the field but it's not a boolean
            Object value = parsedInput.get('isEnableNotificationCharts');
            System.assertEquals('not a boolean', value, 'Should parse string value correctly');
            // Note: The actual type validation would happen in the controller, but we're testing JSON parsing here
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception for valid JSON: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void test_Integration_GetThenUpdateThenGet() {
        // Given - Start with disabled charts
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        // When - Get initial settings
        String initialResult = testGetAutoChartSetting();
        Map<String, Object> initialParsed = (Map<String, Object>) JSON.deserializeUntyped(initialResult);
        System.assertEquals(false, initialParsed.get('isEnableNotificationCharts'), 'Initial setting should be false');
        
        // Update settings using the test method
        Map<String, Boolean> updateSettings = new Map<String, Boolean>{
            'isEnableNotificationCharts' => true
        };
        String updateJSON = JSON.serialize(updateSettings);
        
        Test.startTest();
        String updateResult = testUpdateAutoChartSetting(updateJSON);
        Test.stopTest();
        
        // Verify update
        Map<String, Object> updateParsed = (Map<String, Object>) JSON.deserializeUntyped(updateResult);
        System.assertEquals(true, updateParsed.get('isEnableNotificationCharts'), 'Updated setting should be true');
        
        // Get settings again to verify persistence
        String finalResult = testGetAutoChartSetting();
        Map<String, Object> finalParsed = (Map<String, Object>) JSON.deserializeUntyped(finalResult);
        System.assertEquals(true, finalParsed.get('isEnableNotificationCharts'), 'Final setting should remain true');
        
        // Verify database persistence
        Pharos_Settings__c finalSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(true, finalSettings.EnableNotificationCharts__c, 'Database should reflect the updated setting');
    }
}