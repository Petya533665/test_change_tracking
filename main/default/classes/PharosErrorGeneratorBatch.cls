public with sharing class PharosErrorGeneratorBatch implements Database.Batchable<SObject> {

    @TestVisible
    private static final String THROW_EXCEPTION_MESSAGE = 'Batch Error';

    private final Boolean shouldThrow;
    public PharosErrorGeneratorBatch(Boolean shouldThrow) {
        this.shouldThrow = shouldThrow;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (this.shouldThrow) {
            throw new IllegalArgumentException(THROW_EXCEPTION_MESSAGE);
        }
        return Database.getQueryLocator([SELECT Id FROM Triton_Error_Data__c]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        // no-op for now
    }

    public void finish(Database.BatchableContext bc) {
        // another no-op
    }
}