# output "db_instance_arn" {
#   description = "The ARN of the RDS instance"
#   value       = try(aws_rds_cluster.rds_cluster.arn, "")
# }

# output "db_instance_availability_zone" {
#   description = "The availability zone of the RDS instance"
#   value       = try(aws_rds_cluster.rds_cluster.availability_zones, "")
# }

# output "db_instance_endpoint" {
#   description = "The connection endpoint"
#   value       = try(aws_rds_cluster.rds_cluster.endpoint, "")
# }

# output "db_instance_engine" {
#   description = "The database engine"
#   value       = try(aws_rds_cluster.rds_cluster.engine, "")
# }

# output "db_instance_hosted_zone_id" {
#   description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
#   value       = try(aws_rds_cluster.rds_cluster.hosted_zone_id, "")
# }

# output "db_instance_id" {
#   description = "The RDS instance ID"
#   value       = try(aws_rds_cluster.rds_cluster.id, "")
# }

# output "db_instance_name" {
#   description = "The database name"
#   value       = try(aws_rds_cluster.rds_cluster.database_name, "")
# }

# output "db_instance_username" {
#   description = "The master username for the database"
#   value       = try(aws_rds_cluster.rds_cluster.master_username, "")
#   sensitive   = true
# }

# output "db_instance_port" {
#   description = "The database port"
#   value       = try(aws_rds_cluster.rds_cluster.port, "")
# }

# output "db_instance_password" {
#   description = "The master password"
#   value       = try(aws_rds_cluster.rds_cluster.master_password, "")
#   sensitive   = true
# }

# ################################################################################
# # CloudWatch Log Group
# ################################################################################

# output "db_instance_cloudwatch_log_groups" {
#   description = "Map of CloudWatch log groups created and their attributes"
#   value       = aws_cloudwatch_log_group.this
# }
