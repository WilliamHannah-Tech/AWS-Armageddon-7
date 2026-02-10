############################################
# Bonus B - Route53 (Hosted Zone + DNS records + ACM validation + ALIAS to ALB)
############################################

locals {
  # Explanation: bentley needs a home planet—Route53 hosted zone is your DNS territory.
  bentley_zone_name = var.domain_name

  # Explanation: Use either Terraform-managed zone or a pre-existing zone ID (students choose their destiny).
  # bentley_zone_id = var.manage_route53_in_terraform ? aws_route53_zone.bentley_zone01[0].zone_id : var.route53_hosted_zone_id

  # Explanation: This is the app address that will growl at the galaxy (app.bentley-growl.com).
  bentley_app_fqdn = "${var.app_subdomain}.${var.domain_name}"

  bentley_zone_id = var.manage_route53_in_terraform ? aws_route53_zone.bentley_zone01[0].zone_id : var.route53_hosted_zone_id

}

############################################
# Hosted Zone (optional creation)
############################################

# Explanation: A hosted zone is like claiming Kashyyyk in DNS—names here become law across the galaxy.
resource "aws_route53_zone" "bentley_zone01" {
  count = var.manage_route53_in_terraform ? 1 : 0

  name = local.bentley_zone_name

  tags = {
    Name = "${var.project_name}-zone01"
  }
}

############################################
# ACM DNS Validation Records
############################################

# Explanation: ACM asks “prove you own this planet”—DNS validation is bentley roaring in the right place.
# resource "aws_route53_record" "bentley_acm_validation_records01" {
#   for_each = var.certificate_validation_method == "DNS" ? {
#     for dvo in data.aws_acm_certificate.bentley_existing_cert.domain_validation_options :
#     dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   } : {}

#   zone_id = local.bentley_zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60

#   records = [each.value.record]
# }

# Explanation: This ties the “proof record” back to ACM—bentley gets his green checkmark for TLS.
# resource "aws_acm_certificate_validation" "bentley_acm_validation01_dns_bonus" {
#   count = var.certificate_validation_method == "DNS" ? 1 : 0

#   certificate_arn = data.aws_acm_certificate.bentley_existing_cert.arn

#   validation_record_fqdns = [
#     for r in aws_route53_record.bentley_acm_validation_records01 : r.fqdn
#   ]
# }


# resource "aws_route53_record" "bentley_app_alias01" { 
#     zone_id = local.bentley_zone_id 
#     name    = local.bentley_app_fqdn 
#     type    = "A"


# alias { 
#     name                   = aws_lb.bentley_alb01.dns_name 
#     zone_id                = aws_lb.bentley_alb01.zone_id 
#     evaluate_target_health = true 
# } 


###############################################Bonus_b_logging_route53_apex #####################################################3
############################################
# Bonus B - Route53 Zone Apex + ALB Access Logs to S3
############################################

############################################
# Route53: Zone Apex (root domain) -> ALB
############################################

# Explanation: The zone apex is the throne room—bentley-growl.com itself should lead to the ALB.
resource "aws_route53_record" "bentley_apex_alias01" {
  zone_id = local.bentley_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.bentley_alb01.dns_name
    zone_id                = aws_lb.bentley_alb01.zone_id
    evaluate_target_health = true
  }
}

############################################
# S3 bucket for ALB access logs
############################################

# Explanation: This bucket is bentley’s log vault—every visitor to the ALB leaves footprints here.
resource "aws_s3_bucket" "bentley_alb_logs_bucket01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = "${var.project_name}-alb-logs-${data.aws_caller_identity.bentley_self01.account_id}"

  tags = {
    Name = "${var.project_name}-alb-logs-bucket01"
  }
}

# Explanation: Block public access—bentley does not publish the ship’s black box to the galaxy.
resource "aws_s3_bucket_public_access_block" "bentley_alb_logs_pab01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket                  = aws_s3_bucket.bentley_alb_logs_bucket01[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Explanation: Bucket ownership controls prevent log delivery chaos—bentley likes clean chain-of-custody.
resource "aws_s3_bucket_ownership_controls" "bentley_alb_logs_owner01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.bentley_alb_logs_bucket01[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Explanation: TLS-only—bentley growls at plaintext and throws it out an airlock.
resource "aws_s3_bucket_policy" "bentley_alb_logs_policy01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.bentley_alb_logs_bucket01[0].id

  # NOTE: This is a skeleton. Students may need to adjust for region/account specifics.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bentley_alb_logs_bucket01[0].arn,
          "${aws_s3_bucket.bentley_alb_logs_bucket01[0].arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Sid    = "AllowALBLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.bentley_alb_logs_bucket01[0].arn
      },
      {
        Sid    = "AllowALBLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.bentley_alb_logs_bucket01[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.bentley_self01.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
############################################
# Enable ALB access logs (on the ALB resource)
############################################

# Explanation: Turn on access logs—bentley wants receipts when something goes wrong.
# NOTE: This is a skeleton patch: students must merge this into aws_lb.bentley_alb01
# by adding/accessing the `access_logs` block. Terraform does not support "partial" blocks.
#
# Add this inside resource "aws_lb" "bentley_alb01" { ... } in bonus_b.tf:
#
# access_logs {
#   bucket  = aws_s3_bucket.bentley_alb_logs_bucket01[0].bucket
#   prefix  = var.alb_access_logs_prefix
#   enabled = var.enable_alb_access_logs
# }


