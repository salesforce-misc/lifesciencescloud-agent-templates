/**
 * Test class for Daily Briefing Agent
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
@isTest
public class DailyBriefingAgentTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser@test.com.dailybriefing' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert testUser;
        
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Hospital',
            Type = 'Hospital'
        );
        insert testAccount;
        
        // Use System.runAs to handle mixed DML operations
        System.runAs(testUser) {
            // Create test territory (using existing territory type and model)
            Territory2Type territoryType = [SELECT Id FROM Territory2Type LIMIT 1];
            Territory2Model territoryModel = [SELECT Id FROM Territory2Model LIMIT 1];
            
            Territory2 testTerritory = new Territory2(
                Name = 'Test Territory',
                DeveloperName = 'Test_Territory',
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
            // Create test visit
            Visit testVisit = new Visit(
                AccountId = testAccount.Id,
                VisitorId = testUser.Id,
                PlannedVisitStartTime = DateTime.now().addHours(2),
                PlannedVisitEndTime = DateTime.now().addHours(3),
                Status = 'Planned',
                InstructionDescription = 'Test Visit Description',
                PlaceId = '8lWYH000000ccKP2AY' // Use existing PlaceId
            );
            insert testVisit;
            
            // Create test provider visit
            ProviderVisit testProviderVisit = new ProviderVisit(
                VisitId = testVisit.Id,
                IsAdhocProviderVisit = false,
                IsOfflineModeSignature = false,
                IsSignedAwayFrmAllowDstn = false,
                IsBackdatedSgnVldSkipped = false,
                IsOfflineModeSubmit = false,
                IsSubmitAwayFrmAllowDstn = false,
                IsBackdatedSbmtVldSkipped = false,
                HasAttachments = false,
                IsConfirmed = true,
                PreProviderVisitNotes = 'Test pre-visit notes',
                AdditionalInformation = 'Test additional information',
                NextProviderVisitObjective = 'Test objective'
            );
            insert testProviderVisit;
            
            // Create test provider account territory summary
            PrvdAccountTerritorySummary testSummary = new PrvdAccountTerritorySummary(
                AccountId = testAccount.Id,
                Territory2Id = testTerritory.Id,
                UserId = testUser.Id,
                KeyInformationSummary = 'Test Hospital is a 500-bed teaching hospital serving the test area. Dr. Test is the primary decision maker.'
            );
            insert testSummary;
        }
    }
    
    @isTest
    static void testGenerateDailyBriefing_Success() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Call the method
        BriefingResponse response = DailyBriefingAgent.generateDailyBriefing(
            testUser.Id, 
            Date.today(), 
            'all'
        );
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.briefing, 'Briefing should not be null');
        System.assert(response.briefing.contains('Test Hospital'), 'Briefing should contain account name');
        System.assert(response.briefing.contains('Test User'), 'Briefing should contain user name');
        System.assertEquals(0.85, response.confidence, 'Confidence should be 0.85');
        System.assertEquals('High', response.dataQuality, 'Data quality should be High');
        System.assertNotEquals(null, response.recommendations, 'Recommendations should not be null');
        System.assert(response.recommendations.size() > 0, 'Should have recommendations');
    }
    
    @isTest
    static void testGenerateDailyBriefing_NoVisits() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        // Delete the test visit
        delete [SELECT Id FROM Visit WHERE VisitorId = :testUser.Id];
        
        Test.startTest();
        
        // Call the method
        BriefingResponse response = DailyBriefingAgent.generateDailyBriefing(
            testUser.Id, 
            Date.today(), 
            'all'
        );
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.briefing, 'Briefing should not be null');
        System.assert(response.briefing.contains('No visits scheduled'), 'Should indicate no visits');
        System.assertEquals(1.0, response.confidence, 'Confidence should be 1.0 for empty response');
        System.assertEquals('Complete', response.dataQuality, 'Data quality should be Complete');
    }
    
    @isTest
    static void testGenerateDailyBriefing_InvalidUser() {
        Test.startTest();
        
        try {
            DailyBriefingAgent.generateDailyBriefing('invalid_user_id', Date.today(), 'all');
            System.assert(false, 'Should have thrown an exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('User not found') || e.getMessage().contains('Error generating briefing'), 'Should indicate user not found');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateDailyBriefing_NoTerritory() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        // Remove user from territory
        delete [SELECT Id FROM UserTerritory2Association WHERE UserId = :testUser.Id];
        
        Test.startTest();
        
        try {
            DailyBriefingAgent.generateDailyBriefing(testUser.Id, Date.today(), 'all');
            System.assert(false, 'Should have thrown an exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('No territory assigned') || e.getMessage().contains('Error generating briefing'), 'Should indicate no territory');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateDailyBriefing_NullDate() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Call the method with null date
        BriefingResponse response = DailyBriefingAgent.generateDailyBriefing(
            testUser.Id, 
            null, 
            'all'
        );
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.briefing, 'Briefing should not be null');
        System.assert(response.briefing.contains(Date.today().format()), 'Should use today\'s date');
    }
    
    @isTest
    static void testGenerateDailyBriefing_DifferentFocus() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Test different focus values
        BriefingResponse response1 = DailyBriefingAgent.generateDailyBriefing(
            testUser.Id, 
            Date.today(), 
            'priority'
        );
        
        BriefingResponse response2 = DailyBriefingAgent.generateDailyBriefing(
            testUser.Id, 
            Date.today(), 
            'visits'
        );
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response1, 'Priority response should not be null');
        System.assertNotEquals(null, response2, 'Visits response should not be null');
    }
}
