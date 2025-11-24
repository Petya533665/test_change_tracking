/**
* QBuilderTest is used to test QBuilder logic
*/
@IsTest
private class QBuilderTest {

    @IsTest
    static void testConstructor() {
        String query =
            new QBuilder(Account.SObjectType)
                .build();

        System.assertEquals('SELECT Id FROM Account', query);
        Database.query(query);
    }

    @IsTest
    static void testAddSubQuery() {
        String query =
            new QBuilder(Account.SObjectType)
                .addSubquery(new QBuilder('Contacts'))
                .build();

        System.assertEquals('SELECT (SELECT Id FROM Contacts) FROM Account', query);
        Database.query(query);
    }

    @IsTest
    static void testSelectFieldsUsingSetString() {
        String query =
            new QBuilder(Account.SObjectType)
                .selectFields(new Set<String>{'CreatedById', 'Description', 'Owner.Email'})
                .build();

        System.assertEquals('SELECT CreatedById, Description, Owner.Email FROM Account', query);
        Database.query(query);
    }

    @IsTest
    static void testAddOrders() {
        String query =
            new QBuilder(Account.SObjectType)
                .add(QBuilder.orderBy('Name').nullsLast())
                .add(QBuilder.orderBy('BillingCountry').descending())
                .build();

        System.assertEquals('SELECT Id FROM Account ORDER BY Name ASC NULLS LAST, BillingCountry DESC', query);
        Database.query(query);
    }

    @IsTest
    static void testAddCondition1() {
        String query =
            new QBuilder(Account.SObjectType)
                .add(QBuilder.condition('BillingCountry').isNotNull())
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE BillingCountry != null', query);
        Database.query(query);
    }

    @IsTest
    static void testAddCondition2() {
        String query =
            new QBuilder(Account.SObjectType)
                .add(QBuilder.condition('Name').isLike('%Acme%'))
                .build();

        System.assertEquals('SELECT Id FROM Account WHERE Name LIKE \'%Acme%\'', query);
        Database.query(query);
    }

    @IsTest
    static void testAddLimit() {
        String query =
            new QBuilder(Account.SObjectType)
                .addLimit(5)
                .build();

        System.assertEquals('SELECT Id FROM Account LIMIT 5', query);
        Database.query(query);
    }

    @IsTest
    static void testAddOffset() {
        String query =
            new QBuilder(Account.SObjectType)
                .addOffset(5)
                .build();

        System.assertEquals('SELECT Id FROM Account OFFSET 5', query);
        Database.query(query);
    }

    @IsTest
    static void testEqualsString() {
        String segment = new QCondition('Name').equalsTo('Jean').build();
        System.assertEquals('Name = \'Jean\'', segment);
    }

    @IsTest
    static void testEqualsInteger() {
        String segment = new QCondition('Age').equalsTo(5).build();
        System.assertEquals('Age = 5', segment);
    }

    @isTest
    static void testNotEquals() {
        String segment = new QCondition('Name').notEqualsTo('Jean').build();
        System.assertEquals('Name != \'Jean\'', segment);
    }

    @IsTest
    static void testIsLessThan() {
        String segment = new QCondition('Age').isLessThan(5).build();
        System.assertEquals('Age < 5', segment);
    }

    @IsTest
    static void testIsLessOrEquals() {
        String segment = new QCondition('Age').isLessOrEquals(5).build();
        System.assertEquals('Age <= 5', segment);
    }

    @IsTest
    static void testIsGreaterThan() {
        String segment = new QCondition('Age').isGreaterThan(5).build();
        System.assertEquals('Age > 5', segment);
    }

    @IsTest
    static void testIsGreaterOrEquals() {
        String segment = new QCondition('Age').isGreaterOrEquals(5).build();
        System.assertEquals('Age >= 5', segment);
    }

    @IsTest
    static void testIsLike() {
        String segment = new QCondition('Name').isLike('%Acme%').build();
        System.assertEquals('Name LIKE \'%Acme%\'', segment);
    }

    @IsTest
    static void testIsIn() {
        List<String> names = new List<String>{'John', 'Jane'};
        String segment = new QCondition('Name').isIn(names).build();
        System.assertEquals('Name IN (\'John\', \'Jane\')', segment);
    }

    @IsTest
    static void testIsNotIn() {
        List<String> names = new List<String>{'John', 'Jane'};
        String segment = new QCondition('Name').isNotIn(names).build();
        System.assertEquals('Name NOT IN (\'John\', \'Jane\')', segment);
    }

