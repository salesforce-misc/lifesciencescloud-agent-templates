/**
 * Invocable Action for generating conversation starters
 * Used by Agentforce Actions
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public with sharing class GenerateConversationStartersAction {
    
    /**
     * Invocable method to generate conversation starters for Agentforce Actions
     */
    @InvocableMethod(label='Generate Conversation Starters' description='Generates conversation starters for account visits')
    public static List<String> generateConversationStarters(List<ConversationStartersRequest> requests) {
        List<String> results = new List<String>();
        for (ConversationStartersRequest request : requests) {
            List<ConversationStarter> starters = DailyBriefingAgent.generateConversationStarters(
                request.accountSummary, 
                request.visitHistory, 
                request.context
            );
            for (ConversationStarter starter : starters) {
                results.add(JSON.serialize(starter));
            }
        }
        return results;
    }
    
    /**
     * Request wrapper class for Conversation Starters invocable method
     */
    public class ConversationStartersRequest {
        @InvocableVariable(label='Account Summary' description='Account summary information' required=true)
        public String accountSummary;
        
        @InvocableVariable(label='Visit History' description='Recent visit history for the account' required=false)
        public String visitHistory;
        
        @InvocableVariable(label='Context' description='Additional context for conversation starters' required=false)
        public String context;
    }
}
