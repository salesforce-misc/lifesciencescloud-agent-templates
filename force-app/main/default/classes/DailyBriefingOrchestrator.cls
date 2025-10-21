/**
 * Daily Briefing Orchestrator - Single invocable method that orchestrates
 * the entire daily briefing generation process
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public with sharing class DailyBriefingOrchestrator {
    
    /**
     * Main invocable method that orchestrates the complete daily briefing process
     * Automatically uses the current user's context
     */
    @InvocableMethod(label='Generate Complete Daily Briefing' description='Orchestrates the complete daily briefing generation process including data retrieval and AI formatting')
    public static List<String> generateCompleteDailyBriefing(List<DailyBriefingRequest> requests) {
        List<String> results = new List<String>();
        
        for (DailyBriefingRequest request : requests) {
            try {
                System.debug('=== DAILY BRIEFING ORCHESTRATOR START ===');
                
                // Step 1: Get user context (use provided userId or current user)
                String currentUserId = String.isNotBlank(request.userId) ? request.userId : UserInfo.getUserId();
                System.debug('User ID: ' + currentUserId + (String.isNotBlank(request.userId) ? ' (provided)' : ' (current user)'));
                System.debug('Target Date: ' + request.targetDate);
                System.debug('Focus: ' + request.focus);
                
                // Step 2: Get user context
                User currentUser = getUserContext(currentUserId);
                if (currentUser == null) {
                    results.add('Error: Current user not found');
                    continue;
                }
                
                // Step 3: Get user territory
                String userTerritoryId = DailyBriefingAgent.getUserTerritory(currentUserId);
                if (String.isBlank(userTerritoryId)) {
                    results.add('Error: No territory assigned to current user');
                    continue;
                }
                
                // Step 4: Generate the complete briefing using DailyBriefingAgent
                BriefingResponse briefingResponse = DailyBriefingAgent.generateDailyBriefing(currentUserId, request.targetDate, request.focus);
                System.debug('Generated briefing with confidence: ' + briefingResponse.confidence);
                
                results.add(briefingResponse.briefing);
                System.debug('=== DAILY BRIEFING ORCHESTRATOR COMPLETE ===');
                
            } catch (Exception e) {
                System.debug('Error in Daily Briefing Orchestrator: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
                results.add('Error generating briefing: ' + e.getMessage());
            }
        }
        
        return results;
    }
    
    
    /**
     * Get user context information
     */
    private static User getUserContext(String userId) {
        try {
            return [
                SELECT Id, Name, Email
                FROM User 
                WHERE Id = :userId 
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('Error getting user context: ' + e.getMessage());
            return null;
        }
    }
    
    
    /**
     * Request wrapper class for Daily Briefing invocable method
     */
    public class DailyBriefingRequest {
        @InvocableVariable(label='User ID' description='Salesforce User ID (optional - will use current user if not provided)' required=false)
        public String userId;
        
        @InvocableVariable(label='Target Date' description='Date for briefing generation' required=true)
        public Date targetDate;
        
        @InvocableVariable(label='Focus' description='Focus area for the briefing' required=false)
        public String focus;
    }
}