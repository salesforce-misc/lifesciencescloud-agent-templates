# Daily Briefing Agentforce Components

## Overview
This directory contains all Agentforce components for the Daily Briefing functionality, including actions, topics, agents, and prompts.

## Components

### Actions
- `Get_Daily_Visits_Action.agentforce-action` - Retrieves daily visits for a user
- `Get_Account_Summaries_Action.agentforce-action` - Gets account summaries for visits
- `Calculate_Priority_Metrics_Action.agentforce-action` - Calculates priority metrics
- `Generate_Conversation_Starters_Action.agentforce-action` - Generates conversation starters

### Topics
- `Daily_Briefing_Topic.agentforce-topic` - Main topic for daily briefing requests


### Agents
- `Default_Agent.agentforce-agent` - Default agent configuration

### Prompts
- `Conversation_Starters_Prompt.agentforce-prompt` - Prompt template for conversation starters

## Setup Instructions
1. Deploy the Apex classes and flows first
2. Create Agentforce actions using the action files
3. Configure topics using the topic files
4. Set up prompts using the prompt files
5. Test the integration

## Dependencies
- DailyBriefingAgent Apex class
- DailyBriefingOrchestrator Apex class
- Get_Visits_Enhanced Flow
- BriefingData and BriefingResponse classes

