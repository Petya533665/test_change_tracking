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

}