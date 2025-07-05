# scripts/cleanup.sh
#!/bin/bash

set -e

# Configuration
PROJECT_NAME="student-record-system"
TERRAFORM_DIR="terraform"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🧹 Cleaning up resources for $PROJECT_NAME"

# Warning message
echo "⚠️  WARNING: This will destroy ALL resources created by Terraform!"
echo "   This action cannot be undone."
echo ""
read -p "🤔 Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

# Navigate to terraform directory
cd $TERRAFORM_DIR

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
    echo "ℹ️ No Terraform state found. Nothing to destroy."
    exit 0
fi

# Plan destroy
echo "📋 Planning destroy..."
terraform plan -destroy -out=destroy_plan

# Final confirmation
echo ""
read -p "🚨 FINAL CONFIRMATION: Type 'DELETE' to proceed with destruction: " confirmation
echo ""

if [ "$confirmation" = "DELETE" ]; then
    # Apply destroy
    echo "💥 Destroying infrastructure..."
    terraform apply destroy_plan
    
    echo ""
    echo "✅ Infrastructure destruction completed!"
    
    # Clean up local files
    echo "🧹 Cleaning up local files..."
    rm -f destroy_plan
    rm -f terraform.tfstate*
    rm -f .terraform.lock.hcl
    rm -rf .terraform/
    
    echo "✅ Local cleanup completed!"
    
else
    echo "❌ Destruction cancelled - confirmation did not match 'DELETE'"
    rm -f destroy_plan
    exit 1
fi

echo "🎉 Cleanup completed successfully!"