    @IsTest
    static void testIncludes() {
        List<String> markets = new List<String>{'APAC', 'EMEA'};
        String segment = new QCondition('Market').includes(markets).build();
        System.assertEquals('Market INCLUDES (\'APAC\', \'EMEA\')', segment);
    }

    @IsTest
    static void testExcludes() {
        List<String> markets = new List<String>{'APAC', 'EMEA'};
        String segment = new QCondition('Market').excludes(markets).build();
        System.assertEquals('Market EXCLUDES (\'APAC\', \'EMEA\')', segment);
    }

    @IsTest
    static void testIsNull() {
        String segment = new QCondition('Name').isNull().build();
        System.assertEquals('Name = null', segment);
    }

    @IsTest
    static void testIsNotNull() {
        String segment = new QCondition('Name').isNotNull().build();
        System.assertEquals('Name != null', segment);
    }
    @IsTest
    static void testQOrderConstructor() {
        String segment = new QOrder('Name').build();
        System.assertEquals('Name ASC', segment);
    }

    @IsTest
    static void testQOrderAscending() {
        String segment = new QOrder('Name').ascending().build();
        System.assertEquals('Name ASC', segment);
    }

    @IsTest
    static void testQOrderDescending() {
        String segment = new QOrder('Name').descending().build();
        System.assertEquals('Name DESC', segment);
    }

    @isTest
    static void testQOrderNullsFirst() {
        String segment = new QOrder('Name').nullsFirst().build();
        System.assertEquals('Name ASC NULLS FIRST', segment);
    }

    @IsTest
    static void testQOrderNullsLast() {
        String segment = new QOrder('Name').nullsLast().build();
        System.assertEquals('Name ASC NULLS LAST', segment);
    }

    @IsTest
    static void test_simpleGroupBy() {
        // Test simple GROUP BY
        String query = new QBuilder(Account.SObjectType)
            .selectFields(new Set<String>{'COUNT(Id) cnt', 'Type'})
            .add(QBuilder.groupBy('Type'))
            .build();
        
        Assert.areEqual('SELECT COUNT(Id) cnt, Type FROM Account GROUP BY Type', query);
    }

    @IsTest
    static void test_multipleGroupBy() {
        // Test multiple GROUP BY fields
        String query = new QBuilder(Opportunity.SObjectType)
            .selectFields(new Set<String>{'COUNT(Id) cnt', 'StageName', 'Type'})
            .add(QBuilder.groupBy('StageName'))
            .add(QBuilder.groupBy('Type'))
            .build();
        
        Assert.areEqual('SELECT COUNT(Id) cnt, StageName, Type FROM Opportunity GROUP BY StageName, Type', query);
    }

    @IsTest
    static void test_groupByWithDateFunction() {
        // Test GROUP BY with date function
        String query = new QBuilder(Account.SObjectType)
            .selectFields(new Set<String>{'COUNT(Id) cnt', 'CALENDAR_MONTH(CreatedDate) month'})
            .add(QBuilder.groupBy('CreatedDate').withDateFunction(QGroup.DateFunction.CALENDAR_MONTH))
            .build();
        
        Assert.areEqual('SELECT COUNT(Id) cnt, CALENDAR_MONTH(CreatedDate) month FROM Account GROUP BY CALENDAR_MONTH(CreatedDate)', query);
    }

    @IsTest
    static void test_groupByWithRollup() {
        // Test GROUP BY with ROLLUP
        String query = new QBuilder(Account.SObjectType)
            .selectFields(new Set<String>{'COUNT(Id) cnt', 'Type'})
            .add(QBuilder.groupBy('Type').rollup())
            .build();
        
        Assert.areEqual('SELECT COUNT(Id) cnt, Type FROM Account GROUP BY ROLLUP(Type)', query);
    }

    @IsTest
    static void test_groupByWithCube() {
        // Test GROUP BY with CUBE
        String query = new QBuilder(Account.SObjectType)
            .selectFields(new Set<String>{'COUNT(Id) cnt', 'Type', 'Industry'})
            .add(QBuilder.groupBy('Type').cube())
            .add(QBuilder.groupBy('Industry').cube())
            .build();
        
        Assert.areEqual('SELECT COUNT(Id) cnt, Type, Industry FROM Account GROUP BY CUBE(Type), CUBE(Industry)', query);
    }

