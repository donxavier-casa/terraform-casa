resource "aws_s3_bucket" "this" {
  bucket = var.s3
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowCloudFrontAccessOnly",
        Effect : "Allow",
        Principal = "*",
        Action : "s3:GetObject",
        Resource : "${aws_s3_bucket.this.arn}/*",
        Condition : {
          StringEquals : {
            "aws:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}
