# LSC4CE-AGENTFORCE-SOLUTIONS Deployment Guide

## 🎯 Overview

This comprehensive guide provides step-by-step instructions for deploying the LSC4CE Agentforce Solutions package to a new Salesforce Org. The package includes conversational AI capabilities for field sales representatives in Life Sciences Cloud environments.

## 📋 Prerequisites Checklist

### Salesforce Org Requirements
- [ ] **Salesforce Org** with Life Sciences Cloud for Customer Engagement enabled
- [ ] **Agentforce** enabled and configured
- [ ] **Provider Visit Management** objects enabled
- [ ] **Territory2** and **UserTerritory2Association** configured
- [ ] **Admin permissions** for Agentforce and Life Sciences Cloud configuration
- [ ] **API Version 65.0** or higher

### Required Objects (Must be available in target org)
- [ ] Visit
- [ ] ProviderVisit
- [ ] Account
- [ ] Territory2
- [ ] UserTerritory2Association
- [ ] ProviderAccountTerritorySummary
- [ ] ContactPointAddress
- [ ] Product2
- [ ] Life Sciences Marketable Product

### Development Environment
- [ ] **Salesforce CLI** (sf CLI) installed and authenticated
- [ ] **Git** installed
- [ ] **Access to the repository** code

## 🚀 Step-by-Step Deployment Process

### Step 1: Prepare Your Environment

#### 1.1 Install Salesforce CLI
```bash
# Install Salesforce CLI (if not already installed)
npm install -g @salesforce/cli

# Verify installation
sf --version
```

#### 1.2 Authenticate with Your Target Org
```bash
# Authenticate with your target org
sf org login web --alias your-org-alias --instance-url https://your-instance.salesforce.com

# Verify authentication
sf org display --target-org your-org-alias
```

#### 1.3 Clone/Download the Repository
```bash
# If using Git
git clone https://git.soma.salesforce.com/nilotpal-paul/lsc4ce.git
cd lsc4ce-agentforce-solutions

# Or download and extract the ZIP file to your local directory
```

### Step 2: Validate Prerequisites

#### 2.1 Check Org Features
```bash
# Check if Life Sciences Cloud is enabled
sf data query --query "SELECT Id FROM Account LIMIT 1" --target-org your-org-alias

# Check if Agentforce is available
sf data query --query "SELECT Id FROM Agentforce__Agent__c LIMIT 1" --target-org your-org-alias
```

#### 2.2 Verify Required Objects
```bash
# Check for required objects
sf data query --query "SELECT Id FROM Visit LIMIT 1" --target-org your-org-alias
sf data query --query "SELECT Id FROM ProviderVisit LIMIT 1" --target-org your-org-alias
sf data query --query "SELECT Id FROM Territory2 LIMIT 1" --target-org your-org-alias
```

### Step 3: Deploy the Package

#### 3.1 Using the Deployment Script (Recommended)
```bash
# Make the script executable
chmod +x deployment/deploy.sh

# Deploy using the script
./deployment/deploy.sh your-org-alias
```

#### 3.2 Manual Deployment
```bash
# Deploy all metadata
sf project deploy start --target-org your-org-alias

# Or deploy specific components
sf project deploy start --source-dir force-app --target-org your-org-alias
```

#### 3.3 Verify Deployment
```bash
# Check deployment status
sf project deploy report --target-org your-org-alias

# Verify Apex classes are deployed
sf data query --query "SELECT Id, Name FROM ApexClass WHERE Name LIKE '%DailyBriefing%'" --target-org your-org-alias
```

### Step 4: Activate Flows

#### 4.1 Navigate to Flow Management
1. Go to **Setup** → **Process Automation** → **Flows**
2. Find and activate the following flows:
   - [ ] **Get_Visits_Enhanced**
   - [ ] **Get_Visits_Simple**
   - [ ] **Influencer_Map_Flow**
   - [ ] **GetNBC**
   - [ ] **X258_LSC4CE_NBC_UPDATE**
   - [ ] **Visit_Note_based_Logging**
   - [ ] **Provider_Summarization**
   - [ ] **Get_Provider_Account_Territory_Summary**
   - [ ] **AccountAProductNames**

#### 4.2 Activate Each Flow
1. Click on each flow name
2. Click **Activate**
3. Confirm activation
4. Repeat for all flows listed above

### Step 5: Configure Agentforce Components

#### 5.1 Daily Briefing Agent
1. Navigate to **Setup** → **Agentforce** → **Actions**
2. Create new actions using files from `agentforce-components/daily-briefing/actions/`:
   - [ ] **Calculate_Priority_Metrics_Action**
   - [ ] **Generate_Conversation_Starters_Action**
   - [ ] **Get_Account_Summaries_Action**
   - [ ] **Get_Daily_Visits_Action**

3. Navigate to **Setup** → **Agentforce** → **Topics**
4. Create topics using files from `agentforce-components/daily-briefing/topics/`:
   - [ ] **Conversation_Starters_Topic**
   - [ ] **Daily_Briefing_Topic**
   - [ ] **Priority_Account_Topic**

5. Navigate to **Setup** → **Agentforce** → **Agents**
6. Create agent using files from `agentforce-components/daily-briefing/agents/`:
   - [ ] **Default_Agent**

7. Navigate to **Setup** → **Agentforce** → **Prompts**
8. Create prompt using files from `agentforce-components/daily-briefing/prompts/`:
   - [ ] **Conversation_Starters_Prompt**

#### 5.2 Influencer Map
1. Follow the detailed setup guide in `agentforce-components/influencer-map/setup/AGENTFORCE_SETUP.md`
2. Create the Influencer Map Analysis action
3. Configure the Visit Planning topic integration

