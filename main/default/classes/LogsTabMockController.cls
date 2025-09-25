public with sharing class LogsTabMockController {
    
    public LogsTabMockController() {
        // Simple constructor - no record context needed
    }
    
    public String getPageTitle() {
        return 'Logs Charts';
    }
    
    public String getWelcomeMessage() {
        return 'This is a mock page for testing the tab configuration.';
    }
    
    public PageReference navigateToLogs() {
        // Navigate to the LogsChartsWrapper page
        PageReference pageRef = Page.LogsChartsWrapper;
        return pageRef;
    }
}