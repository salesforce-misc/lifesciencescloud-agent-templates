# LSC4CE Agentforce Solutions

This repository contains all Agentforce components and dependencies for the LSC4CE project, providing comprehensive conversational AI capabilities for field sales representatives.

## 🎯 Components

### 1. Daily Briefing Agent
- **Purpose**: Generates on-demand daily briefings for field sales representatives
- **Features**: Visit schedules, priority accounts, conversation starters
- **Location**: `agentforce-components/daily-briefing/`

**Topic Configuration:**
- **Name**: Daily Briefing
- **API Name**: `Daily_Briefing_16jWs000000Qc3F`
- **Classification Description**: Handles requests for daily briefings, visit summaries, and priority account information for field sales representatives
- **Scope**: Your job is to generate comprehensive daily briefings for field sales representatives

**Instructions (verbatim):**

**Instruction 1:**
This topic handles requests for daily briefings from field sales representatives. It uses the DailyBriefingOrchestrator to generate comprehensive briefings that include:
1. Today's scheduled visits with detailed information
2. Account insights and territory summaries
3. Priority account analysis and rankings
4. Personalized conversation starters for each account
5. Action items and recommendations
The topic should:
- Personalize responses with the user's name and territory information
- Handle different focus areas (priority, visits, accounts, conversation, all)
- Provide helpful fallback responses for various error scenarios
- Format responses with clear sections, emojis, and markdown formatting
- Always include actionable recommendations and next steps
- Respect territory boundaries and data access restrictions

**Instruction 2:**
Recognize the following intent patterns:
1. Daily Briefing Requests:
- "Generate my daily briefing"
- "Show me today's agenda"
- "What's on my schedule today?"
- "Give me my daily briefing"
2. Priority-Focused Requests:
- "Show me my priority accounts"
- "What are my priority accounts for today?"
- "Give me priority account analysis"
3. Visit-Focused Requests:
- "What visits do I have today?"
- "Show me my visit schedule"
- "What's on my calendar today?"
4. Account-Focused Requests:
- "Give me account insights"
- "Show me account summaries"
- "What do I need to know about my accounts?"
5. Conversation-Focused Requests:
- "Help me prepare for my meetings"
- "Give me conversation starters"
- "What should I talk about with my accounts?"
6. Date-Specific Requests:
- "Generate briefing for [date]"
- "Show me visits for [date]"
- "What's on my schedule for [date]?"

**Instruction 3:**
Process entities as follows:
1. Date Entity:
- Default to "today" if not specified
- Support relative dates: "today", "tomorrow", "yesterday"
- Support specific dates: "January 15", "1/15/2024", "2024-01-15"
- Validate date is not too far in the past or future
2. Focus Entity:
- Default to "all" if not specified
- Map user intent to focus values:
* Priority requests → "priority"
* Visit requests → "visits"
* Account requests → "accounts"
* Conversation requests → "conversation"
* General requests → "all"
3. AccountName Entity:
- Use for account-specific briefings
- Validate account exists in user's territory
- Provide fallback if account not found

**Instruction 4:**
Generate responses with the following structure:
1. Header Section:
- Date and user information
- Territory context
- Briefing type based on focus
2. Content Sections (based on focus):
- Visits: Detailed visit information with timing and status
- Accounts: Account insights and summaries
- Priority: Priority analysis and rankings
- Conversation: Conversation starters and talking points
- All: Comprehensive briefing with all sections
3. Action Items:
- Always include actionable recommendations
- Suggest next steps based on the briefing content
- Provide follow-up activities
4. Footer:
- Generation timestamp
- Data freshness information
- Contact information for issues

**Instruction 5:**
Handle errors gracefully with appropriate fallback responses:
1. No Visits Found:
- "I couldn't find any visits scheduled for [date]. You might want to check your calendar or plan some visits for the day."
2. User Not Found:
- "I couldn't find your user information. Please contact your administrator to ensure your account is properly set up."
3. No Territory Assigned:
- "You don't have a territory assigned. Please contact your administrator to set up your territory assignment."
4. No Account Data:
- "I couldn't retrieve account information for your territory. Please try again later or contact your administrator."
5. General Errors:
- "I encountered an error while generating your daily briefing. Please try again later or contact your administrator if the issue persists."
6. Invalid Date:
- "I couldn't process that date. Please try using a specific date like 'today', 'tomorrow', or a date like 'January 15'."

**Example User Inputs:**
Show daily briefing
Provide my daily brief
Provide daily brief for tomorrow
Provide daily brief from yesterday

