@isTest
public class Test_Hashes {

	public static String log1 = ''+
		'Apex script unhandled trigger exception by user/organization: 00540000003tYUb/00D40000000N3x2\n'+
		'\n'+
		'LeadTrigger: execution of BeforeUpdate\n'+
		'\n'+
		'caused by: System.QueryException: expecting a right parentheses, found ‘33128’\n'+
		'\n'+
		'Class.PatchManager.queryPatchManger: line 223, column 1 \n'+
		'Class.PatchManager.getPatchMap: line 178, column 1 \n'+
		'Class.LeadTriggerHandler.bulkBefore: line 14, column 1 \n'+
		'Class.TriggerFactory.execute: line 40, column 1 \n'+
		'Class.TriggerFactory.createHandler: line 23, column 1 \n'+
		'Trigger.LeadTrigger: line 2, column 1';

	public static String stacktrace1 = ''+
		'Class.PatchManager.queryPatchManger: line 223, column 1 \n'+
		'Class.PatchManager.getPatchMap: line 178, column 1 \n'+
		'Class.LeadTriggerHandler.bulkBefore: line 14, column 1 \n'+
		'Class.TriggerFactory.execute: line 40, column 1 \n'+
		'Class.TriggerFactory.createHandler: line 23, column 1 \n'+
		'Trigger.LeadTrigger: line 2, column 1';

	@IsTest
	static void test1 () {
		String hash_1 = LogService.generateHash_1(log1);
		String hash_2 = LogService.generateHash_2(stacktrace1);
		String hash_3 = LogService.generateHash_3(stacktrace1);

		System.assertNotEquals(null, hash_1);
		System.assertNotEquals(null, hash_2);
		System.assertNotEquals(null, hash_3);
	}

	@IsTest
	static void test2 () {
		String hash_1 = LogService.generateHash_1(log1);
		Log__c log = new Log__c(
			Details__c = log1,
			Stacktrace__c = stacktrace1
		);
		insert log;
		System.assertNotEquals(null, hash_1);
	}

}