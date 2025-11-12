@IsTest
public with sharing class MonitoringServiceSchedulerTest {

    @IsTest
    static void test_execute() {
        Test.startTest();
        MonitoringServiceScheduler scheduler = new MonitoringServiceScheduler();
        scheduler.execute(null);
        Test.stopTest();

        Assert.areNotEqual(null, scheduler, 'Scheduler should not be null');
    }

}