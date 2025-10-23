# LSC4CE Agentforce Solutions - API Reference

## Apex Classes

### DailyBriefingAgent
Main class for generating daily briefings for field sales representatives.

#### Methods
- `generateDailyBriefing(String userId, Date targetDate, String focus)`
- `generateBriefing(String userId, String timePeriod, String focus)`
- `getDailyVisits(String userId, Date targetDate)`
- `getUserTerritory(String userId)`

#### Parameters
- `userId`: Salesforce User ID
- `targetDate`: Date for the briefing
- `timePeriod`: Time period (Today, Tomorrow, This Week, etc.)
- `focus`: Focus area (all, priority, visits, accounts)

### DailyBriefingOrchestrator
Orchestrates the complete daily briefing generation process.

#### Methods
- `generateCompleteDailyBriefing(List<DailyBriefingRequest> requests)`

### VisitNoteProcessor
Processes visit notes and creates related records.

#### Methods
- `processVisitNotes(List<VisitNoteRequest> requests)`

### VisitDateRangeAction
Calculates date ranges for different time periods.

#### Methods
- `calculateDateRange(List<DateRangeRequest> requests)`

## Flows

### Get_Visits_Enhanced
Retrieves and formats visit schedules with territory filtering.

#### Input Variables
- `timePeriod`: String (Today, Tomorrow, This Week, etc.)
- `userId`: String (optional, defaults to current user)

#### Output Variables
- `formattedVisits`: String (formatted visit schedule)

### Influencer_Map_Flow
Analyzes provider affiliations and relationships.

#### Input Variables
- `targetAccountId`: String (Account ID to analyze)

#### Output Variables
- `finalResponse`: String (analysis results)
- `success`: Boolean (operation status)

### GetNBC
Identifies next best customers for sales focus.

#### Input Variables
- `userId`: String (optional, defaults to current user)

#### Output Variables
- `nextBestCustomerFormattedOutput`: String (formatted NBC results)

## Agentforce Actions

### Daily Briefing Actions
- `Get_Daily_Visits_Action`
- `Get_Account_Summaries_Action`
- `Calculate_Priority_Metrics_Action`
- `Generate_Conversation_Starters_Action`

### Influencer Map Actions
- `Influencer_Map_Analysis`

### Visit Note Processor Actions
- `Process_Visit_Notes`

## Data Models

### BriefingResponse
Response wrapper for daily briefing generation.

#### Fields
- `success`: Boolean
- `message`: String
- `briefingData`: BriefingData
- `errorMessage`: String

### BriefingData
Contains all briefing-related data.

#### Fields
- `user`: User
- `visits`: List<Visit>
- `providerVisits`: List<ProviderVisit>
- `accountSummaries`: List<AccountSummary>
- `priority`: PriorityAssessment

### ConversationStarter
Represents a conversation starter for account visits.

#### Fields
- `topic`: String
- `context`: String
- `suggestedApproach`: String

## Error Handling

### Common Error Codes
- `USER_NOT_FOUND`: User ID not found
- `NO_TERRITORY`: No territory assigned to user
- `NO_VISITS`: No visits found for specified period
- `INVALID_DATE`: Invalid date or time period

### Error Response Format
```json
{
  "success": false,
  "errorCode": "USER_NOT_FOUND",
  "errorMessage": "User not found: 005...",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Usage Examples

### Generate Daily Briefing
```apex
BriefingResponse response = DailyBriefingAgent.generateDailyBriefing(
    UserInfo.getUserId(), 
    Date.today(), 
    'all'
);
```

### Process Visit Notes
```apex
List<VisitNoteProcessor.VisitNoteRequest> requests = new List<VisitNoteProcessor.VisitNoteRequest>();
VisitNoteProcessor.VisitNoteRequest request = new VisitNoteProcessor.VisitNoteRequest();
request.visitNotesJson = '{"accountName": "Test Account", ...}';
requests.add(request);

List<VisitNoteProcessor.ProcessingResult> results = VisitNoteProcessor.processVisitNotes(requests);
```

## Performance Considerations

### Best Practices
- Use appropriate time periods to limit data retrieval
- Implement caching for frequently accessed data
- Monitor execution time for large datasets
- Use batch processing for bulk operations

### Limits
- Maximum 10,000 records per query
- 2-minute execution time limit for flows
- 6MB heap size limit for Apex

## Security

### Data Access
- All classes use `with sharing` to respect user permissions
- Territory-based data filtering enforced
- No sensitive data stored in Agentforce

### Permissions Required
- Customize Application
- Manage Agentforce
- View All Data (for Flow execution)
- Edit Topics
- Configure Entities

