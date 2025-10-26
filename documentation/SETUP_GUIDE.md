# Life Sciences Cloud Agentforce Templates - Setup Guide

## Overview

This guide provides step-by-step instructions for deploying and configuring the Life Sciences Cloud Agentforce Templates package.

## ⚠️ Critical Deployment Requirements

**Before proceeding with deployment, ensure you understand these mandatory requirements:**

1. **Flex-based Prompt Templates**: Must be created FIRST with exact Label and API Names from `agentforce-components/` files
2. **Manual Action Creation**: Admins must manually create Agentforce Actions from deployed Apex classes and Flows
3. **User Access**: End users must have access to the Agent containing the actions
4. **Permission Set License**: End users must be assigned "Prompt Template User" license
5. **Deployment Order**: Prompt templates → Package deployment → Manual action creation → User configuration

**Failure to follow these requirements will result in deployment failures and non-functional Agentforce actions.**

## Prerequisites

### Salesforce Org Requirements
- Salesforce org with **Life Sciences Cloud for Customer Engagement** enabled
- Agentforce for Life Sciences Cloud enabled and configured
- Provider Visit Management objects enabled
- Territory2 and UserTerritory2Association configured
- Admin permissions for Agentforce and Life Sciences Cloud configuration

### Required Objects
- Visit
- ProviderVisit
- Account
- Territory2
- UserTerritory2Association
- ProviderAccountTerritorySummary
- ContactPointAddress
- Product2
- Life Sciences Marketable Product

## Step 1: Create Flex-based Prompt Templates (REQUIRED FIRST)

⚠️ **CRITICAL**: This step must be completed BEFORE running the deployment script, as Flows have dependencies on these prompt templates.

### 1.1 Create Prompt Templates
1. Navigate to Setup → Agentforce → Prompt Templates
2. Create the following prompt templates using the exact Label and API Names from the files in `agentforce-components/`:

   **From `agentforce-components/get-nbc/prompts/`:**
   - NBC_Formatted_Output

   **From `agentforce-components/influencer-map/prompts/`:**
   - Formatted_Influence_Graph

   **From `agentforce-components/daily-briefing/prompts/`:**
   - Conversation_Starters_Prompt

   **From `agentforce-components/visit-note-processor/prompts/`:**
   - Visit_Note_Mapper

3. Copy the content from each `.genAiPromptTemplate-meta.xml` file and create the prompt template with the exact Label and API Name specified
4. Ensure all prompt templates are saved and active

## Step 2: Deploy the Package

### 2.1 Using Deployment Script
```bash
./deployment/deploy.sh your-org-alias
```

### 2.2 Manual Deployment
```bash
sf project deploy start --target-org your-org-alias
```

## Step 3: Create Agentforce Actions Manually

⚠️ **CRITICAL**: After package deployment, you must manually create Agentforce Actions from the deployed Apex classes and Flows.

### 3.1 Create Actions from Apex Classes
1. Navigate to Setup → Agentforce → Actions
2. Click "New Action"
3. Select "Apex" as the action type
4. Create the following actions:

   **Generate_Complete_Daily_Briefing Action:**
   - Action Name: `Generate_Complete_Daily_Briefing`
   - Apex Class: `DailyBriefingOrchestrator`
   - Description: "Generates comprehensive daily briefings for field sales representatives"
   - **Input**: Target Date (Require Input)
   - **Output**: output (Show in conversation)

### 3.2 Create Actions from Flows
1. Navigate to Setup → Agentforce → Actions
2. Click "New Action"
3. Select "Flow" as the action type
4. Create the following actions:

   **GetNBC Action:**
   - Action Name: `GetNBC`
   - Flow: `GetNBC`
   - Description: "Identifies next best customers for sales focus"
   - **Input**: RAC (Require Input)
   - **Output**: NextBestCustomerFormattedOutput (Show in conversation), ErrorMessage (Show in conversation)


   **Influencer_Map_Flow Action:**
   - Action Name: `Influencer_Map_Flow`
   - Flow: `Influencer_Map_Flow`
   - Description: "Analyzes provider affiliations to identify key relationships"
   - **Input**: TargetAccountName (Require Input), targetAccountId (Require Input)
   - **Output**: FormattedAffiliationOutput (Show in conversation), errorMessage (Show in conversation)

   **Visit_Note_Processor_Simple Action:**
   - Action Name: `Visit_Note_Processor_Simple`
   - Flow: `Visit_Note_Processor_Simple`
   - Description: "Processes and logs visit notes using AI with JSON processing and automatic data creation"
   - **Input**: VoiceNote (Require Input, Collect Data from User)
   - **Output**: FullUpdateSummary (Show in conversation)

