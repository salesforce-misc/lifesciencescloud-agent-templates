/**
 * Daily Briefing Agent - Main class for generating on-demand daily briefings
 * for field sales representatives using Agentforce integration
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public with sharing class DailyBriefingAgent {
    
    // Supported time periods for flexible briefing generation
    private static final Set<String> SUPPORTED_TIME_PERIODS = new Set<String>{
        'Today', 'Tomorrow', 'This Week', 'Next Week', 'This Month', 'Next Month'
    };
    
    /**
     * Main method to generate daily briefing for a user
     * @param userId - Salesforce User ID
     * @param targetDate - Date for the briefing (defaults to today)
     * @param focus - Optional focus parameter (all, priority, visits, accounts)
     * @return BriefingResponse - Complete briefing data
     */
    @AuraEnabled(cacheable=false)
    public static BriefingResponse generateDailyBriefing(String userId, Date targetDate, String focus) {
        try {
            // Validate inputs
            if (String.isBlank(userId)) {
                throw new IllegalArgumentException('User ID is required');
            }
            
            if (targetDate == null) {
                targetDate = Date.today();
            }
            
            if (String.isBlank(focus)) {
                focus = 'all';
            }
            
            System.debug('=== DAILY BRIEFING AGENT START ===');
            System.debug('User ID: ' + userId);
            System.debug('Target Date: ' + targetDate);
            System.debug('Focus: ' + focus);
            
            // Get user context
            User currentUser = getUserContext(userId);
            if (currentUser == null) {
                throw new IllegalArgumentException('User not found: ' + userId);
            }
            
            // Get user's territory
            String userTerritoryId = getUserTerritory(userId);
            if (String.isBlank(userTerritoryId)) {
                throw new IllegalArgumentException('No territory assigned to user: ' + userId);
            }
            
            // Retrieve daily visits
            List<Visit> dailyVisits = getDailyVisits(userId, targetDate);
            System.debug('Found ' + dailyVisits.size() + ' visits for ' + targetDate);
            
            if (dailyVisits.isEmpty()) {
                return createEmptyBriefingResponse(currentUser, targetDate, 'No visits scheduled for ' + targetDate.format());
            }
            
            // Get provider visit details
            List<ProviderVisit> providerVisits = getProviderVisitDetails(dailyVisits);
            System.debug('Found ' + providerVisits.size() + ' provider visit details');
            
            // Get contact point addresses for places
            Map<Id, String> placeAddresses = getContactPointAddresses(dailyVisits);
            System.debug('Found ' + placeAddresses.size() + ' contact point addresses');
            
            // Get account territory summaries
            List<AccountSummary> accountSummaries = getAccountSummaries(dailyVisits, userTerritoryId, userId);
            System.debug('Found ' + accountSummaries.size() + ' account summaries');
            
            // Calculate priority metrics
            PriorityAssessment priority = calculatePriorityMetrics(dailyVisits);
            System.debug('Priority assessment completed');
            
            // Prepare data for Agentforce
            BriefingData briefingData = new BriefingData();
            briefingData.user = currentUser;
            briefingData.visits = dailyVisits;
            briefingData.providerVisits = providerVisits;
            briefingData.accountSummaries = accountSummaries;
            briefingData.priority = priority;
            briefingData.focus = focus;
            briefingData.targetDate = targetDate;
            briefingData.userTerritoryId = userTerritoryId;
            briefingData.userTerritoryName = getUserTerritoryName(userId);
            briefingData.placeAddresses = placeAddresses;
            
            // Call Agentforce API (simulated for now)
            BriefingResponse response = callAgentforceAPI(briefingData);
            
            System.debug('=== DAILY BRIEFING AGENT COMPLETE ===');
            return response;
            
        } catch (Exception e) {
            System.debug('Error in generateDailyBriefing: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new IllegalArgumentException('Error generating briefing: ' + e.getMessage());
        }
    }
    
    /**
     * Enhanced method to generate briefing for a flexible time period
     * @param userId - Salesforce User ID
     * @param timePeriod - Time period (Today, Tomorrow, This Week, Next Week, This Month, Next Month)
     * @param focus - Optional focus parameter (all, priority, visits, accounts)
     * @return BriefingResponse - Complete briefing data
     */
    @AuraEnabled(cacheable=false)
    public static BriefingResponse generateBriefing(String userId, String timePeriod, String focus) {
        try {
            // Validate inputs
            if (String.isBlank(userId)) {
                throw new IllegalArgumentException('User ID is required');
            }
            
            if (String.isBlank(timePeriod)) {
                timePeriod = 'Today';
            }
            
            if (String.isBlank(focus)) {
                focus = 'all';
            }
            
            // Validate time period
            validateTimePeriod(timePeriod);
            
            System.debug('=== FLEXIBLE BRIEFING AGENT START ===');
            System.debug('User ID: ' + userId);
            System.debug('Time Period: ' + timePeriod);
            System.debug('Focus: ' + focus);
            
            // Get user context
            User currentUser = getUserContext(userId);
            if (currentUser == null) {
                throw new IllegalArgumentException('User not found: ' + userId);
            }
            
            // Get user's territory
            String userTerritoryId = getUserTerritory(userId);
            if (String.isBlank(userTerritoryId)) {
                throw new IllegalArgumentException('No territory assigned to user: ' + userId);
            }
            
            // Retrieve visits for the time period
            List<Visit> visits = getVisitsForTimePeriod(userId, timePeriod);
            System.debug('Found ' + visits.size() + ' visits for ' + timePeriod);
            
            if (visits.isEmpty()) {
                return createEmptyBriefingResponseForPeriod(currentUser, timePeriod, 'No visits scheduled for ' + timePeriod);
            }
            
            // Get provider visit details
            List<ProviderVisit> providerVisits = getProviderVisitDetails(visits);
            System.debug('Found ' + providerVisits.size() + ' provider visit details');
            
            // Get contact point addresses for places
            Map<Id, String> placeAddresses = getContactPointAddresses(visits);
            System.debug('Found ' + placeAddresses.size() + ' contact point addresses');
            
            // Get account territory summaries
            List<AccountSummary> accountSummaries = getAccountSummaries(visits, userTerritoryId, userId);
            System.debug('Found ' + accountSummaries.size() + ' account summaries');
            
            // Calculate priority metrics
            PriorityAssessment priority = calculatePriorityMetrics(visits);
            System.debug('Priority assessment completed');
            
            // Prepare data for Agentforce
            BriefingData briefingData = new BriefingData();
            briefingData.user = currentUser;
            briefingData.visits = visits;
            briefingData.providerVisits = providerVisits;
            briefingData.accountSummaries = accountSummaries;
            briefingData.priority = priority;
            briefingData.focus = focus;
            briefingData.targetDate = Date.today(); // Keep for compatibility
            briefingData.userTerritoryId = userTerritoryId;
            briefingData.userTerritoryName = getUserTerritoryName(userId);
            briefingData.timePeriod = timePeriod; // Add time period context
            briefingData.placeAddresses = placeAddresses;
            
            // Call Agentforce API (simulated for now)
            BriefingResponse response = callAgentforceAPI(briefingData);
            
            System.debug('=== FLEXIBLE BRIEFING AGENT COMPLETE ===');
            return response;
            
        } catch (Exception e) {
            System.debug('Error in generateBriefing: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new IllegalArgumentException('Error generating briefing: ' + e.getMessage());
        }
    }
    
    /**
     * Validate time period parameter
     */
    private static void validateTimePeriod(String timePeriod) {
        if (!SUPPORTED_TIME_PERIODS.contains(timePeriod)) {
            throw new IllegalArgumentException('Unsupported time period: ' + timePeriod + 
                '. Supported periods: ' + String.join(new List<String>(SUPPORTED_TIME_PERIODS), ', '));
        }
    }
    
    /**
     * Get user context information
     */
    private static User getUserContext(String userId) {
        try {
            List<User> users = [
                SELECT Id, Name, Email, Profile.Name
                FROM User 
                WHERE Id = :userId 
                LIMIT 1
            ];
            return users.isEmpty() ? null : users[0];
        } catch (Exception e) {
            System.debug('Error getting user context: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Get user's territory ID
     */
    public static String getUserTerritory(String userId) {
        try {
            List<UserTerritory2Association> territories = [
                SELECT Territory2Id, Territory2.Name
                FROM UserTerritory2Association 
                WHERE UserId = :userId 
                LIMIT 1
            ];
            return territories.isEmpty() ? null : territories[0].Territory2Id;
        } catch (Exception e) {
            System.debug('Error getting user territory: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Get user's territory name
     */
    public static String getUserTerritoryName(String userId) {
        try {
            List<UserTerritory2Association> territories = [
                SELECT Territory2Id, Territory2.Name
                FROM UserTerritory2Association 
                WHERE UserId = :userId 
                LIMIT 1
            ];
            return territories.isEmpty() ? null : territories[0].Territory2.Name;
        } catch (Exception e) {
            System.debug('Error getting user territory name: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Get daily visits for a user and date based on territory and user ownership/assignment/creation
     * Step 1: Find the user's territory
     * Step 2: Find visits in that territory where user has ownership, assignment, or created the visit
     */
    public static List<Visit> getDailyVisits(String userId, Date targetDate) {
        try {
            // Step 1: Get the user's territory
            String userTerritoryId = getUserTerritory(userId);
            if (String.isBlank(userTerritoryId)) {
                System.debug('No territory found for user: ' + userId);
                return new List<Visit>();
            }
            
            System.debug('User territory ID: ' + userTerritoryId);
            
        // Step 2: Get visits for the user's territory where user has ownership/assignment
        // Only include visits where:
        // 1. Visit is in the user's territory (TerritoryId = userTerritoryId)
        // 2. User has ownership, assignment, or created the visit (OwnerId, VisitorId, UserId, or CreatedById = userId)
        // 3. Visit is a parent visit (ParentVisitId = null)
        return [
            SELECT Id, StatusRemarks, AccountId, Account.Name, Account.Type,
                   PlannedVisitStartTime, PlannedVisitEndTime, Status, 
                   InstructionDescription, VisitorId, PlaceId, Place.Name,
                   OwnerId, UserId, TerritoryId, CreatedById, ParentVisitId
            FROM Visit 
            WHERE TerritoryId = :userTerritoryId
            AND (OwnerId = :userId OR VisitorId = :userId OR UserId = :userId OR CreatedById = :userId)
            AND ParentVisitId = null
            AND DAY_ONLY(PlannedVisitStartTime) = :targetDate
            ORDER BY PlannedVisitStartTime
        ];
        } catch (Exception e) {
            System.debug('Error getting daily visits: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return new List<Visit>();
        }
    }
    
    /**
     * Get visits for a user and time period based on territory and user ownership/assignment/creation using VisitDateRangeAction
     * @param userId - Salesforce User ID
     * @param timePeriod - Time period (Today, Tomorrow, This Week, Next Week, This Month, Next Month)
     * @return List<Visit> - Visits for the specified time period in user's territory where user has ownership/assignment/creation
     */
    public static List<Visit> getVisitsForTimePeriod(String userId, String timePeriod) {
        try {
            // Step 1: Get the user's territory
            String userTerritoryId = getUserTerritory(userId);
            if (String.isBlank(userTerritoryId)) {
                System.debug('No territory found for user: ' + userId);
                return new List<Visit>();
            }
            
            System.debug('User territory ID: ' + userTerritoryId);
            System.debug('Time period: ' + timePeriod);
            
            // Step 2: Calculate date range using VisitDateRangeAction
            List<VisitDateRangeAction.DateRangeResult> dateRanges = 
                VisitDateRangeAction.calculateDateRange(new List<String>{timePeriod});
            
            if (dateRanges.isEmpty()) {
                System.debug('No date range calculated for time period: ' + timePeriod);
                return new List<Visit>();
            }
            
            VisitDateRangeAction.DateRangeResult dateRange = dateRanges[0];
            System.debug('Date range: ' + dateRange.startDate + ' to ' + dateRange.endDate);
            
        // Step 3: Get visits for the user's territory within the date range where user has ownership/assignment
        // Only include visits where:
        // 1. Visit is in the user's territory (TerritoryId = userTerritoryId)
        // 2. User has ownership, assignment, or created the visit (OwnerId, VisitorId, UserId, or CreatedById = userId)
        // 3. Visit is a parent visit (ParentVisitId = null)
        return [
            SELECT Id, StatusRemarks, AccountId, Account.Name, Account.Type,
                   PlannedVisitStartTime, PlannedVisitEndTime, Status, 
                   InstructionDescription, VisitorId, PlaceId, Place.Name,
                   OwnerId, UserId, TerritoryId, CreatedById, ParentVisitId
            FROM Visit 
            WHERE TerritoryId = :userTerritoryId
            AND (OwnerId = :userId OR VisitorId = :userId OR UserId = :userId OR CreatedById = :userId)
            AND ParentVisitId = null
            AND PlannedVisitStartTime >= :dateRange.startDate
            AND PlannedVisitEndTime <= :dateRange.endDate
            ORDER BY PlannedVisitStartTime
        ];
        } catch (Exception e) {
            System.debug('Error getting visits for time period: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return new List<Visit>();
        }
    }
    
    /**
     * Get visits for multiple time periods
     * @param userId - Salesforce User ID
     * @param timePeriods - List of time periods
     * @return Map<String, List<Visit>> - Visits organized by time period
     */
    public static Map<String, List<Visit>> getUpcomingVisits(String userId, List<String> timePeriods) {
        Map<String, List<Visit>> visitsByPeriod = new Map<String, List<Visit>>();
        
        try {
            for (String period : timePeriods) {
                validateTimePeriod(period);
                List<Visit> visits = getVisitsForTimePeriod(userId, period);
                visitsByPeriod.put(period, visits);
            }
        } catch (Exception e) {
            System.debug('Error getting upcoming visits: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return visitsByPeriod;
    }
    
    /**
     * Get contact point addresses for the places in visits
     */
    private static Map<Id, String> getContactPointAddresses(List<Visit> visits) {
        Map<Id, String> placeAddresses = new Map<Id, String>();
        
        if (visits.isEmpty()) {
            return placeAddresses;
        }
        
        try {
            Set<Id> placeIds = new Set<Id>();
            for (Visit visit : visits) {
                if (visit.PlaceId != null) {
                    placeIds.add(visit.PlaceId);
                }
            }
            
            if (placeIds.isEmpty()) {
                return placeAddresses;
            }
            
            List<ContactPointAddress> addresses = [
                SELECT Id, Name, Address
                FROM ContactPointAddress
                WHERE Id IN :placeIds
            ];
            
            for (ContactPointAddress address : addresses) {
                String formattedAddress = formatContactPointAddress(address.Address);
                if (String.isNotBlank(formattedAddress)) {
                    placeAddresses.put(address.Id, formattedAddress);
                }
            }
            
        } catch (Exception e) {
            System.debug('Error getting contact point addresses: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return placeAddresses;
    }
    
    /**
     * Get provider visit details for the visits
     */
    private static List<ProviderVisit> getProviderVisitDetails(List<Visit> visits) {
        if (visits.isEmpty()) {
            return new List<ProviderVisit>();
        }
        
        try {
            Set<Id> visitIds = new Set<Id>();
            for (Visit visit : visits) {
                visitIds.add(visit.Id);
            }
            
            return [
                SELECT Id, VisitId, PreProviderVisitNotes, AdditionalInformation,
                       NextProviderVisitObjective, IsConfirmed, HasAttachments
                FROM ProviderVisit 
                WHERE VisitId IN :visitIds
            ];
        } catch (Exception e) {
            System.debug('Error getting provider visit details: ' + e.getMessage());
            return new List<ProviderVisit>();
        }
    }
    
    /**
     * Get account territory summaries for the visits
     */
    public static List<AccountSummary> getAccountSummaries(List<Visit> visits, String userTerritoryId, String userId) {
        if (visits.isEmpty()) {
            return new List<AccountSummary>();
        }
        
        try {
            Set<Id> accountIds = new Set<Id>();
            for (Visit visit : visits) {
                accountIds.add(visit.AccountId);
            }
            
            List<PrvdAccountTerritorySummary> summaries = [
                SELECT Id, AccountId, Account.Name, Territory2Id, Territory2.Name,
                       KeyInformationSummary, LastModifiedDate, KeyInformationHash,
                       KeyInfoSummaryDateTime, UserId, CreatedById, LastModifiedById
                FROM PrvdAccountTerritorySummary 
                WHERE AccountId IN :accountIds 
                AND Territory2Id = :userTerritoryId
                AND (UserId = :userId OR CreatedById = :userId OR LastModifiedById = :userId)
                ORDER BY LastModifiedDate DESC
            ];
            
            // Transform to AccountSummary objects
            List<AccountSummary> accountSummaries = new List<AccountSummary>();
            for (PrvdAccountTerritorySummary summary : summaries) {
                AccountSummary accSummary = new AccountSummary();
                accSummary.accountId = summary.AccountId;
                accSummary.accountName = summary.Account.Name;
                accSummary.lastUpdated = summary.KeyInfoSummaryDateTime;
                accSummary.territoryName = summary.Territory2.Name;
                accSummary.territoryId = summary.Territory2Id;
                
                // Parse JSON data from KeyInformationSummary
                if (String.isNotBlank(summary.KeyInformationSummary)) {
                    parseAccountSummaryJSON(summary.KeyInformationSummary, accSummary);
                }
                
                accountSummaries.add(accSummary);
            }
            
            return accountSummaries;
        } catch (Exception e) {
            System.debug('Error getting account summaries: ' + e.getMessage());
            return new List<AccountSummary>();
        }
    }
    
    /**
     * Calculate priority metrics for accounts
     */
    public static PriorityAssessment calculatePriorityMetrics(List<Visit> visits) {
        if (visits.isEmpty()) {
            return new PriorityAssessment();
        }
        
        try {
            Set<Id> accountIds = new Set<Id>();
            for (Visit visit : visits) {
                accountIds.add(visit.AccountId);
            }
            
            // Get visit statistics for priority calculation
            List<AggregateResult> visitStats = [
                SELECT AccountId, Account.Name, COUNT(Id) visitCount,
                       MAX(PlannedVisitStartTime) lastVisit
                FROM Visit 
                WHERE AccountId IN :accountIds 
                AND ParentVisitId = null
                AND PlannedVisitStartTime >= LAST_N_DAYS:30
                GROUP BY AccountId, Account.Name
                ORDER BY COUNT(Id) DESC
            ];
            
            PriorityAssessment priority = new PriorityAssessment();
            priority.totalAccounts = accountIds.size();
            priority.accountsWithRecentActivity = visitStats.size();
            
            if (!visitStats.isEmpty()) {
                AggregateResult topAccount = visitStats[0];
                priority.priorityAccountId = (Id) topAccount.get('AccountId');
                priority.priorityAccountName = (String) topAccount.get('Name');
                priority.priorityReason = 'Highest visit frequency and completion rate in last 30 days';
            }
            
            return priority;
        } catch (Exception e) {
            System.debug('Error calculating priority metrics: ' + e.getMessage());
            return new PriorityAssessment();
        }
    }
    
    /**
     * Call Agentforce API (simulated for now)
     */
    private static BriefingResponse callAgentforceAPI(BriefingData briefingData) {
        // For now, we'll create a mock response
        // In production, this would call the actual Agentforce API
        
        BriefingResponse response = new BriefingResponse();
        response.briefing = generateMockBriefing(briefingData);
        response.confidence = 0.85;
        response.dataQuality = 'High';
        response.recommendations = new List<String>{
            'Focus on priority account: ' + briefingData.priority.priorityAccountName,
            'Prepare conversation starters for each visit',
            'Review account summaries before visits'
        };
        
        return response;
    }
    
    /**
     * Generate mock briefing content (placeholder for Agentforce integration)
     */
    private static String generateMockBriefing(BriefingData data) {
        String briefing;
        if (String.isNotBlank(data.timePeriod)) {
            briefing = '📅 **Briefing for ' + data.timePeriod + '**\n';
        } else {
            briefing = '📅 **Daily Briefing for ' + data.targetDate.format() + '**\n';
        }
        briefing += '👤 **Sales Rep:** ' + data.user.Name + '\n';
        briefing += '🏢 **Territory:** ' + (String.isNotBlank(data.userTerritoryName) ? data.userTerritoryName : data.userTerritoryId) + '\n\n';
        
        briefing += '🎯 **Visit Details (' + data.visits.size() + ' total)**\n';
        for (Visit visit : data.visits) {
            briefing += '• 🕐 **' + visit.PlannedVisitStartTime.format('h:mm a') + '** - ' + 
                       visit.Account.Name + '\n';
            if (visit.Place != null && String.isNotBlank(visit.Place.Name)) {
                String placeInfo = visit.Place.Name;
                if (data.placeAddresses != null && data.placeAddresses.containsKey(visit.PlaceId)) {
                    String address = data.placeAddresses.get(visit.PlaceId);
                    if (String.isNotBlank(address)) {
                        placeInfo += ' - ' + address;
                    }
                }
                briefing += '  📍 Place: ' + placeInfo + '\n';
            }
            if (String.isNotBlank(visit.Status)) {
                briefing += '  📊 Status: ' + visit.Status + '\n';
            }
        }
        
        if (data.priority.priorityAccountName != null) {
            briefing += '\n⭐ **Priority Account: ' + data.priority.priorityAccountName + '**\n';
            briefing += '**Why Priority:** ' + data.priority.priorityReason + '\n';
        }
        
        // Key Insights Section
        briefing += '\n🔍 **Key Insights**\n';
        
        // Priority Account Analysis
        if (data.priority != null && data.priority.totalAccounts > 0) {
            briefing += '📊 **Priority Account Analysis:**\n';
            briefing += '• Total Accounts: ' + data.priority.totalAccounts + '\n';
            briefing += '• Active Accounts: ' + data.priority.accountsWithRecentActivity + '\n';
            briefing += '• Average Completion Rate: ' + (data.priority.averageCompletionRate * 100).intValue() + '%\n';
            briefing += '• Priority Level: ' + data.priority.getPriorityLevel() + '\n\n';
        }
        
        // Account Insights
        if (data.accountSummaries != null && !data.accountSummaries.isEmpty()) {
            briefing += '🏢 **Account Insights:**\n';
            for (AccountSummary summary : data.accountSummaries) {
                briefing += '**' + summary.accountName + '**\n';
                if (String.isNotBlank(summary.priority)) {
                    briefing += '• Priority: ' + summary.priority + '\n';
                }
                if (String.isNotBlank(summary.strategicFocus)) {
                    briefing += '• Strategic Focus: ' + summary.strategicFocus + '\n';
                }
                if (String.isNotBlank(summary.keyInformation)) {
                    briefing += '• Key Info: ' + summary.keyInformation + '\n';
                }
                briefing += '\n';
            }
        }
        
        briefing += '\n💬 **Conversation Starters**\n';
        
        // Group visits by account to avoid duplicate conversation starters
        Map<Id, List<Visit>> visitsByAccount = new Map<Id, List<Visit>>();
        for (Visit visit : data.visits) {
            if (!visitsByAccount.containsKey(visit.AccountId)) {
                visitsByAccount.put(visit.AccountId, new List<Visit>());
            }
            visitsByAccount.get(visit.AccountId).add(visit);
        }
        
        // Generate conversation starters for each unique account
        for (Id accountId : visitsByAccount.keySet()) {
            List<Visit> accountVisits = visitsByAccount.get(accountId);
            Visit firstVisit = accountVisits[0]; // Use first visit for account name
            
            briefing += '**For ' + firstVisit.Account.Name + ':**\n';
            
            // Show visit times if multiple visits for the same account
            if (accountVisits.size() > 1) {
                briefing += '📅 **Visit Times:** ';
                List<String> visitTimes = new List<String>();
                for (Visit visit : accountVisits) {
                    visitTimes.add(visit.PlannedVisitStartTime.format('h:mm a'));
                }
                briefing += String.join(visitTimes, ', ') + '\n';
            }
            
            // Generate personalized conversation starters based on account data
            String accountSummary = '';
            String visitHistory = '';
            String context = 'Daily briefing for ' + firstVisit.Account.Name;
            
            // Find account summary for this account
            for (AccountSummary accSummary : data.accountSummaries) {
                if (accSummary.accountId == accountId) {
                    accountSummary = JSON.serialize(accSummary);
                    break;
                }
            }
            
            List<ConversationStarter> starters = generateConversationStarters(accountSummary, visitHistory, context);
            if (!starters.isEmpty()) {
                ConversationStarter starter = starters[0];
                for (Integer i = 0; i < starter.starters.size() && i < 3; i++) {
                    briefing += (i + 1) + '. "' + starter.starters[i] + '"\n';
                }
            } else {
                // Fallback to generic starters if generation fails
                briefing += '1. "Good morning! I have the latest updates you requested."\n';
                briefing += '2. "Let\'s discuss how our solution can help with your current priorities."\n';
                briefing += '3. "I\'d like to share some recent success stories from similar accounts."\n';
            }
            briefing += '\n';
        }
        
        return briefing;
    }
    
    /**
     * Format Contact Point Address into a readable string
     */
    private static String formatContactPointAddress(Object addressObj) {
        if (addressObj == null) {
            return '';
        }
        
        try {
            String addressJson;
            if (addressObj instanceof String) {
                addressJson = (String) addressObj;
            } else {
                // If it's a System.Address object, convert to JSON
                addressJson = JSON.serialize(addressObj);
            }
            
            if (String.isBlank(addressJson)) {
                return '';
            }
            
            Map<String, Object> addressMap = (Map<String, Object>) JSON.deserializeUntyped(addressJson);
            List<String> addressParts = new List<String>();
            
            if (addressMap.containsKey('street') && addressMap.get('street') != null) {
                addressParts.add((String) addressMap.get('street'));
            }
            if (addressMap.containsKey('city') && addressMap.get('city') != null) {
                addressParts.add((String) addressMap.get('city'));
            }
            if (addressMap.containsKey('state') && addressMap.get('state') != null) {
                addressParts.add((String) addressMap.get('state'));
            }
            if (addressMap.containsKey('postalCode') && addressMap.get('postalCode') != null) {
                addressParts.add((String) addressMap.get('postalCode'));
            }
            
            return String.join(addressParts, ', ');
        } catch (Exception e) {
            System.debug('Error parsing address: ' + e.getMessage());
            return '';
        }
    }
    
    /**
     * Create empty briefing response when no visits are found
     */
    private static BriefingResponse createEmptyBriefingResponse(User user, Date targetDate, String message) {
        BriefingResponse response = new BriefingResponse();
        response.briefing = '📅 **Daily Briefing for ' + targetDate.format() + '**\n' +
                           '👤 **Sales Rep:** ' + user.Name + '\n\n' +
                           'ℹ️ **' + message + '**\n\n' +
                           '💡 **Recommendations:**\n' +
                           '• Review your calendar for other activities\n' +
                           '• Plan follow-up activities for previous visits\n' +
                           '• Prepare for upcoming visits';
        response.confidence = 1.0;
        response.dataQuality = 'Complete';
        response.recommendations = new List<String>{
            'No visits scheduled for today',
            'Consider planning future visits',
            'Review account summaries for preparation'
        };
        return response;
    }
    
    /**
     * Create empty briefing response when no visits are found for a time period
     */
    private static BriefingResponse createEmptyBriefingResponseForPeriod(User user, String timePeriod, String message) {
        BriefingResponse response = new BriefingResponse();
        response.briefing = '📅 **Briefing for ' + timePeriod + '**\n' +
                           '👤 **Sales Rep:** ' + user.Name + '\n\n' +
                           'ℹ️ **' + message + '**\n\n' +
                           '💡 **Recommendations:**\n' +
                           '• Review your calendar for other activities\n' +
                           '• Plan follow-up activities for previous visits\n' +
                           '• Prepare for upcoming visits';
        response.confidence = 1.0;
        response.dataQuality = 'Complete';
        response.recommendations = new List<String>{
            'No visits scheduled for ' + timePeriod,
            'Consider planning future visits',
            'Review account summaries for preparation'
        };
        return response;
    }
    
    /**
     * Generate conversation starters for an account
     */
    public static List<ConversationStarter> generateConversationStarters(String accountSummary, String visitHistory, String context) {
        List<ConversationStarter> starters = new List<ConversationStarter>();
        
        try {
            // Parse account summary if it's JSON
            AccountSummary summary = null;
            if (String.isNotBlank(accountSummary)) {
                try {
                    summary = (AccountSummary) JSON.deserialize(accountSummary, AccountSummary.class);
                } catch (Exception e) {
                    System.debug('Error parsing account summary: ' + e.getMessage());
                }
            }
            
            // Create conversation starter
            ConversationStarter starter = new ConversationStarter();
            
            if (summary != null) {
                starter.accountName = summary.accountName;
                starter.accountId = summary.accountId;
                starter.context = context;
                
                // Generate conversation starters based on account data
                if (String.isNotBlank(summary.strategicFocus)) {
                    starter.addStarter('I wanted to discuss your ' + summary.strategicFocus + ' strategy and how we can support your goals.');
                }
                
                if (String.isNotBlank(summary.recentActivity)) {
                    starter.addStarter('I see you\'ve been active recently. How has that been working for you?');
                }
                
                if (String.isNotBlank(summary.priority)) {
                    starter.addStarter('Given your ' + summary.priority + ' priority status, I\'d like to explore new opportunities for collaboration.');
                }
                
                // Add generic starters if no specific ones were generated
                if (starter.getStarterCount() == 0) {
                    starter.addStarter('How has your experience been with our recent interactions?');
                    starter.addStarter('What are your current priorities and how can we help?');
                    starter.addStarter('I\'d like to understand your goals for this quarter and beyond.');
                }
            } else {
                // Fallback starters when no account data is available
                starter.accountName = 'Account';
                starter.addStarter('How has your experience been with our recent interactions?');
                starter.addStarter('What are your current priorities and how can we help?');
                starter.addStarter('I\'d like to understand your goals for this quarter and beyond.');
            }
            
            starter.relevanceScore = 0.8;
            starter.source = 'AI Generated';
            starters.add(starter);
            
        } catch (Exception e) {
            System.debug('Error generating conversation starters: ' + e.getMessage());
            
            // Return fallback starter
            ConversationStarter fallbackStarter = new ConversationStarter();
            fallbackStarter.accountName = 'Account';
            fallbackStarter.addStarter('How has your experience been with our recent interactions?');
            fallbackStarter.addStarter('What are your current priorities and how can we help?');
            fallbackStarter.addStarter('I\'d like to understand your goals for this quarter and beyond.');
            fallbackStarter.relevanceScore = 0.5;
            fallbackStarter.source = 'Fallback';
            starters.add(fallbackStarter);
        }
        
        return starters;
    }
    
    /**
     * Parse JSON data from KeyInformationSummary and populate AccountSummary fields
     * Handles both the new keyInfo structure and legacy flat structure
     */
    private static void parseAccountSummaryJSON(String jsonData, AccountSummary accSummary) {
        try {
            // Preprocess the data to extract JSON if it's embedded in text
            String cleanJsonData = extractJsonFromText(jsonData);
            
            // Try to parse as JSON first
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(cleanJsonData);
            
            // Handle the new keyInfo structure (from PrvdAccountTerritorySummary)
            if (jsonMap.containsKey('keyInfo')) {
                Object keyInfoObj = jsonMap.get('keyInfo');
                if (keyInfoObj instanceof List<Object>) {
                    parseKeyInfoStructure((List<Object>) keyInfoObj, accSummary);
                }
            }
            
            // Handle the new changeInfo structure (from PrvdAccountTerritorySummary)
            if (jsonMap.containsKey('changeInfo')) {
                Object changeInfoObj = jsonMap.get('changeInfo');
                if (changeInfoObj instanceof List<Object>) {
                    parseChangeInfoStructure((List<Object>) changeInfoObj, accSummary);
                }
            }
            // Handle legacy summary structure
            else if (jsonMap.containsKey('summary')) {
                Object summaryObj = jsonMap.get('summary');
                if (summaryObj instanceof List<Object>) {
                    accSummary.keyInformation = formatStructuredSummary((List<Object>) summaryObj);
                } else if (summaryObj instanceof String) {
                    accSummary.keyInformation = (String) summaryObj;
                }
            }
            // Handle flat structure (legacy)
            else {
                parseFlatStructure(jsonMap, accSummary);
            }
            
        } catch (Exception e) {
            // If JSON parsing fails, treat as plain text
            System.debug('JSON parsing failed, treating as plain text: ' + e.getMessage());
            accSummary.keyInformation = jsonData;
        }
    }
    
    /**
     * Parse the keyInfo structure from PrvdAccountTerritorySummary
     */
    private static void parseKeyInfoStructure(List<Object> keyInfoSections, AccountSummary accSummary) {
        List<String> keyInfoParts = new List<String>();
        List<String> recentActivities = new List<String>();
        List<String> keyContacts = new List<String>();
        List<String> strategicFocuses = new List<String>();
        
        for (Object sectionObj : keyInfoSections) {
            if (sectionObj instanceof Map<String, Object>) {
                Map<String, Object> section = (Map<String, Object>) sectionObj;
                String sectionName = (String) section.get('sectionName');
                Object sectionDataObj = section.get('sectionData');
                
                if (String.isNotBlank(sectionName) && sectionDataObj instanceof List<Object>) {
                    List<Object> sectionData = (List<Object>) sectionDataObj;
                    List<String> sectionTexts = new List<String>();
                    
                    for (Object dataObj : sectionData) {
                        if (dataObj instanceof Map<String, Object>) {
                            Map<String, Object> dataMap = (Map<String, Object>) dataObj;
                            String dataText = (String) dataMap.get('data');
                            if (String.isNotBlank(dataText)) {
                                sectionTexts.add(dataText);
                            }
                        }
                    }
                    
                    if (!sectionTexts.isEmpty()) {
                        String sectionContent = String.join(sectionTexts, '; ');
                        keyInfoParts.add(sectionName + ': ' + sectionContent);
                        
                        // Map sections to appropriate fields
                        if (sectionName.contains('Key Activities') || sectionName.contains('Engagement')) {
                            recentActivities.addAll(sectionTexts);
                        } else if (sectionName.contains('Discussion Points') || sectionName.contains('Interactions')) {
                            recentActivities.addAll(sectionTexts);
                        } else if (sectionName.contains('Affiliations') || sectionName.contains('Key Contacts')) {
                            // Extract contact names from affiliation data
                            for (String text : sectionTexts) {
                                if (text.contains('Dr.') || text.contains('Tier') || text.contains('Partners')) {
                                    // Extract doctor names from text like "Dr. William Smith (Tier 1)"
                                    String[] parts = text.split('\\(');
                                    if (parts.size() > 0) {
                                        String contactName = parts[0].trim();
                                        if (contactName.startsWith('Dr.') || contactName.startsWith('Ms.') || contactName.startsWith('Mr.')) {
                                            keyContacts.add(contactName);
                                        }
                                    }
                                }
                            }
                        } else if (sectionName.contains('Clinical Trials') || sectionName.contains('Trials')) {
                            strategicFocuses.addAll(sectionTexts);
                        } else if (sectionName.contains('Social Insights') || sectionName.contains('Publications')) {
                            strategicFocuses.addAll(sectionTexts);
                        }
                    }
                }
            }
        }
        
        // Set the fields based on parsed data
        if (!keyInfoParts.isEmpty()) {
            accSummary.keyInformation = String.join(keyInfoParts, '\n');
        }
        
        if (!recentActivities.isEmpty()) {
            accSummary.recentActivity = String.join(recentActivities, '; ');
        }
        
        if (!keyContacts.isEmpty()) {
            for (String contact : keyContacts) {
                accSummary.addKeyContact(contact);
            }
        }
        
        if (!strategicFocuses.isEmpty()) {
            accSummary.strategicFocus = String.join(strategicFocuses, '; ');
        }
        
        // Set priority based on available data
        if (String.isNotBlank(accSummary.strategicFocus) || !keyContacts.isEmpty() || !recentActivities.isEmpty()) {
            accSummary.priority = 'High';
            accSummary.priorityReason = 'Active engagement, clinical trials, and key affiliations';
        }
    }
    
    /**
     * Parse the changeInfo structure from PrvdAccountTerritorySummary
     */
    private static void parseChangeInfoStructure(List<Object> changeInfoSections, AccountSummary accSummary) {
        List<String> changeInfoParts = new List<String>();
        List<String> recentActivities = new List<String>();
        List<String> keyContacts = new List<String>();
        List<String> strategicFocuses = new List<String>();
        
        for (Object sectionObj : changeInfoSections) {
            if (sectionObj instanceof Map<String, Object>) {
                Map<String, Object> section = (Map<String, Object>) sectionObj;
                String sectionName = (String) section.get('sectionName');
                Object sectionDataObj = section.get('sectionData');
                
                if (String.isNotBlank(sectionName) && sectionDataObj instanceof List<Object>) {
                    List<Object> sectionData = (List<Object>) sectionDataObj;
                    List<String> sectionTexts = new List<String>();
                    
                    for (Object dataObj : sectionData) {
                        if (dataObj instanceof Map<String, Object>) {
                            Map<String, Object> dataMap = (Map<String, Object>) dataObj;
                            String dataText = (String) dataMap.get('data');
                            if (String.isNotBlank(dataText)) {
                                sectionTexts.add(dataText);
                            }
                        }
                    }
                    
                    if (!sectionTexts.isEmpty()) {
                        String sectionContent = String.join(sectionTexts, '; ');
                        changeInfoParts.add(sectionName + ': ' + sectionContent);
                        
                        // Map sections to appropriate fields
                        if (sectionName.contains('Affiliation Updates') || sectionName.contains('Affiliations')) {
                            recentActivities.addAll(sectionTexts);
                            // Extract contact names from affiliation data
                            for (String text : sectionTexts) {
                                if (text.contains('Dr.') || text.contains('Tier') || text.contains('Partners')) {
                                    // Extract organization names from text like "Partners HealthCare"
                                    String[] parts = text.split('\\s+');
                                    for (String part : parts) {
                                        if (part.contains('HealthCare') || part.contains('Medical') || part.contains('Center')) {
                                            keyContacts.add(part);
                                        }
                                    }
                                }
                            }
                        } else if (sectionName.contains('Publications') || sectionName.contains('Accreditations')) {
                            strategicFocuses.addAll(sectionTexts);
                        }
                    }
                }
            }
        }
        
        // Set the fields based on parsed data
        if (!changeInfoParts.isEmpty()) {
            String existingKeyInfo = accSummary.keyInformation;
            if (String.isNotBlank(existingKeyInfo)) {
                accSummary.keyInformation = existingKeyInfo + '\n\nRecent Changes:\n' + String.join(changeInfoParts, '\n');
            } else {
                accSummary.keyInformation = 'Recent Changes:\n' + String.join(changeInfoParts, '\n');
            }
        }
        
        if (!recentActivities.isEmpty()) {
            String existingActivity = accSummary.recentActivity;
            if (String.isNotBlank(existingActivity)) {
                accSummary.recentActivity = existingActivity + '; ' + String.join(recentActivities, '; ');
            } else {
                accSummary.recentActivity = String.join(recentActivities, '; ');
            }
        }
        
        if (!keyContacts.isEmpty()) {
            for (String contact : keyContacts) {
                accSummary.addKeyContact(contact);
            }
        }
        
        if (!strategicFocuses.isEmpty()) {
            String existingFocus = accSummary.strategicFocus;
            if (String.isNotBlank(existingFocus)) {
                accSummary.strategicFocus = existingFocus + '; ' + String.join(strategicFocuses, '; ');
            } else {
                accSummary.strategicFocus = String.join(strategicFocuses, '; ');
            }
        }
    }
    
    /**
     * Parse flat JSON structure (legacy format)
     */
    private static void parseFlatStructure(Map<String, Object> jsonMap, AccountSummary accSummary) {
        // Extract key information from other possible field names
        if (jsonMap.containsKey('keyInformation')) {
            accSummary.keyInformation = (String) jsonMap.get('keyInformation');
        } else if (jsonMap.containsKey('description')) {
            accSummary.keyInformation = (String) jsonMap.get('description');
        }
        
        // Extract strategic focus
        if (jsonMap.containsKey('strategicFocus')) {
            accSummary.strategicFocus = (String) jsonMap.get('strategicFocus');
        } else if (jsonMap.containsKey('focus')) {
            accSummary.strategicFocus = (String) jsonMap.get('focus');
        } else if (jsonMap.containsKey('strategy')) {
            accSummary.strategicFocus = (String) jsonMap.get('strategy');
        }
        
        // Extract priority
        if (jsonMap.containsKey('priority')) {
            accSummary.priority = (String) jsonMap.get('priority');
        } else if (jsonMap.containsKey('priorityLevel')) {
            accSummary.priority = (String) jsonMap.get('priorityLevel');
        } else if (jsonMap.containsKey('status')) {
            accSummary.priority = (String) jsonMap.get('status');
        }
        
        // Extract recent activity
        if (jsonMap.containsKey('recentActivity')) {
            accSummary.recentActivity = (String) jsonMap.get('recentActivity');
        } else if (jsonMap.containsKey('activity')) {
            accSummary.recentActivity = (String) jsonMap.get('activity');
        } else if (jsonMap.containsKey('updates')) {
            accSummary.recentActivity = (String) jsonMap.get('updates');
        }
        
        // Extract key contacts
        if (jsonMap.containsKey('keyContacts')) {
            Object contactsObj = jsonMap.get('keyContacts');
            if (contactsObj instanceof List<Object>) {
                List<Object> contactsList = (List<Object>) contactsObj;
                for (Object contact : contactsList) {
                    if (contact instanceof String) {
                        accSummary.addKeyContact((String) contact);
                    } else if (contact instanceof Map<String, Object>) {
                        Map<String, Object> contactMap = (Map<String, Object>) contact;
                        if (contactMap.containsKey('name')) {
                            accSummary.addKeyContact((String) contactMap.get('name'));
                        }
                    }
                }
            }
        }
        
        // Extract priority reason
        if (jsonMap.containsKey('priorityReason')) {
            accSummary.priorityReason = (String) jsonMap.get('priorityReason');
        } else if (jsonMap.containsKey('reason')) {
            accSummary.priorityReason = (String) jsonMap.get('reason');
        }
    }
    
    /**
     * Format structured summary data into readable text
     */
    private static String formatStructuredSummary(List<Object> summarySections) {
        String formattedSummary = '';
        
        for (Object sectionObj : summarySections) {
            if (sectionObj instanceof Map<String, Object>) {
                Map<String, Object> section = (Map<String, Object>) sectionObj;
                String sectionName = (String) section.get('sectionName');
                Object sectionDataObj = section.get('sectionData');
                
                if (String.isNotBlank(sectionName) && sectionDataObj instanceof List<Object>) {
                    formattedSummary += sectionName + '\n';
                    
                    List<Object> sectionData = (List<Object>) sectionDataObj;
                    for (Object dataObj : sectionData) {
                        if (dataObj instanceof Map<String, Object>) {
                            Map<String, Object> data = (Map<String, Object>) dataObj;
                            String dataText = (String) data.get('data');
                            if (String.isNotBlank(dataText)) {
                                formattedSummary += '• ' + dataText + '\n';
                            }
                        }
                    }
                    formattedSummary += '\n';
                }
            }
        }
        
        return formattedSummary.trim();
    }
    
    /**
     * Extract JSON from text that may contain prefix text
     */
    private static String extractJsonFromText(String text) {
        if (String.isBlank(text)) {
            return text;
        }
        
        // Look for JSON object starting with {
        Integer jsonStart = text.indexOf('{');
        if (jsonStart != -1) {
            // Find the matching closing brace
            Integer braceCount = 0;
            Integer jsonEnd = -1;
            
            for (Integer i = jsonStart; i < text.length(); i++) {
                String charAt = text.substring(i, i + 1);
                if (charAt == '{') {
                    braceCount++;
                } else if (charAt == '}') {
                    braceCount--;
                    if (braceCount == 0) {
                        jsonEnd = i;
                        break;
                    }
                }
            }
            
            if (jsonEnd != -1) {
                return text.substring(jsonStart, jsonEnd + 1);
            }
        }
        
        // If no JSON object found, return original text
        return text;
    }
    
}