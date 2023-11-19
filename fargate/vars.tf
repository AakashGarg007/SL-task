variable "aws_region" {
  type = string
}

variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "default_tags" {
  type = map
}

variable "container_image" {
  type = string
}

variable "container_image1" {
  type = string
}

variable "cloudwatch_logs_retention_days" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}


variable "subnets" {
  type = list(string)
}

output "ecs_cluster" {
  value = aws_ecs_cluster.main
}

output "ecs_task_definition" {
  value = aws_ecs_task_definition.main
}

output "ecs_task_exec_role" {
  value = aws_iam_role.ecs_task_execution_role
}
