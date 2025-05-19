public with sharing class TestDataGeneratorScheduler implements Schedulable, Database.AllowsCallouts {

	public Enum MODE {
		CHECK_COMPLETE_SETUP_CONNECTED_APP_AND_SEND_EMAIL
	}

	public TestDataGeneratorScheduler.MODE mode;
	public String data;

	public TestDataGeneratorScheduler(TestDataGeneratorScheduler.MODE runMode, String data) {
		this.mode = runMode;
		this.data = data;
	}

	public void execute(SchedulableContext sc) {
		switch on this.mode {
			when CHECK_COMPLETE_SETUP_CONNECTED_APP_AND_SEND_EMAIL {
				TestDataGenerator.startCheckSetupConnectedAppFuture(this.data);
			}
		}
	}

}