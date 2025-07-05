# scripts/build-and-push.sh
#!/bin/bash

set -e

# Configuration
PROJECT_NAME="student-record-system"
AWS_REGION="${AWS_REGION:-us-east-1}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "🚀 Building and pushing Docker image for $PROJECT_NAME"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Error: Unable to get AWS account ID. Please check your AWS configuration."
    exit 1
fi

# ECR repository URL
ECR_REPOSITORY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME"

echo "📋 Configuration:"
echo "   AWS Account ID: $AWS_ACCOUNT_ID"
echo "   AWS Region: $AWS_REGION"
echo "   ECR Repository: $ECR_REPOSITORY"
echo "   Image Tag: $IMAGE_TAG"

# Get ECR login token and login to ECR
echo "🔑 Logging into Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY

# Build Docker image
echo "🔨 Building Docker image..."
cd app
docker build -t $PROJECT_NAME:$IMAGE_TAG .

# Tag image for ECR
echo "🏷️ Tagging image for ECR..."
docker tag $PROJECT_NAME:$IMAGE_TAG $ECR_REPOSITORY:$IMAGE_TAG

# Push image to ECR
echo "⬆️ Pushing image to ECR..."
docker push $ECR_REPOSITORY:$IMAGE_TAG

echo "✅ Successfully built and pushed image: $ECR_REPOSITORY:$IMAGE_TAG"

# Update ECS service if it exists
echo "🔄 Checking if ECS service exists..."
if aws ecs describe-services --cluster "$PROJECT_NAME-cluster" --services "$PROJECT_NAME-service" --region $AWS_REGION >/dev/null 2>&1; then
    echo "🔄 Updating ECS service to use new image..."
    aws ecs update-service --cluster "$PROJECT_NAME-cluster" --service "$PROJECT_NAME-service" --force-new-deployment --region $AWS_REGION
    echo "✅ ECS service update initiated"
else
    echo "ℹ️ ECS service not found. Deploy infrastructure first."
fi

echo "🎉 Build and push completed successfully!"