## Step 4: Create Agent Topics

Create the Agent Topics through **Agentforce Studio → Agentforce Assets → Topics**:
- [Daily Briefing](agentforce-components/daily-briefing/topic-configuration/Daily_Briefing_Topic.md)
- [Influencer Map](agentforce-components/influencer-map/topic-configuration/Influencer_Map_Topic.md)
- [NextBestCustomer](agentforce-components/get-nbc/topic-configuration/NextBestCustomer_Topic.md)
- [PostCallVisitNote](agentforce-components/visit-note-processor/topic-configuration/PostCallVisitNotes_Topic.md)

Use the Topic details provided in the documentation links above.

## Step 5: Create Life Sciences Field Sales Agent

Create the Life Sciences Field Sales Agent through **Agentforce Studio → Agentforce Agents → New Agent** using the Life Sciences Field Sales Template.

## Step 6: Configure Agent

Add the Topics and Actions to the New Agent.

## Step 7: Test Agent

Test the Agent in Agentforce Studio to ensure all components are working correctly.

## Step 8: Activate Flows

1. Navigate to Setup → Process Automation → Flows
2. Activate the following flows:
   - Influencer_Map_Flow
   - GetNBC
   - Visit_Note_Processor_Simple

## Step 9: Configure User Access and Permissions

### 9.1 Create Permission Set
1. Navigate to Setup → Permission Sets
2. Create new permission set: "Life Sciences Cloud Agentforce User"
3. Assign the following permissions:
   - Customize Application
   - Manage Agentforce
   - View All Data
   - Edit Topics
   - Configure Entities

### 9.2 Assign Agent Access
1. Navigate to Setup → Agentforce → Agents
2. For each agent containing the actions:
   - Click on the agent name
   - Go to the "Access" tab
   - Add end users who will use the Agentforce actions
   - Ensure users have appropriate territory assignments

### 9.3 Assign Permission Set License
1. Navigate to Setup → Permission Set Licenses
2. Assign the **"Prompt Template User"** permission set license to end users
3. This license is required for users to access and use the prompt templates

### 9.4 Assign Permission Set to Users
1. Navigate to Setup → Users
2. For each end user:
   - Click on the user name
   - Go to "Permission Set Assignments"
   - Assign the "Life Sciences Cloud Agentforce User" permission set
   - Ensure the "Prompt Template User" license is also assigned

## Step 10: Assign Permissions

Assign Agent permission to users who need access to the agent functionality.

## Step 11: Test the Installation

### 11.1 Run Tests
```bash
sf apex run test --target-org your-org --class-names DailyBriefingAgentTest
```

### 11.2 Test Agentforce Actions
1. Navigate to Agentforce Chat
2. Test the following utterances:
   - "Generate my daily briefing"
   - "Show me affiliations for [Account Name]"
   - "Who should I meet with next?"
   - "Process my visit notes"

## Troubleshooting

### Common Issues
1. **Flows not available**: Ensure flows are deployed and activated
2. **Territory not found**: Verify user territory assignments
3. **Agentforce actions not working**: Check Agentforce configuration and permissions

### Debug Steps
1. Check Flow execution logs
2. Verify user permissions and territory assignments
3. Review Apex debug logs
4. Test with different time periods and accounts

## Next Steps

After successful installation:
1. Train users on the new capabilities
2. Monitor usage and performance
3. Gather feedback for improvements
4. Plan for future enhancements

## Support

For additional help:
- Check the troubleshooting guide
- Review the API reference
- Contact the Life Sciences Cloud team

