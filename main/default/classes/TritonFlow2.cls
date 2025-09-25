public with sharing class TritonFlow2 {
    
    @InvocableMethod(label='After Flow Screen Log' description='Log details after a flow screen execution')
    public static void logDetails(List<FlowLogInput> inputs) {
        // No logic required, this is just a placeholder
    }

    // Inner class to define the input parameters
    public class FlowLogInput {
        @InvocableVariable(label='Area' description='The area of the flow' required=true)
        public String area;
        
        @InvocableVariable(label='Category' description='The category of the log' required=true)
        public String category;
        
        @InvocableVariable(label='Details' description='Additional details about the log')
        public String details;
        
        @InvocableVariable(label='Flow API Name' description='API name of the flow' required=true)
        public String flowApiName;
        
        @InvocableVariable(label='Interview GUID' description='Flow Interview GUID')
        public String interviewGUID;
        
        @InvocableVariable(label='Level' description='Log level (e.g., DEBUG, INFO)' required=true)
        public String level;
        
        @InvocableVariable(label='Summary' description='Summary of the log')
        public String summary;
        
        @InvocableVariable(label='Type' description='Type of the flow' required=true)
        public String type;
    }
}