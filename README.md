# lifesciencescloud-agent-templates

![Agentforce Logo](https://via.placeholder.com/200x100/0070D2/FFFFFF?text=Agentforce)

Welcome to the lifesciencescloud-agent-templates, a comprehensive solution for deploying and managing Salesforce Agentforce agents. This package provides a complete framework for creating, deploying, and managing AI-powered agents across different business scenarios.

The lifesciencescloud-agent-templates showcases **Agentforce Agents**, **GenAI Functions**, and **Custom Business Logic**.

## Table of Contents

- [Installation](#installation)
- [Features](#features)
- [Architecture](#architecture)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)

## Installation

### Requirements

#### Environment

The lifesciencescloud-agent-templates requires licenses for the following features:

- Agentforce
- Einstein Platform
- Custom Objects and Fields

**Trailhead Badge**: Obtain an Org with these features and learn more about the app with the [Quick Start: Explore Agentforce](https://trailhead.salesforce.com) Trailhead badge.

> **Important**
> 
> Start from a brand-new environment to avoid conflicts with previous work you may have done.

#### Salesforce CLI

Install the Salesforce CLI or check that your installed CLI version is greater than `2.109.6` by running `sf -v` in a terminal.

If you need to update the Salesforce CLI, either run `sf update` or `npm install --global @salesforce/cli` depending on how you installed the CLI.

### Step 1: Feature Activation

1. Make sure that Agentforce is enabled in your org.
   To check this, go to **Setup** → **Agentforce Agents**. The page should show available agents if Agentforce is properly configured.

2. From **Setup**, go to **Einstein Setup** and click **Turn on Einstein**.

3. From **Setup**, go to **Agentforce Agents** and toggle on **Agentforce**.

### Step 2: Package Deployment

1. Clone this repository:
   ```bash
   git clone https://github.com/salesforce-misc/lifesciencescloud-agent-templates
   cd lifesciencescloud-agent-templates
   ```

2. Authorize your org with the Salesforce CLI, set it as the default org for this project and save an alias (`agentforce-org` in the command below):
   ```bash
   sf org login web -s -a agentforce-org
   ```

3. Deploy the complete package:
   ```bash
   ./scripts/deploy.sh agentforce-org
   ```

4. If your org isn't already open, open it now:
   ```bash
   sf org open
   ```

## Features

### 🤖 **AI-Powered Agents**

- **Daily Briefing Agent**: Generates comprehensive daily briefings with key insights and priorities
- **Influencer Map Agent**: Creates relationship maps and influence networks
- **Next Best Customer Agent**: Identifies and recommends high-priority customers
- **Post-Call Visit Notes Agent**: Processes and formats visit notes automatically

### 🧠 **GenAI Functions**

- **Generate Complete Daily Briefing**: Apex-based action for comprehensive briefings
- **Get Next Best Customer**: Flow-based action for customer recommendations
- **Influencer Map Flow**: Flow-based action for relationship mapping
- **Visit Note Processor**: Flow-based action for note processing

### 📊 **Business Intelligence**

- **Territory Analysis**: Territory-based data analysis and insights
- **Account Scoring**: Automated account prioritization and scoring
- **Visit Optimization**: Smart visit scheduling and planning
- **Conversation Starters**: AI-generated talking points and conversation prompts

### 🔧 **Custom Components**

- **12 Apex Classes**: Complete business logic and data processing
- **4 Salesforce Flows**: Automated workflows and business processes
- **13 GenAI Prompt Templates**: AI-powered conversation and data processing
- **4 Agentforce Topics**: Specialized knowledge areas and capabilities

## Architecture

### **Three-Tier Agentforce Architecture**

The package follows the modern Agentforce architecture introduced in Winter '26:

```
GenAiPlannerBundle (Complete Agent)
├── References GenAiPlugins (Topics)
│   ├── Daily_Briefing
│   ├── Influencer_Map
│   ├── NextBestCustomer
│   └── PostCallVisitNotes
└── Each GenAiPlugin references GenAiFunctions (Actions)
    ├── Generate_Complete_Daily_Briefing
    ├── GetNBC
    ├── Influencer_Map_Flow
    └── Visit_Note_Processor_Simple
```

### **Component Structure**

- **GenAiPlannerBundles**: Complete agent definitions with reasoning and planning capabilities
- **GenAiPlugins**: Topic definitions with specialized instructions and capabilities
- **GenAiFunctions**: Individual action implementations (Apex, Flows, or Prompt Templates)
- **GenAiPromptTemplates**: AI-powered conversation and data processing templates

## Usage

### **Accessing Agents**

1. Navigate to **Agentforce Studio** in your Salesforce org
2. Select the agent you want to interact with
3. Start a conversation using natural language

### **Example Interactions**

#### Daily Briefing Agent
```
"Generate my daily briefing"
"What are my priority accounts for today?"
"Show me my visit schedule"
```

#### Influencer Map Agent
```
"Create an influencer map for Acme Corp"
"Show me the decision makers at this account"
"Who are the key influencers in this territory?"
```

#### Next Best Customer Agent
```
"Who are my next best customers?"
"Show me high-priority accounts in my territory"
"Recommend customers for this week"
```

#### Post-Call Visit Notes Agent
```
"Process my visit notes from today"
"Format my meeting notes"
"Create a summary of my customer interactions"
```

## Troubleshooting

### **Deployment Issues**

#### Salesforce CLI deployment fails with metadata errors
This may happen if the metadata structure is incompatible. To fix it:

1. Ensure you're using Salesforce CLI version 2.109.6 or higher
2. Check that your org has the required licenses
3. Verify that Agentforce is properly enabled

#### Agent not responding in Agentforce Studio
If agents are not responding:

1. Check that all GenAiFunctions are properly deployed
2. Verify that GenAiPlugins reference the correct functions
3. Ensure that GenAiPlannerBundles are properly configured

### **Common Issues**

#### "Agent not found" error
- Verify that the GenAiPlannerBundle is deployed and active
- Check that the agent is properly configured in Agentforce Studio

#### "Function not available" error
- Ensure that GenAiFunctions are deployed and active
- Verify that GenAiPlugins reference the correct function names

#### "Topic not recognized" error
- Check that GenAiPlugins are deployed and active
- Verify that intent patterns are properly configured

## Development

### **Creating Custom Agents**

1. **Create GenAiFunction**: Define individual actions using Apex, Flows, or Prompt Templates
2. **Create GenAiPlugin**: Define topics with instructions and function references
3. **Create GenAiPlannerBundle**: Define complete agents with plugin references
4. **Deploy and Test**: Use the deployment scripts to deploy and validate

### **Extending Existing Agents**

1. **Add New Functions**: Create additional GenAiFunctions for new capabilities
2. **Update Plugins**: Add function references to existing GenAiPlugins
3. **Enhance Instructions**: Update plugin instructions for better AI understanding
4. **Test and Deploy**: Validate changes and deploy updates

### **Best Practices**

- **Modular Design**: Keep functions focused on specific tasks
- **Clear Instructions**: Provide detailed instructions for AI understanding
- **Error Handling**: Implement robust error handling in all functions
- **Testing**: Thoroughly test all agents before deployment

## Contributing

We welcome contributions to the lifesciencescloud-agent-templates! Please follow these guidelines:

1. **Fork the repository** and create a feature branch
2. **Follow coding standards** and include proper documentation
3. **Test thoroughly** before submitting pull requests
4. **Update documentation** for any new features or changes

### **Development Setup**

1. Clone the repository
2. Install Salesforce CLI
3. Set up a development org
4. Deploy the package for testing

### **Submitting Changes**

1. Create a pull request with a clear description
2. Include tests for new functionality
3. Update documentation as needed
4. Ensure all checks pass

## About

Sample application that showcases **Agentforce Agents**, **GenAI Functions**, and **Custom Business Logic**.

### Topics

- agentforce
- ai
- salesforce
- agents
- genai
- automation

### Resources

- [Salesforce Agentforce Documentation](https://help.salesforce.com/s/articleView?id=sf.agentforce_overview.htm)
- [GenAI Functions Guide](https://help.salesforce.com/s/articleView?id=sf.genai_functions.htm)
- [Agentforce Studio](https://help.salesforce.com/s/articleView?id=sf.agentforce_studio.htm)

### License

MIT License

### Code of Conduct

[Code of Conduct](CODE_OF_CONDUCT.md)

### Security Policy

[Security Policy](SECURITY.md)