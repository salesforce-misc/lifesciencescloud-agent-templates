#!/bin/bash

# LSC4CE Agentforce Solutions Deployment Script
# Usage: ./deploy.sh <target-org-alias>

if [ $# -eq 0 ]; then
    echo "Usage: ./deploy.sh <target-org-alias>"
    echo "Example: ./deploy.sh my-org"
    exit 1
fi

TARGET_ORG=$1

echo "🚀 Deploying LSC4CE Agentforce Solutions to $TARGET_ORG..."

# Deploy the package
echo "📦 Deploying Apex classes and flows..."
sf project deploy start --target-org $TARGET_ORG

if [ $? -eq 0 ]; then
    echo "✅ Deployment successful!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Configure Agentforce components manually:"
    echo "   - Daily Briefing: agentforce-components/daily-briefing/"
    echo "   - Influencer Map: agentforce-components/influencer-map/setup/AGENTFORCE_SETUP.md"
    echo "   - Visit Note Processor: agentforce-components/visit-note-processor/prompts/"
    echo ""
    echo "2. Run tests:"
    echo "   sf apex run test --target-org $TARGET_ORG --class-names DailyBriefingAgentTest"
    echo ""
    echo "3. Activate flows in Setup → Process Automation → Flows"
else
    echo "❌ Deployment failed. Check the error messages above."
    exit 1
fi

