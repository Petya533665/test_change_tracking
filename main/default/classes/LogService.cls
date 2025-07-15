global with sharing class LogService {

    public static String ERROR_MESSAGE = 'An error occurred retrieving this information, please check the log records for details.';
    public static final String DEFAULT_PARSER_ERROR_CATEGORY = 'Error';
    public static final String PHAROS_HIDE_TOKEN = '(pharos)';
    public static final String PHAROS_CODE_TOKEN = 'pharos.';
    public static final String LOG_SERVICE_CLASS_NAME = 'LogService';
    public static final String CUSTOM_POST_PROCESSING = 'customPostProcessing';
    public static final String CUSTOM_SKIP = 'customSkip';
    public static final String FIELD_TYPE_BOOLEAN = 'BOOLEAN';
    public static final String FIELD_TYPE_DOUBLE = 'DOUBLE';
    public static final String NAMESPACE_UNKNOWN = 'unknown';

    private static Map<String, Id> getMapRecordTypes() {
        Map<String, Id> result = new Map<String, Id>();
        Map<String, Log_Category_Mapping_Setting__c> records = Log_Category_Mapping_Setting__c.getAll();

        if(!records.isEmpty()) {

            Map<String, Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Log__c.getRecordTypeInfosByName();
            Map<String, Id> rtMapByDeveloperName = new Map<String, Id>();

            for(String rtName : rtMapByName.keySet()) {
                Schema.RecordTypeInfo rtInfo = rtMapByName.get(rtName);
                rtMapByDeveloperName.put(rtInfo.getDeveloperName(), rtInfo.getRecordTypeId());
            }

            List<Log_Category_Mapping_Setting__c> mappingRecords = records.values();
            for(Log_Category_Mapping_Setting__c categoryMapping : mappingRecords) {
                if(categoryMapping.Category__c != null && categoryMapping.Record_Type_Developer_Name__c != null) {
                    String rtDeveloperNameValue = categoryMapping.Record_Type_Developer_Name__c;
                    String categoryFieldValue = categoryMapping.Category__c;

                    Id rtId = rtMapByDeveloperName.get(rtDeveloperNameValue);
                    if(rtId != null) {
                        result.put(categoryFieldValue, rtId);
                    }
                }
            }
        }

        return result;
    }

    public static void assignRecordTypes(List<Log__c> newLogs, Map<Id, Log__c> mapOldLogs) {
        Map<String, Id> mapRecordTypes = getMapRecordTypes();
        for(Log__c log : newLogs) {
            Log__c oldLog = (mapOldLogs != null) ? mapOldLogs.get(log.Id) : null;

            if(oldLog == null
                && String.isNotBlank(log.Category__c)
                && mapRecordTypes.containsKey(log.Category__c)) {
                log.RecordTypeId = mapRecordTypes.get(log.Category__c);
            }
            else if(oldLog != null
                && oldLog.Category__c != log.Category__c
                && String.isNotBlank(log.Category__c)
                && mapRecordTypes.containsKey(log.Category__c)) {
                log.RecordTypeId = mapRecordTypes.get(log.Category__c);
            }
        }
    }


    // PUBLIC
    public static IErrorParser processor = null;

    public static void runAsyncMethods(List<Log__c> logs) {
        if (processor == null || Test.isRunningTest()) {
            return;
        }
        List<Queueable> asyncMethods = new List<Queueable>();
        for (Log__c log : logs) {
            asyncMethods.addAll(processor.getAsyncMethods(log.Id));
        }
        for (Queueable m : asyncMethods) {
            System.enqueueJob(m);
        }
    }

    public static Log__c createLogFromEmailBody(String emailBody, String emailSubject, String fromAddress, Datetime createdAt) {
        return createLogFromEmailBody(emailBody, emailSubject, fromAddress, createdAt, null, null);
    }

    public static final String FLOW_HANDLED_ERROR_MESSAGE = 'Error Handled, flow element has a fault connector, the interview executes the elements in the fault path.';

    public static Log__c createLogFromEmailBody(String emailBody, String emailSubject, String fromAddress, Datetime createdAt, String incomingOrganizationId) {
        return createLogFromEmailBody(emailBody, emailSubject, fromAddress, createdAt, incomingOrganizationId, null);
    }

    public static Log__c createLogFromEmailBody(String emailBody, String emailSubject, String fromAddress, Datetime createdAt, String incomingOrganizationId, Logger loggerInstance) {

        if (emailBody == null) {
            throw new LogException('Error message is empty');
        }

        Log__c log;

        List<String> availableParsers = new List<String>();

        String customErrorParserClassName = ConfigUtil.PHAROS_SETTINGS.Custom_Error_Parser__c;
        if (customErrorParserClassName != null) {
            List<String> pp = customErrorParserClassName.split(';');
            for (String parserName : pp) {
                availableParsers.add(parserName.trim());
            }
        }

        availableParsers.add('ApexExceptionParser');
        availableParsers.add('FlowExceptionParser');
        if (ConfigUtil.SETTINGS.Web_2_Lead_Parser_Enabled__c) {
            availableParsers.add('Web2LeadParser');
        }
        if (ConfigUtil.SETTINGS.Enable_Email_To_Case_Error_Tracking__c == Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED) {
            availableParsers.add('Email2CaseParser');
        }

        String parsingErrors = '';

        for (String parserName : availableParsers) {
            try {
                String customErrorParserClassNamespace = '';
                String customErrorParserClassLocalName = '';
                List<String> nameParts = parserName.split('\\.');
                if (nameParts.size() > 1) {
                    customErrorParserClassNamespace = nameParts[0];
                    customErrorParserClassLocalName = nameParts[1];
                } else {
                    customErrorParserClassLocalName = nameParts[0];
                }
                IErrorParser processor = (IErrorParser)Type.forName(customErrorParserClassNamespace, customErrorParserClassLocalName).newInstance();

                // Error processing
                processor.init(emailBody, emailSubject, fromAddress);

                if (!processor.canProcess()) continue;

                if (processor.getError() == null) {
                    throw new LogException('Error message not found. Please override getError() method to return error message.');
                }

                processor.process();

                log = (Log__c)PermissionsUtil.newSObject(Schema.SObjectType.Log__c);
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Category__c, DEFAULT_PARSER_ERROR_CATEGORY);
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Created_At__c, createdAt);
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Created_Timestamp__c, Double.valueOf(createdAt.getTime()));
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Request_Id_External__c, System.Request.getCurrent().getRequestId());
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Organization_Id__c, (String.isNotBlank(incomingOrganizationId)) ? incomingOrganizationId : processor.getOrganizationId());


                Boolean isCustomSkip = false;
                List<ICustomErrorInfo> customLogFields = processor.getCustomInfo();
                if (customLogFields != null) {
                    for (ICustomErrorInfo f : customLogFields) {
                        try {
                            Map<String, SObjectField> fieldMap = Log__c.getSObjectType().getDescribe().fields.getMap();
                            // skip create log if Flow stacktrace has handled error
                            if (f.getLogFieldName() == CUSTOM_SKIP && f.getValue() == 'true') {
                                isCustomSkip = true;
                            } else if (f.getLogFieldName() == CUSTOM_POST_PROCESSING && f.getValue() == 'true') {
                                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Post_Processing_Status__c, LogPostProcessingService.POST_PROCESSING_STATUS_CUSTOM_NEEDED);
                            } else if (String.valueOf(fieldMap.get(f.getLogFieldName())?.getDescribe().getType()) == FIELD_TYPE_BOOLEAN
                                    || String.valueOf(fieldMap.get(ConfigUtil.nameSpacePrefix + f.getLogFieldName())?.getDescribe().getType()) == FIELD_TYPE_BOOLEAN) {
                                PermissionsUtil.putSObjectField(log, f.getLogFieldName(), String.isNotBlank(f.getValue()) ? Boolean.valueOf(f.getValue()) : false);
                            } else if (String.valueOf(fieldMap.get(f.getLogFieldName())?.getDescribe().getType()) == FIELD_TYPE_DOUBLE
                                    || String.valueOf(fieldMap.get(ConfigUtil.nameSpacePrefix + f.getLogFieldName())?.getDescribe().getType()) == FIELD_TYPE_DOUBLE) {
                                PermissionsUtil.putSObjectField(log, f.getLogFieldName(), String.isNotBlank(f.getValue()) ? (Double.valueOf(f.getValue()) * 1000) : 0);
                            } else {
                                PermissionsUtil.putSObjectField(log, f.getLogFieldName(), f.getValue());
                            }
                        }
                        catch (Exception e) {
                            parsingErrors = parsingErrors + parserName + ':\n' +
                                    e.getMessage() + '\n' +
                                    e.getStackTraceString() + '\n\n';
                        }
                    }
                }

                if (isCustomSkip) break;

                if (log.Post_Processing_Status__c != LogPostProcessingService.POST_PROCESSING_STATUS_CUSTOM_NEEDED) {
                    // Check if Connected Org for found OrgID exists to continue parsing
                    Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(log.Organization_Id__c);
                    if (corg == null) {
                        throw new LogService.LogException('Exception Email from Unknown source: ' + log.Organization_Id__c);
                    }
                    PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Is_Sandbox__c, corg.Is_Sandbox__c);
                    PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Organization_Name__c, corg.Title__c);
                    PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Organization_Url__c, corg.Instance_Url__c);
                }
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Summary__c, processor.getErrorSummary());

                if(processor.getErrorDetails().length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD) {
                    PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Details__c, processor.getErrorDetails().abbreviate(ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD));
                }
                else {
                    PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Details__c, processor.getErrorDetails());
                }
                
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Related_Object_Type__c, processor.getRelatedObjectType());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Related_Id__c, processor.getRelatedId());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Async_Job_Name__c, processor.getAsyncJobName());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Async_Job_Id__c, processor.getAsyncJobId());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Type__c, processor.getErrorType());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Area__c, processor.getArea());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.User_Id__c, processor.getUserId());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Stacktrace__c, processor.getStackTrace());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Stacktrace_Parse_Result__c, processor.parseStackTrace());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Apex_Name__c, processor.getMethodName());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Hash_1__c, processor.getHash1());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Hash_2__c, processor.getHash2());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Hash_3__c, processor.getHash3());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Pending_Jobs__c, processor.getPendingJobsInfo());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Total_Active_Sessions__c, processor.getTotalActiveSessions());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Setup_Audit_Trail__c, processor.getAuditTrail());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Installed_Packages__c, processor.getInstalledPackagesInfo());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Deploy_Results__c, processor.getDeploymentsInfo());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Flow_Version__c, processor.getFlowVersion());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Salesforce_Error_Id__c, processor.getSalesforceErrorId());
                PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Namespace__c, processor.getNamespace());

                // populate default as unknown if not found
                if(String.isBlank(log.Namespace__c)) {
                    PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Namespace__c, NAMESPACE_UNKNOWN);
                }

                if (processor.getStackTrace()?.containsIgnoreCase(PHAROS_CODE_TOKEN) || processor.getStackTrace()?.containsIgnoreCase(PHAROS_HIDE_TOKEN)) {
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Category__c, Logger.CATEGORY_PHAROS_ERROR);
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Area__c, Logger.AREA_PHAROS_ERROR);
                }

                LogService.processor = processor;

                return log;

            }
            catch (Exception e) {
                parsingErrors = parsingErrors + parserName + ':\n' +
                                e.getMessage() + '\n' +
                                e.getStackTraceString() + '\n\n';
                continue;
            }
        }
        throw new LogException(parsingErrors);
    }

    public static void copyLogFlagsFields(List<Log__c> newLogs) {
        Set<String> logIndexKeys = new Set<String>();
        Map<String, DateTime> earliestCreatedAtByHash = new Map<String, DateTime>();
        Map<String, DateTime> earliestFirstOccurredByHash = new Map<String, DateTime>();
        Map<String, Boolean> minDateCopiedForHash = new Map<String, Boolean>();
        Map<String, Integer> logsCountByHash = new Map<String, Integer>(); // Track count of logs per hash
        Map<String, Map<DateTime, Integer>> createdAtCountByHash = new Map<String, Map<DateTime, Integer>>(); // Track count of logs per created_at per hash
        
        // First pass - collect hashes and find earliest dates
        for(Log__c log : newLogs) {
            if(String.isNotBlank(log?.Hash_1__c)) {
                String indexKey = ConfigUtil.getLogIndexKey(log?.Hash_1__c, log?.Organization_Id__c);
                logIndexKeys.add(indexKey);
                
                // Track count of logs per hash
                logsCountByHash.put(indexKey, (logsCountByHash.containsKey(indexKey) ? logsCountByHash.get(indexKey) + 1 : 1));
                
                // Track count of logs per created_at per hash
                if(!createdAtCountByHash.containsKey(indexKey)) {
                    createdAtCountByHash.put(indexKey, new Map<DateTime, Integer>());
                }
                Map<DateTime, Integer> createdAtCount = createdAtCountByHash.get(indexKey);
                if(log.Created_At__c != null) {
                    createdAtCount.put(log.Created_At__c, (createdAtCount.containsKey(log.Created_At__c) ? createdAtCount.get(log.Created_At__c) + 1 : 1));
                }
                
                // Track earliest Created_At__c
                if(!earliestCreatedAtByHash.containsKey(indexKey) || 
                   (log.Created_At__c != null && log.Created_At__c < earliestCreatedAtByHash.get(indexKey))) {
                    earliestCreatedAtByHash.put(indexKey, log.Created_At__c);
                }
                
                // Track earliest First_Occurred_On__c
                if(!earliestFirstOccurredByHash.containsKey(indexKey) || 
                   (log.First_Occurred_On__c != null && log.First_Occurred_On__c < earliestFirstOccurredByHash.get(indexKey))) {
                    earliestFirstOccurredByHash.put(indexKey, log.First_Occurred_On__c);
                }
            }
            else {
                log.Do_Not_Create_Issue__c = true;
            }
        }

        if(!logIndexKeys.isEmpty()) {
            ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(logIndexKeys);
            
            for(Log__c log : newLogs) {
                if(String.isBlank(log?.Hash_1__c)) continue;
                
                String indexKey = ConfigUtil.getLogIndexKey(log?.Hash_1__c, log?.Organization_Id__c);
                ConfigUtil.LogIndex index = helper.getLogIndex(log);
                
                if(index == null) {
                    // No existing index - use new logic with earliest dates
                    DateTime earliestDate;
                    if(earliestFirstOccurredByHash.containsKey(indexKey) && earliestFirstOccurredByHash.get(indexKey) != null) {
                        earliestDate = earliestFirstOccurredByHash.get(indexKey);
                    }
                    else if(earliestCreatedAtByHash.containsKey(indexKey) && earliestCreatedAtByHash.get(indexKey) != null) {
                        earliestDate = earliestCreatedAtByHash.get(indexKey);
                    }
                    else {
                        earliestDate = log.Created_At__c;
                    }
                    
                    if(earliestDate != null) {
                        // Check if we need to subtract a second (when multiple logs share same created_at)
                        Boolean hasMultipleLogsWithSameDate = false;
                        if(createdAtCountByHash.containsKey(indexKey) && 
                           createdAtCountByHash.get(indexKey).containsKey(earliestDate) && 
                           createdAtCountByHash.get(indexKey).get(earliestDate) > 1) {
                            hasMultipleLogsWithSameDate = true;
                        }
                        
                        if(hasMultipleLogsWithSameDate) {
                            earliestDate = earliestDate.addSeconds(-1);
                        }
                        PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.First_Occurred_On__c, earliestDate);
                        // Set Created_At__c to earliest date only for the first record of this hash
                        if(hasMultipleLogsWithSameDate && !minDateCopiedForHash.containsKey(indexKey)) {
                            PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Created_At__c, earliestDate);
                            minDateCopiedForHash.put(indexKey, true);
                        }
                    }
                    
                    // Create new index with calculated date
                    index = helper.createLogIndex(log);
                    if(index != null) {
                        index.firstOccurredOn = earliestDate;
                    }
                }
                else {
                    // Existing index logic remains unchanged
                    if(String.isNotBlank(index.bugTracker) && index.resolvedOn == null) {
                        PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Bug_Tracker__c, index.bugTracker);
                        PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Jira_Integration_Status__c, ConfigUtil.EXISTING_TICKET_LINKED_STATUS);
                    }
                    
                    if(log.First_Occurred_On__c == null && index.firstOccurredOn != null) {
                        PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.First_Occurred_On__c, index.firstOccurredOn);
                    }
                    
                    if(index.resolvedOn != null) {
                        PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Regression__c, true);
                        PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Regressed_On__c, log.Created_At__c);
                    }
                }
            }
            helper.saveLogIndexes(Logger.getInstance());
        }
    }

    /*
    https://[yourinstance].my.salesforce.com/services/wsdl/tooling
    <xsd:simpleType name="StatusCode">
    v54
    * */
    public static List<String> SALESFORCE_ERROR_CODES = new List<String> {
        'ALERT_NOTIFICATION_LIMIT_EXCEEDED',
        'ALL_OR_NONE_OPERATION_ROLLED_BACK',
        'ALREADY_APPLIED',
        'ALREADY_IN_PROCESS',
        'ALREADY_REDEEMED_VOUCHER',
        'APEX_DATA_ACCESS_RESTRICTION',
        'APEX_FAILED',
        'APPLICATION_ALREADY_EXISTS',
        'ASSIGNEE_TYPE_REQUIRED',
        'ATTRIBUTE_DEFINITION_LIMIT_EXCEEDED',
        'AURA_COMPILE_ERROR',
        'AUTH_PROVIDER_NEEDS_AUTH',
        'AUTH_PROVIDER_NOT_FOUND',
        'B2B_SEARCH_ADMIN_ERROR',
        'BAD_CUSTOM_ENTITY_PARENT_DOMAIN',
        'BCC_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED',
        'BLOCKED_EXCLUSIVE',
        'CANNOT_CASCADE_PRODUCT_ACTIVE',
        'CANNOT_CHANGE_FIELD_TYPE_OF_APEX_REFERENCED_FIELD',
        'CANNOT_CHANGE_FIELD_TYPE_OF_REFERENCED_FIELD',
        'CANNOT_CREATE_ANOTHER_MANAGED_PACKAGE',
        'CANNOT_DEACTIVATE_DIVISION',
        'CANNOT_DELETE_GLOBAL_ACTION_LIST',
        'CANNOT_DELETE_LAST_DATED_CONVERSION_RATE',
        'CANNOT_DELETE_MANAGED_OBJECT',
        'CANNOT_DISABLE_LAST_ADMIN',
        'CANNOT_ENABLE_IP_RESTRICT_REQUESTS',
        'CANNOT_EXECUTE_FLOW_TRIGGER',
        'CANNOT_FREEZE_SELF',
        'CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY',
        'CANNOT_MODIFY_MANAGED_OBJECT',
        'CANNOT_PASSWORD_LOCKOUT',
        'CANNOT_POST_TO_ARCHIVED_GROUP',
        'CANNOT_RENAME_APEX_REFERENCED_FIELD',
        'CANNOT_RENAME_APEX_REFERENCED_OBJECT',
        'CANNOT_RENAME_REFERENCED_FIELD',
        'CANNOT_RENAME_REFERENCED_OBJECT',
        'CANNOT_REPARENT_RECORD',
        'CANNOT_UPDATE_CONVERTED_LEAD',
        'CANNOT_UPDATE_IS_THIRD_PARTY',
        'CANNOT_UPDATE_PAYMENT_METHOD_SET',
        'CANT_DISABLE_CORP_CURRENCY',
        'CANT_UNSET_CORP_CURRENCY',
        'CART_ITEM_NOT_FOUND',
        'CART_NOT_FOUND',
        'CHECKOUT_CONFLICT',
        'CHECKOUT_EXPIRED',
        'CHECKOUT_INVALIDATED',
        'CHECKOUT_LOCKED',
        'CHECKOUT_NOT_FOUND',
        'CHECKOUT_UNAUTHORIZED',
        'CHILD_SHARE_FAILS_PARENT',
        'CIRCULAR_DEPENDENCY',
        'CLEAN_SERVICE_ERROR',
        'CLONE_FIELD_INTEGRITY_EXCEPTION',
        'CLONE_NOT_SUPPORTED',
        'CMS_FOLDER_ITEM_MOVE_FAILED',
        'COLLISION_DETECTED',
        'COMMERCE_SEARCH_INDEXING_SYSTEM_ERROR',
        'COMMERCE_SEARCH_MQ_ERROR',
        'COMMERCE_SEARCH_PROVIDER_LIMIT_EXCEEDED',
        'COMMERCE_SEARCH_RESOURCE_NOT_FOUND',
        'COMMERCIAL_CONTROL_ERROR',
        'COMMUNITY_NOT_ACCESSIBLE',
        'CONFLICT',
        'CONFLICTING_ENVIRONMENT_HUB_MEMBER',
        'CONFLICTING_SSO_USER_MAPPING',
        'CONTENT_NOT_FOUND',
        'CONTENT_SEARCH_NOT_ENABLED',
        'CONTENT_TYPE_DISABLED_FOR_API',
        'CONTENT_TYPE_NOT_FOUND',
        'COUPON_REDEMPTION_LIMIT_EXCEEDED',
        'CUSTOM_APEX_ERROR',
        'CUSTOM_CLOB_FIELD_LIMIT_EXCEEDED',
        'CUSTOM_ENTITY_OR_FIELD_LIMIT',
        'CUSTOM_FIELD_INDEX_LIMIT_EXCEEDED',
        'CUSTOM_INDEX_EXISTS',
        'CUSTOM_LINK_LIMIT_EXCEEDED',
        'CUSTOM_METADATA_LIMIT_EXCEEDED',
        'CUSTOM_METADATA_REL_FIELD_MANAGEABILITY',
        'CUSTOM_SETTINGS_LIMIT_EXCEEDED',
        'CUSTOM_TAB_LIMIT_EXCEEDED',
        'DATAASSESSMENT_CONFIG_ASSESSMENT_IN_PROGRESS_ERROR',
        'DATAASSESSMENT_CONFIG_SERVICE_ERROR',
        'DATACLOUDADDRESS_NO_RECORDS_FOUND',
        'DATACLOUDADDRESS_PROCESSING_ERROR',
        'DATACLOUDADDRESS_SERVER_ERROR',
        'DATA_MAPPING_NOT_FOUND',
        'DATA_MAPPING_SCHEMA_NOT_FOUND',
        'DATA_TRANSFER_RECORD_LIMIT_EXCEEDED',
        'DATA_TYPE_NOT_SUPPORTED',
        'DATE_OUT_OF_RANGE',
        'DELETE_FAILED',
        'DELETE_NOT_ALLOWED',
        'DELETE_OPERATION_TOO_LARGE',
        'DELETE_REQUIRED_ON_CASCADE',
        'DEPENDENCY_EXISTS',
        'DUPLICATES_DETECTED',
        'DUPLICATE_CASE_SOLUTION',
        'DUPLICATE_COMM_NICKNAME',
        'DUPLICATE_CUSTOM_ENTITY_DEFINITION',
        'DUPLICATE_CUSTOM_TAB_MOTIF',
        'DUPLICATE_DEVELOPER_NAME',
        'DUPLICATE_EXTERNAL_ID',
        'DUPLICATE_MASTER_LABEL',
        'DUPLICATE_SENDER_DISPLAY_NAME',
        'DUPLICATE_USERNAME',
        'DUPLICATE_VALUE',
        'EMAIL_ADDRESS_BOUNCED',
        'EMAIL_EXTERNAL_TRANSPORT_CONNECTION_ERROR',
        'EMAIL_EXTERNAL_TRANSPORT_PERMISSION_ERROR',
        'EMAIL_EXTERNAL_TRANSPORT_TOKEN_ERROR',
        'EMAIL_EXTERNAL_TRANSPORT_TOO_LARGE_ERROR',
        'EMAIL_EXTERNAL_TRANSPORT_TOO_MANY_REQUESTS_ERROR',
        'EMAIL_EXTERNAL_TRANSPORT_UNKNOWN_ERROR',
        'EMAIL_NOT_PROCESSED_DUE_TO_PRIOR_ERROR',
        'EMAIL_OPTED_OUT',
        'EMAIL_TEMPLATE_FORMULA_ERROR',
        'EMAIL_TEMPLATE_MERGEFIELD_ACCESS_ERROR',
        'EMAIL_TEMPLATE_MERGEFIELD_ERROR',
        'EMAIL_TEMPLATE_MERGEFIELD_VALUE_ERROR',
        'EMAIL_TEMPLATE_PROCESSING_ERROR',
        'EMPTY_CATALOG',
        'EMPTY_INGESTION_JOB',
        'EMPTY_SCONTROL_FILE_NAME',
        'ENHANCED_EMAIL_TEMPLATE_COMPILATION_ERROR',
        'ENTITY_FAILED_IFLASTMODIFIED_ON_UPDATE',
        'ENTITY_IS_ARCHIVED',
        'ENTITY_IS_DELETED',
        'ENTITY_IS_LOCKED',
        'ENTITY_SAVE_ERROR',
        'ENTITY_SAVE_VALIDATION_ERROR',
        'ENVIRONMENT_HUB_MEMBERSHIP_CONFLICT',
        'ENVIRONMENT_HUB_MEMBERSHIP_ERROR_JOINING_HUB',
        'ENVIRONMENT_HUB_MEMBERSHIP_USER_ALREADY_IN_HUB',
        'ENVIRONMENT_HUB_MEMBERSHIP_USER_NOT_ORG_ADMIN',
        'ERROR_CALCULATING_EXPIRY_DATE',
        'ERROR_IN_MAILER',
        'EXCEEDED_MAX_SEMIJOIN_SUBSELECTS_WRITE',
        'EXCHANGE_WEB_SERVICES_URL_INVALID',
        'EXTERNAL_RESOURCE_FORBIDDEN',
        'FAILED_ACTIVATION',
        'FAILED_DUE_TO_OTHER_INPUTS',
        'FAILED_TO_RESOLVE_MAPPING',
        'FAILED_TO_RESOLVE_SCHEMA_INFORMATION',
        'FIELD_CUSTOM_VALIDATION_EXCEPTION',
        'FIELD_FILTER_VALIDATION_EXCEPTION',
        'FIELD_INTEGRITY_EXCEPTION',
        'FIELD_KEYWORD_LIST_MATCH_LIMIT',
        'FIELD_MAPPING_ERROR',
        'FIELD_MODERATION_RULE_BLOCK',
        'FIELD_NOT_UPDATABLE',
        'FILE_EXTENSION_NOT_ALLOWED',
        'FILE_SIZE_LIMIT_EXCEEDED',
        'FILTERED_LOOKUP_LIMIT_EXCEEDED',
        'FIND_DUPLICATES_ERROR',
        'FLOW_EXCEPTION',
        'FUNCTIONALITY_NOT_ENABLED',
        'GET_EINSTEIN_TENANT_ERROR',
        'GUEST_INSUFFICIENT_ACCESS',
        'HAS_PUBLIC_REFERENCES',
        'HTML_FILE_UPLOAD_NOT_ALLOWED',
        'IAS_AM_AUTH_BAD_REQUEST',
        'IAS_AM_AUTH_UNAUTHORIZED',
        'IAS_INVALID_AUTH',
        'IAS_INVALID_REQUEST_PARAMETER',
        'IAS_RECORD_DOES_NOT_EXIST',
        'IAS_TENANT_NOT_PROVISIONED',
        'IAS_UNCOMMITTED_WORK',
        'IMAGE_TOO_LARGE',
        'INACTIVE_OWNER_OR_USER',
        'INACTIVE_RULE_ERROR',
        'INDEX_ITEM_LIMIT_EXCEEDED',
        'INDEX_PAYLOAD_NOT_FOUND',
        'INGESTION_JOB_RECORDS_LIMIT_EXCEEDED',
        'INGESTION_TOTAL_FILE_SIZE_LIMIT_EXCEEDED',
        'INPUTPARAM_INCOMPATIBLE_DATATYPE',
        'INSERT_UPDATE_DELETE_NOT_ALLOWED_DURING_MAINTENANCE',
        'INSUFFICIENT_ACCESS',
        'INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY',
        'INSUFFICIENT_ACCESS_OR_READONLY',
        'INSUFFICIENT_ACCESS_TO_INSIGHTSEXTERNALDATA',
        'INSUFFICIENT_BALANCE',
        'INSUFFICIENT_BENEFIT_REMAINING',
        'INSUFFICIENT_CREDITS',
        'INTEGRATION_CANCELLED',
        'INTERNAL_ERROR',
        'INVALID_ACCESS_LEVEL',
        'INVALID_ACCESS_TOKEN',
        'INVALID_ACCOUNT',
        'INVALID_ACTION_VERSION',
        'INVALID_API_INPUT',
        'INVALID_ARGUMENT_TYPE',
        'INVALID_ASSIGNEE_TYPE',
        'INVALID_ASSIGNMENT_RULE',
        'INVALID_AUTH_HEADER',
        'INVALID_BATCH_OPERATION',
        'INVALID_BUSINESS_HOURS_NAME',
        'INVALID_CHECKOUT_INPUT',
        'INVALID_CONTACT',
        'INVALID_CONTENT_TYPE',
        'INVALID_CREDIT_CARD_INFO',
        'INVALID_CROSS_REFERENCE_KEY',
        'INVALID_CROSS_REFERENCE_TYPE_FOR_FIELD',
        'INVALID_CURRENCY_CONV_RATE',
        'INVALID_CURRENCY_CORP_RATE',
        'INVALID_CURRENCY_ISO',
        'INVALID_DATASET_REFERENCE_INPUT',
        'INVALID_DATA_CATEGORY_GROUP_REFERENCE',
        'INVALID_DATA_URI',
        'INVALID_EBV_OPERATION',
        'INVALID_EMAIL_ADDRESS',
        'INVALID_EMPTY_KEY_OWNER',
        'INVALID_ENTITY_FOR_MATCH_ENGINE_ERROR',
        'INVALID_ENTITY_FOR_MATCH_OPERATION_ERROR',
        'INVALID_ENTITY_FOR_UPSERT',
        'INVALID_ENVIRONMENT_HUB_MEMBER',
        'INVALID_EVENT_DELIVERY',
        'INVALID_EVENT_INPUT',
        'INVALID_EVENT_SUBSCRIPTION',
        'INVALID_EXTENSION_ID',
        'INVALID_EXTERNAL_ID_FIELD_NAME',
        'INVALID_FIELD',
        'INVALID_FIELD_FOR_INSERT_UPDATE',
        'INVALID_FIELD_WHEN_USING_TEMPLATE',
        'INVALID_FILTER_ACTION',
        'INVALID_GOOGLE_DOCS_URL',
        'INVALID_ID_FIELD',
        'INVALID_INET_ADDRESS',
        'INVALID_INPUT',
        'INVALID_INPUT_FORMAT',
        'INVALID_KEY_FIELD_INPUT',
        'INVALID_LINEITEM_CLONE_STATE',
        'INVALID_MARKUP',
        'INVALID_MASTER_OR_TRANSLATED_SOLUTION',
        'INVALID_MERCHANT_ACCOUNT_MODE',
        'INVALID_MERCHANT_ACCOUNT_MODE_OR_STATUS',
        'INVALID_MERGE_RECORD',
        'INVALID_MESSAGE_ID_REFERENCE',
        'INVALID_NAMESPACE_PREFIX',
        'INVALID_OAUTH_URL',
        'INVALID_OPERATION',
        'INVALID_OPERATOR',
        'INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST',
        'INVALID_OWNER',
        'INVALID_PACKAGE_LICENSE',
        'INVALID_PACKAGE_VERSION',
        'INVALID_PARTNER_NETWORK_STATUS',
        'INVALID_PAYLOAD_VERSION',
        'INVALID_PERSON_ACCOUNT_OPERATION',
        'INVALID_PROFILE',
        'INVALID_PROMOTION',
        'INVALID_PROVIDER_TYPE',
        'INVALID_QUERY_KEY',
        'INVALID_QUERY_LOCATOR',
        'INVALID_QUERY_VALUE',
        'INVALID_READ_ONLY_USER_DML',
        'INVALID_RECEIVEDDOCUMENTID_ATTACHMENT',
        'INVALID_RECORD_ATTRIBUTE_VALUE',
        'INVALID_RECORD_TYPE',
        'INVALID_REFRESH_TOKEN',
        'INVALID_REQUEST_STATE',
        'INVALID_RUNTIME_VALUE',
        'INVALID_SAVE_AS_ACTIVITY_FLAG',
        'INVALID_SCS_INBOUND_USER',
        'INVALID_SEARCH_PROVIDER_REQUEST',
        'INVALID_SESSION_ID',
        'INVALID_SETUP_OWNER',
        'INVALID_SIGNUP_COUNTRY',
        'INVALID_SIGNUP_OPTION',
        'INVALID_SITE_DELETE_EXCEPTION',
        'INVALID_SITE_FILE_IMPORTED_EXCEPTION',
        'INVALID_SITE_FILE_TYPE_EXCEPTION',
        'INVALID_SOURCE_OBJECT_ID',
        'INVALID_STATUS',
        'INVALID_SUBDOMAIN',
        'INVALID_TARGET_OBJECT_NAME',
        'INVALID_TEXT_REPRESENTATION',
        'INVALID_TYPE',
        'INVALID_TYPE_FOR_OPERATION',
        'INVALID_TYPE_ON_FIELD_IN_RECORD',
        'INVALID_UNMERGE_RECORD',
        'INVALID_USERID',
        'INVALID_USER_OBJECT',
        'IP_RANGE_LIMIT_EXCEEDED',
        'ITEM_NOT_FOUND',
        'JIGSAW_IMPORT_LIMIT_EXCEEDED',
        'LICENSE_LIMIT_EXCEEDED',
        'LIGHT_PORTAL_USER_EXCEPTION',
        'LIMIT_EXCEEDED',
        'LIST_PRICE_NOT_FOUND',
        'MALFORMED_ID',
        'MANAGER_NOT_DEFINED',
        'MASSMAIL_RETRY_LIMIT_EXCEEDED',
        'MASS_MAIL_LIMIT_EXCEEDED',
        'MATCH_DEFINITION_ERROR',
        'MATCH_OPERATION_ERROR',
        'MATCH_OPERATION_INVALID_ENGINE_ERROR',
        'MATCH_OPERATION_INVALID_RULE_ERROR',
        'MATCH_OPERATION_MISSING_ENGINE_ERROR',
        'MATCH_OPERATION_MISSING_OBJECT_TYPE_ERROR',
        'MATCH_OPERATION_MISSING_OPTIONS_ERROR',
        'MATCH_OPERATION_MISSING_RULE_ERROR',
        'MATCH_OPERATION_UNKNOWN_RULE_ERROR',
        'MATCH_OPERATION_UNSUPPORTED_VERSION_ERROR',
        'MATCH_PRECONDITION_FAILED',
        'MATCH_PRECONDITION_REQUIRED',
        'MATCH_RUNTIME_ERROR',
        'MATCH_SERVICE_ERROR',
        'MATCH_SERVICE_TIMED_OUT',
        'MATCH_SERVICE_UNAVAILABLE_ERROR',
        'MAXIMUM_CCEMAILS_EXCEEDED',
        'MAXIMUM_DASHBOARD_COMPONENTS_EXCEEDED',
        'MAXIMUM_HIERARCHY_CHILDREN_REACHED',
        'MAXIMUM_HIERARCHY_LEVELS_REACHED',
        'MAXIMUM_HIERARCHY_TREE_SIZE_REACHED',
        'MAXIMUM_SIZE_OF_ATTACHMENT',
        'MAXIMUM_SIZE_OF_DOCUMENT',
        'MAX_ACTIONS_PER_RULE_EXCEEDED',
        'MAX_ACTIVE_RULES_EXCEEDED',
        'MAX_APPROVAL_STEPS_EXCEEDED',
        'MAX_DEPTH_IN_FLOW_EXECUTION',
        'MAX_FORMULAS_PER_RULE_EXCEEDED',
        'MAX_LIMIT_EXCEEDED',
        'MAX_RULES_EXCEEDED',
        'MAX_RULE_ENTRIES_EXCEEDED',
        'MAX_TASK_DESCRIPTION_EXCEEEDED',
        'MAX_TM_RULES_EXCEEDED',
        'MAX_TM_RULE_ITEMS_EXCEEDED',
        'MAX_TRIGGERS_EXCEEDED',
        'MERGE_FAILED',
        'METADATA_FIELD_UPDATE_ERROR',
        'METHOD_NOT_ALLOWED',
        'MISMATCHING_TYPES',
        'MISSING_ARGUMENT',
        'MISSING_OMNI_PROCESS_ID',
        'MISSING_RECEIVEDDOCUMENTID_ATTACHMENT',
        'MISSING_RECORD',
        'MIXED_DML_OPERATION',
        'MODEL_NOT_ACTIVE',
        'MULTIPLE_CONTENT_FOUND',
        'MULTIPLE_VOUCHERS',
        'NONUNIQUE_SHIPPING_ADDRESS',
        'NOT_FOUND',
        'NOT_RECOVERABLE_SEARCH_PROVIDER_ERROR',
        'NO_ACCESS_TOKEN',
        'NO_ACCESS_TOKEN_FROM_REFRESH',
        'NO_APPLICABLE_PROCESS',
        'NO_ATTACHMENT_PERMISSION',
        'NO_AUTH_PROVIDER',
        'NO_BUSINESS_HOURS_FOUND',
        'NO_INACTIVE_DIVISION_MEMBERS',
        'NO_MASS_MAIL_PERMISSION',
        'NO_MESSAGE_TYPE_MESSAGES',
        'NO_PARTNER_PERMISSION',
        'NO_REFRESH_TOKEN',
        'NO_SEARCH_ATTRIBUTES',
        'NO_SINGLE_MAIL_PERMISSION',
        'NO_SORT_PRICEBOOK_ASSOCIATED_ERROR',
        'NO_SUCH_USER_EXISTS',
        'NO_TOKEN_ENDPOINT',
        'NUMBER_OUTSIDE_VALID_RANGE',
        'NUM_HISTORY_FIELDS_BY_SOBJECT_EXCEEDED',
        'OCR_INVALID_REQUEST',
        'OPERATION_ENQUEUED',
        'OPERATION_WITH_CALLBACK_ENQUEUED',
        'OPTED_OUT_OF_MASS_MAIL',
        'OP_WITH_INVALID_USER_TYPE_EXCEPTION',
        'ORCHESTRATION_INVALID',
        'ORDER_MANAGEMENT_ACTION_NOT_ALLOWED',
        'ORDER_MANAGEMENT_INVALID_RECORD',
        'ORDER_MANAGEMENT_RECORD_EXISTS',
        'ORDER_MANAGEMENT_RECORD_NOT_FOUND',
        'ORG_SETTING_REQUIRED',
        'PACKAGE_DISABLED',
        'PACKAGE_LICENSE_REQUIRED',
        'PACKAGING_API_INSTALL_FAILED',
        'PACKAGING_API_UNINSTALL_FAILED',
        'PALI_INVALID_ACTION_ID',
        'PALI_INVALID_ACTION_NAME',
        'PALI_INVALID_ACTION_TYPE',
        'PAL_INVALID_ASSISTANT_RECOMMENDATION_TYPE_ID',
        'PAL_INVALID_ENTITY_ID',
        'PAL_INVALID_FLEXIPAGE_ID',
        'PAL_INVALID_LAYOUT_ID',
        'PAL_INVALID_PARAMETERS',
        'PARAMETER_TOO_LARGE',
        'PARTICIPANT_RELATIONSHIP_EXISTS',
        'PAYLOAD_SIZE_EXCEEDED',
        'PA_API_EXCEPTION',
        'PA_AXIS_FAULT',
        'PA_INVALID_ID_EXCEPTION',
        'PA_NO_ACCESS_EXCEPTION',
        'PA_NO_DATA_FOUND_EXCEPTION',
        'PA_URI_SYNTAX_EXCEPTION',
        'PA_VISIBLE_ACTIONS_FILTER_ORDERING_EXCEPTION',
        'PENDING_COMMIT',
        'PICKLIST_INACTIVE_VALUES_EXCEEDED',
        'PLATFORM_EVENT_ENCRYPTION_ERROR',
        'PLATFORM_EVENT_PUBLISHING_UNAVAILABLE',
        'PLATFORM_EVENT_PUBLISH_FAILED',
        'PORTAL_NO_ACCESS',
        'PORTAL_USER_ALREADY_EXISTS_FOR_CONTACT',
        'PORTAL_USER_CREATION_RESTRICTED_WITH_ENCRYPTION',
        'PRICE_NOT_FOUND',
        'PRIVATE_CONTACT_ON_ASSET',
        'PROCESSING_HALTED',
        'PROGRAM_PROGRESS_NOT_ACTIVE',
        'PROMOTION_NOT_FOUND',
        'QA_INVALID_CREATE_FEED_ITEM',
        'QA_INVALID_SUCCESS_MESSAGE',
        'QUERY_REFINEMENT_VALUE_LIMIT_EXCEEDED',
        'QUERY_TIMEOUT',
        'QUERY_TOKEN_COUNT_LIMIT_EXCEEDED',
        'QUICK_ACTION_LIST_ITEM_NOT_ALLOWED',
        'QUICK_ACTION_LIST_NOT_ALLOWED',
        'RECORD_CREATION_FAILED',
        'RECORD_IN_USE_BY_WORKFLOW',
        'RECORD_MISSING_REQUIRED_FIELD',
        'RECORD_UPDATE_FAILED',
        'RECOVERABLE_SEARCH_PROVIDER_ERROR',
        'REFRESH_FAILED',
        'RELATED_ENTITY_FILTER_VALIDATION_EXCEPTION',
        'REL_FIELD_BAD_ACCESSIBILITY',
        'REPUTATION_MINIMUM_NUMBER_NOT_REACHED',
        'REQUEST_RUNNING_TOO_LONG',
        'REQUIRED_FEATURE_MISSING',
        'REQUIRED_FIELD_MISSING',
        'REQUIRE_CONNECTED_APP_SCS',
        'REQUIRE_CONNECTED_APP_SESSION_SCS',
        'REQUIRE_RUNAS_USER',
        'RETRIEVE_EXCHANGE_ATTACHMENT_FAILED',
        'RETRIEVE_EXCHANGE_EMAIL_FAILED',
        'RETRIEVE_EXCHANGE_EVENT_FAILED',
        'RETRIEVE_GOOGLE_EMAIL_FAILED',
        'RETRIEVE_GOOGLE_EVENT_FAILED',
        'RETRIEVE_USER_CONFIG_ERROR',
        'ROUTES_EVALUATION_LIMIT_EXCEEDED',
        'SALESFORCE_INBOX_TRANSPORT_CONNECTION_ERROR',
        'SALESFORCE_INBOX_TRANSPORT_INVALID_INPUT_ERROR',
        'SALESFORCE_INBOX_TRANSPORT_TOKEN_ERROR',
        'SALESFORCE_INBOX_TRANSPORT_UNKNOWN_ERROR',
        'SCHEMA_OBJECT_NOT_FOUND',
        'SCREEN_POP_REQUIRED_INPUT_MISSING',
        'SEARCH_INCLUDE_RULES_MAX_RULE_DEFINITION_LIMIT_EXCEEDED',
        'SEARCH_INCLUDE_RULES_MIN_RULE_DEFINITION_NOT_MET',
        'SEARCH_PROVIDER_REQUEST_RATE_EXCEEDED',
        'SEGMENT_COUNT_LIMIT_EXCEEDED',
        'SELF_REFERENCE_FROM_FLOW',
        'SELF_REFERENCE_FROM_TRIGGER',
        'SERVICE_UNAVAILABLE',
        'SESSION_EXPIRED',
        'SESSION_INVALIDATED',
        'SHARE_NEEDED_FOR_CHILD_OWNER',
        'SINGLE_EMAIL_LIMIT_EXCEEDED',
        'SLACK_API_ERROR',
        'SOCIAL_ACCOUNT_NOT_FOUND',
        'SOCIAL_ACTION_INVALID',
        'SOCIAL_PERSONA_NOT_FOUND',
        'SOCIAL_POST_INVALID',
        'SOCIAL_POST_NOT_FOUND',
        'SPECIFICATION_GENERATION_EXCEPTION',
        'STANDARD_PRICE_NOT_DEFINED',
        'STORAGE_LIMIT_EXCEEDED',
        'STRING_TOO_LONG',
        'SUBDOMAIN_IN_USE',
        'TABSET_LIMIT_EXCEEDED',
        'TEMPLATE_NOT_ACTIVE',
        'TEMPLATE_NOT_FOUND',
        'TERMS_OF_SERVICE_UNREAD',
        'TERRITORY_REALIGN_IN_PROGRESS',
        'TEXT_DATA_OUTSIDE_SUPPORTED_CHARSET',
        'TEXT_TO_PICKLIST_VALUES_EXCEEDED',
        'TOO_MANY_APEX_REQUESTS',
        'TOO_MANY_ENUM_VALUE',
        'TOO_MANY_JOBS',
        'TOO_MANY_POSSIBLE_USERS_EXIST',
        'TRANSFER_REQUIRES_READ',
        'TXN_SECURITY_NO_ACCESS',
        'UISF_ENTITY_QUERY_FAILED',
        'UISF_NO_MAPPINGS_FOUND',
        'UISF_TOKEN_NOT_FOUND',
        'UISF_UNKNOWN_EXCEPTION',
        'UISF_USER_MAPPING_FAILED',
        'UNABLE_TO_LOCK_ROW',
        'UNAUTHORIZED_SEARCH_PROVIDER_REQUEST',
        'UNAVAILABLE_RECORDTYPE_EXCEPTION',
        'UNAVAILABLE_REF',
        'UNDEFINED_MAPPING_DEFINITION',
        'UNDELETE_FAILED',
        'UNKNOWN_EXCEPTION',
        'UNKNOWN_TOKEN_ERROR',
        'UNPROCESSABLE_REQUEST',
        'UNQUALIFIED_CART',
        'UNSAFE_HTML_CONTENT',
        'UNSPECIFIED_EMAIL_ADDRESS',
        'UNSUPPORTED_APEX_TRIGGER_OPERATON',
        'UNSUPPORTED_MODE',
        'UNSUPPORTED_PAYMENT_GATEWAY_TYPE',
        'UNSUPPORTED_PAYMENT_REQUEST_TYPE',
        'UNSUPPORTED_SITE',
        'UNSUPPORTED_SITE_FILE_IMPORTED_EXCEPTION',
        'UNSUPPORTED_SOCIAL_PROVIDER',
        'UNVERIFIED_SENDER_ADDRESS',
        'UPDATE_GOOGLE_EMAIL_LABEL_FAILED',
        'USER_OWNS_PORTAL_ACCOUNT_EXCEPTION',
        'USER_WITHOUT_WEM_PERMISSION',
        'USER_WITH_APEX_SHARES_EXCEPTION',
        'VARIANT_NOT_FOUND',
        'VF_COMPILE_ERROR',
        'VOICE_CAPACITY_ERROR',
        'WEBLINK_SIZE_LIMIT_EXCEEDED',
        'WEBLINK_URL_INVALID',
        'WEM_SEGMENTS_CAN_NOT_HAVE_NON_ACTIVE_SEGMENT_TYPE',
        'WEM_SHIFT_SEGMENT_TIME_IS_OUTSIDE_OF_THE_SHIFT_DURATION',
        'WEM_USER_NOT_ORG_ADMIN',
        'WORKSPACE_NOT_FOUND',
        'WRONG_CONTROLLER_TYPE',
        'XCLEAN_DJ_MATCH_IGNORABLE_ERROR',
        'XCLEAN_DJ_MATCH_INTERNAL_DJ_ERROR',
        'XCLEAN_DJ_MATCH_NON_RETRIABLE_ERROR',
        'XCLEAN_DJ_MATCH_RETRIABLE_ERROR',
        'XCLEAN_DJ_MATCH_UNKNOWN_ERROR',
        'XCLEAN_UNEXPECTED_ERROR'
    };

    public static List<String> getExceptionCodesInString(String message) {
        Set<String> exceptionCodes = new Set<String>();
        if (String.isBlank(message)) return new List<String>(exceptionCodes);
        for (String exceptionCode : LogService.SALESFORCE_ERROR_CODES) {
            if (message.contains(exceptionCode)) exceptionCodes.add(exceptionCode);
        }
        return new List<String>(exceptionCodes);
    }

    public static final String ERROR_CODE_END1 = ': ';
    public static final String ERROR_CODE_END2 = ', ';
    public static final String ERROR_CODE_END3 = '.. ';
    public static final String ERROR_CODE_END4 = '. ';

    /*
     Example
      input : Update failed. First exception on row 0 with id a2q4z000008bcsqAAA; first error: STRING_TOO_LONG, Job Opening Name: data value too large: 001343-Fieldstone Architecture &amp; Engineering-Temple Terrace- FL-BIM Engineer - Structural (max length=80): [Name]
      output : Update failed. First exception on row 0 with id a2q4z000008bcsqAAA; first error: STRING_TOO_LONG: [Name]
    */
    public static String removeExtraErrorDetails(String summary) {
        String result = summary;
        // skip HttpUtils.HttpUtilsException integration errors
        // 400: [{"message":"No such column 'IsAuthenticationRequired' on sobject of type EmailServicesFunction","errorCode":"INVALID_FIELD"}]
        if(summary?.length() > 5 && summary?.substring(0, 3)?.isNumeric() && summary?.substring(3, 5)?.equals(ERROR_CODE_END1)) {
            return summary;
        }

        for(String errorCode : LogService.SALESFORCE_ERROR_CODES) {
            Integer startPosition = summary?.indexOf(errorCode);
            if(startPosition != null && startPosition != -1) {
                Integer errorPositionStart;
                Integer errorPositionEnd = summary.length();
                if(summary.indexOf(ERROR_CODE_END1, startPosition) != -1
                    || summary.indexOf(ERROR_CODE_END2, startPosition) != -1) {
                    errorPositionStart = startPosition + errorCode.length() + ERROR_CODE_END1.length();
                }
                if(errorPositionStart != null) {
                    if(summary.indexOf(ERROR_CODE_END1, errorPositionStart) != -1) {
                        errorPositionEnd = summary.indexOf(ERROR_CODE_END1, errorPositionStart);
                    }
                    else if(summary.indexOf(ERROR_CODE_END2, errorPositionStart) != -1) {
                        errorPositionEnd = summary.indexOf(ERROR_CODE_END2, errorPositionStart);
                    }
                    else if(summary.indexOf(ERROR_CODE_END3, errorPositionStart) != -1) {
                        errorPositionEnd = summary.indexOf(ERROR_CODE_END3, errorPositionStart);
                    }
                    else if(summary.indexOf(ERROR_CODE_END4, errorPositionStart) != -1) {
                        errorPositionEnd = summary.indexOf(ERROR_CODE_END4, errorPositionStart);
                    }
                }
                result = summary.substring(startPosition, errorPositionEnd);
            }
        }
        return result;
    }

    public static Log__c calculateHashes(Log__c log) {

        String valueForHash1;
        String valueForHash2;
        String valueForHash3;
        Set<String> stackTraceUniqueLines = new Set<String>();
        String firstLineStacktrace = '';
        String lastLineStacktrace = '';
        String logSummary = removeExtraErrorDetails(log.Summary__c);

        if(String.isNotBlank(log.Stacktrace__c)) {
            stackTraceUniqueLines = new Set<String>(ApexExceptionParser.getStackTraceLines(log.Stacktrace__c, ApexExceptionParser.PATTERN_CLASS_2));
            firstLineStacktrace = ApexExceptionParser.getFirstStacktraceLine(stackTraceUniqueLines);
            lastLineStacktrace = ApexExceptionParser.getLastStacktraceLine(stackTraceUniqueLines);
        }
        valueForHash1 = (!stackTraceUniqueLines?.isEmpty()) ? (JSON.serialize(stackTraceUniqueLines) + logSummary) : log.Details__c;
        valueForHash2 = (!stackTraceUniqueLines?.isEmpty()) ? (firstLineStacktrace + lastLineStacktrace + logSummary) : log.Stacktrace__c;
        valueForHash3 = (!stackTraceUniqueLines?.isEmpty()) ? (lastLineStacktrace + logSummary) : log.Apex_Name__c;

        if(String.isBlank(log.Hash__c)) {
            PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Hash__c, generateHash_0(log.Details__c));
        }
        if(String.isBlank(log.Hash_1__c) && String.isNotBlank(valueForHash1)) {
            PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Hash_1__c, generateHash_1(valueForHash1));
        }
        if (String.isBlank(log.Hash_2__c) && String.isNotBlank(valueForHash2)) {
            PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Hash_2__c, generateHash_2(valueForHash2));
        }
        if (String.isBlank(log.Hash_3__c) && String.isNotBlank(valueForHash3)) {
            PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Hash_3__c, generateHash_3(valueForHash3));
        }

        return log;
    }

    public static String generateHash_0(String value) {
        if (String.isBlank(value)) {
            return null;
        }

        // fix "for job id '7070O00005VBQcW'" difference in duplacates
        // value = value.replaceAll('for job id \\\'[\\s\\S]{15,18}\\\'', 'for job id \'...\'');

        return EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));
    }

    public static final String REGEX_ID_PATTERN = '[\\w]{15,18}';
    public static final String REGEX_NON_ALPHANUMERIC_PATTERN = '[\\W]';
    public static final String REGEX_ALL_NUMBERS_PATTERN = '[\\d]';
    public static final String REGEX_FLOW_GUID_PATTERN = 'Interview GUID: ([\\s\\S]+?)[\\n|\\r\\n|\\r]';
    public static final String REGEX_TIME_PATTERN = '[AaPp][Mm]';
    public static final String REGEX_FLOW_CURRENT_USER = 'Current User: [\\s\\S]+? \\(([\\s\\S]+?)\\)[\\n|\\r\\n|\\r]';
    public static final String REGEX_FLOW_RUNNING_USER = 'How the Interview Started([\\s\\S]+?) started the flow interview';

    public static final String REGEX_GUID_TOKEN = 'HttpUtilsException';
    public static final String REGEX_GUID = '([0-9A-Fa-f]{8}[-]?[0-9A-Fa-f]{4}[-]?[0-9A-Fa-f]{4}[-]?[0-9A-Fa-f]{4}[-]?[0-9A-Fa-f]{12})';

    public static String generateHash_1(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        // remove GUID's from Http Exceptions
        if(value.contains(REGEX_GUID_TOKEN)) {
            value = value.replaceAll(REGEX_GUID, '');
        }
        /* PROCESSING */
        // remove all IDs (pseudo Ids)
        value = value.replaceAll(REGEX_ID_PATTERN, '');
        // remove all Non-alphanum characters and whitespaces
        value = value.replaceAll(REGEX_NON_ALPHANUMERIC_PATTERN, '');
        // remove all numbers
        value = value.replaceAll(REGEX_ALL_NUMBERS_PATTERN, '');

        /* HASH CALCULATING */
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));

        return hash;
    }

    public static String generateHash_2(String stacktrace) {
        if (String.isBlank(stacktrace)) {
            return null;
        }

        /* PROCESSING */
        List<String> stacktraceLines = stacktrace.split('[\\n|\\r\\n|\\r]');

        String value = stacktraceLines[0] + stacktraceLines[stacktraceLines.size() - 1];

        // remove line/column information
        value = value.replaceAll(' line ([\\s\\S]+?), column [\\s\\S]+?', '');

        /* HASH CALCULATING */
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));

        return hash;
    }

    public static String generateHash_3(String apexName) {

        if (String.isBlank(apexName)) {
            return null;
        }

        /* HASH CALCULATING */
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(apexName)));

        return hash;
    }

    public static String getApexName(String stacktrace) {
        if (String.isBlank(stacktrace)) {
            return null;
        }

        List<String> stacktraceLines = stacktrace.split('[\\n|\\r\\n|\\r]');

        String value = stacktraceLines[stacktraceLines.size() - 1];

        // remove line/column information
        value = value.split(': line ')[0];

        value = value.replaceAll('^(Trigger\\.|Class\\.)', '');

        return value;
    }

    public class LogException extends Exception {}
}