@isTest
public class NotificationServiceIterationTest {

    private class TestBatchContext extends NotificationService.BaseBatchContextManager {}

    @isTest
    static void testIterableAndIteratorCountWithNoRecords() {
        NotificationService service = new NotificationService(NotificationBatch.class.getName(), Logger.getInstance());
        NotificationService.ActionIterationIterable iterable = (NotificationService.ActionIterationIterable) service.getIterableForBatch(null, false);
        NotificationService.ActionIterationIterator it = (NotificationService.ActionIterationIterator) iterable.iterator();
        System.assertEquals(0, it.count(), 'Iterator should have zero when no records');
        System.assertEquals(false, it.hasNext(), 'hasNext should be false');
    }

    @isTest
    static void testBatchContextSetAndClearIteration() {
        NotificationService.BatchContextManager ctx = new TestBatchContext();
        String recordId = '001000000000000AAA';
        NotificationService.ActionIteration i1 = new NotificationService.ActionIteration(recordId, 2, 3, Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION, 'a1');
        NotificationService.ActionIteration i2 = new NotificationService.ActionIteration(recordId, 3, 3, Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION, 'a2');
        ctx.setIterationContext(recordId, i1);
        ctx.setIterationContext(recordId, i2);
        System.assertEquals(i1, ctx.getIterationContext(recordId), 'First set becomes current');
        ctx.clearIterationContext(recordId);
        System.assertEquals(i2, ctx.getIterationContext(recordId), 'Second becomes current after clear');
        ctx.clearIterationContext(recordId);
        System.assertEquals(null, ctx.getIterationContext(recordId), 'Queue should be empty after clearing all');
    }
}