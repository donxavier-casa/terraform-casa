# Security group for Lambda (allow egress to DB)
resource "aws_security_group" "lambda_sg" {
  name   = "${var.project_name}-${var.environment}-lambda-sg"
  vpc_id = aws_vpc.main.id
  description = "Allow Lambda to access DB and internet via NAT"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for DB (allow only from lambda_sg)
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow DB access from Lambda SG"

  ingress {
    description = "Postgres from lambda"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
