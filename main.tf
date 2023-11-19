#-- root/main.tf -- # 

module "vpc_a" {
  source           = "./networking"
  vpc_cidr         = var.vpc_cidr_a #"10.1.0.0/16"
  private_sn_count = 3
  public_sn_count  = 1
  name             = "VPC-A"
  public_cidrs     = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr_a, 8, i)]
  private_cidrs    = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr_a, 8, i)]
}


module "security_group_a" {
  source      = "./securitygroup"
  vpc_id      = module.vpc_a.vpc_id
  cidr_blocks = "0.0.0.0/0"
  sg_type_protocol = {
    all = 0

  }
  sg_egrees_ports = [0]

}

module "s3Primary" {
  source      = "./s3"
  bucket_name = "sl-static-app"
  source_file = "s3/index.html"
}

module "s3Failover" {
  source      = "./s3"
  bucket_name = "static-app-f"
  source_file = "s3/index_f.html"
}

module "cloud-front" {
  source      = "./cloud-front"
  s3_primary  = module.s3Primary.bucket_id
  s3_failover = module.s3Failover.bucket_id
  depends_on = [
    module.s3Primary,
    module.s3Failover
  ]
}

module "cdn-oac-bucket-policy-failover" {
  source         = "./cdn-oac"
  bucket_id      = module.s3Failover.bucket_id
  cloudfront_arn = module.cloud-front.cloudfront_arn
  bucket_arn     = module.s3Failover.bucket_arn
}

module "ecr" {
  source              = "./ecr"
  tag_mutability      = "MUTABLE"
  should_scan_on_push = false
  default_tags        = local.default_tags
}

module "fargate" {
  source                         = "./fargate/"
  aws_region                     = var.aws_region
  app_name                       = local.app_name
  environment                    = "default"
  default_tags                   = local.default_tags
  vpc_id                         = module.vpc_a.vpc_id
  container_image                = "${module.ecr.ecr1_url}:latest"
  container_image1               = "${module.ecr.ecr2_url}:latest"
  cloudwatch_logs_retention_days = 14
  subnets                        = module.vpc_a.private_subnet_id
  memory                         = local.memory
  cpu                            = local.cpu
}

module "db_cluster" {
  source = "./rds"

  cluster_identifier = "sldb"

  engine = var.engine


  database_name   = "slDB"
  master_username = var.master_username
  port            = var.port
  master_password = var.master_password

  db_subnet_group_name   = module.vpc_a.db_subnet_id
  vpc_security_group_ids = [module.security_group_a.security_group_id]

  preferred_backup_window         = var.preferred_backup_window
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  backup_retention_period         = var.backup_retention_period
  deletion_protection             = var.deletion_protection
}

resource "aws_budgets_budget" "myBudget" {
  budget_type  = "COST"
  limit_amount = "10"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["aakashgarg007@gmail.com"]
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["aakashgarg007@gmail.com"]
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 85
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["aakashgarg007@gmail.com"]
  }
}

resource "aws_cloudwatch_metric_alarm" "test" {
  alarm_name                = "cf_4XX"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "4xxErrorRate"
  namespace                 = "AWS/CloudFront"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 10
  alarm_description         = "This metric monitors ec2 cpu utilization"
  dimensions                = {
    DistributionId = "E3AJCCAGMTD1EL"
    Region         = "Global"
  }
  datapoints_to_alarm = 1
  alarm_actions = [aws_sns_topic.sns.arn]
}
resource "aws_cloudwatch_metric_alarm" "test1" {
  alarm_name                = "cf_5XX"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "5xxErrorRate"
  namespace                 = "AWS/CloudFront"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 10
  alarm_description         = "This metric monitors ec2 cpu utilization"
  dimensions                = {
    DistributionId = "E3AJCCAGMTD1EL"
    Region         = "Global"
  }
  datapoints_to_alarm = 1
  alarm_actions = [aws_sns_topic.sns.arn]
}

resource "aws_sns_topic" "sns" {
  name = "Default_CloudWatch_Alarms_Topic"
  application_success_feedback_sample_rate = 0
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  sqs_success_feedback_sample_rate         = 0
}
