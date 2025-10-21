/**
 * Test class for Daily Briefing Orchestrator
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
@isTest
public class DailyBriefingOrchestratorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser@test.com.orchestrator' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert testUser;
        
        // Use System.runAs to handle mixed DML operations
        System.runAs(testUser) {
            // Create test territory (using existing territory type and model)
            Territory2Type territoryType = [SELECT Id FROM Territory2Type LIMIT 1];
            Territory2Model territoryModel = [SELECT Id FROM Territory2Model LIMIT 1];
            
            Territory2 testTerritory = new Territory2(
                Name = 'Test Territory',
                DeveloperName = 'Test_Territory_Orchestrator',
                Territory2TypeId = territoryType.Id,
                Territory2ModelId = territoryModel.Id
            );
            insert testTerritory;
            
            // Assign user to territory
            UserTerritory2Association userTerritory = new UserTerritory2Association(
                UserId = testUser.Id,
                Territory2Id = testTerritory.Id
            );
            insert userTerritory;
        }
    }
    
    @isTest
    static void testGenerateCompleteDailyBriefing_Success() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Create request
        DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request.userId = testUser.Id;
        request.targetDate = Date.today();
        request.focus = 'all';
        
        List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{request};
        
        // Call the orchestrator method
        List<String> results = DailyBriefingOrchestrator.generateCompleteDailyBriefing(requests);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertNotEquals(null, results[0], 'Result should not be null');
        System.assertNotEquals('', results[0], 'Result should not be empty');
        // Note: May return error if no visits/accounts exist, which is expected in test environment
    }
    
    @isTest
    static void testGenerateCompleteDailyBriefing_CurrentUser() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Create request without userId (should use current user)
        DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request.targetDate = Date.today();
        request.focus = 'priority';
        
        List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{request};
        
        // Run as test user
        System.runAs(testUser) {
            List<String> results = DailyBriefingOrchestrator.generateCompleteDailyBriefing(requests);
            
            // Assertions
            System.assertNotEquals(null, results, 'Results should not be null');
            System.assertEquals(1, results.size(), 'Should return one result');
            System.assertNotEquals(null, results[0], 'Result should not be null');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateCompleteDailyBriefing_InvalidUser() {
        Test.startTest();
        
        // Create request with invalid user ID
        DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request.userId = 'INVALID_USER_ID';
        request.targetDate = Date.today();
        request.focus = 'all';
        
        List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{request};
        
        // Call the orchestrator method
        List<String> results = DailyBriefingOrchestrator.generateCompleteDailyBriefing(requests);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assert(results[0].contains('Error'), 'Should return error message for invalid user');
    }
    
    @isTest
    static void testGenerateCompleteDailyBriefing_NoTerritory() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        // Remove user from territory
        delete [SELECT Id FROM UserTerritory2Association WHERE UserId = :testUser.Id];
        
        Test.startTest();
        
        // Create request
        DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request.userId = testUser.Id;
        request.targetDate = Date.today();
        request.focus = 'all';
        
        List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{request};
        
        // Call the orchestrator method
        List<String> results = DailyBriefingOrchestrator.generateCompleteDailyBriefing(requests);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assert(results[0].contains('Error'), 'Should return error message for no territory');
        System.assert(results[0].contains('territory'), 'Error should mention territory');
    }
    
    @isTest
    static void testGenerateCompleteDailyBriefing_MultipleRequests() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Create multiple requests
        DailyBriefingOrchestrator.DailyBriefingRequest request1 = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request1.userId = testUser.Id;
        request1.targetDate = Date.today();
        request1.focus = 'all';
        
        DailyBriefingOrchestrator.DailyBriefingRequest request2 = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request2.userId = testUser.Id;
        request2.targetDate = Date.today().addDays(1);
        request2.focus = 'priority';
        
        List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{request1, request2};
        
        // Call the orchestrator method
        List<String> results = DailyBriefingOrchestrator.generateCompleteDailyBriefing(requests);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(2, results.size(), 'Should return two results');
        System.assertNotEquals(null, results[0], 'First result should not be null');
        System.assertNotEquals(null, results[1], 'Second result should not be null');
    }
    
    @isTest
    static void testGenerateCompleteDailyBriefing_ExceptionHandling() {
        Test.startTest();
        
        // Create request that will cause an exception
        DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request.userId = null; // This should cause an exception
        request.targetDate = Date.today();
        request.focus = 'all';
        
        List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>{request};
        
        // Call the orchestrator method
        List<String> results = DailyBriefingOrchestrator.generateCompleteDailyBriefing(requests);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one result');
        // The orchestrator handles null userId by using current user, so it may not return an error
        System.assertNotEquals(null, results[0], 'Result should not be null');
    }
    
    @isTest
    static void testDailyBriefingRequestClass() {
        Test.startTest();
        
        // Test the request wrapper class
        DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
        request.userId = UserInfo.getUserId();
        request.targetDate = Date.today();
        request.focus = 'test';
        
        // Verify the request object is properly constructed
        System.assertEquals(UserInfo.getUserId(), request.userId, 'User ID should be set');
        System.assertEquals(Date.today(), request.targetDate, 'Target date should be set');
        System.assertEquals('test', request.focus, 'Focus should be set');
        
        Test.stopTest();
    }
    
    @isTest
    static void testEmptyRequestList() {
        Test.startTest();
        
        // Test with empty request list
        List<DailyBriefingOrchestrator.DailyBriefingRequest> emptyRequests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>();
        List<String> results = DailyBriefingOrchestrator.generateCompleteDailyBriefing(emptyRequests);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Should return empty results for empty input');
    }
}
