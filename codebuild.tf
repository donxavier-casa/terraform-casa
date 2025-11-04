resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-${var.environment}-cb-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cb_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeBuildDeveloperAccess"
}

resource "aws_codebuild_project" "alembic_migrations" {
  name         = "${var.project_name}-${var.environment}-migrations"
  description  = "Run Alembic migrations inside VPC"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts { type = "NO_ARTIFACTS" }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "DB_SECRET_ARN"
      value = aws_secretsmanager_secret.db_secret.arn
    }
  }

  source { type = "GITHUB" url = "https://github.com/your/repo" } # replace

  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnets            = aws_subnet.private[*].id
  }
}
