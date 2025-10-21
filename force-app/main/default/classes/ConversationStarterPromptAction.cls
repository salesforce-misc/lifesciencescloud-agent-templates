/**
 * Conversation Starter Prompt Action - Invokes the Conversation Starters Prompt template
 * to generate personalized conversation starters based on account summary information
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public with sharing class ConversationStarterPromptAction {
    
    /**
     * Request wrapper for conversation starter generation
     */
    public class ConversationStarterRequest {
        @InvocableVariable(label='Account Name' description='Name of the account' required=true)
        public String accountName;
        
        @InvocableVariable(label='Account ID' description='Salesforce Account ID' required=false)
        public String accountId;
        
        @InvocableVariable(label='Strategic Focus' description='Strategic focus area of the account' required=false)
        public String strategicFocus;
        
        @InvocableVariable(label='Priority Level' description='Priority level of the account' required=false)
        public String priorityLevel;
        
        @InvocableVariable(label='Key Information' description='Key information about the account' required=false)
        public String keyInformation;
        
        @InvocableVariable(label='Recent Activity' description='Recent activity information' required=false)
        public String recentActivity;
        
        @InvocableVariable(label='Key Contacts' description='Key contacts at the account' required=false)
        public String keyContacts;
        
        @InvocableVariable(label='Priority Reason' description='Reason for priority status' required=false)
        public String priorityReason;
        
        @InvocableVariable(label='Account Summary' description='Complete account summary information' required=true)
        public String accountSummary;
    }
    
    /**
     * Response wrapper for conversation starter generation
     */
    public class ConversationStarterResponse {
        @InvocableVariable(label='Conversation Starters' description='Generated conversation starters')
        public String conversationStarters;
        
        @InvocableVariable(label='Success' description='Whether the generation was successful')
        public Boolean success;
        
        @InvocableVariable(label='Error Message' description='Error message if generation failed')
        public String errorMessage;
    }
    
    /**
     * Main invocable method that generates conversation starters using the prompt template
     */
    @InvocableMethod(label='Generate Conversation Starters with Prompt' description='Generates personalized conversation starters using the Conversation Starters Prompt template')
    public static List<ConversationStarterResponse> generateConversationStarters(List<ConversationStarterRequest> requests) {
        List<ConversationStarterResponse> responses = new List<ConversationStarterResponse>();
        
        for (ConversationStarterRequest request : requests) {
            ConversationStarterResponse response = processConversationStarterRequest(request);
            responses.add(response);
        }
        
        return responses;
    }
    
    /**
     * Processes a single conversation starter request to reduce cognitive complexity
     */
    public static ConversationStarterResponse processConversationStarterRequest(ConversationStarterRequest request) {
        ConversationStarterResponse response = new ConversationStarterResponse();
        
        try {
            System.debug('=== CONVERSATION STARTER PROMPT ACTION START ===');
            System.debug('Account Name: ' + request.accountName);
            System.debug('Account ID: ' + request.accountId);
            
            // Prepare the prompt template variables
            Map<String, Object> promptVariables = preparePromptVariables(request);
            
            // Invoke the prompt template
            String promptResponse = invokePromptTemplate('Conversation_Starters_Prompt', promptVariables);
            
            if (String.isNotBlank(promptResponse)) {
                response.conversationStarters = promptResponse;
                response.success = true;
                System.debug('Successfully generated conversation starters: ' + promptResponse);
            } else {
                response.success = false;
                response.errorMessage = 'No response received from prompt template';
                System.debug('No response from prompt template');
            }
            
        } catch (Exception e) {
            System.debug('Error in Conversation Starter Prompt Action: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            response.success = false;
            response.errorMessage = 'Error generating conversation starters: ' + e.getMessage();
        }
        
        System.debug('=== CONVERSATION STARTER PROMPT ACTION COMPLETE ===');
        return response;
    }
    
    /**
     * Prepares prompt template variables from the request
     */
    private static Map<String, Object> preparePromptVariables(ConversationStarterRequest request) {
        Map<String, Object> promptVariables = new Map<String, Object>();
        // Use the correct parameter names that the prompt template expects (with double Input: prefix)
        promptVariables.put('Input:Input_AccountName', String.isNotBlank(request.accountName) ? request.accountName : 'Account');
        promptVariables.put('Input:Input_StrategicFocus', String.isNotBlank(request.strategicFocus) ? request.strategicFocus : 'Not specified');
        promptVariables.put('Input:Input_PriorityLevel', String.isNotBlank(request.priorityLevel) ? request.priorityLevel : 'Not specified');
        promptVariables.put('Input:Input_KeyInformation', String.isNotBlank(request.keyInformation) ? request.keyInformation : 'No key information available');
        promptVariables.put('Input:Input_RecentActivity', String.isNotBlank(request.recentActivity) ? request.recentActivity : 'No recent activity information');
        promptVariables.put('Input:Input_KeyContacts', String.isNotBlank(request.keyContacts) ? request.keyContacts : 'No key contacts specified');
        promptVariables.put('Input:Input_PriorityReason', String.isNotBlank(request.priorityReason) ? request.priorityReason : 'Not specified');
        promptVariables.put('Input:Input_AccountSummary', String.isNotBlank(request.accountSummary) ? request.accountSummary : 'No account summary available');
        return promptVariables;
    }
    
    /**
     * Invoke a prompt template with the given variables
     * This method uses the ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate method
     */
    private static String invokePromptTemplate(String templateName, Map<String, Object> variables) {
        try {
            System.debug('Invoking prompt template: ' + templateName);
            System.debug('Variables: ' + JSON.serialize(variables));
            
            // Create input parameters for the prompt template
            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
            
            // Add each variable as a WrappedValue
            for (String key : variables.keySet()) {
                ConnectApi.WrappedValue wrappedValue = new ConnectApi.WrappedValue();
                wrappedValue.value = variables.get(key);
                inputParams.put(key, wrappedValue);
            }
            
            // Configure invocation parameters
            ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
            executeTemplateInput.isPreview = false;
            executeTemplateInput.inputParams = inputParams;
            
            // Call the Einstein Prompt Template service
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(templateName, executeTemplateInput);
            
            if (generationsOutput.generations != null && !generationsOutput.generations.isEmpty()) {
                ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
                System.debug('Successfully generated response from prompt template');
                System.debug('Response text: ' + response.text);
                return response.text;
            } else {
                System.debug('No generations returned from prompt template');
                System.debug('Generations output: ' + JSON.serialize(generationsOutput));
                return generateFallbackStarters(variables);
            }
            
        } catch (ConnectApi.ConnectApiException e) {
            System.debug('ConnectApi error invoking prompt template: ' + e.getMessage());
            System.debug('Error code: ' + e.getErrorCode());
            return generateFallbackStarters(variables);
        } catch (Exception e) {
            System.debug('General error invoking prompt template: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return generateFallbackStarters(variables);
        }
    }
    
    /**
     * Generate fallback conversation starters when prompt template is not available
     */
    private static String generateFallbackStarters(Map<String, Object> variables) {
        String accountName = (String) variables.get('AccountName');
        String strategicFocus = (String) variables.get('StrategicFocus');
        String priorityLevel = (String) variables.get('PriorityLevel');
        String keyInformation = (String) variables.get('KeyInformation');
        String recentActivity = (String) variables.get('RecentActivity');
        
        List<String> starters = new List<String>();
        
        // Generate conversation starters based on available information
        if (String.isNotBlank(strategicFocus) && !strategicFocus.equals('Not specified')) {
            starters.add('I wanted to discuss your ' + strategicFocus + ' strategy and explore how our solutions can support your goals in this area.');
        }
        
        if (String.isNotBlank(priorityLevel) && !priorityLevel.equals('Not specified')) {
            starters.add('Given your ' + priorityLevel + ' priority status, I\'d like to explore new opportunities for collaboration and support.');
        }
        
        if (String.isNotBlank(recentActivity) && !recentActivity.equals('No recent activity information')) {
            starters.add('I see you\'ve been active recently with ' + recentActivity + '. How has that been working for you?');
        }
        
        // Add generic starters if we don't have enough specific ones
        if (starters.size() < 3) {
            starters.add('What are your current priorities and how can we help you achieve them?');
            starters.add('I\'d like to understand your goals for this quarter and explore how we can support your success.');
            starters.add('How has your experience been with our recent interactions, and what can we do to improve?');
        }
        
        // Format the response as numbered list
        String response = '';
        for (Integer i = 0; i < Math.min(3, starters.size()); i++) {
            response += (i + 1) + '. ' + starters[i] + '\n';
        }
        
        return response.trim();
    }
}
