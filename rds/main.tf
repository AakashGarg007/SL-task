locals {

  cluster_identifier        = var.use_identifier_prefix ? null : var.cluster_identifier
  cluster_identifier_prefix = var.use_identifier_prefix ? "${var.cluster_identifier}-" : null
}

data "aws_partition" "current" {}

resource "aws_rds_cluster" "rds_cluster" {
  # count = var.create ? 1 : 0

  cluster_identifier = var.cluster_identifier

  engine            = var.engine
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  database_name                             = var.database_name
  master_username                            = var.master_username
  master_password                            = var.master_password
  port                                = var.port
  
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
  
  #Option group is not supported in PostgreSQL
  #option_group_name      = var.option_group_name
  network_type           = var.network_type

  skip_final_snapshot = true
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  backup_retention_period = var.backup_retention_period
  preferred_backup_window           = var.preferred_backup_window
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection      = var.deletion_protection

  tags = var.tags

  depends_on = [aws_cloudwatch_log_group.this]


}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 3
  identifier         = "sldb-${count.index}"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = "db.t3.medium"
  engine             = var.engine
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  for_each = toset([for log in var.enabled_cloudwatch_logs_exports : log if var.create && var.create_cloudwatch_log_group])

  name              = "/aws/rds/instance/${var.cluster_identifier}/${each.value}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}

################################################################################
# Enhanced monitoring
################################################################################

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}
