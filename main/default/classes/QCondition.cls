/**
* QCondition is used to build WHERE for SOQL statements
*/
public with sharing class QCondition {

    public enum ComparisonOperator { EQUALS, NOT_EQUALS, LESS_THAN, LESS_OR_EQUAL, GREATER_THAN, GREATER_OR_EQUAL, IS_LIKE, IS_IN, IS_IN_VARIABLE, NOT_IN, INCLUDES, EXCLUDES , NOP}

    private ComparisonOperator operatorValue;

    private String field {
        private get { return String.escapeSingleQuotes(field); }
        private set;
    }

    private Object fieldValue {
        private get { return formatFieldValue(fieldValue); }
        private set { fieldValue = value; }
    }
    public QCondition(String field) {
        this.field = field;
    }

    private Object formatFieldValue(Object val) {
        if (val instanceof List<Object>) {
            List<String> values = new List<String>();
            for (Object value : (List<Object>) val) {
                if (value instanceof String) {
                    values.add('\'' + String.escapeSingleQuotes((String) value) + '\'');
                } else {
                    values.add((String) value);
                }
            }
            return String.join(values, ', ');
        }
        if (val instanceof Boolean) {
            return val;
        }
        if (val instanceof String) {
            if(String.valueOf(val).startsWith(':')) {
                return String.escapeSingleQuotes((String) val);
            }
            else {
                return '\'' + String.escapeSingleQuotes((String) val) + '\'';
            }
        } else if (val instanceof Date) {
            String dateString = String.valueOf(val);
            return dateString.substring(0, dateString.indexOf(' '));
        } else if (val instanceof DateTime) {
            return ((DateTime)val).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
        } else {
            return val;
        }
    }

    public QCondition equalsTo(Object value) {
        this.operatorValue = ComparisonOperator.EQUALS;
        this.fieldValue = value;
        return this;
    }

    public QCondition notEqualsTo(Object value) {
        this.operatorValue = ComparisonOperator.NOT_EQUALS;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLessThan(Object value) {
        this.operatorValue = ComparisonOperator.LESS_THAN;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLessOrEquals(Object value) {
        this.operatorValue = ComparisonOperator.LESS_OR_EQUAL;
        this.fieldValue = value;
        return this;
    }

    public QCondition isGreaterThan(Object value) {
        this.operatorValue = ComparisonOperator.GREATER_THAN;
        this.fieldValue = value;
        return this;
    }

    public QCondition isGreaterOrEquals(Object value) {
        this.operatorValue = ComparisonOperator.GREATER_OR_EQUAL;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLike(String value) {
        this.operatorValue = ComparisonOperator.IS_LIKE;
        this.fieldValue = value;
        return this;
    }

    public QCondition isIn(String value) {
        this.operatorValue = ComparisonOperator.IS_IN_VARIABLE;
        this.fieldValue = value;
        return this;
    }

    public QCondition isIn(List<Object> values) {
        this.operatorValue = ComparisonOperator.IS_IN;
        this.fieldValue = values;
        return this;
    }

    public QCondition isNotIn(List<Object> values) {
        this.operatorValue = ComparisonOperator.NOT_IN;
        this.fieldValue = values;
        return this;
    }

    public QCondition includes(List<Object> values) {
        this.operatorValue = ComparisonOperator.INCLUDES;
        this.fieldValue = values;
        return this;
    }

    public QCondition excludes(List<Object> values) {
        this.operatorValue = ComparisonOperator.EXCLUDES;
        this.fieldValue = values;
        return this;
    }

    public QCondition isNull() {
        this.operatorValue = ComparisonOperator.EQUALS;
        this.fieldValue = null;
        return this;
    }

    public QCondition isNotNull() {
        this.operatorValue = ComparisonOperator.NOT_EQUALS;
        this.fieldValue = null;
        return this;
    }

    public void setOperatorValue(ComparisonOperator comparisonOperator, Object fieldValue) {
        this.operatorValue = comparisonOperator;
        this.fieldValue = fieldValue;
    }

    public String build() {
        if (operatorValue.equals(ComparisonOperator.EQUALS)) {
            return field + ' = ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.NOT_EQUALS)) {
            return field + ' != ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.LESS_THAN)) {
            return field + ' < ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.LESS_OR_EQUAL)) {
            return field + ' <= ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.GREATER_THAN)) {
            return field + ' > ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.GREATER_OR_EQUAL)) {
            return field + ' >= ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.IS_LIKE)) {
            return field + ' LIKE ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.IS_IN)) {
            return field + ' IN (' + fieldValue + ')';
        } else if (operatorValue.equals(ComparisonOperator.IS_IN_VARIABLE)) {
            return field + ' IN ' + fieldValue;
        } else if (operatorValue.equals(ComparisonOperator.NOT_IN)) {
            return field + ' NOT IN (' + fieldValue + ')';
        } else if (operatorValue.equals(ComparisonOperator.INCLUDES)) {
            return field + ' INCLUDES (' + fieldValue + ')';
        } else if (operatorValue.equals(ComparisonOperator.EXCLUDES)) {
            return field + ' EXCLUDES (' + fieldValue + ')';
        } else {
            return '';
        }
    }

}