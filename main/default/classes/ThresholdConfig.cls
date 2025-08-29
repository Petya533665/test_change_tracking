public class ThresholdConfig implements System.Comparable {

    public enum EvaluationType {
        GREATER_THAN,
        LESS_THAN,
        EQUALS,
        NOT_EQUALS,
        NOT_NULL,
        IS_IN
    }

    public String eventType { get; private set; }
    public String metric { get; private set; }
    public Object threshold { get; private set; }
    public EvaluationType evaluationType { get; private set; }

    // Constructor with threshold only
    public ThresholdConfig(String eventType, String metric, Object thresholdValue, EvaluationType evalType) {
        this.eventType = eventType;
        this.metric = metric;
        this.threshold = thresholdValue;
        this.evaluationType = evalType;
        validateConfig();
    }

    // Validate configuration
    private void validateConfig() {
        // Check required fields
        if (String.isBlank(eventType) || String.isBlank(metric)) {
            throw new ThresholdConfigException('EventType and Metric must be specified');
        }

        // Validate evaluation type
        if (evaluationType == null) {
            throw new ThresholdConfigException('Evaluation type must be specified');
        }

        // Validate thresholds based on evaluation type
        switch on evaluationType {
            when NOT_NULL {
                if (threshold != null) {
                    throw new ThresholdConfigException('NOT_NULL evaluation type does not accept thresholds');
                }
            }
            when IS_IN {
                if (!(threshold instanceof List<Object>)) {
                    throw new ThresholdConfigException('IS_IN evaluation type requires List threshold');
                }
            }
            when NOT_EQUALS {
                // NOT_EQUALS can have null thresholds - no validation needed
            }
            when else {
                // For all other types, threshold must be specified
                if (threshold == null) {
                    throw new ThresholdConfigException('Threshold must be specified for ' + evaluationType + ' evaluation type');
                }
            }
        }

        // Validate threshold ranges
        if (!isValidThresholdRange()) {
            throw new ThresholdConfigException('Invalid threshold range for evaluation type: ' + evaluationType);
        }
    }

    // Check if thresholds are in valid range based on evaluation type
    private Boolean isValidThresholdRange() {
        // Skip validation for types that don't require range comparison
        if (evaluationType == ThresholdConfig.EvaluationType.NOT_NULL || 
            evaluationType == ThresholdConfig.EvaluationType.NOT_EQUALS ||
            evaluationType == ThresholdConfig.EvaluationType.EQUALS ||
            evaluationType == ThresholdConfig.EvaluationType.IS_IN) {
            return true;
        }

        // Skip if threshold is null
        if (threshold == null) {
            return true;
        }

        // With only threshold, no range validation needed
        return true;
    }

    private Double toDouble(Object value) {
        if (value instanceof Decimal) {
            return (Double)value;
        } else if (value instanceof Integer) {
            return Double.valueOf(value);
        } else if (value instanceof Double) {
            return (Double)value;
        } else if (value instanceof String) {
            try {
                return Double.valueOf(value);
            } catch (TypeException e) {
                throw new ThresholdConfigException('Cannot convert value to Double: ' + value);
            }
        }
        throw new ThresholdConfigException('Cannot convert value to Double: ' + value);
    }

    // Implement comparable interface
    public Integer compareTo(Object compareTo) {
        ThresholdConfig other = (ThresholdConfig)compareTo;
        String thisKey = this.eventType + '.' + this.metric;
        String otherKey = other.eventType + '.' + other.metric;
        return thisKey.compareTo(otherKey);
    }

    public Boolean evaluateValue(Object value, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig) {
        if(fieldMetadataConfig == null) {
            throw new ThresholdConfigException('FieldMetadataConfig is required to evaluate value');
        }
        if(String.isBlank(metric)) {
            throw new ThresholdConfigException('Metric is required to evaluate value');
        }
        if(fieldMetadataConfig.getFieldType(metric) == null) {
            throw new ThresholdConfigException('FieldMetadataConfig does not contain metric: ' + metric);
        }
        
        String fieldType = fieldMetadataConfig?.getFieldType(metric)?.toLowerCase();
        if (fieldType == 'number') {
            Double doubleValue = null;
            Double thresholdDouble = null;
            
            try {
                doubleValue = (value != null) ? toDouble(value) : null;
                thresholdDouble = (threshold != null) ? toDouble(threshold) : null;
            } catch (ThresholdConfigException e) {
                // If any value cannot be converted to double, treat as non-numeric and return false
                return false;
            }

            switch on evaluationType {
                when GREATER_THAN {
                    if (doubleValue == null) return false;
                    if (thresholdDouble != null && doubleValue >= thresholdDouble) return true;
                }
                when LESS_THAN {
                    if (doubleValue == null) return false;
                    if (thresholdDouble != null && doubleValue <= thresholdDouble) return true;
                }
                when EQUALS {
                    if (thresholdDouble != null && doubleValue == thresholdDouble) return true;
                }
                when NOT_EQUALS {
                    if (thresholdDouble != null && doubleValue != thresholdDouble) return true;
                }
                when NOT_NULL {
                    if (doubleValue != null) return true;
                }
            }
        }
        else if (fieldType == 'boolean') {
            Boolean booleanValue = (value != null) ? Boolean.valueOf(value) : null;
            Boolean thresholdBoolean = (threshold != null) ? Boolean.valueOf(threshold) : null;
            switch on evaluationType {
                when EQUALS {
                    if (booleanValue == thresholdBoolean) return true;
                }
                when NOT_EQUALS {
                    if (booleanValue != thresholdBoolean) return true;
                }
            }
        }
        else if (fieldType == 'datetime') {
            return false;
        }
        else {
            String stringValue = (value != null) ? String.valueOf(value) : null;
            String thresholdString = (this.threshold != null) ? String.valueOf(this.threshold) : null;

            switch on evaluationType {
                when EQUALS {
                    if (stringValue == thresholdString) return true;
                }
                when NOT_EQUALS {
                    // Handle special case: NOT_EQUALS with empty string threshold means "trigger on any non-empty value"
                    if ((thresholdString == null || thresholdString == '') && String.isNotBlank(stringValue)) {
                        return true;
                    }
                    // Handle normal NOT_EQUALS comparison
                    if (String.isNotBlank(thresholdString) && stringValue != thresholdString) return true;
                }
                when NOT_NULL {
                    if (String.isNotBlank(stringValue)) return true;
                }
                when IS_IN {
                    if (this.threshold instanceof List<Object>) {
                        List<Object> thresholdList = (List<Object>) this.threshold;
                        for (Object item : thresholdList) {
                            if (stringValue == String.valueOf(item)) {
                                return true;
                            }
                        }
                    }
                }
            }
        }
        return false;
    }

    // Custom string representation
    public override String toString() {
        return String.format(
            'ThresholdConfig[{0}.{1}] Threshold: {2}, Type: {3}',
            new List<Object>{
                eventType,
                metric,
                threshold,
                evaluationType
            }
        );
    }

    // Custom exception class
    public class ThresholdConfigException extends Exception {}

    // Builder pattern for complex configuration
    public class Builder {
        private String eventType;
        private String metric;
        private Object threshold;
        private EvaluationType evaluationType;

        public Builder setEventType(String eventType) {
            this.eventType = eventType;
            return this;
        }

        public Builder setMetric(String metric) {
            this.metric = metric;
            return this;
        }

        public Builder setThreshold(Object thresholdValue) {
            this.threshold = thresholdValue;
            return this;
        }

        public Builder setEvalType(String evalType) {
            this.evaluationType = ThresholdConfig.EvaluationType.valueOf(evalType);
            return this;
        }

        public Builder setEvalType(EvaluationType evalType) {
            this.evaluationType = evalType;
            return this;
        }

        public ThresholdConfig build() {
            ThresholdConfig config = new ThresholdConfig(
                eventType,
                metric,
                threshold,
                evaluationType
            );
            config.validateConfig();
            return config;
        }
    }
}