    @IsTest
    static void test_groupByWithConditionAndOrderBy() {
        // Test GROUP BY with WHERE and ORDER BY
        String query = new QBuilder(Account.SObjectType)
            .selectFields(new Set<String>{'COUNT(Id) cnt', 'Type'})
            .add(QBuilder.condition('Type').isNotNull())
            .add(QBuilder.groupBy('Type'))
            .add(QBuilder.orderBy('Type').ascending())
            .build();
        
        Assert.areEqual('SELECT COUNT(Id) cnt, Type FROM Account WHERE Type != null GROUP BY Type ORDER BY Type ASC', query);
    }

    @IsTest
    static void test_groupByWithLimit() {
        // Test GROUP BY with LIMIT
        String query = new QBuilder(Account.SObjectType)
            .selectFields(new Set<String>{'COUNT(Id) cnt', 'Type'})
            .add(QBuilder.groupBy('Type'))
            .addLimit(10)
            .build();
        
        Assert.areEqual('SELECT COUNT(Id) cnt, Type FROM Account GROUP BY Type LIMIT 10', query);
    }

    @IsTest
    static void test_allDateFunctions() {
        // Test all date functions
        Map<QGroup.DateFunction, String> expectedFunctions = new Map<QGroup.DateFunction, String>{
            QGroup.DateFunction.CALENDAR_MONTH => 'CALENDAR_MONTH',
            QGroup.DateFunction.CALENDAR_QUARTER => 'CALENDAR_QUARTER',
            QGroup.DateFunction.CALENDAR_YEAR => 'CALENDAR_YEAR',
            QGroup.DateFunction.DAY_IN_MONTH => 'DAY_IN_MONTH',
            QGroup.DateFunction.DAY_IN_WEEK => 'DAY_IN_WEEK',
            QGroup.DateFunction.DAY_IN_YEAR => 'DAY_IN_YEAR',
            QGroup.DateFunction.DAY_ONLY => 'DAY_ONLY',
            QGroup.DateFunction.FISCAL_MONTH => 'FISCAL_MONTH',
            QGroup.DateFunction.FISCAL_QUARTER => 'FISCAL_QUARTER',
            QGroup.DateFunction.FISCAL_YEAR => 'FISCAL_YEAR',
            QGroup.DateFunction.HOUR_IN_DAY => 'HOUR_IN_DAY',
            QGroup.DateFunction.WEEK_IN_MONTH => 'WEEK_IN_MONTH',
            QGroup.DateFunction.WEEK_IN_YEAR => 'WEEK_IN_YEAR'
        };

        for (QGroup.DateFunction func : expectedFunctions.keySet()) {
            String query = new QBuilder(Account.SObjectType)
                .selectFields(new Set<String>{'COUNT(Id) cnt'})
                .add(QBuilder.groupBy('CreatedDate').withDateFunction(func))
                .build();
            
            String expectedFunction = expectedFunctions.get(func);
            Assert.areEqual(
                'SELECT COUNT(Id) cnt FROM Account GROUP BY ' + expectedFunction + '(CreatedDate)',
                query
            );
        }
    }

    @IsTest
    static void test_noGroupBy() {
        // Test query without GROUP BY
        String query = new QBuilder(Account.SObjectType)
            .selectFields(new Set<String>{'Id', 'Name'})
            .build();
        
        Assert.areEqual('SELECT Id, Name FROM Account', query);
    }

    @IsTest
    static void test_realWorldExample_salesByMonth() {
        // Real-world example: Sales grouped by month
        String query = new QBuilder(Opportunity.SObjectType)
            .selectFields(new Set<String>{
                'SUM(Amount) totalAmount',
                'CALENDAR_MONTH(CloseDate) month',
                'CALENDAR_YEAR(CloseDate) year'
            })
            .add(QBuilder.condition('StageName').equalsTo('Closed Won'))
            .add(QBuilder.groupBy('CloseDate').withDateFunction(QGroup.DateFunction.CALENDAR_MONTH))
            .add(QBuilder.groupBy('CloseDate').withDateFunction(QGroup.DateFunction.CALENDAR_YEAR))
            .add(QBuilder.orderBy('CloseDate').descending())
            .addLimit(12)
            .build();
        
        Assert.areEqual('SELECT SUM(Amount) totalAmount, CALENDAR_MONTH(CloseDate) month, CALENDAR_YEAR(CloseDate) year FROM Opportunity WHERE StageName = \'Closed Won\' GROUP BY CALENDAR_MONTH(CloseDate), CALENDAR_YEAR(CloseDate) ORDER BY CloseDate DESC LIMIT 12', query);
    }
}