#### 5.3 Visit Note Processor
1. Navigate to **Setup** → **Agentforce** → **Prompts**
2. Copy the prompt template from `agentforce-components/visit-note-processor/prompts/agentforce_prompt_template_corrected.txt`
3. Create a new prompt template in Agentforce
4. Configure the Process Visit Notes action

### Step 6: Configure Permissions

#### 6.1 Create Permission Set
1. Navigate to **Setup** → **Permission Sets**
2. Click **New**
3. Create permission set: **"LSC4CE Agentforce User"**
4. Assign the following permissions:
   - [ ] **Customize Application**
   - [ ] **Manage Agentforce**
   - [ ] **View All Data**
   - [ ] **Edit Topics**
   - [ ] **Configure Entities**
   - [ ] **Run Flows**
   - [ ] **View Setup and Configuration**

#### 6.2 Assign Permission Set to Users
1. Navigate to **Setup** → **Permission Sets**
2. Find **"LSC4CE Agentforce User"**
3. Click **Manage Assignments**
4. Assign to users who will use the agentforce features
5. Ensure users have appropriate territory assignments

### Step 7: Test the Installation

#### 7.1 Run Apex Tests
```bash
# Run all tests
sf apex run test --target-org your-org-alias

# Run specific test classes
sf apex run test --target-org your-org-alias --class-names DailyBriefingAgentTest
sf apex run test --target-org your-org-alias --class-names DailyBriefingAgentSimpleTest
sf apex run test --target-org your-org-alias --class-names DailyBriefingOrchestratorTest
```

#### 7.2 Test Agentforce Actions
1. Navigate to **Agentforce Chat**
2. Test the following utterances:
   - [ ] **"Generate my daily briefing"**
   - [ ] **"Show me affiliations for [Account Name]"**
   - [ ] **"What visits do I have today?"**
   - [ ] **"Who should I meet with next?"**
   - [ ] **"Process my visit notes"**

#### 7.3 Test Flows
1. Navigate to **Setup** → **Process Automation** → **Flow**
2. Test each flow individually:
   - [ ] **Get_Visits_Enhanced** - Test with valid territory
   - [ ] **Influencer_Map_Flow** - Test with provider data
   - [ ] **Visit_Note_based_Logging** - Test with sample visit notes

### Step 8: Post-Deployment Configuration

#### 8.1 Configure Territory Assignments
1. Navigate to **Setup** → **Territory Management**
2. Ensure users have proper territory assignments
3. Verify **UserTerritory2Association** records exist

#### 8.2 Configure Sample Data (Optional)
1. Create test accounts with proper territory assignments
2. Create sample visits and provider visits
3. Test the complete workflow

#### 8.3 User Training
1. Provide training on Agentforce capabilities
2. Share the **User Guide** (`documentation/USER_GUIDE.md`)
3. Conduct hands-on training sessions

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Issue 1: Flows Not Available
**Problem**: Flows are deployed but not visible
**Solution**: 
- Check if flows are activated
- Verify user permissions
- Check flow criteria and entry conditions

#### Issue 2: Territory Not Found
**Problem**: Territory-related errors
**Solution**:
- Verify Territory2 setup
- Check UserTerritory2Association records
- Ensure proper territory assignments

#### Issue 3: Agentforce Actions Not Working
**Problem**: Actions fail or return errors
**Solution**:
- Check Agentforce configuration
- Verify permissions
- Review Apex debug logs
- Test with different time periods and accounts

#### Issue 4: Deployment Failures
**Problem**: Metadata deployment fails
**Solution**:
- Check API version compatibility
- Verify org features are enabled
- Review deployment logs
- Ensure all dependencies are met

### Debug Steps
1. **Check Flow execution logs** in Setup → Process Automation → Flow
2. **Verify user permissions** and territory assignments
3. **Review Apex debug logs** in Setup → Developer Console
4. **Test with different time periods** and accounts
5. **Check Agentforce configuration** in Setup → Agentforce

## 📊 Validation Checklist

### Deployment Validation
- [ ] All Apex classes deployed successfully
- [ ] All flows deployed and activated
- [ ] No deployment errors in logs
- [ ] Permission set created and assigned

### Functionality Validation
- [ ] Daily Briefing agent responds correctly
- [ ] Influencer Map analysis works
- [ ] Visit retrieval functions properly
- [ ] Visit note processing works
- [ ] NBC action provides recommendations

### User Access Validation
- [ ] Users can access Agentforce Chat
- [ ] Territory-based filtering works
- [ ] All agentforce actions are available
- [ ] Flows execute without errors

## 📞 Support and Next Steps

### After Successful Deployment
1. **Monitor usage and performance**
2. **Gather user feedback**
3. **Plan for future enhancements**
4. **Schedule regular maintenance**

### Support Resources
- **Troubleshooting Guide**: `documentation/TROUBLESHOOTING.md`
- **API Reference**: `documentation/API_REFERENCE.md`
- **User Guide**: `documentation/USER_GUIDE.md`
- **Setup Guide**: `documentation/SETUP_GUIDE.md`

### Contact Information
For additional help:
- Check the troubleshooting guide
- Review the API reference
- Contact the LSC4CE team

## 🎉 Success!

Once all steps are completed and validated, your LSC4CE Agentforce Solutions package will be fully deployed and ready for use in your Salesforce org. Users will have access to powerful conversational AI capabilities for their field sales activities.

---

**Note**: This deployment guide assumes you have administrative access to the target Salesforce org and the necessary permissions to configure Agentforce and Life Sciences Cloud features.