### 2. Influencers Map
- **Purpose**: Analyzes provider affiliations to identify key relationships
- **Features**: Introduction paths, network analysis, relationship mapping
- **Location**: `agentforce-components/influencer-map/`

### 3. Get Visits
- **Purpose**: Retrieves and formats visit schedules
- **Features**: Territory-based filtering, date range calculations
- **Location**: `agentforce-components/get-visits/`

### 4. NBC (Next Best Customer) Action
- **Purpose**: Identifies next best customers for sales focus
- **Features**: Customer scoring, territory analysis, prediction models
- **Location**: `agentforce-components/nbc-action/`

**Topic Configuration:**
- **Name**: NextBestCustomer
- **API Name**: `NextBestCustomer`
- **Classification Description**: This topic is triggered when a user asks for recommendations on which customers or accounts to meet with next. It directly calls the GetNBC action to retrieve this information and presents the list to the user. No further input is required from the user.

**Example Phrases (Utterances):**
- "who else could I meet with?"
- "recommend top account for me"
- "who are the next best customers"
- "who are the next best accounts"
- "show me the next best accounts"
- "find my top accounts"
- "who should I target next?"
- "suggest some customers"

**Scope:**
Your job is to assist in the preparation of customer list that Field Sales rep should consider while planning for a week or day or even ad-hoc.

**Instructions (verbatim):**

**Instruction 1:**
Start: The topic begins when the user's request matches one of the example phrases.

**Instruction 2:**
Execute Action: Immediately call the Action: GetNBC.

**Instruction 3:**
Display Results: Present the list of accounts returned by the GetNBC action to the user with a brief introductory message.

**Instruction 4:**
Example Response: "Here are your next best accounts to connect with:" [List from GetNBC]

**Example User Inputs:**
- "who else could I meet with?"
- "recommend top account for me"
- "who are the next best customers"
- "who are the next best accounts"
- "show me the next best accounts"
- "find my top accounts"
- "who should I target next?"
- "suggest some customers"

### 5. Visit Note Processor
- **Purpose**: Processes and logs visit notes using AI
- **Features**: JSON processing, automatic data creation, territory mapping, dynamic account/product context
- **Components**: Enhanced prompt template, AccountAProductNames flow for context injection
- **Location**: `agentforce-components/visit-note-processor/`

### 6. Pre Call Planning
- **Purpose**: Helps prepare for visits by gathering insights and summaries about accounts and customers
- **Features**: Account insights, provider affiliations, visit scheduling, HCP/HCO analysis
- **Components**: Influencers Map and Get Visits actions, plus standard Identify Record by Name action
- **Location**: `agentforce-components/pre-call-planning/`

**Topic Configuration:**
- **Name**: Pre Call Planning
- **API Name**: `PreCallPlanning`
- **Classification Description**: Helps prepare for visits by gathering insights and summaries about accounts and customers, specifically HCPs or HCOs, to ensure effective engagement. This includes identifying and analyzing key information about HCPs, identifying key referrers, scheduling and managing visits, and distributing relevant content. The core objective is to ensure that Field Representatives are fully prepared and have a clear, data-driven plan before initiating any contact.

**Scope:**
Your job is to gather relevant information and insights about the accounts or customers before a visit. You should not attempt to schedule visits or manage post-visit activities.

**Instructions (verbatim):**

**Instruction 1:**
If user asks to gather insights or summarize the account HCPs or HCOs, then follow the below steps in strict sequence:
Step 1- If provider name is present in utterance, use it as accName and directly execute from step 4.
Step 2 - If context_variable currentObjectApiName is "Account" and context_variable currentRecordId is neither empty nor the hard coded string 'currentRecordId', use currentRecordId as accId. Do not hardcode accountId as 'currentRecordId'.
Step 3 - If context_variable currentObjectApiName is not "Account" or context_variable currentRecordId is empty or equals the hard coded string 'currentRecordId', prompt the user for a Provider Name. Use this provider name as accName discarding any salutations (Mr., Dr., etc.).
Step 4 - Call "IdentifyRecordByName" action with recordName as accName removing any salutations(Mr., Dr., etc.) and objectApiName as "Account" and get accountId.
Step 5 - Call "GenerateProviderSummary" action using the retrieved accountId, TerritoryId context variable if present and user utterance.

