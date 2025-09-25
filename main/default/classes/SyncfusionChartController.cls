public with sharing class SyncfusionChartController {

	public String recordId { get; private set; }
	public String chart { get; private set; }
	public String modal { get; private set; }
	public List<Object> chartData { get; private set; }

	public SyncfusionChartController() {
		this.recordId = ApexPages.currentPage().getParameters().get('id');
		this.chart = ApexPages.currentPage().getParameters().get('chart');
		this.modal = ApexPages.currentPage().getParameters().get('modal');
		if (String.isNotBlank(this.recordId)) {
			this.chartData = LogLimitsChartController.getLimitsChartData(this.recordId);
		}
	}

	public String getChartDataJSON() {
		return JSON.serialize(this.chartData);
	}

}