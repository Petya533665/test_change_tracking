public with sharing class DatabaseUtils {

	public static Decimal percentAsyncApexJobsFreeOnOrg = 0.85; // 15%

	public List<SObject> sObjects;

	public List<Database.SaveResult> saveResults;
	public List<Database.UpsertResult> upsertResults;
	public List<Database.DeleteResult> deleteResults;

	public static DatabaseUtils getInstance() {
		return new DatabaseUtils();
	}

	public List<SObject> getSuccessSObjects() {
		List<SObject> successSObjects = new List<SObject>();
		if (sObjects != null && !sObjects.isEmpty()) {
			if (saveResults != null) {
				for (Database.SaveResult saveResult : saveResults) {
					if (saveResult.isSuccess()) {
						for (SObject sObjectRecord : sObjects) {
							if (saveResult.getId() == sObjectRecord.Id) {
								successSObjects.add(sObjectRecord);
								break;
							}
						}
					}
				}
			}
			if (upsertResults != null) {
				for (Database.UpsertResult upsertResult : upsertResults) {
					if (upsertResult.isSuccess()) {
						for (SObject sObjectRecord : sObjects) {
							if (upsertResult.getId() == sObjectRecord.Id) {
								successSObjects.add(sObjectRecord);
								break;
							}
						}
					}
				}
			}
			if (deleteResults != null) {
				for (Database.DeleteResult deleteResult : deleteResults) {
					if (deleteResult.isSuccess()) {
						for (SObject sObjectRecord : sObjects) {
							if (deleteResult.getId() == sObjectRecord.Id) {
								successSObjects.add(sObjectRecord);
								break;
							}
						}
					}
				}
			}
		}
		return successSObjects;
	}

	public DatabaseUtils handleError(String area, String apexName) {
		handleError(area, apexName, Logger.getInstance());
		return this;
	}

	public DatabaseUtils handleError(String area, String apexName, Logger logger) {
		if (saveResults != null) logger?.addInternalErrors(saveResults, area, apexName);
		if (upsertResults != null) logger?.addInternalErrors(upsertResults, area, apexName);
		if (deleteResults != null) logger?.addInternalErrors(deleteResults, area, apexName);
		return this;
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			Schema.DescribeSObjectResult dsr = sObjectList.get(0).getSObjectType().getDescribe();
			performInsertDML(sObjectList, dsr, allOrNone);
		}
		return this;
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performInsertDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		return performInsertDML(sObjectList, dsr, allOrNone, false);
	}

	public DatabaseUtils performInsertImmediateDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performInsertDML(sObjectList, dsr, null, true);
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone, Boolean immediate) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isInsertable(dsr)) {
				saveResults = immediate ? Database.insertImmediate(sObjectList) : Database.insert(sObjectList, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performUpsertDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		return performUpsertDML(sObjectList, dsr, null, allOrNone);
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, SObjectField field) {
		return performUpsertDML(sObjectList, dsr, field, false);
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, SObjectField field, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isUpsertable(dsr)) {
				upsertResults = field == null ? Database.upsert(sObjectList, allOrNone) : Database.upsert(sObjectList, field, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils filterUpsertResultsDuplicateValue(String byField) {
		return filterUpsertResults(byField, System.StatusCode.DUPLICATE_VALUE);
	}

	public DatabaseUtils filterUpsertResultsRowLock() {
		return filterUpsertResults(null, System.StatusCode.UNABLE_TO_LOCK_ROW);
	}

	public DatabaseUtils filterUpsertResults(String message, System.StatusCode statusCode) {
		if(this.upsertResults != null && !this.upsertResults.isEmpty()) {
			for(Integer i = 0; i < this.upsertResults.size(); i++) {
				Database.UpsertResult upsertResult = this.upsertResults.get(i);
				if (!upsertResult.isSuccess()) {
					for (Database.Error error : upsertResult.getErrors()) {
						if(error?.getStatusCode() == statusCode 
							&& (String.isBlank(message) 
							|| (String.isNotBlank(message) && error?.getMessage()?.containsIgnoreCase(message)))) {
							
							this.upsertResults.remove(i);
							break;
						}
					}
				}
			}
		}
		return this;
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList) {
		return performUpdateDML(sObjectList, false);
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			Schema.DescribeSObjectResult dsr = sObjectList.get(0).getSObjectType().getDescribe();
			performUpdateDML(sObjectList, dsr, allOrNone);
		}
		return this;
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performUpdateDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isUpdateable(dsr)) {
				saveResults = Database.update(sObjectList, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList) {
		return performDeleteDML(sObjectList, false);
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			Schema.DescribeSObjectResult dsr = sObjectList.get(0).getSObjectType().getDescribe();
			performDeleteDML(sObjectList, dsr, allOrNone);
		}
		return this;
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performDeleteDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isDeletable(dsr)) {
				deleteResults = Database.delete(sObjectList, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils performDeleteDML(List<Id> listIds, Schema.DescribeSObjectResult dsr) {
		if (!listIds.isEmpty()) {
			if (PermissionsUtil.isDeletable(dsr)) {
				deleteResults = Database.delete(listIds, false);
			}
		}
		return this;
	}

	public class DatabaseUtilsException extends Exception {}
	public static final Integer MAX_SIZE_PER_ONE_EVENT = 130000;
	public static final Decimal STRING_TO_JSON_MULTIPLIER = 1.085;
	public static final String ERROR_LOG_EVENTS_NOT_AVAILABLE = 'Platform Event (Log_Event__e) not available: {0} of {1}';
	public static final String ERROR_LOG_EVENTS_OUT_OF_LIMIT = 'Reached max number of Platform Event allocations: {0} of {1}';
	
	public static List<Log_Event__e> splitLogsByEvents(List<Log__c> logs) {
		List<Log_Event__e> result = new List<Log_Event__e>();

		Integer eventsAvailable = Limits.getLimitPublishImmediateDML() - Limits.getPublishImmediateDML();
		if(eventsAvailable == 0) {
			throw new DatabaseUtilsException(String.format(ERROR_LOG_EVENTS_NOT_AVAILABLE, new List<String>{
				String.valueOf(Limits.getPublishImmediateDML()),
				String.valueOf(Limits.getLimitPublishImmediateDML())
			}));
		}
		List<List<Log__c>> logsPerEvent = splitLogs(logs);
		if(result.size() > eventsAvailable) {
			throw new DatabaseUtilsException(String.format(ERROR_LOG_EVENTS_OUT_OF_LIMIT, new List<String>{
				String.valueOf(result.size()),
				String.valueOf(Limits.getLimitPublishImmediateDML())
			}));
		}
		for(List<Log__c> logChunk : logsPerEvent) {
			Log_Event__e logEvent = (Log_Event__e)PermissionsUtil.newSObject(Schema.SObjectType.Log_Event__e);
			PermissionsUtil.putSObjectField(logEvent, Schema.SObjectType.Log_Event__e.fields.Body__c, JSON.serialize(logChunk));
			result.add(logEvent);
		}
		return result;
	}

	public static List<List<Log__c>> splitLogs(List<Log__c> logs) {
		List<List<Log__c>> result = new List<List<Log__c>>{new List<Log__c>()};
		Integer sizePart = 0;
		Integer index = 0;
		
		for(Log__c log : logs) {
			Integer logSize = Integer.valueOf(log.toString().length() * STRING_TO_JSON_MULTIPLIER);
			if(sizePart + logSize <= MAX_SIZE_PER_ONE_EVENT) {
				sizePart += logSize;
			}
			else {
				index++;
				sizePart = logSize;
			}
			if (result.size() == index) {
				result.add(new List<Log__c>());
			}
			result.get(index).add(log);
		}
		return result;
	}

	public static void publishLogEvent(List<Log__c> logs) {
		List<Log_Event__e> logEvents = splitLogsByEvents(logs);
		EventBus.publish(logEvents);
	}

	public interface PharosBatchInterface {
		void startBatch();
		Boolean initialValidation();
		Integer getIterationsCount();
	}

	public virtual class PharosBatchImpl implements PharosBatchInterface {
		public Logger loggerInstance;
		public Integer BATCH_SCOPE = 1;
		public Boolean isForceStart = false;
		public LogServiceScheduler schedulerInstance;
		public String jobId;
		public PharosBatchImpl() {}
		public PharosBatchImpl(Logger logger) {
			this.loggerInstance = logger;
		}
		public virtual void startBatch() {}
		public virtual void forceStartBatch() {
			this.isForceStart = true;
			startBatch();
		}
		public virtual Boolean initialValidation() {
			return true;
		}
		public virtual Integer getIterationsCount() {
			return 0;
		}
		public virtual String getJobId() {
			return this.jobId;
		}
		public virtual void finishBatch() {
			if (schedulerInstance != null) {
				schedulerInstance.serviceSchedulerDispatcher();
			}
		}
		public virtual Boolean isExecutionTime(String jobName) {
			Boolean result = true;
			Integer recurring = getRecurring(jobName, LogServiceScheduler.FREQUENCY_HOURS);
			if (recurring == null) recurring = getRecurring(jobName, LogServiceScheduler.FREQUENCY_HOURS_DEFAULT);
			if (recurring != null) {
				Datetime systemTime = System.now();
				switch on recurring {
					when 0 {
						result = false;
					}
					when 24 {
						result = systemTime.hour() == 1;
					}
					when 168 {
						if (!systemTime.format('EEE').equalsIgnoreCase('SUN') || systemTime.hour() != 0) result = false;
					}
					when else {
						result = systemTime.hour() / recurring * recurring == systemTime.hour();
					}
				}
			}
			return result;
		}
		public virtual void setSchedulerInstance(LogServiceScheduler schedulerInstance) {
			this.schedulerInstance = schedulerInstance;
		}
		private Integer getRecurring(String jobName, Map<String, String> FREQUENCY_HOURS) {
			Integer frequency;
			if (FREQUENCY_HOURS.containsKey(jobName) && String.isNotBlank(FREQUENCY_HOURS.get(jobName))) {
				try {
					frequency = Integer.valueOf(FREQUENCY_HOURS.get(jobName));
				} catch (Exception e) {}
			}
			return frequency;
		}
	}

    public static List<AsyncApexJob> getCurrentJobs(List<String> apexClassNames) {
        System.debug('++++DatabaseUtils.getCurrentJobs called with apexClassNames: ' + apexClassNames);
        try {
            List<AsyncApexJob> results = [
                SELECT Id
                FROM AsyncApexJob
                WHERE Status IN :ConfigUtil.ASYNC_APEX_JOB_PROCESS_STATUS
                AND JobType NOT IN :ConfigUtil.ASYNC_APEX_JOB_PROCESS_TYPES
                AND ApexClass.Name IN :apexClassNames
                LIMIT 1
            ];
            System.debug('++++DatabaseUtils.getCurrentJobs query results: ' + results);
            System.debug('++++DatabaseUtils.getCurrentJobs returning: ' + results);
            return results;
        } catch (Exception e) {
            System.debug('++++DatabaseUtils.getCurrentJobs exception: ' + e.getMessage());
            System.debug('++++DatabaseUtils.getCurrentJobs returning empty list due to exception');
            return new List<AsyncApexJob>();
        }
    }

    public static Integer getSumTotalJobItems() {
        System.debug('++++DatabaseUtils.getSumTotalJobItems called');
        try {
            List<AggregateResult> results = [
                SELECT SUM(TotalJobItems) sumTotalJobItems
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
                AND Status IN :ConfigUtil.ASYNC_APEX_JOB_PROCESS_STATUS
            ];
            System.debug('++++DatabaseUtils.getSumTotalJobItems query results: ' + results);
            
            if (results != null && !results.isEmpty() && results[0].get('sumTotalJobItems') != null) {
                Integer result = Integer.valueOf(results[0].get('sumTotalJobItems'));
                System.debug('++++DatabaseUtils.getSumTotalJobItems returning: ' + result);
                return result;
            } else {
                System.debug('++++DatabaseUtils.getSumTotalJobItems returning 0 (no results or null value)');
                return 0;
            }
        } catch (Exception e) {
            System.debug('++++DatabaseUtils.getSumTotalJobItems exception: ' + e.getMessage());
            System.debug('++++DatabaseUtils.getSumTotalJobItems returning 0 due to exception');
            return 0;
        }
    }

	public static Boolean TEST_MODE = false;
	public static Set<String> startJobs = new Set<String>();

	public static Boolean executeBatchWithLimitCheck(String jobName, Object batchInstance) {
		return executeBatchWithLimitCheck(new List<String>{jobName}, batchInstance);
	}

	public static Boolean executeBatchWithLimitCheck(List<String> jobNames, Object batchInstance) {
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck called with jobNames: ' + jobNames);
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck batchInstance: ' + batchInstance);
		
		if (jobNames == null || jobNames.isEmpty()) {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning false: jobNames is null or empty');
			return false;
		}

		PharosBatchImpl pharosBatch = (PharosBatchImpl)batchInstance;
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck pharosBatch: ' + pharosBatch);
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck pharosBatch.isForceStart: ' + pharosBatch.isForceStart);

		if (TEST_MODE) startJobs.add(jobNames[0]);

		if (!pharosBatch.isForceStart && !pharosBatch.isExecutionTime(jobNames[0])) {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning false: not force start and not execution time');
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck isExecutionTime result: ' + pharosBatch.isExecutionTime(jobNames[0]));
			return false;
		}
		
		if (!pharosBatch.initialValidation()) {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning false: initial validation failed');
			return false;
		}

		// check duplicate jobs
		List<AsyncApexJob> currentJobs = getCurrentJobs(jobNames);
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck current jobs: ' + currentJobs);
		if (currentJobs.size() >= 3) {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning false: duplicate jobs found');
			return false;
		}

		// check AsyncApexExecutions limits
		Integer sumTotalJobItems = getSumTotalJobItems();
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck sumTotalJobItems: ' + sumTotalJobItems);
		Integer availableQuantityAsyncApexExecutionsOnOrg = Integer.valueOf(LimitsService.getAvailableQuantityAsyncApexExecutions() * percentAsyncApexJobsFreeOnOrg);
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck availableQuantityAsyncApexExecutionsOnOrg: ' + availableQuantityAsyncApexExecutionsOnOrg);
		Integer availableQuantityAsyncApexExecutions = availableQuantityAsyncApexExecutionsOnOrg - (sumTotalJobItems != null ? sumTotalJobItems : 0);
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck availableQuantityAsyncApexExecutions: ' + availableQuantityAsyncApexExecutions);

		Integer batchIterations = Integer.valueOf(Math.ceil(pharosBatch.getIterationsCount() / Decimal.valueOf(pharosBatch.BATCH_SCOPE)));
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck batchIterations: ' + batchIterations);
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck pharosBatch.getIterationsCount(): ' + pharosBatch.getIterationsCount());
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck pharosBatch.BATCH_SCOPE: ' + pharosBatch.BATCH_SCOPE);
		
		// "-2" - Decreasing count by 2 to reserve slots for batch start and finish in async apex executions.
		Decimal neededAsyncApexExecutionsRuns = (availableQuantityAsyncApexExecutions - batchIterations - 2);
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck neededAsyncApexExecutionsRuns: ' + neededAsyncApexExecutionsRuns);

		if (batchIterations <= 0 || neededAsyncApexExecutionsRuns <= 0) {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning false: batchIterations <= 0 or neededAsyncApexExecutionsRuns <= 0');
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck batchIterations <= 0: ' + (batchIterations <= 0));
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck neededAsyncApexExecutionsRuns <= 0: ' + (neededAsyncApexExecutionsRuns <= 0));
			return false;
		}

		// check You've exceeded the limit of 100 jobs in the flex queue
		Boolean isFlexQueueSlotAvailable = LimitsService.isFlexQueueSlotAvailable();
		System.debug('++++DatabaseUtils.executeBatchWithLimitCheck isFlexQueueSlotAvailable: ' + isFlexQueueSlotAvailable);
		if (!isFlexQueueSlotAvailable) {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning false: flex queue slot not available');
			return false;
		}

		try {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck calling Database.executeBatch');
			pharosBatch.jobId = Database.executeBatch((Database.Batchable<PharosBatchInterface>)pharosBatch, pharosBatch.BATCH_SCOPE);
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck Database.executeBatch returned jobId: ' + pharosBatch.jobId);
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning true');
			return true;
		}
		catch(Exception e) {
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck Database.executeBatch threw exception: ' + e.getMessage());
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck exception stack trace: ' + e.getStackTraceString());
			String className = String.valueOf(batchInstance).split(':')[0];
			Logger.getInstance().internalError(e, null, true, className, className);
			System.debug('++++DatabaseUtils.executeBatchWithLimitCheck returning false due to exception');
			return false;
		}
	}

}