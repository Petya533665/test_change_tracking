@IsTest
private class HoltwintersForecastParametersTest {
    
    @IsTest
    static void testDefaultConstructor() {
        HoltwintersForecastParameters params = new HoltwintersForecastParameters();
        
        System.assertEquals(null, params.issueId);
        System.assertEquals(null, params.startDatetime);
        System.assertEquals(null, params.endDatetime);
        System.assertEquals(null, params.logsData);
        System.assertEquals(null, params.traceScheduleId);
    }
    
    @IsTest
    static void testSetDefaultDates() {
        HoltwintersForecastParameters params = new HoltwintersForecastParameters();
        params.issueId = 'test123';
        
        // Initially dates should be null
        System.assertEquals(null, params.startDatetime);
        System.assertEquals(null, params.endDatetime);
        
        // Set default dates
        params.setDefaultDates();
        
        // After setting default dates, they should not be null
        System.assertNotEquals(null, params.startDatetime);
        System.assertNotEquals(null, params.endDatetime);
        
        // Verify dates are approximately 90 days apart
        Long daysDifference = (params.endDatetime.getTime() - params.startDatetime.getTime()) / (1000 * 60 * 60 * 24);
        System.assert(daysDifference >= 89 && daysDifference <= 91, 'Expected approximately 90 days difference');
        
        // Should be valid after setting default dates
        System.assertEquals(true, params.isValid());
    }
    
    @IsTest
    static void testValidation() {
        // Test with missing issueId
        HoltwintersForecastParameters params1 = new HoltwintersForecastParameters();
        params1.startDatetime = Datetime.now();
        params1.endDatetime = Datetime.now().addDays(30);
        
        System.assertEquals(false, params1.isValid());
        System.assertEquals('issueId is required', params1.getValidationErrorMessage());
        
        // Test with missing startDatetime
        HoltwintersForecastParameters params2 = new HoltwintersForecastParameters();
        params2.issueId = 'test123';
        params2.endDatetime = Datetime.now().addDays(30);
        
        System.assertEquals(false, params2.isValid());
        System.assertEquals('startDatetime is required', params2.getValidationErrorMessage());
        
        // Test with missing endDatetime
        HoltwintersForecastParameters params3 = new HoltwintersForecastParameters();
        params3.issueId = 'test123';
        params3.startDatetime = Datetime.now();
        
        System.assertEquals(false, params3.isValid());
        System.assertEquals('endDatetime is required', params3.getValidationErrorMessage());
        
        // Test with all required fields
        HoltwintersForecastParameters params4 = new HoltwintersForecastParameters();
        params4.issueId = 'test123';
        params4.startDatetime = Datetime.now();
        params4.endDatetime = Datetime.now().addDays(30);
        
        System.assertEquals(true, params4.isValid());
        System.assertEquals(null, params4.getValidationErrorMessage());
    }
    
    @IsTest
    static void testValidationWithEmptyIssueId() {
        HoltwintersForecastParameters params = new HoltwintersForecastParameters();
        params.issueId = '';
        params.startDatetime = Datetime.now();
        params.endDatetime = Datetime.now().addDays(30);
        
        System.assertEquals(false, params.isValid());
        System.assertEquals('issueId is required', params.getValidationErrorMessage());
    }
    
    @IsTest
    static void testValidationWithWhitespaceIssueId() {
        HoltwintersForecastParameters params = new HoltwintersForecastParameters();
        params.issueId = '   ';
        params.startDatetime = Datetime.now();
        params.endDatetime = Datetime.now().addDays(30);
        
        System.assertEquals(false, params.isValid());
        System.assertEquals('issueId is required', params.getValidationErrorMessage());
    }
    
    @IsTest
    static void testSetDefaultDatesWithExistingDates() {
        HoltwintersForecastParameters params = new HoltwintersForecastParameters();
        params.issueId = 'test123';
        
        // Set custom dates first
        Datetime customStart = Datetime.now().addDays(-30);
        Datetime customEnd = Datetime.now().addDays(-10);
        params.startDatetime = customStart;
        params.endDatetime = customEnd;
        
        // Call setDefaultDates - should not override existing dates
        params.setDefaultDates();
        
        // Dates should remain the same
        System.assertEquals(customStart, params.startDatetime);
        System.assertEquals(customEnd, params.endDatetime);
        
        // Should be valid
        System.assertEquals(true, params.isValid());
    }
    
    @IsTest
    static void testSetDefaultDatesWithPartialDates() {
        HoltwintersForecastParameters params = new HoltwintersForecastParameters();
        params.issueId = 'test123';
        
        // Set only start date
        Datetime customStart = Datetime.now().addDays(-30);
        params.startDatetime = customStart;
        
        // Call setDefaultDates
        params.setDefaultDates();
        
        // Start date should remain the same, end date should be set to now
        System.assertEquals(customStart, params.startDatetime);
        System.assertNotEquals(null, params.endDatetime);
        System.assertEquals(Datetime.now().day(), params.endDatetime.day());
        
        // Should be valid
        System.assertEquals(true, params.isValid());
    }
    
    @IsTest
    static void testAdditionalParameters() {
        HoltwintersForecastParameters params = new HoltwintersForecastParameters();
        
        // Test setting additional parameters
        params.logsData = 'test logs data';
        params.traceScheduleId = 'test-schedule-id';
        
        System.assertEquals('test logs data', params.logsData);
        System.assertEquals('test-schedule-id', params.traceScheduleId);
        
        // Should still be invalid without required fields
        System.assertEquals(false, params.isValid());
    }
}