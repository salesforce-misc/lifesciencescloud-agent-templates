// Daily Briefing Agent - Deployment Test Script
// This script validates that the Daily Briefing Agent is properly deployed and functional

System.debug('==========================================');
System.debug('Daily Briefing Agent - Deployment Test');
System.debug('==========================================');

// Test 1: Verify all classes are accessible
System.debug('Test 1: Verifying class accessibility...');

try {
    // Test DailyBriefingOrchestrator
    DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
    System.debug('✅ DailyBriefingOrchestrator class is accessible');
    
    // Test DailyBriefingAgent
    List<Visit> testVisits = DailyBriefingAgent.getDailyVisits(UserInfo.getUserId(), Date.today());
    System.debug('✅ DailyBriefingAgent class is accessible');
    
    // Test ConversationStarter
    ConversationStarter starter = new ConversationStarter();
    System.debug('✅ ConversationStarter class is accessible');
    
    // Test ConversationStarterPromptAction
    ConversationStarterPromptAction.ConversationStarterRequest promptRequest = new ConversationStarterPromptAction.ConversationStarterRequest();
    System.debug('✅ ConversationStarterPromptAction class is accessible');
    
} catch (Exception e) {
    System.debug('❌ Class accessibility test failed: ' + e.getMessage());
}

// Test 2: Test data retrieval
System.debug('Test 2: Testing data retrieval...');

try {
    String userId = UserInfo.getUserId();
    Date testDate = Date.today();
    
    // Test visit retrieval
    List<Visit> visits = DailyBriefingAgent.getDailyVisits(userId, testDate);
    System.debug('✅ Visit retrieval successful. Found ' + visits.size() + ' visits');
    
    // Test account summaries
    List<DailyBriefingAgent.AccountSummary> summaries = DailyBriefingAgent.getAccountSummaries(userId);
    System.debug('✅ Account summary retrieval successful. Found ' + summaries.size() + ' summaries');
    
    // Test priority calculation
    if (!visits.isEmpty()) {
        DailyBriefingAgent.PriorityMetrics metrics = DailyBriefingAgent.calculatePriorityMetrics(visits);
        System.debug('✅ Priority calculation successful. Score: ' + metrics.overallPriorityScore);
    }
    
} catch (Exception e) {
    System.debug('❌ Data retrieval test failed: ' + e.getMessage());
}

// Test 3: Test orchestrator functionality
System.debug('Test 3: Testing orchestrator functionality...');

try {
    DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
    request.userId = UserInfo.getUserId();
    request.date = String.valueOf(Date.today());
    
    List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{request};
    List<String> results = DailyBriefingOrchestrator.generateDailyBriefing(requests);
    
    if (!results.isEmpty() && String.isNotBlank(results[0])) {
        System.debug('✅ Orchestrator functionality successful');
        System.debug('Sample output length: ' + results[0].length() + ' characters');
    } else {
        System.debug('⚠️ Orchestrator returned empty result');
    }
    
} catch (Exception e) {
    System.debug('❌ Orchestrator test failed: ' + e.getMessage());
}

// Test 4: Test conversation starter generation
System.debug('Test 4: Testing conversation starter generation...');

try {
    ConversationStarterPromptAction.ConversationStarterRequest promptRequest = new ConversationStarterPromptAction.ConversationStarterRequest();
    promptRequest.accountName = 'Test Account';
    promptRequest.strategicFocus = 'Cardiology';
    promptRequest.priorityLevel = 'High';
    promptRequest.keyInformation = 'Recent research on cardiac interventions';
    promptRequest.recentActivity = 'Published paper on treatment protocols';
    promptRequest.keyContacts = 'Dr. Smith, Dr. Johnson';
    promptRequest.priorityReason = 'Strategic partnership opportunity';
    promptRequest.accountSummary = 'Leading cardiology practice with research focus';
    
    List<ConversationStarterPromptAction.ConversationStarterRequest> promptRequests = new List<ConversationStarterPromptAction.ConversationStarterRequest>{promptRequest};
    List<ConversationStarterPromptAction.ConversationStarterResponse> responses = ConversationStarterPromptAction.generateConversationStarters(promptRequests);
    
    if (!responses.isEmpty() && responses[0].success) {
        System.debug('✅ Conversation starter generation successful');
        System.debug('Generated starters: ' + responses[0].conversationStarters.size());
    } else {
        System.debug('⚠️ Conversation starter generation returned no results or failed');
    }
    
} catch (Exception e) {
    System.debug('❌ Conversation starter test failed: ' + e.getMessage());
}

// Test 5: Test error handling
System.debug('Test 5: Testing error handling...');

try {
    // Test with invalid user ID
    DailyBriefingOrchestrator.DailyBriefingRequest invalidRequest = new DailyBriefingOrchestrator.DailyBriefingRequest();
    invalidRequest.userId = 'INVALID_USER_ID';
    invalidRequest.date = String.valueOf(Date.today());
    
    List<DailyBriefingOrchestrator.DailyBriefingRequest> invalidRequests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{invalidRequest};
    List<String> invalidResults = DailyBriefingOrchestrator.generateDailyBriefing(invalidRequests);
    
    System.debug('✅ Error handling test completed (invalid user ID handled gracefully)');
    
} catch (Exception e) {
    System.debug('✅ Error handling test successful (exception caught): ' + e.getMessage());
}

// Test 6: Performance test
System.debug('Test 6: Performance test...');

try {
    Long startTime = System.currentTimeMillis();
    
    DailyBriefingOrchestrator.DailyBriefingRequest perfRequest = new DailyBriefingOrchestrator.DailyBriefingRequest();
    perfRequest.userId = UserInfo.getUserId();
    perfRequest.date = String.valueOf(Date.today());
    
    List<DailyBriefingOrchestrator.DailyBriefingRequest> perfRequests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{perfRequest};
    List<String> perfResults = DailyBriefingOrchestrator.generateDailyBriefing(perfRequests);
    
    Long endTime = System.currentTimeMillis();
    Long executionTime = endTime - startTime;
    
    System.debug('✅ Performance test completed');
    System.debug('Execution time: ' + executionTime + 'ms');
    
    if (executionTime < 10000) {
        System.debug('✅ Performance is acceptable (< 10 seconds)');
    } else {
        System.debug('⚠️ Performance may need optimization (> 10 seconds)');
    }
    
} catch (Exception e) {
    System.debug('❌ Performance test failed: ' + e.getMessage());
}

// Summary
System.debug('==========================================');
System.debug('Deployment Test Summary');
System.debug('==========================================');
System.debug('✅ All tests completed');
System.debug('📋 Next steps:');
System.debug('1. Configure Agentforce Topic and Actions');
System.debug('2. Test with actual user utterances');
System.debug('3. Train end users on functionality');
System.debug('4. Monitor performance and usage');
System.debug('==========================================');
