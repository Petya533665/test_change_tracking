public virtual class BaseEventData implements EventLogProcessors.IBaseEventData {
    protected Map<String, Object> eventData;
    public DateTime timestamp;
    public String userId;
    public String organizationId;
    public String requestId;

    public BaseEventData(Map<String, Object> data) {
        this.eventData = data != null ? data : new Map<String, Object>();
        this.timestamp = parseTimestamp(getField('TIMESTAMP'));
        
        // Fallback to TIMESTAMP_DERIVED if TIMESTAMP is null/empty
        if (this.timestamp == null) {
            // First check if TIMESTAMP_DERIVED is already a DateTime object (from CSV processing)
            Object timestampDerivedObj = getValue('TIMESTAMP_DERIVED');
            
            if (timestampDerivedObj instanceof DateTime) {
                this.timestamp = (DateTime)timestampDerivedObj;
            } else {
                // If it's a string, parse it with millisecond precision
                String timestampDerivedStr = getField('TIMESTAMP_DERIVED');
                
                // Use JSON.deserialize for clean ISO8601 parsing with millisecond precision
                if (String.isNotBlank(timestampDerivedStr)) {
                    try {
                        // JSON.deserialize handles ISO8601 format perfectly, including milliseconds
                        this.timestamp = (DateTime)JSON.deserialize('"' + timestampDerivedStr + '"', DateTime.class);
                    } catch (Exception e) {
                        // Fallback to legacy parsing method
                        this.timestamp = parseTimestampDerived(timestampDerivedStr);
                    }
                }
            }
        }
        
        this.userId = getField('USER_ID');
        this.organizationId = getField('ORGANIZATION_ID');
        this.requestId = getField('REQUEST_ID');
    }

    public Object getValue(String metric) {
        return eventData.get(metric);
    }

    protected String getField(String field) {
        return String.valueOf(getValue(field));
    }

    protected DateTime parseTimestamp(String timestamp) {
        if (String.isBlank(timestamp)) return null;
        
        try {
            // Extract components from timestamp string "20250108001501.473"
            String year = timestamp.substring(0, 4);
            String month = timestamp.substring(4, 6);
            String day = timestamp.substring(6, 8);
            String hour = timestamp.substring(8, 10);
            String minute = timestamp.substring(10, 12);
            String second = timestamp.substring(12, 14);
            String millisecond = timestamp.substring(15);

            return DateTime.newInstanceGMT(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day), Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second));
        }
        catch (Exception e) {
            return null;
        }
    }
    
    protected DateTime parseTimestampDerived(String timestampDerivedStr) {
        if (String.isBlank(timestampDerivedStr)) {
            // Try to get the actual object from eventData in case it's a DateTime object
            Object timestampObj = getValue('TIMESTAMP_DERIVED');
            if (timestampObj instanceof DateTime) {
                return (DateTime)timestampObj;
            }
            return null;
        }
        
        try {
            // Use JSON.deserialize for clean ISO8601 parsing with millisecond precision
            return (DateTime)JSON.deserialize('"' + timestampDerivedStr + '"', DateTime.class);
        }
        catch (Exception e) {
            return null;
        }
    }
}