**Instruction 2:**
2.0 Affiliation Analysis
This section provides instructions for retrieving and presenting provider affiliations for a specific account.
2.1 Triggering the Action
The agent should trigger this action when a user requests to see "affiliations," "connections," or "networks" for a specific account.
2.2 Action Execution
Extract the [Account Name] from the user's utterance.
Use the Identify Record by Name action to find the AccountID.
If the action finds a single, unique account, proceed directly without asking for confirmation. Pass the AccountID to the Influencer_Map_Flow.
If the action returns multiple accounts with the same name, prompt the user to select the correct one before proceeding.
2.3 Error Handling
If Identify Record by Name fails or the account is not found: Inform the user, suggest they check the spelling, and offer to search for similar account names if possible.
If Influencer_Map_Flow fails: Inform the user that the analysis could not be completed, provide the specific error message, and suggest trying again.
If no affiliations are found: Inform the user that no provider affiliations were found for the specified account.
2.4 Response Formatting
Present the affiliation analysis results using the following exact format:
Provider Affiliation Analysis for [Account Name]
Top 5 Provider Affiliations:
[Affiliated Account Name]
Account Name: [RelatedAccountName]
Influence Type: [InfluenceType]
Affiliation Strength Type: [AffiliationStrengthType]
Care Specialty: [CareSpecialtyId]
Affiliation Type: [AffiliationType]
[Next Affiliated Account Name]
(Same format as above)
(Continue for up to 5 affiliations)
Summary:
Total Affiliations Found: [Number]
Hard Affiliations: [Number]
Soft Affiliations: [Number]

**Instruction 3:**
This section provides instructions for retrieving and presenting a schedule of upcoming visits using the Get_Visits_Simple flow.
## 1.1 Triggering the Action
The agent should trigger this action when a user's request includes keywords or phrases such as:
- "schedule"
- "visits"
- "appointments"
- "calendar"
- "itinerary"
- "my visits"
- "territory visits"
- "upcoming visits"
## 1.2 Action Execution
The agent must parse the user's request to identify the key parameter: [Time Frame].
### Flow Execution Process:
1. Territory-Based Retrieval: The agent will use the Get_Visits_Simple flow which automatically:
- Retrieves the current user's assigned territory from UserTerritory2Association
- Uses the territory ID to filter visits by TerritoryId (not VisitorId)
- Ensures the user only sees visits within their assigned territory
2. Time Frame Parameter: The agent must pass the [Time Frame] parameter to the flow. Supported values include:
- "Today"
- "Tomorrow"
- "This Week"
- "Next Week"
- "This Month"
- "Next Month"
3. Flow Input: The agent will call the Get_Visits_Simple flow with:
- Input: TimePeriod (String) - The specified time frame
- Output: VisitResults (String) - Formatted visit schedule data
## 1.3 Handling Missing Information & No Results
### Missing Time Frame:
If the [Time Frame] is not specified (e.g., "Show me my schedule"):
- The agent must prompt the user for this information
- Example: "Please specify a time frame, such as 'today', 'this week', 'next week', 'this month', or 'next month'."
- The agent should present the available options to the user
### No Territory Assignment:
If the user has no territory assignment:
- The flow will return an error message: "No territory assignment found for the current user. Please ensure the user is assigned to a territory."
- The agent must inform the user that they need to be assigned to a territory to view visits
### No Visits Found:
If the Get_Visits_Simple flow returns no data:
- The flow will return: "No visits found for the user's territory in the specified time period: [TimePeriod]"
- The agent must inform the user that no visits are scheduled for their territory in the specified time frame
## 1.4 Response Generation
### Data Format:
The Get_Visits_Simple flow returns formatted visit data in the following structure:
<br>Visit #1 | Account: [Account Name] | Time: [Planned Visit Start Time]<br>Visit #2 | Account: [Account Name] | Time: [Planned Visit Start Time]<br>...<br>``````<br>Your visit schedule for [Time Frame]:<br>📅 [Date]<br>• [Time] - [Account Name]<br>• [Time] - [Account Name]<br>📅 [Date] <br>• [Time] - [Account Name]<br>Total: [X] visits scheduled<br>

**Example User Inputs:**
- "Show me my visits for this week"
- "What visits do I have today?"
- "Summarize Aaron Morita"
- "Summarize Thomas"
- "Show affiliations for Aaron"
- "Who influences Thomas"

### 7. Post Call Visit Notes
- **Purpose**: Analyzes dictated or written free text notes following customer visits and updates structured CRM records
- **Features**: Voice note processing, structured data logging, medical inquiry creation, follow-up visit scheduling
- **Components**: Visit_Note_Processor_Simple action integration
- **Location**: `agentforce-components/post-call-visit-notes/`

**Topic Configuration:**
- **Name**: PostCallVisitNotes
- **API Name**: `PostCallVisitNotes_16jWs000000Qc3F`
- **Classification Description**: You are an AI assistant for a pharmaceutical representative. Your task is to analyze a dictated or written free text note following a customer visit and update a structured CRM record.

