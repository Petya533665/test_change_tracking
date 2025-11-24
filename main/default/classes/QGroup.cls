/**
* QGroup is used to build GROUP BY for SOQL statements
*/
public with sharing class QGroup {

	public enum GroupingType { SIMPLE, ROLLUP, CUBE }
	public enum DateFunction { 
		CALENDAR_MONTH, CALENDAR_QUARTER, CALENDAR_YEAR, 
		DAY_IN_MONTH, DAY_IN_WEEK, DAY_IN_YEAR, DAY_ONLY,
		FISCAL_MONTH, FISCAL_QUARTER, FISCAL_YEAR,
		HOUR_IN_DAY, WEEK_IN_MONTH, WEEK_IN_YEAR
	}

	private String field;
	private GroupingType groupType;
	private DateFunction dateFunc;

	public QGroup(String field) {
		this.field = field;
		this.groupType = GroupingType.SIMPLE;
	}

	/**
	 * Add ROLLUP grouping
	 */
	public QGroup rollup() {
		this.groupType = GroupingType.ROLLUP;
		return this;
	}

	/**
	 * Add CUBE grouping
	 */
	public QGroup cube() {
		this.groupType = GroupingType.CUBE;
		return this;
	}

	/**
	 * Add date function (e.g., CALENDAR_MONTH(CreatedDate))
	 */
	public QGroup withDateFunction(DateFunction func) {
		this.dateFunc = func;
		return this;
	}

	/**
	 * Build the GROUP BY field
	 */
	public String build() {
		String groupString = '';

		// Apply date function if specified
		if (dateFunc != null) {
			groupString = getDateFunctionString(dateFunc, field);
		} else {
			groupString = field;
		}

		// Apply ROLLUP or CUBE if specified
		if (groupType == GroupingType.ROLLUP) {
			groupString = 'ROLLUP(' + groupString + ')';
		} else if (groupType == GroupingType.CUBE) {
			groupString = 'CUBE(' + groupString + ')';
		}

		return groupString;
	}

	/**
	 * Get the field expression with date function
	 */
	private String getDateFunctionString(DateFunction func, String fieldName) {
		String funcName = '';
		
		switch on func {
			when CALENDAR_MONTH {
				funcName = 'CALENDAR_MONTH';
			}
			when CALENDAR_QUARTER {
				funcName = 'CALENDAR_QUARTER';
			}
			when CALENDAR_YEAR {
				funcName = 'CALENDAR_YEAR';
			}
			when DAY_IN_MONTH {
				funcName = 'DAY_IN_MONTH';
			}
			when DAY_IN_WEEK {
				funcName = 'DAY_IN_WEEK';
			}
			when DAY_IN_YEAR {
				funcName = 'DAY_IN_YEAR';
			}
			when DAY_ONLY {
				funcName = 'DAY_ONLY';
			}
			when FISCAL_MONTH {
				funcName = 'FISCAL_MONTH';
			}
			when FISCAL_QUARTER {
				funcName = 'FISCAL_QUARTER';
			}
			when FISCAL_YEAR {
				funcName = 'FISCAL_YEAR';
			}
			when HOUR_IN_DAY {
				funcName = 'HOUR_IN_DAY';
			}
			when WEEK_IN_MONTH {
				funcName = 'WEEK_IN_MONTH';
			}
			when WEEK_IN_YEAR {
				funcName = 'WEEK_IN_YEAR';
			}
		}

		return funcName + '(' + fieldName + ')';
	}
}