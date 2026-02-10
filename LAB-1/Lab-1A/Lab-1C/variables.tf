variable "aws_region" {
  description = "tokyo-region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "aws-armageddon-7"
  type        = string
  default     = "aws-armageddon-7"
}

variable "vpc_cidr" {
  description = "VPC CIDR 10.30.0.0/16"
  type        = string
  default     = "10.30.0.0/16" # TODO: student supplies
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs 10.30.10.0/24"
  type        = list(string)
  default     = ["10.30.1.0/24", "10.30.2.0/24"] # TODO: student supplies
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs 10.30.101.0/24"
  type        = list(string)
  default     = ["10.30.101.0/24", "10.30.102.0/24"] # TODO: student supplies
}

variable "azs" {
  description = "Availability Zones list"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"] # TODO: student supplies
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 app host."
  type        = string
  default     = "ami-06cce67a5893f85f9" # TODO
}

variable "ec2_instance_type" {
  description = "EC2 instance size for the app."
  type        = string
  default     = "t2.micro"
}

variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "database1" # Students can change
}

variable "db_username" {
  description = "DB master username (students should use Secrets Manager in 1B/1C)."
  type        = string
  default     = "admin" # TODO: student supplies
}

variable "db_password" {
  description = "DB master password (DO NOT hardcode in real life; for lab only)."
  type        = string
  sensitive   = true
  default     = "newcloudlife" # TODO: student supplies
}

variable "sns_email_endpoint" {
  description = "Email for SNS subscription (PagerDuty simulation)."
  type        = string
  default     = "williamhannah.tech@gmail.com" # TODO: student supplies
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logging to S3."
  type        = bool
  default     = true
}

variable "alb_access_logs_prefix" {
  description = "S3 prefix for ALB access logs."
  type        = string
  default     = "alb-access-logs"
}
  