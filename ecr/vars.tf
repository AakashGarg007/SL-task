variable "repo_name1" {
  type = string
  default = "app1"
}

variable "repo_name2" {
  type = string
  default = "app2"
}

variable "tag_mutability" {
  type = string
}

variable "should_scan_on_push" {
  type = bool
}

variable "default_tags" {
  type = map
}

output "ecr1_arn" {
  value = aws_ecr_repository.app1.arn
}

output "ecr1_name" {
  value = aws_ecr_repository.app1.name
}

output "ecr1_url" {
  value = aws_ecr_repository.app1.repository_url
}
output "ecr2_arn" {
  value = aws_ecr_repository.app2.arn
}

output "ecr2_name" {
  value = aws_ecr_repository.app2.name
}

output "ecr2_url" {
  value = aws_ecr_repository.app2.repository_url
}
