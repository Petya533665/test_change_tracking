@IsTest
private class QueueableJobChainTest {

    @TestSetup
    private static void testSetup() {
        insert new Account(Name = 'test');
    }

    @IsTest
    private static void testChain() {
        Account aBefore = [SELECT Name FROM Account LIMIT 1];
        System.assertEquals('test', aBefore.Name);

        Test.startTest();
        QueueableJobChain chain = new QueueableJobChain();
        chain.chainFirst(new A(chain));
        chain.runNext();
        Test.stopTest();

        Account aAfter = [SELECT Name FROM Account LIMIT 1];
        System.assertEquals('testA', aAfter.Name);
    }

    public with sharing class A extends ChainedQueuable {
        public A(QueueableJobChain chain) {
            super(chain);
        }
        public override void execute(QueueableContext context) {
            Account a = [SELECT Name FROM Account LIMIT 1];
            a.Name = a.Name + 'A';
            update a;
            super.execute(context);
        }
    }
}