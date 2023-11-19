resource "aws_ecr_repository" "app1" {
  name                 = var.repo_name1
  image_tag_mutability = var.tag_mutability

  image_scanning_configuration {
    scan_on_push = var.should_scan_on_push
  }

  tags = var.default_tags
}

resource "aws_ecr_lifecycle_policy" "main1" {
  repository = aws_ecr_repository.app1.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Delete untagged images when image count breaches 5",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
resource "aws_ecr_repository" "app2" {
  name                 = var.repo_name2
  image_tag_mutability = var.tag_mutability

  image_scanning_configuration {
    scan_on_push = var.should_scan_on_push
  }

  tags = var.default_tags
}

resource "aws_ecr_lifecycle_policy" "main2" {
  repository = aws_ecr_repository.app2.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Delete untagged images when image count breaches 5",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}