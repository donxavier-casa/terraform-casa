# Private S3 bucket for frontend
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-${var.environment}-frontend-${replace(var.aws_region, "/", "-")}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = { Name = "${var.project_name}-${var.environment}-frontend" }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control (OAC) for signed origin requests (newer than OAI)
resource "aws_cloudfront_origin_access_control" "oac" {
  name = "${var.project_name}-${var.environment}-oac"
  description = "OAC for CloudFront -> S3 access"
  signing_behavior = "always"
  signing_protocol = "sigv4"
  origin_access_control_origin_type = "s3"
}

# S3 bucket policy to allow CloudFront OAC principal
data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_control.oac.iam_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.frontend.arn,
      "${aws_s3_bucket.frontend.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# ACM certificate in us-east-1 (CloudFront)
resource "aws_acm_certificate" "cloudfront_cert" {
  provider = aws.use1
  domain_name = var.domain_name != "" ? var.domain_name : "${var.project_name}.${replace(var.domain_name, "\"\"", "")}"
  validation_method = var.route53_zone_id != "" ? "DNS" : "EMAIL"
  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation if Route53 zone id provided
resource "aws_route53_record" "cert_validation" {
  count = var.route53_zone_id != "" ? length(aws_acm_certificate.cloudfront_cert.domain_validation_options) : 0

  zone_id = var.route53_zone_id
  name    = aws_acm_certificate.cloudfront_cert.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.cloudfront_cert.domain_validation_options[count.index].resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.cloudfront_cert.domain_validation_options[count.index].resource_record_value]
  provider = aws.use1
}

resource "aws_acm_certificate_validation" "cloudfront_cert_validation" {
  provider = aws.use1
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = var.route53_zone_id != "" ? aws_route53_record.cert_validation[*].fqdn : []
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "frontend" {
  enabled = true
  aliases = var.domain_name != "" ? [var.domain_name] : []
  comment = "${var.project_name} ${var.environment} frontend"

  origins {
    origin_id = "s3-frontend-origin"
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    s3_origin_config {
      origin_access_identity = ""  # not used with OAC
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET","HEAD","OPTIONS"]
    cached_methods   = ["GET","HEAD"]
    target_origin_id = "s3-frontend-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    # Long TTL default - but index.html will be uploaded with short TTL (via CI)
    min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = { Name = "${var.project_name}-${var.environment}-cf" }
}
