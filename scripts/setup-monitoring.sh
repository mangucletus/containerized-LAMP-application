# scripts/setup-monitoring.sh
#!/bin/bash

set -e

PROJECT_NAME="student-record-system"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🔧 Setting up monitoring for $PROJECT_NAME"

# Create CloudWatch Dashboard
echo "📊 Creating CloudWatch Dashboard..."
aws cloudwatch put-dashboard \
    --dashboard-name "$PROJECT_NAME-dashboard" \
    --dashboard-body file://cloudwatch-dashboard.json \
    --region $AWS_REGION

# Create CPU Utilization Alarm
echo "🚨 Creating CPU utilization alarm..."
aws cloudwatch put-metric-alarm \
    --alarm-name "$PROJECT_NAME-high-cpu" \
    --alarm-description "High CPU utilization for ECS service" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 70.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=ServiceName,Value="$PROJECT_NAME-service" Name=ClusterName,Value="$PROJECT_NAME-cluster" \
    --region $AWS_REGION

# Create Memory Utilization Alarm
echo "🚨 Creating memory utilization alarm..."
aws cloudwatch put-metric-alarm \
    --alarm-name "$PROJECT_NAME-high-memory" \
    --alarm-description "High memory utilization for ECS service" \
    --metric-name MemoryUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=ServiceName,Value="$PROJECT_NAME-service" Name=ClusterName,Value="$PROJECT_NAME-cluster" \
    --region $AWS_REGION

# Create ALB 5xx Error Alarm
echo "🚨 Creating ALB error alarm..."
aws cloudwatch put-metric-alarm \
    --alarm-name "$PROJECT_NAME-alb-5xx-errors" \
    --alarm-description "High 5xx error rate from ALB" \
    --metric-name HTTPCode_Target_5XX_Count \
    --namespace AWS/ApplicationELB \
    --statistic Sum \
    --period 300 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --region $AWS_REGION

# Create Database Connection Alarm
echo "🚨 Creating database connection alarm..."
aws cloudwatch put-metric-alarm \
    --alarm-name "$PROJECT_NAME-db-connections" \
    --alarm-description "High database connections" \
    --metric-name DatabaseConnections \
    --namespace AWS/RDS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=DBClusterIdentifier,Value="$PROJECT_NAME-aurora-cluster" \
    --region $AWS_REGION

echo "✅ Monitoring setup completed!"
echo "📊 Dashboard URL: https://console.aws.amazon.com/cloudwatch/home?region=$AWS_REGION#dashboards:name=$PROJECT_NAME-dashboard"