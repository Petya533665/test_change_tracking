@isTest
public class NotificationBatchTest {

    @isTest
    static void testContextManagerDelegation() {
        NotificationBatch batch = NotificationBatch.getInstance();

        String recordId = '001000000000000AAA';
        NotificationService.ActionIteration iteration = new NotificationService.ActionIteration(recordId, 1, 2, Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION, 'act1');

        // iteration context
        batch.setIterationContext(recordId, iteration);
        System.assertEquals(iteration, batch.getIterationContext(recordId), 'Iteration context should be stored');
        batch.clearIterationContext(recordId);
        System.assertEquals(null, batch.getIterationContext(recordId), 'Iteration context should be cleared');

        // attempts
        System.assertEquals(0, batch.getNotificationAttempts(recordId), 'Default attempts should be 0');
        batch.incrementNotificationAttempts(recordId);
        System.assertEquals(1, batch.getNotificationAttempts(recordId), 'Attempts should increment');
        batch.clearNotificationAttempts(recordId);
        System.assertEquals(0, batch.getNotificationAttempts(recordId), 'Attempts should reset to 0');

        // records with attempts
        batch.addRecordNotificationAttempt(recordId);
        System.assert(batch.getRecordsWithNotificationAttempts().contains(recordId), 'Record should be tracked for attempts');

        // chart data
        String chartJson = '{"k":"v"}';
        batch.storeChartData(recordId, chartJson);
        System.assertEquals(chartJson, batch.getChartData(recordId), 'Chart data should be retrievable');
        batch.clearChartData(recordId);
        System.assertEquals(null, batch.getChartData(recordId), 'Chart data should be cleared');

        // chart images
        Map<String, String> images = new Map<String, String>{'img1' => 'data:image/png;base64,AAA'};
        batch.storeChartImages(recordId, images);
        System.assertNotEquals(null, batch.getChartImages(recordId), 'Chart images should be retrievable');
        System.assertEquals('data:image/png;base64,AAA', batch.getChartImages(recordId).get('img1'));
        batch.clearChartImages(recordId);
        System.assertEquals(null, batch.getChartImages(recordId), 'Chart images should be cleared');
    }

    @isTest
    static void testFinishDoesNotThrow() {
        NotificationBatch batch = NotificationBatch.getInstance();
        batch.finish(null);
        System.assert(true, 'finish should complete without exception');
    }
}