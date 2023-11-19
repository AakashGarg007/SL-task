# 1. ECS Task definition for the Docker container with proper permissions
# Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name                  = "${var.app_name}-ecsTaskExecutionRole-${var.environment}"
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task  Role
resource "aws_iam_role" "ecs_task_role" {
  name                  = "${var.app_name}-ecsTaskRole-${var.environment}"
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.app_name}-task-${var.environment}"
  retention_in_days = var.cloudwatch_logs_retention_days
  tags              = var.default_tags
}
resource "aws_cloudwatch_log_group" "main1" {
  name              = "/ecs/${var.app_name}-task2-${var.environment}"
  retention_in_days = var.cloudwatch_logs_retention_days
  tags              = var.default_tags
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app_name}-task-${var.environment}"
  tags                     = var.default_tags
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu        
  memory                   = var.memory  
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions     = <<TASK_DEFINITION
  [
    {
      "essential": true,
      "image": "${var.container_image}",
      "name": "${var.app_name}-container-${var.environment}",
      "logConfiguration":{
        "logDriver": "awslogs",
        "options": {
          "awslogs-group":	"${aws_cloudwatch_log_group.main.name}",
          "awslogs-region":	"${var.aws_region}",
          "awslogs-stream-prefix":	"ecs"
        }
      }
    }
  ]
  TASK_DEFINITION
}

resource "aws_ecs_task_definition" "main1" {
  family                   = "${var.app_name}-task1-${var.environment}"
  tags                     = var.default_tags
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu        
  memory                   = var.memory  
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions     = <<TASK_DEFINITION
  [
    {
      "essential": true,
      "image": "${var.container_image1}",
      "name": "${var.app_name}-container1-${var.environment}",
      "logConfiguration":{
        "logDriver": "awslogs",
        "options": {
          "awslogs-group":	"${aws_cloudwatch_log_group.main1.name}",
          "awslogs-region":	"${var.aws_region}",
          "awslogs-stream-prefix":	"ecs"
        }
      }
    }
  ]
  TASK_DEFINITION
}

# 2. Cluster where the service instances will run
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster-${var.environment}"
  tags = var.default_tags
}

# 3. Service which is an instance of task-defination which will go into the cluster
resource "aws_security_group" "main" {
  description = "2020-07-24T09:29:30.516Z"   
  egress {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
    
  name        = "${var.app_name}-sg-ecs_tasks-${var.environment}"
  tags        = var.default_tags
  vpc_id      = var.vpc_id

  timeouts {}
}

resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-service1-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = 0
  

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  } 
}
resource "aws_ecs_service" "main2" {
  name            = "${var.app_name}-service2-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = 0
  

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  } 
}