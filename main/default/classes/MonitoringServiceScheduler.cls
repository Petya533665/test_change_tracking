public with sharing class MonitoringServiceScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        LogServiceScheduler.rescheduleCronTriggers();
    }
}