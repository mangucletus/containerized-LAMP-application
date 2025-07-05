# scripts/deploy.sh
#!/bin/bash

set -e

# Configuration
PROJECT_NAME="student-record-system"
TERRAFORM_DIR="terraform"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🚀 Deploying infrastructure for $PROJECT_NAME"

# Check if terraform.tfvars exists
if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    echo "❌ Error: terraform.tfvars not found!"
    echo "📋 Please create terraform.tfvars from terraform.tfvars.example"
    echo "   cp $TERRAFORM_DIR/terraform.tfvars.example $TERRAFORM_DIR/terraform.tfvars"
    echo "   # Edit terraform.tfvars with your values"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ Error: AWS CLI not configured or no valid credentials found"
    echo "📋 Please run: aws configure"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "📋 Please start Docker and try again"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Navigate to terraform directory
cd $TERRAFORM_DIR

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate Terraform configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
echo ""
read -p "🤔 Do you want to apply this plan? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Apply deployment
    echo "🚀 Applying deployment..."
    terraform apply tfplan
    
    # Get outputs
    echo ""
    echo "📋 Deployment Outputs:"
    terraform output
    
    echo ""
    echo "✅ Infrastructure deployment completed!"
    echo ""
    echo "🔄 Next steps:"
    echo "1. Build and push your Docker image:"
    echo "   ./scripts/build-and-push.sh"
    echo ""
    echo "2. Access your application at:"
    terraform output -raw application_url 2>/dev/null || echo "   Check the ALB DNS name in the outputs above"
    
else
    echo "❌ Deployment cancelled"
    rm -f tfplan
    exit 1
fi

# Clean up plan file
rm -f tfplan

echo "🎉 Deployment script completed successfully!"