**Scope:**
Your job is to assist the pharma representative by parsing the information they dictate about a provider visit and accurately logging it into the Note record. You also create medical inquiries as needed and schedule follow up Provider Visits.

**Instructions (verbatim):**

Take the voice note provided by the User and provide that as input to the Vist_Note_Processor_Simple Action and Output the response provided by the action

**Example User Input:**

Example User Input

## 🚀 Quick Start

### Prerequisites
- Salesforce org with **Life Sciences Cloud for Customer Engagement** enabled
- Agentforce enabled and configured
- Provider Visit Management objects and Life Sciences Marketable Product objects
- Territory2 and UserTerritory2Association setup
- Admin permissions for Agentforce and Life Sciences Cloud configuration

### Installation
```bash
# 1. Clone the repository
git clone https://github.com/salesforce-misc/lifesciencescloud-agent-templates.git
cd lifesciencescloud-agent-templates

# 2. Create Flex-based Prompt Templates FIRST
# IMPORTANT: Create prompt templates from agentforce-components/ with exact Label and API Names
# This is required before deployment as Flows have dependencies on these templates

# 3. Deploy to your org
./deployment/deploy.sh your-org-alias

# 4. Configure Agentforce components (see documentation/)
```

### ⚠️ Critical Deployment Requirements

**Before running the deployment script:**

1. **Create Flex-based Prompt Templates**: 
   - Navigate to `agentforce-components/` and create prompt templates with exact Label and API Names as specified in the files
   - This step is mandatory as Flows have dependencies on these prompt templates
   - Deployment will fail without these templates created first

2. **User Access Configuration**:
   - End users must be provided access to the Agent that contains the actions
   - End users must be assigned the **Permission Set License → Prompt Template User**
   - Without these permissions, users cannot access the Agentforce functionality

3. **Manual Agentforce Action Creation**:
   - Admins must manually create Agentforce Actions from the deployed Apex classes and Flows
   - **daily-briefing**: Create `Generate_Complete_Daily_Briefing` action from Apex class `DailyBriefingOrchestrator`
     - **Input**: Target Date (Require Input)
     - **Output**: output (Show in conversation)
   - **get-nbc**: Create `GetNBC` action from Flow `GetNBC`
     - **Input**: NumberOfNBC (Require Input)
     - **Output**: NextBestCustomerFormattedOutput (Show in conversation), ErrorMessage (Show in conversation)
   - **get-visits**: Create `Get_Visits_Simple` action from Flow `Get_Visits_Simple`
     - **Input**: TimePeriod (Require Input, Collect Data from User), targetAccountId (Require Input)
     - **Output**: FormattedOutput (Show in conversation), ErrorMessage (Show in conversation)
   - **influencer-map**: Create `Influencer_Map_Flow` action from Flow `Influencer_Map_Flow`
     - **Input**: TargetAccountName (Require Input), targetAccountId (Require Input)
     - **Output**: FormattedAffiliationOutput (Show in conversation), errorMessage (Show in conversation)
   - **visit-note-processor**: Create `Visit_Note_Processor_Simple` action from Flow `Visit_Note_Processor_Simple`
     - **Input**: VoiceNote (Require Input, Collect Data from User)
     - **Output**: FullUpdateSummary (Show in conversation)
   - **pre-call-planning**: This topic uses the actions from get-visits and influencer-map, plus requires the standard **Identify Record by Name** action
   - **post-call-visit-notes**: This topic uses the `Visit_Note_Processor_Simple` action from the visit-note-processor component

## 📁 Repository Structure

```
lsc4ce-agentforce-solutions/
├── agentforce-components/     # Agentforce configurations
├── force-app/                # Salesforce metadata
├── deployment/               # Deployment scripts
├── documentation/            # Setup guides and docs
└── tests/                   # Test classes
```

## 📚 Documentation

- [Setup Guide](documentation/SETUP_GUIDE.md) - Complete installation instructions
- [API Reference](documentation/API_REFERENCE.md) - Technical documentation
- [Troubleshooting](documentation/TROUBLESHOOTING.md) - Common issues and solutions
- [User Guide](documentation/USER_GUIDE.md) - End-user instructions

## 🔧 Development

### Testing
```bash
sf apex run test --target-org your-org --class-names DailyBriefingAgentTest
```

### Deployment
```bash
sf project deploy start --target-org your-org
```

## 📞 Support

For issues or questions:
1. Check the troubleshooting guide
2. Review the setup documentation
3. Contact the LSC4CE team

