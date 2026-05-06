 Terraform AWS Assignment Documentation
 
 
 Quest:- Create VPC with:
* 2 public + 2 private subnets (multi-AZ)
Internet Gateway + NAT Gateway
* Deploy ALB (public)
Route HTTP traffic to backend
* Create Launch Template + Auto Scaling Group
Instances in private subnet
* Min: 2, Max: 5
Install Nginx
Configure Security Groups
* Allow HTTP → ALB
* Allow ALB → EC2 only
Create RDS (MySQL/Postgres)
* Private subnet
* Accessible only from EC2
Create S3 bucket
* Enable versioning


Use modules (VPC, EC2, RDS)
Use variables (region, instance type, DB name)
Support dev & prod environments
Conditional logic:
* dev → 1 instance
* prod → autoscaling
Add lifecycle rule
* Prevent DB deletion

---------------------------
 
 
Task: Deploy EC2 using Terraform

Steps:

Installed Terraform and AWS CLI
Configured AWS CLI using IAM credentials
Created main.tf with EC2 resource
Ran:
terraform init
terraform plan
terraform apply


.....................................................
Task: VPC Setup using Terraform

Steps:

Created VPC using CIDR block
Created public and private subnet
Attached Internet Gateway
Configured route table for public subnet
Used S3 as remote backend


........................................................
Task: Multi-AZ VPC with NAT Gateway

Steps:

Added second public and private subnet across AZs
Created NAT Gateway with Elastic IP
Configured private route table
Enabled private subnet outbound internet


.......................................................
🔹 1. Objective

The aim of this assignment was to create a complete cloud infrastructure using Amazon Web Services with the help of Terraform.

The goal was to understand how real systems are deployed using VPC, EC2, Load Balancer, RDS, and S3.

🔹 2. Services Used
VPC
EC2
Auto Scaling Group
Application Load Balancer (ALB)
RDS (MySQL)
S3
NAT Gateway
Internet Gateway
🔹 3. What I Implemented
✅ VPC Setup
Created a VPC
Created:
2 Public Subnets
2 Private Subnets
✅ Internet Access
Attached Internet Gateway to VPC
Created NAT Gateway for private subnets
Configured Route Tables:
Public → IGW
Private → NAT
✅ EC2 + Auto Scaling
Created Launch Template
Installed Nginx using user_data
Created Auto Scaling Group:
Min = 2
Desired = 2
Max = 5
Instances are in private subnet
✅ Load Balancer
Created Application Load Balancer
Connected it to EC2 using Target Group
Verified using browser:
Hello from <instance-id>
✅ Security Groups
ALB → allows HTTP from internet
EC2 → allows HTTP only from ALB
No direct public access to EC2
✅ S3
Created S3 bucket
Enabled versioning
✅ RDS
Created MySQL database
Placed in private subnet
Allowed access only from EC2
Not publicly accessible
✅ Variables
Used variables for:
region
instance type
db name
✅ Environment Logic
Dev → 1 instance
Prod → Auto Scaling
🔹 4. Architecture (Simple Flow)
User → ALB → EC2 (Private) → RDS
🔹 5. Problems Faced (Important Part)
❌ 1. 502 Bad Gateway
ALB was not working
Reason: Nginx was not installed

✅ Fixed by correcting user_data

❌ 2. Target Group Unhealthy
Health check failed
Reason: EC2 not responding

✅ Fixed by installing and starting Nginx

❌ 3. Could not SSH into EC2
Instance was in private subnet
No public IP

✅ Temporarily moved to public subnet for debugging

❌ 4. User Data not working
Nginx was not installing
Reason: Launch Template issue

✅ Fixed by recreating instances and updating template

❌ 5. Public subnet not working
Internet not working

✅ Found that route table did not have:

0.0.0.0/0 → Internet Gateway
❌ 6. Private subnet issue
EC2 could not install packages

✅ Fixed by adding NAT Gateway route:

0.0.0.0/0 → NAT Gateway

