# Explanation: Outputs are your mission report—what got built and where to find it.
output "bentley_vpc_id" {
  value = aws_vpc.bentley_vpc01.id
}

output "bentley_public_subnet_ids" {
  value = aws_subnet.bentley_public_subnets[*].id
}

output "bentley_private_subnet_ids" {
  value = aws_subnet.bentley_private_subnets[*].id
}

output "bentley_ec2_instance_id" {
  value = aws_instance.bentley_ec201.id
}

output "bentley_rds_endpoint" {
  value = aws_db_instance.bentley_rds01.address
}

output "bentley_sns_topic_arn" {
  value = aws_sns_topic.bentley_sns_topic01.arn
}

output "bentley_log_group_name" {
  value = aws_cloudwatch_log_group.bentley_log_group01.name
}

# Explanation: These outputs prove bentley built private hyperspace lanes (endpoints) instead of public chaos.
output "bentley_vpce_ssm_id" {
  value = aws_vpc_endpoint.bentley_vpce_ssm01.id
}

output "bentley_vpce_logs_id" {
  value = aws_vpc_endpoint.bentley_vpce_logs01.id
}

output "bentley_vpce_secrets_id" {
  value = aws_vpc_endpoint.bentley_vpce_secrets01.id
}

output "bentley_vpce_s3_id" {
  value = aws_vpc_endpoint.bentley_vpce_s3_gw01.id
}

output "bentley_private_ec2_instance_id_bonus" {
  value = aws_instance.bentley_ec201_private_bonus.id
}

# Explanation: Outputs are the mission coordinates — where to point your browser and your blasters.
output "bentley_alb_dns_name" {
  value = aws_lb.bentley_alb01.dns_name
}

output "bentley_app_fqdn" {
  value = "${var.app_subdomain}.${var.domain_name}"
}

output "bentley_target_group_arn" {
  value = aws_lb_target_group.bentley_tg01.arn
}

output "bentley_acm_cert_arn" {
  value = data.aws_acm_certificate.bentley_existing_cert.arn
}

output "bentley_waf_arn" {
  value = var.enable_waf ? aws_wafv2_web_acl.bentley_waf01[0].arn : null
}

output "bentley_dashboard_name" {
  value = aws_cloudwatch_dashboard.bentley_dashboard01.dashboard_name
}

output "bentley_route53_zone_id" {
  value = local.bentley_zone_id
}

output "bentley_app_url_https" {
  value = "https://${var.app_subdomain}.${var.domain_name}"
}

# Explanation: The apex URL is the front gate—humans type this when they forget subdomains.
output "bentley_apex_url_https" {
  value = "https://${var.domain_name}"
}

# Explanation: Log bucket name is where the footprints live—useful when hunting 5xx or WAF blocks.
output "bentley_alb_logs_bucket_name" {
  value = var.enable_alb_access_logs ? aws_s3_bucket.bentley_alb_logs_bucket01[0].bucket : null
}

#Explanation: Coordinates for the WAF log destination—bentley wants to know where the footprints landed.
output "bentley_waf_log_destination" {
  value = var.waf_log_destination
}

output "bentley_waf_cw_log_group_name" { 
  value = var.waf_log_destination == "cloudwatch" ? aws_cloudwatch_log_group.bentley_waf_log_group01[0].name : null
   }

output "bentley_waf_logs_s3_bucket" { 
  value = var.waf_log_destination == "s3" ? aws_s3_bucket.bentley_waf_logs_bucket01[0].bucket : null 
  }

output "bentley_waf_firehose_name" { 
  value = var.waf_log_destination == "firehose" ? aws_kinesis_firehose_delivery_stream.bentley_waf_firehose01[0].name : null 
  }


 
