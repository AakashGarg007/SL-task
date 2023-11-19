# -- variables.tf -- 

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr_a" {
  default = "10.1.0.0/16"
}
variable "engine" {
  description = "Enter the engine name either postgres or mysql ( MAZ Cluster Supported)"
  type        = string
  default     = "aurora-postgresql"
}
variable "master_username" {
  description = "Master Username"
  type        = string
  default     = "postgres"
}

variable "port" {
  description = "The port on which to accept connections"
  type        = string
  default     = "5432"
}

variable "master_password" {
  description = "Master DB password"
  type        = string
  default     = "postgres"
  sensitive   = true
}
variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:00-03:00"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Enable Cloudwatch logs exports"
  type        = list(string)
  default = [
    "postgresql",
  ]
}

variable "create_cloudwatch_log_group" {
  description = "Create Cloudwatch log group"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 7
}
variable "deletion_protection" {
  description = "Enable delete protection for the RDS"
  type        = bool
  default     = true
}
locals {
  cpu      = 512
  memory   = 1024
  app_name = "sl-task"
  default_tags = {
    orchestrator = "terraform",
    project      = local.app_name
    team         = "Aakash"
    env          = "dev"
  }
}
