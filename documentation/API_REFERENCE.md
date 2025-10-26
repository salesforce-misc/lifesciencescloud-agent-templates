# Life Sciences Cloud Agentforce Templates - API Reference

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

#### Input Parameters
- `targetDate`: Date (Target date for the briefing)

#### Output Parameters
- `output`: String (Complete daily briefing output)

### VisitNoteProcessor
Processes visit notes and creates related records.

#### Methods
- `processVisitNotes(List<VisitNoteRequest> requests)`

#### Input Parameters
- `voiceNote`: String (Voice note or text input from user)

#### Output Parameters
- `fullUpdateSummary`: String (Summary of all updates made)

### VisitDateRangeAction
Calculates date ranges for different time periods.

#### Methods
- `calculateDateRange(List<DateRangeRequest> requests)`

## Flows

### Influencer_Map_Flow
Analyzes provider affiliations and relationships.

#### Input Variables
- `targetAccountId`: String (Account ID to analyze)
- `targetAccountName`: String (Account Name to analyze)

#### Output Variables
- `formattedAffiliationOutput`: String (formatted affiliation analysis results)
- `errorMessage`: String (error message if operation fails)

### GetNBC
Identifies next best customers for sales focus.

#### Input Variables
- `RAC`: Number (number of next best customers to return)

#### Output Variables
- `nextBestCustomerFormattedOutput`: String (formatted NBC results)
- `errorMessage`: String (error message if operation fails)

### Visit_Note_Processor_Simple
Processes and logs visit notes using AI with JSON processing and automatic data creation.

#### Input Variables
- `voiceNote`: String (voice note or text input from user)

#### Output Variables
- `fullUpdateSummary`: String (summary of all updates made)

## Agentforce Actions

### Daily Briefing Actions
- `Generate_Complete_Daily_Briefing` (Apex-based action from DailyBriefingOrchestrator class)

### Next Best Customer Actions
- `GetNBC` (Flow-based action)

### Influencer Map Actions
- `Influencer_Map_Flow` (Flow-based action)

### Visit Note Processor Actions
- `Visit_Note_Processor_Simple` (Flow-based action)

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
// Using DailyBriefingOrchestrator (recommended for Agentforce actions)
List<DailyBriefingOrchestrator.DailyBriefingRequest> requests = new List<DailyBriefingOrchestrator.DailyBriefingRequest>();
DailyBriefingOrchestrator.DailyBriefingRequest request = new DailyBriefingOrchestrator.DailyBriefingRequest();
request.targetDate = Date.today();
requests.add(request);

List<DailyBriefingOrchestrator.DailyBriefingResponse> responses = DailyBriefingOrchestrator.generateCompleteDailyBriefing(requests);
```

### Process Visit Notes
```apex
// Using Visit_Note_Processor_Simple Flow (recommended for Agentforce actions)
// Input: voiceNote (String) - Voice note or text input from user
// Output: fullUpdateSummary (String) - Summary of all updates made
```

### Get Next Best Customer
```apex
// Using GetNBC Flow (recommended for Agentforce actions)
// Input: RAC (Number) - Number of next best customers to return
// Output: nextBestCustomerFormattedOutput (String) - Formatted NBC results
```

### Influencer Map Analysis
```apex
// Using Influencer_Map_Flow (recommended for Agentforce actions)
// Input: targetAccountId (String), targetAccountName (String)
// Output: formattedAffiliationOutput (String) - Formatted affiliation analysis results
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
- Prompt Template User (for accessing prompt templates)

