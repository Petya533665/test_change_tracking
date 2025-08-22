public class ThresholdConfig implements System.Comparable {

    public enum EvaluationType {
        GREATER_THAN,
        LESS_THAN,
        EQUALS,
        NOT_EQUALS,
        NOT_NULL,
        IS_IN
    }

    public enum AnomalySeverity {
        NORMAL,
        WARNING,
        CRITICAL
    }

    public String eventType { get; private set; }
    public String metric { get; private set; }
    public Object warningThreshold { get; private set; }
    public Object criticalThreshold { get; private set; }
    public EvaluationType evaluationType { get; private set; }

    // Constructor with various numeric types
    public ThresholdConfig(String eventType, String metric, Object warning, Object critical, EvaluationType evalType) {
        this.eventType = eventType;
        this.metric = metric;
        this.warningThreshold = warning;
        this.criticalThreshold = critical;
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
                if (warningThreshold != null || criticalThreshold != null) {
                    throw new ThresholdConfigException('NOT_NULL evaluation type does not accept thresholds');
                }
            }
            when IS_IN {
                if (!(warningThreshold instanceof List<Object> || criticalThreshold instanceof List<Object>)) {
                    throw new ThresholdConfigException('IS_IN evaluation type requires List thresholds');
                }
            }
            when NOT_EQUALS {
                // NOT_EQUALS can have null thresholds - no validation needed
            }
            when else {
                // For all other types, at least one threshold must be specified
                if (warningThreshold == null && criticalThreshold == null) {
                    throw new ThresholdConfigException('At least one threshold must be specified for ' + evaluationType + ' evaluation type');
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

        // Skip if either threshold is null
        if (warningThreshold == null || criticalThreshold == null) {
            return true;
        }

        try {
            // Convert thresholds to comparable values
            Double warningValue = toDouble(warningThreshold);
            Double criticalValue = toDouble(criticalThreshold);

            switch on evaluationType {
                when GREATER_THAN {
                    // For GREATER_THAN, warning should be less than critical
                    return warningValue <= criticalValue;
                }
                when LESS_THAN {
                    // For LESS_THAN, warning should be greater than critical
                    return warningValue >= criticalValue;
                }
                when else {
                    return false;
                }
            }
        }
        catch (Exception e) {
            // If conversion fails, assume it's a non-numeric comparison
            return true;
        }
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

    public AnomalySeverity evaluateValue(Object value, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig) {
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
            Double criticalThresholdDouble = null;
            Double warningThresholdDouble = null;
            
            try {
                doubleValue = (value != null) ? toDouble(value) : null;
                criticalThresholdDouble = (criticalThreshold != null) ? toDouble(criticalThreshold) : null;
                warningThresholdDouble = (warningThreshold != null) ? toDouble(warningThreshold) : null;
            } catch (ThresholdConfigException e) {
                // If any value cannot be converted to double, treat as non-numeric and return normal
                return AnomalySeverity.NORMAL;
            }

            switch on evaluationType {
                when GREATER_THAN {
                    if (doubleValue == null) return AnomalySeverity.NORMAL;
                    if (criticalThresholdDouble != null && doubleValue >= criticalThresholdDouble) return AnomalySeverity.CRITICAL;
                    if (warningThresholdDouble != null && doubleValue >= warningThresholdDouble) return AnomalySeverity.WARNING;
                }
                when LESS_THAN {
                    if (doubleValue == null) return AnomalySeverity.NORMAL;
                    if (criticalThresholdDouble != null && doubleValue <= criticalThresholdDouble) return AnomalySeverity.CRITICAL;
                    if (warningThresholdDouble != null && doubleValue <= warningThresholdDouble) return AnomalySeverity.WARNING;
                }
                when EQUALS {
                    if (criticalThresholdDouble != null && doubleValue == criticalThresholdDouble) return AnomalySeverity.CRITICAL;
                    if (warningThresholdDouble != null && doubleValue == warningThresholdDouble) return AnomalySeverity.WARNING;
                }
                when NOT_EQUALS {
                    if (criticalThresholdDouble != null && doubleValue != criticalThresholdDouble) return AnomalySeverity.CRITICAL;
                    if (warningThresholdDouble != null && doubleValue != warningThresholdDouble) return AnomalySeverity.WARNING;
                }
                when NOT_NULL {
                    if (doubleValue != null) return AnomalySeverity.CRITICAL;
                }
            }
        }
        else if (fieldType == 'boolean') {
            Boolean booleanValue = (value != null) ? Boolean.valueOf(value) : null;
            Boolean criticalThreshold = (criticalThreshold != null) ? Boolean.valueOf(criticalThreshold) : null;
            Boolean warningThreshold = (warningThreshold != null) ? Boolean.valueOf(warningThreshold) : null;
            switch on evaluationType {
                when EQUALS {
                    if (booleanValue == criticalThreshold) return AnomalySeverity.CRITICAL;
                    if (booleanValue == warningThreshold) return AnomalySeverity.WARNING;
                }
                when NOT_EQUALS {
                    if (booleanValue != criticalThreshold) return AnomalySeverity.CRITICAL;
                    if (booleanValue != warningThreshold) return AnomalySeverity.WARNING;
                }
            }
        }
        else if (fieldType == 'datetime') {
            return AnomalySeverity.NORMAL;
        }
        else {
            String stringValue = (value != null) ? String.valueOf(value) : null;
            String criticalThresholdString = (this.criticalThreshold != null) ? String.valueOf(this.criticalThreshold) : null;
            String warningThresholdString = (this.warningThreshold != null) ? String.valueOf(this.warningThreshold) : null;

            switch on evaluationType {
                when EQUALS {
                    if (stringValue == criticalThresholdString) return AnomalySeverity.CRITICAL;
                    if (stringValue == warningThresholdString) return AnomalySeverity.WARNING;
                }
                when NOT_EQUALS {
                    if (String.isBlank(criticalThresholdString) && String.isNotBlank(stringValue)) {
                        return AnomalySeverity.CRITICAL;
                    }
                    if (String.isBlank(warningThresholdString) && String.isNotBlank(stringValue)) {
                        return AnomalySeverity.WARNING;
                    }
                    // Handle normal NOT_EQUALS comparison
                    if (String.isNotBlank(criticalThresholdString) && stringValue != criticalThresholdString) return AnomalySeverity.CRITICAL;
                    if (String.isNotBlank(warningThresholdString) && stringValue != warningThresholdString) return AnomalySeverity.WARNING;
                }
                when NOT_NULL {
                    if (String.isNotBlank(stringValue)) return AnomalySeverity.CRITICAL;
                }
                when IS_IN {
                    if (this.criticalThreshold instanceof List<Object>) {
                        List<Object> criticalList = (List<Object>) this.criticalThreshold;
                        for (Object item : criticalList) {
                            if (stringValue == String.valueOf(item)) {
                                return AnomalySeverity.CRITICAL;
                            }
                        }
                    }
                    if (this.warningThreshold instanceof List<Object>) {
                        List<Object> warningList = (List<Object>) this.warningThreshold;
                        for (Object item : warningList) {
                            if (stringValue == String.valueOf(item)) {
                                return AnomalySeverity.WARNING;
                            }
                        }
                    }
                }
            }
        }
        return AnomalySeverity.NORMAL;
    }

    // Custom string representation
    public override String toString() {
        return String.format(
            'ThresholdConfig[{0}.{1}] Warning: {2}, Critical: {3}, Type: {4}',
            new List<Object>{
                eventType,
                metric,
                warningThreshold,
                criticalThreshold,
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
        private Object warningThreshold;
        private Object criticalThreshold;
        private EvaluationType evaluationType;

        public Builder setEventType(String eventType) {
            this.eventType = eventType;
            return this;
        }

        public Builder setMetric(String metric) {
            this.metric = metric;
            return this;
        }

        public Builder setWarningThreshold(Object warning) {
            this.warningThreshold = warning;
            return this;
        }

        public Builder setCriticalThreshold(Object critical) {
            this.criticalThreshold = critical;
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
                warningThreshold,
                criticalThreshold,
                evaluationType
            );
            config.validateConfig();
            return config;
        }
    }
}