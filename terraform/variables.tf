variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "patch-management-demo"
}

variable "environment" {
  description = "Environment name used in tags and resource identification"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "EC2 instance type for demo instances"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the Linux instances managed by Systems Manager"
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access"
  type        = string
  default     = ""
}

variable "subnet_id_az1" {
  description = "Subnet ID for the first availability zone"
  type        = string
}

variable "subnet_id_az2" {
  description = "Subnet ID for the second availability zone"
  type        = string
}

variable "subnet_id_az3" {
  description = "Subnet ID for the third availability zone"
  type        = string
}
##adjuste this, never allowed_ssh_full
variable "allowed_ssh_cidr" {
  description = "CIDR allowed to access instances over SSH"
  type        = string
  default     = "0.0.0.0/0"
}
