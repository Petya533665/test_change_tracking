/**
 * @description Service class for handling Salesforce report operations and data processing.
 * This class provides functionality to execute reports, parse report data, and generate
 * filtered report results for various chart types and system reports.
 * 
 * @author Pharos Development Team
 * @since 1.0
 */
public with sharing class ReportService {

    /**
     * @description Static property that maps SystemReport enum values to their corresponding Report IDs.
     * This property is lazily initialized when first accessed.
     * 
     * @return Map<SystemReport, Id> - Mapping of system report types to their Salesforce Report IDs
     */
    public static Map<SystemReport, Id> REPORT_NAME_TO_ID {
        get {
            if (REPORT_NAME_TO_ID == null) {
                REPORT_NAME_TO_ID = getReportByIds();
            }
            return REPORT_NAME_TO_ID;
        }
        set;
    }

    /**
     * @description Enum representing different types of system reports available in the application.
     * Each enum value corresponds to a specific report type used for chart generation.
     */
    public enum SystemReport {
        /** System chart for log occurrence by issue */
        SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE,
        /** System chart for log occurrence by hash1 */
        SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1,
        /** System chart for log occurrence by hash2 */
        SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH2,
        /** System chart for log occurrence by hash3 */
        SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH3,
        /** System chart for user impact details (linked) */
        SYSTEM_CHART_USER_IMPACT_DETAILS_LINKED,
        /** System chart for user impact details (duplicate) */
        SYSTEM_CHART_USER_IMPACT_DETAILS_DUP
    }

    /**
     * @description Maps SystemReport enum values to their corresponding report names in Salesforce.
     * This mapping is used to query for report IDs by name.
     */
    private static final Map<SystemReport, String> SystemChartType = new Map<SystemReport, String>{
        SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE => 'System Chart Log Occurrence by Issue',
        SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1 => 'System Chart Log Occurrence by Hash1',
        SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH2 => 'System Chart Log Occurrence by Hash2',
        SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH3 => 'System Chart Log Occurrence by Hash3',
        SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_LINKED => 'System Chart: User Impact (Linked)',
        SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_DUP => 'System Chart: User Impact (Dup)'
    };

    /**
     * @description Extracts relevant parameters from an SObject record based on its type.
     * This method analyzes the record type and extracts specific fields that are needed
     * for report filtering and processing.
     * 
     * @param record The SObject record to extract parameters from
     * @return Map<String, Object> - Map containing extracted parameters with their values
     * @throws IllegalArgumentException if the record parameter is null
     * 
     * @example
     * Log__c logRecord = [SELECT Id, Hash_1__c, Hash_2__c, Hash_3__c, Organization_Id__c 
     *                     FROM Log__c LIMIT 1];
     * Map<String, Object> params = ReportService.parametersBySObjectRecord(logRecord);
     * // Returns: {'hash1' => 'abc123', 'hash2' => 'def456', 'hash3' => 'ghi789', 
     * //           'organizationId' => 'org123', 'currentLogId' => 'log123'}
     */
    public static Map<String, Object> parametersBySObjectRecord(SObject record) {
        if (record == null) {
            throw new IllegalArgumentException('Record cannot be null');
        }

        Map<String, Object> parameters = new Map<String, Object>();
        String objectType = record.getSObjectType().getDescribe().getName();

        // Check specific object types using string comparison with namespace prefix
        String logObjectName = Log__c.SObjectType.getDescribe().getName();
        String issueObjectName = Issue__c.SObjectType.getDescribe().getName();
        String traceResultObjectName = Trace_Result__c.SObjectType.getDescribe().getName();
        String eventActionObjectName = EventAction__c.SObjectType.getDescribe().getName();

        if (objectType == logObjectName) {
            Log__c logRecord = (Log__c) record;
            parameters.put('hash1', logRecord.Hash_1__c);
            parameters.put('hash2', logRecord.Hash_2__c);
            parameters.put('hash3', logRecord.Hash_3__c);
            parameters.put('organizationId', logRecord.Organization_Id__c);
            parameters.put('currentLogId', logRecord.Id);
        } else if (objectType == issueObjectName) {
            Issue__c issueRecord = (Issue__c) record;
            parameters.put('issueName', issueRecord.Name);

        } else if (objectType == traceResultObjectName) {
            // Trace_Result__c processing
        } else if (objectType == eventActionObjectName) {
            // EventAction__c processing
        }
        return parameters;
    }

    /**
     * @description Queries Salesforce for Report records that match the system chart types
     * and returns a mapping of SystemReport enum values to their corresponding Report IDs.
     * This method is used to initialize the REPORT_NAME_TO_ID static property.
     * 
     * @return Map<SystemReport, Id> - Mapping of system report types to their Salesforce Report IDs
     */
    public static Map<SystemReport, Id> getReportByIds() {
        Map<SystemReport, Id> reportIds = new Map<SystemReport, Id>();
        List<Report> reports = [
            SELECT Id, Name
            FROM Report
            WHERE Name IN :SystemChartType.values()
        ];

        for (Report report : reports) {
            for (SystemReport reportType : SystemChartType.keySet()) {
                if (SystemChartType.get(reportType) == report.Name) {
                    reportIds.put(reportType, report.Id);
                    break;
                }
            }
        }
        return reportIds;
    }

    private static final String LOG_CREATED_AT_FIELD = Schema.SObjectType.Log__c.getName() + '.' + Schema.SObjectType.Log__c.fields.Created_At__c.getName();
    private static final String LOG_ORGANIZATION_ID_FIELD = Schema.SObjectType.Log__c.getName() + '.' + Schema.SObjectType.Log__c.fields.Organization_Id__c.getName();
    private static final String LOG_HASH1_FIELD = Schema.SObjectType.Log__c.getName() + '.' + Schema.SObjectType.Log__c.fields.Hash_1__c.getName();
    private static final String LOG_HASH2_FIELD = Schema.SObjectType.Log__c.getName() + '.' + Schema.SObjectType.Log__c.fields.Hash_2__c.getName();
    private static final String LOG_HASH3_FIELD = Schema.SObjectType.Log__c.getName() + '.' + Schema.SObjectType.Log__c.fields.Hash_3__c.getName();
    private static final String LOG_ID_FIELD = 'CUST_ID';
    private static final String LOG_ISSUE_Related_Issue_Name = Schema.SObjectType.Log__c.getName() + '.' + ConfigUtil.nameSpacePrefix + 'Issue__c.' + ConfigUtil.nameSpacePrefix + 'Related_Issue__c.' + 'Name__lookup';
    private static final String LOG_ISSUE_Status = Schema.SObjectType.Log__c.getName() + '.' + ConfigUtil.nameSpacePrefix + 'Issue__c.' + ConfigUtil.nameSpacePrefix + 'Status__c';

    private static final List<String> REQUIRED_HASH_PARAMETERS = new List<String>{
        'organizationId', 'hash1', 'hash2', 'hash3', 'currentLogId'
    };

    /**
     * @description Generates a list of filters based on the provided chart, system report,
     * parameters, and date range. This method is used to prepare filters for report execution.
     * 
     * @param chart The chart type for which filters are generated
     * @param systemReport The specific system report type
     * @param parameters Map of parameters extracted from the record
     * @param startDateTime The start date for the report date range
     * @param endDateTime The end date for the report date range
     * @return List<Map<String, Object>> - List of filters to apply to the report
     */
    public static List<Map<String, Object>> getReportFilter(
        ChartService.Chart chart,
        ReportService.SystemReport systemReport,
        Map<String, Object> parameters,
        DateTime startDateTime,
        DateTime endDateTime
    ) {
        switch on chart {
            when OCCURRENCE_LAST_7_DAYS, OCCURRENCE_LAST_30_DAYS {
                return createOccurrenceFilters(parameters, startDateTime, endDateTime, systemReport);
            }
            when OCCURRENCE_LOGS_LAST_7_DAYS, OCCURRENCE_LOGS_LAST_30_DAYS {
                return createOccurrenceLogsFilters(parameters, startDateTime, endDateTime, systemReport);
            }
            when USER_IMPACT_LAST_7_DAYS_DETAILS, USER_IMPACT_LAST_30_DAYS_DETAILS {
                return createUserImpactFilters(parameters, startDateTime, endDateTime, systemReport);
            }
            when TIMING_LOGS, EVENT_LOG_RECORDS_BY_TYPE, EVENT_LOG_RECORDS_BY_CATEGORY {
                return new List<Map<String, Object>>();
            }
            when else {
                return new List<Map<String, Object>>();
            }
        }
    }

    private static List<Map<String, Object>> createOccurrenceFilters(
        Map<String, Object> parameters,
        DateTime startDateTime,
        DateTime endDateTime,
        ReportService.SystemReport systemReport
    ) {
        String issueName = (String) parameters.get('issueName');

        if (String.isBlank(issueName)) {
            return new List<Map<String, Object>>();
        }

        List<Map<String, Object>> filters = new List<Map<String, Object>>();


        filters.addAll(ReportApiClient.createDateRangeFilters(LOG_CREATED_AT_FIELD, startDateTime, endDateTime));

        if (systemReport == ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE) {
            filters.add(ReportApiClient.createIssueFilter(issueName));
        }

        return filters;
    }

    private static List<Map<String, Object>> createUserImpactFilters(
        Map<String, Object> parameters,
        DateTime startDateTime,
        DateTime endDateTime,
        ReportService.SystemReport systemReport
    ) {
        List<Map<String, Object>> filters = new List<Map<String, Object>>();
        String issueName = (String) parameters.get('issueName');

        filters.addAll(ReportApiClient.createDateRangeFilters(LOG_CREATED_AT_FIELD, startDateTime, endDateTime));

        if (systemReport == ReportService.SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_LINKED) {
            filters.add(ReportApiClient.createIssueFilter(issueName));
        } else if (systemReport == ReportService.SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_DUP) {
            filters.add(ReportApiClient.createFilter(
                LOG_ISSUE_Related_Issue_Name,
                'equals',
                issueName
            ));

            filters.add(ReportApiClient.createFilter(
                LOG_ISSUE_Status,
                'equals',
                IssueService.ISSUE_STATUS_DUPLICATE
            ));

        }

        return filters;
    }

    private static List<Map<String, Object>> createOccurrenceLogsFilters(
        Map<String, Object> parameters,
        DateTime startDateTime,
        DateTime endDateTime,
        ReportService.SystemReport systemReport
    ) {
        if (!validateRequiredParameters(parameters, REQUIRED_HASH_PARAMETERS)) {
            return new List<Map<String, Object>>();
        }

        List<Map<String, Object>> filters = new List<Map<String, Object>>();

        filters.addAll(createBaseLogsFilters(parameters, startDateTime, endDateTime));

        filters.addAll(createHashSpecificFilters(systemReport, parameters));

        return filters;
    }


    private static List<Map<String, Object>> createBaseLogsFilters(
        Map<String, Object> parameters,
        DateTime startDateTime,
        DateTime endDateTime
    ) {
        List<Map<String, Object>> filters = new List<Map<String, Object>>();

        filters.addAll(ReportApiClient.createDateRangeFilters(LOG_CREATED_AT_FIELD, startDateTime, endDateTime));

        filters.add(ReportApiClient.createFilter(
            LOG_ORGANIZATION_ID_FIELD,
            'equals',
            parameters.get('organizationId')
        ));

        return filters;
    }


    private static List<Map<String, Object>> createHashSpecificFilters(
        ReportService.SystemReport systemReport,
        Map<String, Object> parameters
    ) {
        List<Map<String, Object>> filters = new List<Map<String, Object>>();

        switch on systemReport {
            when SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1 {
                filters.addAll(createHash1Filters(parameters));
            }
            when SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH2 {
                filters.addAll(createHash2Filters(parameters));
            }
            when SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH3 {
                filters.addAll(createHash3Filters(parameters));
            }
        }

        return filters;
    }


    private static List<Map<String, Object>> createHash1Filters(Map<String, Object> parameters) {
        List<Map<String, Object>> filters = new List<Map<String, Object>>();

        filters.add(ReportApiClient.createFilter(LOG_HASH1_FIELD, 'equals', parameters.get('hash1')));
        filters.add(ReportApiClient.createFilter(LOG_HASH1_FIELD, 'notEqual', ''));

        return filters;
    }


    private static List<Map<String, Object>> createHash2Filters(Map<String, Object> parameters) {
        List<Map<String, Object>> filters = new List<Map<String, Object>>();

        filters.add(ReportApiClient.createFilter(LOG_HASH2_FIELD, 'equals', parameters.get('hash2')));
        filters.add(ReportApiClient.createFilter(LOG_HASH2_FIELD, 'notEqual', ''));

        filters.add(ReportApiClient.createFilter(LOG_HASH1_FIELD, 'notEqual', parameters.get('hash1')));

        filters.add(ReportApiClient.createFilter(LOG_ID_FIELD, 'notEqual', parameters.get('currentLogId')));

        return filters;
    }

    private static List<Map<String, Object>> createHash3Filters(Map<String, Object> parameters) {
        List<Map<String, Object>> filters = new List<Map<String, Object>>();

        filters.add(ReportApiClient.createFilter(LOG_HASH3_FIELD, 'equals', parameters.get('hash3')));
        filters.add(ReportApiClient.createFilter(LOG_HASH3_FIELD, 'notEqual', ''));

        filters.add(ReportApiClient.createFilter(LOG_HASH1_FIELD, 'notEqual', parameters.get('hash1')));
        filters.add(ReportApiClient.createFilter(LOG_HASH2_FIELD, 'notEqual', parameters.get('hash2')));

        filters.add(ReportApiClient.createFilter(LOG_ID_FIELD, 'notEqual', parameters.get('currentLogId')));

        return filters;
    }


    private static Boolean validateRequiredParameters(Map<String, Object> parameters, List<String> requiredFields) {
        for (String field : requiredFields) {
            if (String.isBlank((String) parameters.get(field))) {
                return false;
            }
        }
        return true;
    }

    /**
     * @description Retrieves report data for a list of chart types and a given set of parameters.
     * This method iterates through the provided chart types, retrieves their corresponding
     * system reports, and then calls getReportDataBySystemReports to fetch the data.
     * 
     * @param chartsTypeForPrepare List of chart names (e.g., 'OCCURRENCE_LAST_7_DAYS', 'USER_IMPACT_LAST_7_DAYS_DETAILS')
     * @param parameters Map of parameters to pass to the report data fetching methods
     * @return Map<ChartService.Chart, Map<ReportService.SystemReport, String>> - Mapping of charts to their data
     */
    public static Map<ChartService.Chart, Map<ReportService.SystemReport, String>> getReportDataByChart(List<String> chartsTypeForPrepare, Map<String, Object> parameters) {
        Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartToChartData = new Map<ChartService.Chart, Map<ReportService.SystemReport, String>>();

        for (String chartString : chartsTypeForPrepare) {
            ChartService.Chart chart = ChartService.getChartEnumByChartName(chartString);

            Map<String, ReportService.SystemReport> chartToSystemReport = ChartService.CHART_TO_SYSTEM_REPORTS.get(chart);

            Map<ReportService.SystemReport, String> systemReportTotData = ReportService.getReportDataBySystemReports(chart, chartToSystemReport, parameters);

            if (!systemReportTotData?.isEmpty()) {
                chartToChartData.put(chart, systemReportTotData);
            }

        }

        return chartToChartData;
    }

    /**
     * @description Retrieves report data for a specific chart and a list of system reports.
     * This method iterates through the provided system reports, retrieves their corresponding
     * report IDs, and then calls executeReport to fetch the data for each report.
     * 
     * @param chart The chart type for which data is fetched
     * @param chartToSystemReport Map of chart names to their corresponding system report types
     * @param parameters Map of parameters to pass to the report execution methods
     * @return Map<ReportService.SystemReport, String> - Mapping of system reports to their fetched data
     */
    public static Map<ReportService.SystemReport, String> getReportDataBySystemReports(
        ChartService.Chart chart,
        Map<String, ReportService.SystemReport> chartToSystemReport,
        Map<String, Object> parameters) {

        Map<ReportService.SystemReport, String> systemReportTotData = new Map<ReportService.SystemReport, String>();

        if (!chartToSystemReport.isEmpty()) {
            for (String key : chartToSystemReport.keySet()) {
                ReportService.SystemReport systemReport = chartToSystemReport.get(key);

                String reportId = (ReportService.REPORT_NAME_TO_ID).get(systemReport);

                // Skip if report ID is not found
                if (String.isBlank(reportId)) {
                    continue;
                }
                List<Map<String, Object>> reportFilter;

                DateTime currentDate = DateTime.now();
                DateTime startDateTime;
                DateTime endDateTime = DateTime.newInstanceGmt(currentDate.date(), Time.newInstance(23, 59, 59, 0)); // Today 23:59:59

                if (chart == ChartService.Chart.OCCURRENCE_LAST_7_DAYS ||
                    chart == ChartService.Chart.OCCURRENCE_LOGS_LAST_7_DAYS ||
                    chart == ChartService.Chart.USER_IMPACT_LAST_7_DAYS_DETAILS) {
                    startDateTime = DateTime.newInstanceGmt(currentDate.addDays(-6).date(), Time.newInstance(0, 0, 0, 0));
                } else if (chart == ChartService.Chart.OCCURRENCE_LAST_30_DAYS ||
                    chart == ChartService.Chart.OCCURRENCE_LOGS_LAST_30_DAYS ||
                    chart == ChartService.Chart.USER_IMPACT_LAST_30_DAYS_DETAILS) {
                    startDateTime = DateTime.newInstanceGmt(currentDate.addDays(-29).date(), Time.newInstance(0, 0, 0, 0));
                } else {
                    startDateTime = DateTime.newInstanceGmt(currentDate.date(), Time.newInstance(0, 0, 0, 0));
                }

                if (systemReport != null) {
                    reportFilter = ReportService.getReportFilter(
                        chart,
                        systemReport,
                        parameters,
                        startDateTime,
                        endDateTime
                    );
                }

                if (reportFilter != null && !reportFilter.isEmpty()) {
                    try {
                        String response = ReportService.executeReport(reportId, reportFilter);
                        if (String.isNotBlank(response)) {
                            if (chart == ChartService.Chart.USER_IMPACT_LAST_7_DAYS_DETAILS || chart == ChartService.Chart.USER_IMPACT_LAST_30_DAYS_DETAILS) {
                                List<Map<String, Object>> reportParser = new ReportService.ReportParser(startDateTime, endDateTime)
                                    .setTitleY((String) parameters.get('issueName'))
                                    .parseMatrixReport(response);
                                systemReportTotData.put(systemReport, JSON.serialize(reportParser));
                            } else {
                                List<Map<String, Object>> reportParser = new ReportService.ReportParser(startDateTime, endDateTime)
                                    .setTitleY((String) parameters.get('issueName'))
                                    .parseReport(response);
                                systemReportTotData.put(systemReport, JSON.serialize(reportParser));
                            }
                        }
                    } catch (Exception e) {
                        Logger.getInstance().internalError(e, ReportService.class.getName(), 'getReportDataBySystemReports');
                        // Error executing report for system report
                    }
                }
            }
        }

        return systemReportTotData;
    }


    /**
     * @description Executes a Salesforce report with the specified report ID and filters.
     * This method uses the ReportApiClient to send a request to the Salesforce Report API.
     * 
     * @param reportId The ID of the Salesforce Report to execute
     * @param filters List of filters to apply to the report
     * @return String - The response body from the Salesforce Report API
     * @throws IllegalArgumentException if the reportId parameter is null
     */
    public static String executeReport(Id reportId, List<Map<String, Object>> filters) {
        if (reportId == null) {
            throw new IllegalArgumentException('Report ID cannot be null');
        }

        ReportApiClient client = new ReportApiClient()
            .setReportId(reportId)
            .buildCurrentOrgUrl()
            .buildReportPayload(filters)
            .executeReport();

        if (!client.isSuccess()) {
            return null;
        }

        String responseBody = client.getResponseBody();
        return responseBody;
    }


    /**
     * @description Inner class representing an aggregate value in a Salesforce report.
     * Contains the label and numeric value for the aggregate.
     */
    public class Aggregate {
        /** The label for this aggregate */
        public String label;
        /** The numeric value of this aggregate */
        public Integer value;
    }

    /**
     * @description Inner class representing a fact map entry in a Salesforce report.
     * Contains a list of aggregates for a specific grouping.
     */
    public class FactMapEntry {
        /** List of aggregates for this fact map entry */
        public List<Aggregate> aggregates;
    }

    /**
     * @description Inner class representing a grouping in a Salesforce report.
     * Contains the label for the grouping.
     */
    public class Grouping {
        /** The label for this grouping */
        public String label;
    }

    /**
     * @description Inner class representing the groupings down (rows) in a Salesforce report.
     * Contains a list of groupings for the rows.
     */
    public class GroupingsDown {
        /** List of groupings for the rows */
        public List<Grouping> groupings;
    }

    /**
     * @description Inner class representing the groupings across (columns) in a Salesforce report.
     * Contains a list of groupings for the columns.
     */
    public class GroupingsAcross {
        /** List of groupings for the columns */
        public List<Grouping> groupings;
    }

    /**
     * @description Inner class representing the root structure of a Salesforce report response.
     * Contains the fact map and grouping information for both rows and columns.
     */
    public class Root {
        /** Map of fact keys to fact map entries */
        public Map<String, FactMapEntry> factMap;
        /** Groupings for the rows (down) */
        public GroupingsDown groupingsDown;
        /** Groupings for the columns (across) */
        public GroupingsAcross groupingsAcross;
    }

    /**
     * @description Inner class for parsing Salesforce report JSON responses and converting them
     * into a standardized format for chart display. This class handles both regular reports
     * and matrix reports with different parsing logic for each.
     */
    public class ReportParser {
        /** The start date for the report date range */
        public DateTime startDateTime;
        /** The end date for the report date range */
        public DateTime endDateTime;
        /** The title for the Y-axis of the chart */
        public String titleY;

        /**
         * @description Constructor for ReportParser.
         * 
         * @param startDateTime The start date for the report date range
         * @param endDateTime The end date for the report date range
         */
        public ReportParser(DateTime startDateTime, DateTime endDateTime) {
            this.startDateTime = startDateTime;
            this.endDateTime = endDateTime;
        }

        /**
         * @description Sets the title for the Y-axis of the chart.
         * 
         * @param titleY The title to set for the Y-axis
         * @return ReportParser - Returns this instance for method chaining
         */
        public ReportParser setTitleY(String titleY) {
            this.titleY = titleY;
            return this;
        }

        /**
         * @description Parses a regular Salesforce report JSON response and converts it into
         * a standardized format for chart display. This method generates a complete date range
         * from startDateTime to endDateTime and fills in data where available from the report.
         * 
         * @param jsonString The JSON string response from the Salesforce Report API
         * @return List<Map<String, Object>> - List of data points with date, logCount, and titleY
         * 
         * @example
         * String reportJson = '{"factMap":{"0!T":{"aggregates":[{"label":"Total","value":5}]}},"groupingsDown":{"groupings":[{"label":"2024-01-15"}]}}';
         * List<Map<String, Object>> result = parser.parseReport(reportJson);
         * // Returns: [{'date' => '2024-01-15', 'logCount' => 5, 'titleY' => 'Issue Name'}]
         */
        public List<Map<String, Object>> parseReport(String jsonString) {

            Root report = (Root) JSON.deserialize(jsonString, Root.class);

            List<Map<String, Object>> result = new List<Map<String, Object>>();

            // Generate dates from startDateTime to endDateTime (ascending order)
            DateTime current = this.startDateTime;
            while (current <= this.endDateTime) {
                String dateLabel = current.format('yyyy-MM-dd');

                // Find matching data from report if available
                Integer rowCount = 0;
                if (report.groupingsDown != null && report.groupingsDown.groupings != null) {
                    List<Grouping> groupings = report.groupingsDown.groupings;
                    for (Integer i = 0; i < groupings.size(); i++) {
                        // Convert the report date label to yyyy-MM-dd format for comparison
                        String reportDateLabel = groupings[i].label;
                        // Handle different date formats from report
                        if (reportDateLabel.contains('.')) {
                            // Convert from DD.MM.YYYY to YYYY-MM-DD
                            List<String> parts = reportDateLabel.split('\\.');
                            if (parts.size() == 3) {
                                reportDateLabel = parts[2] + '-' + parts[1].leftPad(2, '0') + '-' + parts[0].leftPad(2, '0');
                            }
                        } else if (reportDateLabel.contains('/')) {
                            // Convert from M/D/YYYY to YYYY-MM-DD
                            List<String> parts = reportDateLabel.split('/');
                            if (parts.size() == 3) {
                                reportDateLabel = parts[2] + '-' + parts[0].leftPad(2, '0') + '-' + parts[1].leftPad(2, '0');
                            }
                        }

                        if (reportDateLabel == dateLabel) {
                            String factKey = i + '!T';
                            if (report.factMap != null && report.factMap.containsKey(factKey)) {
                                FactMapEntry factEntry = report.factMap.get(factKey);
                                if (factEntry.aggregates != null && factEntry.aggregates.size() > 0) {
                                    rowCount = factEntry.aggregates[0].value;
                                }
                            }
                            break;
                        }
                    }
                }

                result.add(new Map<String, Object>{
                    'date' => dateLabel,
                    'logCount' => rowCount,
                    'titleY' => this.titleY
                });

                current = current.addDays(1);
            }

            return result;
        }

        /**
         * @description Parses a matrix Salesforce report JSON response and converts it into
         * a standardized format for chart display. This method handles reports with both
         * row and column groupings, typically used for user impact analysis.
         * 
         * @param jsonString The JSON string response from the Salesforce Report API
         * @return List<Map<String, Object>> - List of data points with date, userName, logCount, and titleY
         * 
         * @example
         * String matrixJson = '{"factMap":{"0!0":{"aggregates":[{"label":"Total","value":3}]}},"groupingsDown":{"groupings":[{"label":"User1"}]},"groupingsAcross":{"groupings":[{"label":"2024-01-15"}]}}';
         * List<Map<String, Object>> result = parser.parseMatrixReport(matrixJson);
         * // Returns: [{'date' => '2024-01-15', 'userName' => 'User1', 'logCount' => 3, 'titleY' => 'Issue Name'}]
         */
        public List<Map<String, Object>> parseMatrixReport(String jsonString) {
            Root report = (Root) JSON.deserialize(jsonString, Root.class);
            List<Map<String, Object>> result = new List<Map<String, Object>>();

            // Check if this is a matrix report with groupingsAcross and groupingsDown
            if (report.groupingsAcross == null || report.groupingsDown == null) {
                return result;
            }

            // Get date groupings (across)
            List<Grouping> dateGroupings = report.groupingsAcross.groupings;
            // Get user groupings (down)
            List<Grouping> userGroupings = report.groupingsDown.groupings;

            // Generate dates from startDateTime to endDateTime (ascending order)
            DateTime current = this.startDateTime;
            while (current <= this.endDateTime) {
                String dateLabel = current.format('yyyy-MM-dd');

                // Find matching date in groupingsAcross
                Integer dateIndex = -1;
                if (dateGroupings != null) {
                    for (Integer i = 0; i < dateGroupings.size(); i++) {
                        String reportDateLabel = dateGroupings[i].label;
                        // Handle different date formats from report
                        if (reportDateLabel.contains('.')) {
                            // Convert from DD.MM.YYYY to YYYY-MM-DD
                            List<String> parts = reportDateLabel.split('\\.');
                            if (parts.size() == 3) {
                                reportDateLabel = parts[2] + '-' + parts[1].leftPad(2, '0') + '-' + parts[0].leftPad(2, '0');
                            }
                        } else if (reportDateLabel.contains('/')) {
                            // Convert from M/D/YYYY to YYYY-MM-DD
                            List<String> parts = reportDateLabel.split('/');
                            if (parts.size() == 3) {
                                reportDateLabel = parts[2] + '-' + parts[0].leftPad(2, '0') + '-' + parts[1].leftPad(2, '0');
                            }
                        }

                        if (reportDateLabel == dateLabel) {
                            dateIndex = i;
                            break;
                        }
                    }
                }

                // If we found a matching date, get the data for each user
                if (dateIndex >= 0 && userGroupings != null) {
                    for (Integer userIndex = 0; userIndex < userGroupings.size(); userIndex++) {
                        String userName = userGroupings[userIndex].label;
                        Integer userCount = 0;

                        // Get the fact key for this user and date combination
                        String factKey = userIndex + '!' + dateIndex;
                        if (report.factMap != null && report.factMap.containsKey(factKey)) {
                            FactMapEntry factEntry = report.factMap.get(factKey);
                            if (factEntry.aggregates != null && factEntry.aggregates.size() > 0) {
                                userCount = factEntry.aggregates[0].value;
                            }
                        }

                        // Only add entries with data
                        if (userCount > 0) {
                            result.add(new Map<String, Object>{
                                'date' => dateLabel,
                                'userName' => userName,
                                'logCount' => userCount,
                                'titleY' => this.titleY
                            });
                        }
                    }
                } else {
                    // If no data for this date, add a zero entry
                    result.add(new Map<String, Object>{
                        'date' => dateLabel,
                        'userName' => '',
                        'logCount' => 0,
                        'titleY' => this.titleY
                    });
                }

                current = current.addDays(1);
            }

            return result;
        }
    }

}