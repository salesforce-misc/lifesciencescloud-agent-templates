# Life Sciences Cloud Agentforce Templates

This repository contains Agentforce templates and components for Life Sciences Cloud, providing comprehensive conversational AI capabilities for field sales representatives.

## 🎯 Components

### 1. Daily Briefing Agent
- **Purpose**: Generates on-demand daily briefings for field sales representatives
- **Features**: Visit schedules, priority accounts, conversation starters
- **Location**: `agentforce-components/daily-briefing/`
- **Topic Configuration**: See [Daily Briefing Topic Configuration](agentforce-components/daily-briefing/topic-configuration/Daily_Briefing_Topic.md)

### 2. Influencers Map
- **Purpose**: Analyzes provider affiliations to identify key relationships
- **Features**: Introduction paths, network analysis, relationship mapping
- **Location**: `agentforce-components/influencer-map/`
- **Topic Configuration**: See [Influencer Map Topic Configuration](agentforce-components/influencer-map/topic-configuration/Influencer_Map_Topic.md)

### 3. Next Best Customer
- **Purpose**: Identifies next best customers for sales focus
- **Features**: Customer scoring, territory analysis, prediction models
- **Location**: `agentforce-components/get-nbc/`
- **Topic Configuration**: See [Next Best Customer Topic Configuration](agentforce-components/get-nbc/topic-configuration/NextBestCustomer_Topic.md)

### 4. Post Call Visit Notes
- **Purpose**: Analyzes dictated or written free text notes following customer visits and updates structured CRM records
- **Features**: Voice note processing, structured data logging, medical inquiry creation, follow-up visit scheduling
- **Components**: Visit_Note_Processor_Simple action integration
- **Location**: `agentforce-components/visit-note-processor/`
- **Topic Configuration**: See [Post Call Visit Notes Topic Configuration](agentforce-components/visit-note-processor/topic-configuration/PostCallVisitNotes_Topic.md)

## 🚀 Quick Start

### Prerequisites
- Salesforce org with **Life Sciences Cloud for Customer Engagement** enabled
- Agentforce for Life Sciences Cloud enabled and configured
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
     - **Input**: RAC (Require Input)
     - **Output**: NextBestCustomerFormattedOutput (Show in conversation), ErrorMessage (Show in conversation)
   - **influencer-map**: Create `Influencer_Map_Flow` action from Flow `Influencer_Map_Flow`
     - **Input**: TargetAccountName (Require Input), targetAccountId (Require Input)
     - **Output**: FormattedAffiliationOutput (Show in conversation), errorMessage (Show in conversation)
   - **visit-note-processor**: Create `Visit_Note_Processor_Simple` action from Flow `Visit_Note_Processor_Simple`
     - **Input**: VoiceNote (Require Input, Collect Data from User)
     - **Output**: FullUpdateSummary (Show in conversation)

4. **Create Agent Topics**:
   Create the Agent Topics through **Agentforce Studio → Agentforce Assets → Topics**:
   - [Daily Briefing](agentforce-components/daily-briefing/topic-configuration/Daily_Briefing_Topic.md)
   - [Influencer Map](agentforce-components/influencer-map/topic-configuration/Influencer_Map_Topic.md)
   - [NextBestCustomer](agentforce-components/get-nbc/topic-configuration/NextBestCustomer_Topic.md)
   - [PostCallVisitNote](agentforce-components/visit-note-processor/topic-configuration/PostCallVisitNotes_Topic.md)
   
   Use the Topic details provided in the documentation links above.

5. **Create Life Sciences Field Sales Agent**:
   Create the Life Sciences Field Sales Agent through **Agentforce Studio → Agentforce Agents → New Agent** using the Life Sciences Field Sales Template.

6. **Configure Agent**:
   Add the Topics and Actions to the New Agent.

7. **Test Agent**:
   Test the Agent in Agentforce Studio to ensure all components are working correctly.

8. **Assign Permissions**:
   Assign Agent permission to users who need access to the agent functionality.

## 📁 Repository Structure

```
lifesciencescloud-agent-templates/
├── agentforce-components/     # Agentforce configurations
│   ├── daily-briefing/       # Daily briefing agent
│   ├── get-nbc/             # Next best customer
│   ├── influencer-map/      # Influencer mapping
│   └── visit-note-processor/ # Post-call visit notes
├── force-app/                # Salesforce metadata
├── scripts/                  # Deployment scripts
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

