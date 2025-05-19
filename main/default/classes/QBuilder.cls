/**
* QBuilder is used to build SOQL statements
*/
public with sharing class QBuilder {

	public static final Pattern PATTERN_CONDITIONS_ORDER = Pattern.compile('([0-9]+)');

	private String fromText;
	private Integer numberOfRows;
	private Integer numberOfRowsToSkip;
	private String conditionOrder;

	private Set<String> fieldList = new Set<String>();
	private List<QOrder> orders = new List<QOrder>();
	private List<QCondition> conditions = new List<QCondition>();
	private List<QBuilder> subQueries = new List<QBuilder>();

	private String defaultLogicalOperator = 'AND';

	public QBuilder(SObjectType fromType)	{ this.fromText = String.valueOf(fromType); }
	public QBuilder(String fromText) 		{ this.fromText = fromText; }

	/**
	 * Instantiate an OrderBy object
	 */
	public static QOrder orderBy(String fieldName) {
		QOrder od = new QOrder(fieldName);
		return od;
	}

	/**
	 * Instantiate a Condition object
	 */
	public static QCondition condition(String fieldName) {
		QCondition cond = new QCondition(fieldName);
		return cond;
	}

	/**
	 * Add an OrderBy statement
	 */
	public QBuilder add(QOrder ob) {
		this.orders.add(ob);
		return this;
	}

	/**
	 * Add a Condition statement
	 */
	public QBuilder add(QCondition cnd) {
		if(cnd != null) {
			this.conditions.add(cnd);
		}
		return this;
	}

	/**
	 * Add an SELECT sub-query
	 */
	public QBuilder addSubquery(QBuilder qb) {
		this.subQueries.add(qb);
		return this;
	}

	/**
	 * Add fields to the SELECT statement from FieldSet
	 */
	public QBuilder selectFields(Schema.FieldSet fs) {
		for(Schema.FieldSetMember field : fs.getFields()) {
			this.fieldList.add(field.getFieldPath());
		}
		return this;
	}

	/**
	 * Add fields to the SELECT statement from Set of Strings
	 */
	public QBuilder selectFields(Set<String> fields) {
		for(String field : fields) {
			this.fieldList.add(field);
		}
		return this;
	}

	/**
	 * Add a LIMIT statement
	 */
	public QBuilder addLimit(Integer i) {
		this.numberOfRows = i;
		return this;
	}

	/**
	 * Add an OFFSET statement
	 */
	public QBuilder addOffset(Integer i) {
		this.numberOfRowsToSkip = i;
		return this;
	}

	/**
	 * Build the SELECT statement
	 */
	public String buildSelect() {
		for (QBuilder qb : this.subQueries) {
			this.fieldList.add('(' + qb.build() + ')');
		}

		if (!this.fieldList.isEmpty()) {
			return 'SELECT ' + String.join(new List<String>(this.fieldList), ', ');
		} else {
			return 'SELECT Id';
		}
	}

	public void setConditionOrder(String conditionOrder) {
		String result = conditionOrder;
		Pattern p = PATTERN_CONDITIONS_ORDER;
		Matcher m = p.matcher(conditionOrder);

		if(m.find()) {
			do {
				result = result.replaceFirst(m.group(), '{' + m.group() + '}');
			}
			while(m.find());
		}
		this.conditionOrder = result;
	}

	public QBuilder setDefaultLogicalOperator(String logicalOperator) {
		if (logicalOperator == 'AND' || logicalOperator == 'OR') {
			defaultLogicalOperator = logicalOperator;
		}
		return this;
	}

	/**
	 * Build the WHERE statement
	 */
	public String buildConditions() {
		List<String> condList = new List<String>{''};
		for (QCondition cond : this.conditions) {
			condList.add(cond.build());
		}

		if(String.isBlank(this.conditionOrder)) {
			List<String> indexFilter = new List<String>();
			for(Integer i = 1; i <= this.conditions.size(); i++) {
				indexFilter.add('{' + i + '}');
			}
			this.conditionOrder = String.join(indexFilter, ' ' + defaultLogicalOperator + ' ');
		}

		if (!this.conditions.isEmpty()) {
			String wherePart = this.conditionOrder;
			for(Integer i = 0; i < this.conditions.size(); i++) {
				if(wherePart.contains(String.valueOf(i + 1))) {
					wherePart.replace(String.valueOf(i + 1), condList.get(i));
				}
			}
			return 'WHERE ' + String.format(this.conditionOrder, condList);
		} else {
			return null;
		}
	}

	/**
	 * Build the ORDER BY statement
	 */
	public String buildOrderBy() {
		List<String> orderList = new List<String>();

		for (QOrder order : this.orders) {
			orderList.add(order.build());
		}

		if (!this.orders.isEmpty()) {
			return 'ORDER BY ' + String.join(orderList, ', ');
		} else {
			return '';
		}

	}

	/**
	 * Build the SOQL query
	 */
	public String build() {
		List<String> queryParts = new List<String>();

		queryParts.add(this.buildSelect());
		queryParts.add('FROM ' + this.fromText);

		if (!this.conditions.isEmpty()) {
			queryParts.add(this.buildConditions());
		}

		if (!this.orders.isEmpty()) {
			queryParts.add(this.buildOrderBy());
		}

		if (this.numberOfRows != null) {
			queryParts.add('LIMIT ' + this.numberOfRows);
		}

		if (this.numberOfRowsToSkip != null) {
			queryParts.add('OFFSET ' + this.numberOfRowsToSkip);
		}

		return String.join(queryParts, ' ');
	}

	public String buildToolingQuery() {
		return build().replaceAll(' ', '+');
	}

}