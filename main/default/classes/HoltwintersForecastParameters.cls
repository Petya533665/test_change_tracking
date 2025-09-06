public class HoltwintersForecastParameters {
    
    // Core parameters
    public String issueId { get; set; }
    public Datetime startDatetime { get; set; }
    public Datetime endDatetime { get; set; }
    
    // Additional parameters for specific methods
    public String logsData { get; set; }
    public String traceScheduleId { get; set; }
    
    // Default constructor
    public HoltwintersForecastParameters() {}

    // Set default dates (last 90 days)
    public void setDefaultDates() {
        Datetime currentDatetime = System.now();
        if (this.startDatetime == null) {
            this.startDatetime = currentDatetime.addDays(-90);
        }
        if (this.endDatetime == null) {
            this.endDatetime = currentDatetime;
        }
    }
    
    // Validate required parameters
    public Boolean isValid() {
        return String.isNotBlank(this.issueId) && 
               this.startDatetime != null && 
               this.endDatetime != null;
    }

    // Get validation error message
    public String getValidationErrorMessage() {
        if (String.isBlank(this.issueId)) {
            return 'issueId is required';
        }
        if (this.startDatetime == null) {
            return 'startDatetime is required';
        }
        if (this.endDatetime == null) {
            return 'endDatetime is required';
        }
        return null;
    }
}