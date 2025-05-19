public without sharing class StackTraceParser {

    public static Set<String> prefixes;
    public static Connected_Org__c corg;
    public static Boolean newAccessTokenGenarated = false;

    public static final Pattern PATTERN_STACK_TRACE_LINES = Pattern.compile('[\\n|\\r\\n|\\r]?([^\\n|\\r\\n|\\r]+?): line ([\\s\\S]+?), column [\\s\\S]+?');


    public static List<StackTraceParseResult> parseStackTrace(String stackTrace) {
        List<StackTraceParseResult> stackTraceItems = new LIst<StackTraceParseResult>();
        if(String.isBlank(stackTrace)) {
            return stackTraceItems;
        }
        prefixes = getAvailablePrefixes();
        List<String> classNames = new List<String>();
        List<String> triggerNames = new List<String>();
        if(stackTrace.contains('line') && stackTrace.contains('column')) {
            Matcher pm = PATTERN_STACK_TRACE_LINES.matcher(stackTrace);

            while (pm.find()) {
                StackTraceParseResult str = new StackTraceParseResult();
                str.className = pm.group(1);

                if (str.className.startsWith('Class.') && !str.className.startsWith('Class.System')) {
                    classNames.add(getShortName(str.className));
                    str.type = 'class';
                } else if (str.className.startsWith('Trigger.')) {
                    List<String> nameParts = str.className.split('\\.');
                    triggerNames.add(getShortName(str.className));
                    str.type = 'trigger';
                }

                str.lineNumber = Integer.valueOf(pm.group(2));
                stackTraceItems.add(str);
            }
        }

        Map<String, ApexClassWrapper> classesMap = getClassesMap(classNames);
        Map<String, ApexClassWrapper> triggersMap = getTriggersMap(triggerNames);

        for (StackTraceParseResult str : stackTraceItems) {
            ApexClassWrapper meta = str.type == 'trigger' ? triggersMap.get(getShortName(str.className)) : classesMap.get(getShortName(str.className));
            if (meta != null) {
                String code = meta.Body;
                str.id = meta.Id;
                if (String.isBlank(code)) {
                    continue;
                }
                if (code == '(hidden)') {
                    str.hunk = '(hidden)';
                    continue;
                }

                List<String> codeLines = code.split('\\n');
                codeLines.add(0, '');
                List<String> visibleCodeLines = new List<String>();

                Integer startLine = str.lineNumber - 5 <= 1 ? 1 : str.lineNumber - 5;
                str.hunkFirstLineNumber = startLine;
                Integer endLine = str.lineNumber + 5 >= codeLines.size()-1 ? codeLines.size()-1 : str.lineNumber + 5;
                try {
                    for (Integer i = startLine; i<= str.lineNumber; i++) {
                        visibleCodeLines.add(codeLines[i]);
                    }
                    if (endLine > str.lineNumber) {
                        for (Integer i = str.lineNumber + 1; i<= endLine; i++) {
                            visibleCodeLines.add(codeLines[i]);
                        }
                    }
                    str.hunk = String.join(visibleCodeLines, '\n');
                } catch(Exception e) {
                    str.hunk = '(hidden)';
                }
            }
        }

        return stackTraceItems;
    }

    public static Map<String, String> getHeaders() {
        return new Map<String, String> {
            'Authorization' => 'Bearer ' + ConnectedOrgService.getConnectedOrgAccessToken(corg),
            'Content-Type' => 'application/json'
        };
    }

    public static String getShortName(String fullName) {
        List<String> nameParts = fullName.split('\\.');
        if (nameParts.size() > 1 && !prefixes.contains(nameParts[1])) {
            return nameParts[1];
        } else if (nameParts.size() > 2 && prefixes.contains(nameParts[1])) {
            return nameParts[1] + '.' + nameParts[2];
        }
        return null;
    }

    public static Set<String> getAvailablePrefixes() {
        Set<String> prefixes = new Set<String>();
        for (String resource : new List<String>{'ApexClass', 'ApexTrigger'}) {

            String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_STACK_TRACE, corg.Name, resource);
            Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_STACK_TRACE, keyCache);

            Object cacheObject;

            if(isCacheAvailableForKey) {
                cacheObject = CacheUtils.getCacheValue(keyCache);

                if(cacheObject != null) {
                    List<ApexClassWrapper> cachedValue = (List<ApexClassWrapper>)cacheObject;
                    for(ApexClassWrapper ac : cachedValue) {
                        prefixes.add(ac.NamespacePrefix);
                    }
                }
            }

            if(cacheObject == null) {
                String q = 'SELECT+Id,+Name,+NamespacePrefix+FROM+' + resource;
                String b = HttpUtils.get(
                corg.Instance_Url__c + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + q,
                    getHeaders(),
                    200
                );
                ApexClassesResponseWrapper result = (ApexClassesResponseWrapper)JSON.deserialize(b, ApexClassesResponseWrapper.class);
                for (ApexClassWrapper ac : result.records) {
                    prefixes.add(ac.NamespacePrefix);
                }

                if(isCacheAvailableForKey) {
                    CacheUtils.putCacheValue(keyCache, result.records, CacheUtils.getTTLValue(CacheUtils.KEY_REQUEST_STACK_TRACE));
                }

            }
        }
        return prefixes;
    }

    public static Map<String, ApexClassWrapper> getTriggersMap(List<String> names) {
        String query = 'SELECT+Id,+Name,+NamespacePrefix,+Body+FROM+ApexTrigger+WHERE+Name+IN+(xxxxx)';
        return getCodeFromSF(names, query);
    }

    public static Map<String, ApexClassWrapper> getClassesMap(List<String> names) {
        String query = 'SELECT+Id,+Name,+NamespacePrefix,+Body+FROM+ApexClass+WHERE+Name+IN+(xxxxx)';
        return getCodeFromSF(names, query);
    }

    public static Map<String, ApexClassWrapper> getCodeFromSF(List<String> names, String query) {
        Map<String, ApexClassWrapper> itemsMap = new Map<String, ApexClassWrapper>();
        if (names == null || names.size() == 0) {
            return itemsMap;
        }
        for (Integer i=0; i<names.size(); i++) {
            List<String> nameParts = names[i].split('\\.');
            names[i] = '\'' + (nameParts.size() > 1 ? nameParts[1] : nameParts[0]) + '\'';
        }
        String q = query.replace('xxxxx', String.join(names, ','));

        String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_STACK_TRACE, corg.Name, String.join(names, ''));
        Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_STACK_TRACE, keyCache);
        Object cacheObject;

        if(isCacheAvailableForKey) {
            cacheObject = CacheUtils.getCacheValue(keyCache);

            if(cacheObject != null) {
                List<ApexClassWrapper> cachedValue = (List<ApexClassWrapper>)cacheObject;
                for (ApexClassWrapper ac : cachedValue) {
                    itemsMap.put(ac.NamespacePrefix != null ? ac.NamespacePrefix + '.' + ac.Name : ac.Name, ac);
                }
            }
        }

        if(cacheObject == null) {
            String b = HttpUtils.get(
                corg.Instance_Url__c + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + q,
                getHeaders(),
                200
            );

            ApexClassesResponseWrapper result = (ApexClassesResponseWrapper)JSON.deserialize(b, ApexClassesResponseWrapper.class);
            for (ApexClassWrapper ac : result.records) {
                itemsMap.put(ac.NamespacePrefix != null ? ac.NamespacePrefix + '.' + ac.Name : ac.Name, ac);
            }

            if(isCacheAvailableForKey) {
                CacheUtils.putCacheValue(keyCache, result.records, CacheUtils.getTTLValue(CacheUtils.KEY_REQUEST_STACK_TRACE));
            }
        }
        return itemsMap;
    }

    public class StackTraceParseResult {
        public String type; // class, trigger
        public String id;
        public Integer lineNumber;
        public String className;
        public String hunk;
        public Integer hunkFirstLineNumber;
    }

    public class ApexClassesResponseWrapper {
        public Integer size;
        public List<ApexClassWrapper> records;
    }

    public class ApexClassWrapper {
        public String Id;
        public String Name;
        public String Body;
        public String NamespacePrefix;
    }

    public class StackTraceParserException extends Exception {}
    
}