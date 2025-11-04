output "frontend_bucket" {
  value = aws_s3_bucket.frontend.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "ecr_repo_uri" {
  value = aws_ecr_repository.app.repository_url
}

output "lambda_function_name" {
  value = aws_lambda_function.app.function_name
}

output "github_oidc_role_arn" {
  value = aws_iam_role.github_actions_oidc.arn
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}

output "codebuild_project" {
  value = aws_codebuild_project.alembic_migrations.name
}
