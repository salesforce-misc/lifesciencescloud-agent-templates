#!/bin/bash

# lifesciencescloud-agent-templates - Deployment Script
# This script deploys the complete Agentforce package to a Salesforce org

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if target org is provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <target-org-alias>"
    print_error "Example: $0 myorg"
    exit 1
fi

TARGET_ORG=$1

print_status "Starting lifesciencescloud-agent-templates deployment..."
print_status "Target Org: $TARGET_ORG"

# Check if Salesforce CLI is installed
if ! command -v sf &> /dev/null; then
    print_error "Salesforce CLI is not installed. Please install it first."
    exit 1
fi

# Check if org is authenticated
if ! sf org list | grep -q "$TARGET_ORG"; then
    print_error "Org '$TARGET_ORG' is not authenticated. Please authenticate first using:"
    print_error "sf org login web -a $TARGET_ORG"
    exit 1
fi

print_status "Deploying metadata to $TARGET_ORG..."

# Deploy the metadata
if sf project deploy start --source-dir force-app --target-org "$TARGET_ORG" --wait 10; then
    print_success "Metadata deployment completed successfully!"
else
    print_error "Metadata deployment failed!"
    exit 1
fi

print_status "Creating Topic records..."

# Create Topic records
if sf apex run --file scripts/create-topics.apex --target-org "$TARGET_ORG"; then
    print_success "Topic records created successfully!"
else
    print_warning "Topic creation failed or topics already exist. Continuing..."
fi

print_status "Validating deployment..."

# Validate deployment
if sf apex run --file scripts/validate-deployment.apex --target-org "$TARGET_ORG"; then
    print_success "Deployment validation completed successfully!"
else
    print_warning "Deployment validation failed. Please check the org manually."
fi

print_success "lifesciencescloud-agent-templates deployment completed!"
print_status "You can now access Agentforce Studio in your org to test the agents."

# Open the org
read -p "Would you like to open the org in your browser? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sf org open --target-org "$TARGET_ORG"
fi
