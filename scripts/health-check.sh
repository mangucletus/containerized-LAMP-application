# scripts/health-check.sh
#!/bin/bash

set -e

PROJECT_NAME="student-record-system"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo "🏥 Health Check Report for $PROJECT_NAME"
echo "Generated: $(date)"
echo "=================================================="

# Check ECS Service Health
echo ""
echo "🔧 ECS Service Status:"
aws ecs describe-services \
    --cluster "$PROJECT_NAME-cluster" \
    --services "$PROJECT_NAME-service" \
    --region $AWS_REGION \
    --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount,Pending:pendingCount}' \
    --output table

# Check ECS Tasks
echo ""
echo "📋 ECS Tasks Status:"
aws ecs list-tasks \
    --cluster "$PROJECT_NAME-cluster" \
    --service-name "$PROJECT_NAME-service" \
    --region $AWS_REGION \
    --query 'taskArns[0]' \
    --output text | xargs -I {} aws ecs describe-tasks \
    --cluster "$PROJECT_NAME-cluster" \
    --tasks {} \
    --region $AWS_REGION \
    --query 'tasks[0].{LastStatus:lastStatus,HealthStatus:healthStatus,CPU:cpu,Memory:memory}' \
    --output table

# Check ALB Target Health
echo ""
echo "🎯 ALB Target Health:"
ALB_TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
    --names "$PROJECT_NAME-tg" \
    --region $AWS_REGION \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

aws elbv2 describe-target-health \
    --target-group-arn $ALB_TARGET_GROUP_ARN \
    --region $AWS_REGION \
    --query 'TargetHealthDescriptions[*].{Target:Target.Id,Port:Target.Port,Health:TargetHealth.State}' \
    --output table

# Check RDS Cluster Health
echo ""
echo "🗄️ Database Status:"
aws rds describe-db-clusters \
    --db-cluster-identifier "$PROJECT_NAME-aurora-cluster" \
    --region $AWS_REGION \
    --query 'DBClusters[0].{Status:Status,Engine:Engine,MultiAZ:MultiAZ,BackupRetention:BackupRetentionPeriod}' \
    --output table

# Check Recent Errors
echo ""
echo "🚨 Recent Application Errors (Last 1 Hour):"
aws logs filter-log-events \
    --log-group-name "/aws/ecs/$PROJECT_NAME" \
    --filter-pattern "ERROR" \
    --start-time $(date -d '1 hour ago' +%s)000 \
    --region $AWS_REGION \
    --query 'events[*].{Timestamp:timestamp,Message:message}' \
    --output table 2>/dev/null || echo "No recent errors found"

# Performance Metrics
echo ""
echo "📊 Current Performance Metrics:"
echo "CPU Utilization (Last 15 minutes):"
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name CPUUtilization \
    --dimensions Name=ServiceName,Value="$PROJECT_NAME-service" Name=ClusterName,Value="$PROJECT_NAME-cluster" \
    --start-time $(date -u -d '15 minutes ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --period 300 \
    --statistics Average \
    --region $AWS_REGION \
    --query 'Datapoints[*].{Time:Timestamp,CPU:Average}' \
    --output table

echo ""
echo "Memory Utilization (Last 15 minutes):"
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name MemoryUtilization \
    --dimensions Name=ServiceName,Value="$PROJECT_NAME-service" Name=ClusterName,Value="$PROJECT_NAME-cluster" \
    --start-time $(date -u -d '15 minutes ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --period 300 \
    --statistics Average \
    --region $AWS_REGION \
    --query 'Datapoints[*].{Time:Timestamp,Memory:Average}' \
    --output table

echo ""
echo "=================================================="
echo "✅ Health Check Report Complete"
