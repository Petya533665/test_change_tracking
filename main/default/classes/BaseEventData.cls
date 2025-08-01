public virtual class BaseEventData implements EventLogProcessors.IBaseEventData {
    protected Map<String, Object> eventData;
    public DateTime timestamp;
    public String userId;
    public String organizationId;
    public String requestId;

    public BaseEventData(Map<String, Object> data) {
        this.eventData = data != null ? data : new Map<String, Object>();
        this.timestamp = parseTimestamp(getField('TIMESTAMP'));
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
}