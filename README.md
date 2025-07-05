# Containerized LAMP Application - Student Record System

## Live Application Link
**[View Live Application](http://student-record-system-alb-1334382597.eu-central-1.elb.amazonaws.com)** 

A modern, cloud-native Student Record System built with PHP, Apache, MySQL, and deployed on AWS ECS Fargate using Infrastructure as Code.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Architecture](#architecture)
6. [Prerequisites](#prerequisites)
7. [Quick Start](#quick-start)
8. [Detailed Deployment Guide](#detailed-deployment-guide)
9. [Local Development](#local-development)
10. [Configuration](#configuration)
11. [Monitoring and Logging](#monitoring-and-logging)
12. [Security](#security)
13. [Scaling](#scaling)
14. [Performance Optimization](#performance-optimization)
15. [Troubleshooting](#troubleshooting)
16. [Maintenance](#maintenance)
17. [Cost Estimation](#cost-estimation)
18. [Contributing](#contributing)

---

## Project Overview

This project demonstrates the deployment of a containerized LAMP stack application to Amazon Web Services using best practices for cloud architecture, security, and DevOps. The application is a simple Student Record System that provides CRUD operations for managing student data.

### Key Achievements

- **Cloud-Native Architecture**: Serverless containers with ECS Fargate
- **High Availability**: Multi-AZ deployment with auto-scaling
- **Infrastructure as Code**: Fully automated with modularized Terraform
- **Security**: VPC isolation, security groups, and IAM roles with least privilege
- **Monitoring**: Comprehensive CloudWatch integration with custom dashboards
- **Production Ready**: Includes monitoring, alerting, backup, and disaster recovery

---

## Features

### Application Features
- **Home Page**: Display all students in a responsive table format
- **Add Student**: Modal form to add new students (Name, Age, Department)
- **Delete Student**: One-click button to remove students from the database
- **Responsive Design**: Mobile-friendly Bootstrap interface
- **Real-time Data**: Live database connectivity with Aurora MySQL

### Infrastructure Features
- **Serverless Containers**: ECS Fargate eliminates server management
- **Auto Scaling**: Automatic scaling based on CPU and memory metrics
- **Load Balancing**: Application Load Balancer with health checks
- **High Availability**: Multi-AZ deployment across availability zones
- **Security**: VPC isolation with private subnets for backend components
- **Monitoring**: CloudWatch logs, metrics, and custom dashboards
- **Backup**: Automated daily backups with 7-day retention

---

## Technology Stack

- **Frontend**: HTML5, CSS3, Bootstrap 5.1.3
- **Backend**: PHP 8.1, Apache 2.4
- **Database**: Aurora MySQL 8.0
- **Container**: Docker
- **Orchestration**: AWS ECS Fargate
- **Load Balancer**: Application Load Balancer (ALB)
- **DNS**: Route 53 (optional)
- **Infrastructure**: Terraform
- **Monitoring**: CloudWatch
- **Registry**: Amazon ECR

---

## Project Structure

```
containerized-lamp-application/
├── README.md                           # This comprehensive documentation
├── LICENSE                             # MIT License
├── Makefile                            # Build automation commands
├── .env.example                        # Environment variables template
├── .gitignore                          # Git ignore rules
├── docker-compose.yml                  # Local development environment
├── init.sql                            # Database initialization script
├── cloudwatch-dashboard.json           # CloudWatch dashboard configuration
│
├── app/                                # Application source code
│   ├── Dockerfile                      # Container definition
│   └── src/                            # PHP application files
│       ├── config.php                  # Database configuration
│       ├── index.php                   # Main page - list students
│       ├── add_student.php             # Add student form handler
│       ├── delete_student.php          # Delete student handler
│       └── assets/                     # CSS and static files
│           └── style.css               # Application styles
│
├── terraform/                          # Infrastructure as Code
│   ├── main.tf                         # Main Terraform configuration
│   ├── variables.tf                    # Input variables
│   ├── outputs.tf                      # Output values
│   ├── terraform.tfvars.example        # Example variables file
│   └── modules/                        # Modularized Terraform code
│       ├── ecr/                        # Container registry module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── iam/                        # IAM roles and policies module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── rds/                        # Aurora MySQL database module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── alb/                        # Application Load Balancer module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── ecs/                        # ECS service and cluster module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── route53/                    # DNS configuration module
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
└── scripts/                            # Deployment and utility scripts
    ├── build-and-push.sh               # Build and push Docker image
    ├── deploy.sh                       # Deploy infrastructure
    ├── cleanup.sh                      # Cleanup resources
    ├── setup-monitoring.sh             # Setup CloudWatch monitoring
    └── health-check.sh                 # Health check script
```

---

## Command Line Interface (CLI - AWS CLI | ECS CLI | Copilot CLI)

For command-line usage, please refer to the implementation in the [`commandline-only`](./commandline-only) folder.

### Quick Start

```bash
# Navigate to the CLI implementation
cd commandline-only

```
---



## Architecture

### AWS Architecture Overview

```mermaid
graph TB
    User[End Users] --> Internet[Internet]
    Internet --> Route53[Route 53 DNS]
    Route53 --> ALB[Application Load Balancer]
    
    subgraph "AWS Cloud"
        subgraph "VPC - 10.0.0.0/16"
            subgraph "Public Subnets"
                ALB --> IGW[Internet Gateway]
                NAT1[NAT Gateway AZ-1a]
                NAT2[NAT Gateway AZ-1b]
            end
            
            subgraph "Private Subnets"
                ALB --> ECS1[ECS Fargate Task 1]
                ALB --> ECS2[ECS Fargate Task 2]
                ECS1 --> RDS[(Aurora MySQL Cluster)]
                ECS2 --> RDS
                ECS1 --> NAT1
                ECS2 --> NAT2
            end
        end
        
        subgraph "Supporting Services"
            ECR[Container Registry]
            CloudWatch[CloudWatch Monitoring]
            IAM[IAM Roles]
        end
    end
    
    ECS1 -.-> ECR
    ECS2 -.-> ECR
    ECS1 -.-> CloudWatch
    ECS2 -.-> CloudWatch
    RDS -.-> CloudWatch
    
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef compute fill:#EC7211,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef database fill:#3F48CC,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef network fill:#8C4FFF,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef storage fill:#569A31,stroke:#232F3E,stroke-width:2px,color:#232F3E
    
    class ALB,IGW,NAT1,NAT2,Route53 network
    class ECS1,ECS2,ECR compute
    class RDS database
    class CloudWatch,IAM aws
```

### Data Flow Architecture

```mermaid
sequenceDiagram
    participant User as User Browser
    participant DNS as Route 53 DNS
    participant ALB as Load Balancer
    participant ECS as ECS Container
    participant RDS as MySQL Database
    participant Logs as CloudWatch
    
    User->>DNS: 1. DNS Query
    DNS-->>User: 2. IP Address
    User->>ALB: 3. HTTP Request
    ALB->>ECS: 4. Forward Request
    ECS->>RDS: 5. Database Query
    RDS-->>ECS: 6. Query Results
    ECS-->>ALB: 7. HTTP Response
    ALB-->>User: 8. Final Response
    ECS->>Logs: 9. Application Logs
    RDS->>Logs: 10. Database Metrics
```

### Network Security Architecture

```mermaid
graph TB
    subgraph "Internet"
        Users[Global Users]
    end
    
    subgraph "AWS Security Layers"
        subgraph "Edge Security"
            Route53[Route 53 DNS Protection]
            ACM[SSL Certificate Manager]
        end
        
        subgraph "Network Security"
            ALB_SG[ALB Security Group<br/>Ports: 80, 443<br/>Source: 0.0.0.0/0]
            ECS_SG[ECS Security Group<br/>Port: 80<br/>Source: ALB Only]
            RDS_SG[RDS Security Group<br/>Port: 3306<br/>Source: ECS Only]
        end
        
        subgraph "Access Control"
            IAM_Roles[IAM Roles<br/>Least Privilege Access]
            Task_Role[ECS Task Role<br/>Application Permissions]
            Exec_Role[ECS Execution Role<br/>Infrastructure Permissions]
        end
        
        subgraph "Data Protection"
            VPC_Isolation[VPC Network Isolation]
            Private_Subnets[Private Subnets<br/>No Internet Access]
            Encryption[Data Encryption<br/>At Rest and In Transit]
        end
    end
    
    Users --> Route53
    Route53 --> ACM
    ACM --> ALB_SG
    ALB_SG --> ECS_SG
    ECS_SG --> RDS_SG
    
    IAM_Roles --> Task_Role
    IAM_Roles --> Exec_Role
    
    VPC_Isolation --> Private_Subnets
    Private_Subnets --> Encryption
    
    classDef security fill:#DD344C,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef network fill:#8C4FFF,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef access fill:#4A90E2,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef data fill:#569A31,stroke:#232F3E,stroke-width:2px,color:#fff
    
    class Route53,ACM security
    class ALB_SG,ECS_SG,RDS_SG network
    class IAM_Roles,Task_Role,Exec_Role access
    class VPC_Isolation,Private_Subnets,Encryption data
```

### Infrastructure Components

```mermaid
graph TB
    subgraph "Terraform Infrastructure"
        subgraph "Core Configuration"
            Main[main.tf<br/>Root Module]
            Variables[variables.tf<br/>Input Parameters]
            Outputs[outputs.tf<br/>Export Values]
        end
        
        subgraph "Terraform Modules"
            ECR_Mod[ECR Module<br/>Container Registry]
            IAM_Mod[IAM Module<br/>Roles and Policies]
            RDS_Mod[RDS Module<br/>Aurora MySQL]
            ALB_Mod[ALB Module<br/>Load Balancer]
            ECS_Mod[ECS Module<br/>Fargate Service]
            Route53_Mod[Route53 Module<br/>DNS Management]
        end
    end
    
    subgraph "AWS Resources"
        subgraph "Networking"
            VPC[VPC 10.0.0.0/16]
            Subnets[4 Subnets<br/>2 Public + 2 Private]
            RouteTable[Route Tables<br/>Internet and NAT Routes]
            SecurityGroups[Security Groups<br/>ALB, ECS, RDS]
            NATGW[NAT Gateways<br/>High Availability]
            IGW[Internet Gateway]
        end
        
        subgraph "Compute"
            ECS_Cluster[ECS Cluster<br/>Fargate Provider]
            ECS_Service[ECS Service<br/>Auto Scaling Enabled]
            TaskDef[Task Definition<br/>Container Configuration]
            ALB_Resource[Application Load Balancer<br/>Multi-AZ]
            TargetGroup[Target Group<br/>Health Checks]
        end
        
        subgraph "Database"
            Aurora_Cluster[Aurora MySQL Cluster<br/>Multi-AZ Setup]
            Aurora_Instance[Aurora Instance<br/>db.t3.medium]
            DB_SubnetGroup[DB Subnet Group<br/>Private Subnets]
        end
        
        subgraph "Registry"
            ECR_Repo[ECR Repository<br/>Container Images]
        end
        
        subgraph "Monitoring"
            CloudWatch_Logs[CloudWatch Log Groups]
            CloudWatch_Alarms[CloudWatch Alarms]
        end
    end
    
    Main --> VPC
    Main --> Subnets
    Main --> RouteTable
    
    ECR_Mod --> ECR_Repo
    IAM_Mod --> SecurityGroups
    RDS_Mod --> Aurora_Cluster
    RDS_Mod --> Aurora_Instance
    ALB_Mod --> ALB_Resource
    ALB_Mod --> TargetGroup
    ECS_Mod --> ECS_Cluster
    ECS_Mod --> ECS_Service
    ECS_Mod --> TaskDef
    ECS_Mod --> CloudWatch_Logs
    Route53_Mod --> RouteTable
    
    classDef terraform fill:#623CE4,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef networking fill:#8C4FFF,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef compute fill:#EC7211,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef database fill:#3F48CC,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef registry fill:#569A31,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef monitoring fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E
    
    class Main,Variables,Outputs,ECR_Mod,IAM_Mod,RDS_Mod,ALB_Mod,ECS_Mod,Route53_Mod terraform
    class VPC,Subnets,RouteTable,SecurityGroups,NATGW,IGW networking
    class ECS_Cluster,ECS_Service,TaskDef,ALB_Resource,TargetGroup compute
    class Aurora_Cluster,Aurora_Instance,DB_SubnetGroup database
    class ECR_Repo registry
    class CloudWatch_Logs,CloudWatch_Alarms monitoring
```

### Auto Scaling and High Availability

```mermaid
graph TB
    subgraph "Auto Scaling Triggers"
        CPU[CPU Utilization > 70%]
        Memory[Memory Utilization > 80%]
        RequestCount[High Request Count]
    end
    
    subgraph "Scaling Policies"
        ScaleOut[Scale Out Policy<br/>Add Tasks]
        ScaleIn[Scale In Policy<br/>Remove Tasks]
        TargetTracking[Target Tracking<br/>Maintain 70% CPU]
    end
    
    subgraph "ECS Service Capacity"
        MinCapacity[Minimum: 1 Task]
        DesiredCapacity[Desired: 2 Tasks]
        MaxCapacity[Maximum: 10 Tasks]
    end
    
    subgraph "Health Monitoring"
        ALB_Health[ALB Health Checks<br/>HTTP GET /]
        ECS_Health[ECS Health Checks<br/>Container Status]
        RDS_Health[RDS Health Checks<br/>Database Availability]
    end
    
    subgraph "High Availability"
        MultiAZ[Multi-AZ Deployment<br/>us-east-1a + us-east-1b]
        ALB_Routing[ALB Load Distribution<br/>Round Robin]
        AutoRecovery[Automatic Recovery<br/>Failed Task Replacement]
    end
    
    subgraph "Backup Strategy"
        DB_Backup[Database Backups<br/>7-day Retention]
        Container_Backup[Container Images<br/>ECR Versioning]
        Config_Backup[Infrastructure Backup<br/>Terraform State]
    end
    
    CPU --> ScaleOut
    Memory --> ScaleOut
    RequestCount --> ScaleOut
    
    ScaleOut --> MaxCapacity
    ScaleIn --> MinCapacity
    TargetTracking --> DesiredCapacity
    
    ALB_Health --> AutoRecovery
    ECS_Health --> AutoRecovery
    RDS_Health --> AutoRecovery
    
    MultiAZ --> ALB_Routing
    ALB_Routing --> AutoRecovery
    
    classDef trigger fill:#FF6B6B,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef scaling fill:#4ECDC4,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef capacity fill:#45B7D1,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef health fill:#96CEB4,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef availability fill:#FFEAA7,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef backup fill:#A29BFE,stroke:#232F3E,stroke-width:2px,color:#232F3E
    
    class CPU,Memory,RequestCount trigger
    class ScaleOut,ScaleIn,TargetTracking scaling
    class MinCapacity,DesiredCapacity,MaxCapacity capacity
    class ALB_Health,ECS_Health,RDS_Health health
    class MultiAZ,ALB_Routing,AutoRecovery availability
    class DB_Backup,Container_Backup,Config_Backup backup
```

---

## Prerequisites

### Required Tools
- **AWS CLI** version 2.x or higher
- **Docker Desktop** or Docker Engine
- **Terraform** version 1.0 or higher
- **Git** for version control

### AWS Account Setup
- AWS account with administrative privileges
- AWS CLI configured with access keys
- Appropriate IAM permissions for:
  - ECS, ECR, RDS, ALB, Route53, IAM, VPC, CloudWatch

### Verification Commands
```bash
# Check AWS CLI configuration
aws sts get-caller-identity

# Check Docker installation
docker --version
docker info

# Check Terraform installation
terraform version

# Verify AWS permissions
aws iam get-user
```

---

## Quick Start

### 1. Clone and Setup
```bash
mkdir containerized-lamp-application
cd containerized-lamp-application
# Copy all provided code into the directory structure
```

### 2. Configure Variables
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 3. Deploy Infrastructure
```bash
./scripts/deploy.sh
```

### 4. Build and Deploy Application
```bash
./scripts/build-and-push.sh
```

### 5. Access Application
```bash
# Get application URL
terraform output application_url
```

---

## Detailed Deployment Guide

### Phase 1: Project Setup

**Step 1.1: Create Project Directory Structure**
```bash
# Create main project directory
mkdir containerized-lamp-application
cd containerized-lamp-application

# Create directory structure
mkdir -p app/src/assets
mkdir -p terraform/modules/{ecr,iam,rds,alb,ecs,route53}
mkdir -p scripts
mkdir -p docs
```

**Step 1.2: Create Application Files**

Create all the PHP application files, Terraform modules, and scripts as provided in the artifacts.

**Step 1.3: Make Scripts Executable**
```bash
chmod +x scripts/*.sh
```

### Phase 2: Infrastructure Configuration

**Step 2.1: Configure Variables**
```bash
# Copy example variables file
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit the variables file with your specific values
nano terraform/terraform.tfvars
```

**Sample `terraform/terraform.tfvars`:**
```hcl
# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "student-record-system"
environment  = "production"

# Network Configuration
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.10.0/24", "10.0.20.0/24"]

# Database Configuration
db_username = "admin"
db_password = "SecurePassword123!"
db_name     = "student_db"

# Domain Configuration (optional - leave empty if not using custom domain)
domain_name         = ""  # e.g., "yourdomain.com"
subdomain          = "app"
ssl_certificate_arn = ""  # e.g., "arn:aws:acm:us-east-1:123456789012:certificate/..."

# ECS Configuration
desired_count  = 2
cpu           = 256
memory        = 512
container_port = 80
```

### Phase 3: Local Development and Testing

**Step 3.1: Test Application Locally**
```bash
# Start local environment
docker-compose up -d

# Test application
curl http://localhost:8080

# View logs
docker-compose logs -f web

# Stop local environment
docker-compose down
```

### Phase 4: AWS Infrastructure Deployment

**Step 4.1: Deploy Infrastructure**
```bash
# Navigate to project root
cd containerized-lamp-application

# Run deployment script
./scripts/deploy.sh
```

The script will:
1. Check prerequisites
2. Initialize Terraform
3. Validate configuration
4. Show deployment plan
5. Apply infrastructure changes

**Step 4.2: Monitor Deployment**
```bash
# Check ECS cluster status
aws ecs describe-clusters --clusters student-record-system-cluster

# Check RDS status
aws rds describe-db-clusters --db-cluster-identifier student-record-system-aurora-cluster

# Check ALB status
aws elbv2 describe-load-balancers --names student-record-system-alb
```

### Phase 5: Application Deployment

**Step 5.1: Build and Push Container Image**
```bash
# Build and push Docker image
./scripts/build-and-push.sh
```

**Step 5.2: Verify Deployment**
```bash
# Check ECS service status
aws ecs describe-services \
    --cluster student-record-system-cluster \
    --services student-record-system-service

# Check target group health
aws elbv2 describe-target-health \
    --target-group-arn $(terraform output -raw target_group_arn)
```

### Phase 6: Access and Testing

**Step 6.1: Get Application URL**
```bash
# Get ALB DNS name
terraform output application_url
```

**Step 6.2: Test Application**
```bash
# Test homepage
curl -I http://$(terraform output -raw alb_dns_name)

# Load test (optional)
ab -n 1000 -c 10 http://$(terraform output -raw alb_dns_name)/
```

---

## Local Development

### Development Environment Setup

```bash
# Start local development environment
docker-compose up -d

# Access application
open http://localhost:8080

# View application logs
docker-compose logs -f web

# View database logs
docker-compose logs -f mysql

# Execute commands in containers
docker-compose exec web bash
docker-compose exec mysql mysql -u root -p

# Stop development environment
docker-compose down

# Remove volumes (reset database)
docker-compose down -v
```

### Development Workflow

1. **Make Code Changes**: Edit files in `app/src/`
2. **Test Locally**: Changes are reflected immediately via volume mounts
3. **Build Container**: `docker build -t student-record-system ./app`
4. **Deploy to AWS**: `./scripts/build-and-push.sh`

### Using Makefile Commands

```bash
# View available commands
make help

# Start local development
make dev

# Build and deploy
make build

# View logs
make logs

# Clean up
make clean
```

---

## Configuration

### Environment Variables

The application uses the following environment variables:

```bash
# Database Configuration
DB_HOST=aurora-cluster-endpoint
DB_USER=admin
DB_PASSWORD=secure-password
DB_NAME=student_db
DB_PORT=3306
```

### Terraform Variables

Key configuration options in `terraform.tfvars`:

```hcl
# Project Settings
project_name = "student-record-system"
environment  = "production"
aws_region   = "us-east-1"

# Network Settings
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# ECS Settings
desired_count = 2
cpu          = 256
memory       = 512

# Database Settings
db_username = "admin"
db_password = "SecurePassword123!"
db_name     = "student_db"

# SSL/Domain Settings (optional)
domain_name         = "yourdomain.com"
subdomain          = "app"
ssl_certificate_arn = "arn:aws:acm:..."
```

### Container Configuration

**Dockerfile Configuration:**
- Base Image: `php:8.1-apache`
- Exposed Port: 80
- Health Check: HTTP GET /
- PHP Extensions: PDO MySQL, mbstring, GD

**Resource Limits:**
- CPU: 256 units (0.25 vCPU)
- Memory: 512 MB
- Storage: 20 GB (ephemeral)

---

## Monitoring and Logging

### CloudWatch Monitoring Dashboard

```mermaid
graph TB
    subgraph "CloudWatch Dashboard"
        subgraph "ECS Metrics"
            CPU_Widget[CPU Utilization<br/>Real-time Percentage<br/>Threshold: 70%]
            Memory_Widget[Memory Utilization<br/>Real-time Percentage<br/>Threshold: 80%]
            TaskCount_Widget[Running Tasks<br/>Current vs Desired<br/>Auto Scaling Status]
        end
        
        subgraph "ALB Metrics"
            RequestCount_Widget[Request Count<br/>Requests per Minute<br/>Traffic Patterns]
            ResponseTime_Widget[Response Time<br/>Average Latency<br/>Performance Tracking]
            ErrorRate_Widget[Error Rate<br/>4XX and 5XX Errors<br/>Application Health]
        end
        
        subgraph "RDS Metrics"
            DB_CPU_Widget[Database CPU<br/>Aurora MySQL CPU<br/>Performance Monitoring]
            Connections_Widget[DB Connections<br/>Active Connections<br/>Connection Pool Status]
            IOPS_Widget[Database IOPS<br/>Read/Write Operations<br/>Storage Performance]
        end
        
        subgraph "Application Logs"
            App_Logs[Application Logs<br/>Recent Entries<br/>Error Filtering]
            DB_Logs[Database Logs<br/>Query Logs<br/>Slow Query Analysis]
            ALB_Logs[Access Logs<br/>Request Patterns<br/>Client Analysis]
        end
        
        subgraph "Active Alerts"
            HighCPU_Alert[High CPU Alert<br/>Status: OK/ALARM<br/>Threshold: 70%]
            HighMemory_Alert[High Memory Alert<br/>Status: OK/ALARM<br/>Threshold: 80%]
            Database_Alert[Database Alert<br/>Connection Failures<br/>Availability Issues]
        end
    end
    
    subgraph "CloudWatch Alarms"
        subgraph "Compute Alarms"
            CPU_Alarm[ECS CPU > 70%<br/>Period: 5 minutes<br/>Evaluation: 2 periods]
            Memory_Alarm[ECS Memory > 80%<br/>Period: 5 minutes<br/>Evaluation: 2 periods]
        end
        
        subgraph "Application Alarms"
            HTTP5XX_Alarm[ALB 5XX > 10<br/>Period: 5 minutes<br/>Service Degradation]
            ResponseTime_Alarm[Response Time > 2s<br/>Period: 5 minutes<br/>Performance Issue]
        end
        
        subgraph "Database Alarms"
            DB_CPU_Alarm[RDS CPU > 80%<br/>Period: 5 minutes<br/>Database Overload]
            DB_Connection_Alarm[DB Connections > 80<br/>Period: 5 minutes<br/>Connection Limit]
        end
    end
    
    CPU_Widget -.-> CPU_Alarm
    Memory_Widget -.-> Memory_Alarm
    ErrorRate_Widget -.-> HTTP5XX_Alarm
    ResponseTime_Widget -.-> ResponseTime_Alarm
    DB_CPU_Widget -.-> DB_CPU_Alarm
    Connections_Widget -.-> DB_Connection_Alarm
    
    CPU_Alarm -.-> HighCPU_Alert
    Memory_Alarm -.-> HighMemory_Alert
    DB_CPU_Alarm -.-> Database_Alert
    
    classDef dashboard fill:#E3F2FD,stroke:#1976D2,stroke-width:2px,color:#232F3E
    classDef metrics fill:#E8F5E8,stroke:#388E3C,stroke-width:2px,color:#232F3E
    classDef logs fill:#FFF3E0,stroke:#F57C00,stroke-width:2px,color:#232F3E
    classDef alerts fill:#FFEBEE,stroke:#D32F2F,stroke-width:2px,color:#fff
    classDef alarms fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px,color:#fff
    
    class CPU_Widget,Memory_Widget,TaskCount_Widget,RequestCount_Widget,ResponseTime_Widget,ErrorRate_Widget,DB_CPU_Widget,Connections_Widget,IOPS_Widget metrics
    class App_Logs,DB_Logs,ALB_Logs logs
    class HighCPU_Alert,HighMemory_Alert,Database_Alert alerts
    class CPU_Alarm,Memory_Alarm,HTTP5XX_Alarm,ResponseTime_Alarm,DB_CPU_Alarm,DB_Connection_Alarm alarms
```

### Setting Up Monitoring

```bash
# Setup CloudWatch monitoring
./scripts/setup-monitoring.sh

# Run health checks
./scripts/health-check.sh

# View recent logs
aws logs tail /aws/ecs/student-record-system --follow --since 1h
```

### Custom Metrics

```bash
# CPU utilization over time
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name CPUUtilization \
    --dimensions Name=ServiceName,Value=student-record-system-service \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --period 300 \
    --statistics Average

# Application error rate
aws logs filter-log-events \
    --log-group-name /aws/ecs/student-record-system \
    --filter-pattern "ERROR" \
    --start-time $(date -d '1 hour ago' +%s)000
```

---

## Security

### Multi-Layer Security Framework

```mermaid
graph TB
    subgraph "Layer 1: Edge and Network Security"
        DNS_Security[Route 53 DNS Protection<br/>DDoS Mitigation]
        WAF_Protection[AWS WAF Optional<br/>OWASP Top 10 Protection]
        SSL_Termination[SSL/TLS Termination<br/>AWS Certificate Manager<br/>HTTPS Encryption]
        VPC_Isolation[VPC Network Isolation<br/>10.0.0.0/16 CIDR<br/>Private/Public Separation]
    end
    
    subgraph "Layer 2: Access Control and Identity"
        IAM_Roles[IAM Roles and Policies<br/>Least Privilege Access<br/>No Hardcoded Credentials]
        Service_Roles[Service-Specific Roles<br/>ECS Execution and Task Roles<br/>Cross-Service Permissions]
        Secrets_Management[Secrets Management<br/>Environment Variables<br/>AWS Secrets Manager Optional]
    end
    
    subgraph "Layer 3: Infrastructure Security"
        Security_Groups[Security Groups<br/>Stateful Firewall Rules<br/>Minimal Required Access]
        Private_Subnets[Private Subnets<br/>No Direct Internet Access<br/>NAT Gateway Routing]
        Encryption_Rest[Encryption at Rest<br/>Aurora MySQL Encryption<br/>EBS Volume Encryption]
        Encryption_Transit[Encryption in Transit<br/>TLS 1.2+ Only<br/>Database SSL Connections]
    end
    
    subgraph "Layer 4: Application Security"
        Container_Security[Container Security<br/>Base Image Scanning<br/>Runtime Protection]
        Input_Validation[Input Validation<br/>SQL Injection Prevention<br/>XSS Protection]
        Output_Encoding[Output Encoding<br/>Data Sanitization<br/>CSRF Protection]
    end
    
    subgraph "Layer 5: Monitoring and Compliance"
        Activity_Logging[Activity Logging<br/>CloudTrail API Logs<br/>Application Access Logs]
        Security_Monitoring[Security Monitoring<br/>CloudWatch Security Metrics<br/>Anomaly Detection]
        Vulnerability_Scanning[Vulnerability Scanning<br/>ECR Image Scanning<br/>Security Assessment]
    end
    
    DNS_Security --> WAF_Protection
    WAF_Protection --> SSL_Termination
    SSL_Termination --> VPC_Isolation
    
    IAM_Roles --> Service_Roles
    Service_Roles --> Secrets_Management
    
    Security_Groups --> Private_Subnets
    Private_Subnets --> Encryption_Rest
    Encryption_Rest --> Encryption_Transit
    
    Container_Security --> Input_Validation
    Input_Validation --> Output_Encoding
    
    Activity_Logging --> Security_Monitoring
    Security_Monitoring --> Vulnerability_Scanning
    
    classDef layer1 fill:#E3F2FD,stroke:#1976D2,stroke-width:2px,color:#232F3E
    classDef layer2 fill:#E8F5E8,stroke:#388E3C,stroke-width:2px,color:#232F3E
    classDef layer3 fill:#FFF3E0,stroke:#F57C00,stroke-width:2px,color:#232F3E
    classDef layer4 fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px,color:#232F3E
    classDef layer5 fill:#FFEBEE,stroke:#D32F2F,stroke-width:2px,color:#fff
    
    class DNS_Security,WAF_Protection,SSL_Termination,VPC_Isolation layer1
    class IAM_Roles,Service_Roles,Secrets_Management layer2
    class Security_Groups,Private_Subnets,Encryption_Rest,Encryption_Transit layer3
    class Container_Security,Input_Validation,Output_Encoding layer4
    class Activity_Logging,Security_Monitoring,Vulnerability_Scanning layer5
```

### Security Groups Configuration

**ALB Security Group**:
```
Inbound:
- HTTP (80) from 0.0.0.0/0
- HTTPS (443) from 0.0.0.0/0

Outbound:
- All traffic to ECS Security Group
```

**ECS Security Group**:
```
Inbound:
- HTTP (80) from ALB Security Group only

Outbound:
- All traffic (for database and internet access)
```

**RDS Security Group**:
```
Inbound:
- MySQL (3306) from ECS Security Group only

Outbound:
- None required
```

### Security Best Practices

1. **Input Validation**: All user inputs are validated and sanitized
2. **SQL Injection Prevention**: Prepared statements used exclusively
3. **XSS Protection**: Output data properly escaped
4. **Environment Variables**: No hardcoded secrets
5. **Container Security**: Regular image scanning and updates

---

## Scaling

### Auto Scaling Configuration

The application includes comprehensive auto-scaling:

**ECS Service Auto Scaling**:
- Target CPU Utilization: 70%
- Target Memory Utilization: 80%
- Min Capacity: 1 task
- Max Capacity: 10 tasks

**Database Scaling**:
- Aurora Auto Scaling for storage
- Read replica auto-scaling (optional)
- Connection pooling

### Scaling Strategies

**Horizontal Scaling**:
```bash
# Scale ECS service manually
aws ecs update-service \
    --cluster student-record-system-cluster \
    --service student-record-system-service \
    --desired-count 4
```

**Vertical Scaling**:
```bash
# Update task definition with more resources
# Edit terraform/variables.tf:
cpu    = 512
memory = 1024

# Apply changes
terraform plan
terraform apply
```

### Load Testing

```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Basic load test
ab -n 1000 -c 10 http://your-alb-dns-name/

# Stress test
ab -n 10000 -c 50 -t 60 http://your-alb-dns-name/
```

---

## Performance Optimization

### Application Performance

**PHP Optimization**:
- OPcache enabled for bytecode caching
- Prepared statements for database queries
- Connection pooling
- Optimized autoloader performance

**Database Optimization**:
```sql
-- Add indexes for frequently queried columns
CREATE INDEX idx_student_department ON students(department);
CREATE INDEX idx_student_created_at ON students(created_at);

-- Analyze query performance
EXPLAIN SELECT * FROM students WHERE department = 'Computer Science';
```

**Container Optimization**:
- Multi-stage Docker builds
- Minimal base images
- Optimized startup time
- Efficient health checks

### Infrastructure Performance

**Network Optimization**:
- ALB with multiple availability zones
- Connection keep-alive
- Gzip compression

**Storage Performance**:
- Provisioned IOPS for database
- Aurora performance insights
- Query caching

### Performance Monitoring

```bash
# Check response times
curl -w "@curl-format.txt" -o /dev/null -s http://your-alb-dns-name/

# Database performance
aws rds describe-db-cluster-snapshots \
    --db-cluster-identifier student-record-system-aurora-cluster
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: ECS Service Failed to Start

**Symptoms**: Tasks start and immediately stop

**Diagnostic Steps**:
```bash
# Check task logs
aws logs tail /aws/ecs/student-record-system --since 1h

# Check task definition
aws ecs describe-task-definition --task-definition student-record-system

# Check service events
aws ecs describe-services \
    --cluster student-record-system-cluster \
    --services student-record-system-service
```

**Common Solutions**:
- Verify environment variables are correct
- Check database connectivity
- Ensure adequate memory/CPU allocation
- Verify ECR image exists and is accessible

#### Issue 2: Application Load Balancer 503 Errors

**Symptoms**: HTTP 503 Service Unavailable

**Diagnostic Steps**:
```bash
# Check target group health
aws elbv2 describe-target-health \
    --target-group-arn $(terraform output -raw target_group_arn)

# Check security group rules
aws ec2 describe-security-groups \
    --group-ids <ecs-security-group-id>
```

**Common Solutions**:
- Verify targets are healthy
- Check security group configuration
- Ensure application is listening on correct port
- Review health check configuration

#### Issue 3: Database Connection Failures

**Symptoms**: PDO connection errors in logs

**Diagnostic Steps**:
```bash
# Check RDS cluster status
aws rds describe-db-clusters \
    --db-cluster-identifier student-record-system-aurora-cluster

# Test network connectivity
aws ecs execute-command \
    --cluster student-record-system-cluster \
    --task <task-arn> \
    --container student-record-system \
    --interactive \
    --command "telnet <rds-endpoint> 3306"
```

**Common Solutions**:
- Verify RDS cluster status
- Check database credentials
- Test network connectivity
- Review database security groups

#### Issue 4: High Resource Utilization

**Symptoms**: Container restarts, slow response times

**Diagnostic Steps**:
```bash
# Check resource usage
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name CPUUtilization \
    --dimensions Name=ServiceName,Value=student-record-system-service
```

**Common Solutions**:
- Increase CPU/memory allocation
- Review application code for optimization
- Analyze database query performance
- Implement application caching

### Emergency Procedures

**Service Recovery**:
```bash
# Force new deployment
aws ecs update-service \
    --cluster student-record-system-cluster \
    --service student-record-system-service \
    --force-new-deployment
```

**Database Recovery**:
```bash
# Create point-in-time recovery
aws rds restore-db-cluster-to-point-in-time \
    --source-db-cluster-identifier student-record-system-aurora-cluster \
    --db-cluster-identifier student-record-system-recovery \
    --restore-to-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)
```

**Infrastructure Rollback**:
```bash
# Rollback to previous Terraform state
git checkout HEAD~1
terraform plan
terraform apply
```

### Monitoring Commands

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster student-record-system-cluster \
  --services student-record-system-service

# View recent logs
aws logs tail /aws/ecs/student-record-system \
  --follow \
  --since 1h

# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Database connection test
mysql -h <aurora-endpoint> -u admin -p student_db
```

---

## Maintenance

### Regular Maintenance Tasks

**Daily**:
- Monitor CloudWatch dashboards
- Review application logs for errors
- Check auto-scaling metrics

**Weekly**:
- Review security group rules
- Monitor database performance
- Check backup status

**Monthly**:
- Update container images
- Review cost optimization opportunities
- Test disaster recovery procedures

### Backup and Recovery

**Automated Backups**:
- Database: 7-day retention with point-in-time recovery
- Application: Container images in ECR
- Infrastructure: Terraform state in S3

**Manual Backup**:
```bash
# Create database snapshot
aws rds create-db-cluster-snapshot \
    --db-cluster-identifier student-record-system-aurora-cluster \
    --db-cluster-snapshot-identifier "manual-backup-$(date +%Y%m%d)"

# Backup application code
aws s3 sync . s3://your-backup-bucket/student-record-system/ \
    --exclude ".git/*" --exclude "terraform/.terraform/*"
```

### Updates and Patches

**Application Updates**:
```bash
# Update application code
git pull origin main

# Rebuild and deploy
./scripts/build-and-push.sh
```

**Infrastructure Updates**:
```bash
# Update Terraform modules
terraform get -update

# Plan and apply changes
terraform plan
terraform apply
```

**Security Updates**:
- Container base images updated automatically
- ECS Fargate patches managed by AWS
- Database patches during maintenance windows

---

## Cost Estimation

### Monthly AWS Cost Analysis

```mermaid
graph TB
    subgraph "Monthly Cost Breakdown"
        subgraph "Compute Services"
            ECS_Fargate[ECS Fargate<br/>2 Tasks x 24/7<br/>15-20 USD/month]
            Auto_Scaling[Auto Scaling<br/>Variable Load<br/>5-10 USD/month]
        end
        
        subgraph "Database Services"
            Aurora_MySQL[Aurora MySQL<br/>db.t3.medium x 1<br/>25-35 USD/month]
            Database_Storage[Storage and I/O<br/>Auto-scaling Storage<br/>5-10 USD/month]
            Backup_Storage[Backup Storage<br/>7-day Retention<br/>2-5 USD/month]
        end
        
        subgraph "Networking Services"
            Application_LB[Application Load Balancer<br/>Always Running<br/>16 USD/month]
            NAT_Gateways[NAT Gateways<br/>2 x Multi-AZ<br/>32 USD/month]
            Data_Transfer[Data Transfer<br/>Internet Egress<br/>5-10 USD/month]
        end
        
        subgraph "Supporting Services"
            ECR_Repository[ECR Repository<br/>Image Storage<br/>1-3 USD/month]
            CloudWatch_Logs[CloudWatch Logs<br/>Log Ingestion<br/>2-5 USD/month]
            Route53_DNS[Route 53<br/>DNS Queries Optional<br/>1-2 USD/month]
        end
        
        subgraph "Total Monthly Cost"
            Baseline_Cost[Baseline Cost<br/>Minimum Usage<br/>105 USD/month]
            Typical_Cost[Typical Cost<br/>Normal Usage<br/>115 USD/month]
            Peak_Cost[Peak Cost<br/>High Traffic<br/>131 USD/month]
        end
    end
    
    subgraph "Cost Optimization Strategies"
        subgraph "Immediate Savings"
            Single_NAT[Single NAT Gateway<br/>Reduce Redundancy<br/>Save 16 USD/month]
            Spot_Instances[Fargate Spot<br/>Development Only<br/>Save 70% on Compute]
            Scheduled_Scaling[Scheduled Scaling<br/>Scale Down Off-hours<br/>Save 5-10 USD/month]
        end
        
        subgraph "Medium-term Savings"
            Aurora_Serverless[Aurora Serverless v2<br/>Pay per Use<br/>Save 20-50% Variable Load]
            Reserved_Capacity[Reserved Instances<br/>1-year Commitment<br/>Save 30-60%]
            Data_Transfer_Optimization[CloudFront CDN<br/>Reduce Data Transfer<br/>Save 3-8 USD/month]
        end
        
        subgraph "Long-term Savings"
            Savings_Plans[AWS Savings Plans<br/>Flexible Commitment<br/>Save 20-72%]
            Cross_Region_Optimization[Region Optimization<br/>Lower Cost Regions<br/>Save 10-30%]
            Resource_Right_Sizing[Right-sizing<br/>Optimize Resources<br/>Save 15-25%]
        end
    end
    
    ECS_Fargate --> Baseline_Cost
    Auto_Scaling --> Typical_Cost
    Aurora_MySQL --> Baseline_Cost
    Database_Storage --> Typical_Cost
    Application_LB --> Baseline_Cost
    NAT_Gateways --> Baseline_Cost
    Data_Transfer --> Peak_Cost
    ECR_Repository --> Baseline_Cost
    CloudWatch_Logs --> Typical_Cost
    
    Single_NAT -.-> NAT_Gateways
    Spot_Instances -.-> ECS_Fargate
    Scheduled_Scaling -.-> Auto_Scaling
    Aurora_Serverless -.-> Aurora_MySQL
    Reserved_Capacity -.-> ECS_Fargate
    Data_Transfer_Optimization -.-> Data_Transfer
    
    classDef compute fill:#EC7211,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef database fill:#3F48CC,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef networking fill:#8C4FFF,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef supporting fill:#569A31,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef totals fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef immediate fill:#4CAF50,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef medium fill:#FF9800,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef longterm fill:#9C27B0,stroke:#232F3E,stroke-width:2px,color:#fff
    
    class ECS_Fargate,Auto_Scaling compute
    class Aurora_MySQL,Database_Storage,Backup_Storage database
    class Application_LB,NAT_Gateways,Data_Transfer networking
    class ECR_Repository,CloudWatch_Logs,Route53_DNS supporting
    class Baseline_Cost,Typical_Cost,Peak_Cost totals
    class Single_NAT,Spot_Instances,Scheduled_Scaling immediate
    class Aurora_Serverless,Reserved_Capacity,Data_Transfer_Optimization medium
    class Savings_Plans,Cross_Region_Optimization,Resource_Right_Sizing longterm
```

### Cost Monitoring

```bash
# Enable cost allocation tags
aws ce create-cost-category \
    --name "StudentRecordSystem" \
    --rules file://cost-rules.json

# Get cost and usage
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost
```

---

## Contributing

### Development Guidelines

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/new-feature`
3. **Make your changes**
4. **Add tests if applicable**
5. **Submit a pull request**

### Code Standards

**PHP**:
- Follow PSR-12 coding standards
- Use prepared statements for database queries
- Implement proper error handling
- Add inline documentation

**Terraform**:
- Use consistent naming conventions
- Add variable descriptions
- Include output descriptions
- Follow DRY principles

**Documentation**:
- Update README for significant changes
- Add inline comments for complex logic
- Update architecture diagrams if needed

### Testing

**Local Testing**:
```bash
# Start local environment
docker-compose up -d

# Run application tests
./scripts/test-local.sh

# Stop environment
docker-compose down
```

**Infrastructure Testing**:
```bash
# Validate Terraform
terraform validate

# Plan deployment
terraform plan

# Run security scan
tfsec .
```

---

## Changelog

### Version 1.0.0 (Current)
- Initial release with complete LAMP stack
- Multi-AZ deployment with auto-scaling
- Comprehensive monitoring and logging
- Security best practices implementation
- Complete documentation and troubleshooting guides

### Future Enhancements
- CI/CD pipeline integration
- Enhanced security with AWS WAF
- Multi-region deployment support
- Container registry scanning automation
- Advanced monitoring with X-Ray tracing

---
