output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "log_archive_bucket" {
  value = module.logging.log_bucket_name
}

output "cloudtrail_arn" {
  value = module.logging.cloudtrail_arn
}

output "security_alerts_topic_arn" {
  value = module.logging.sns_topic_arn
}

output "developer_role_arn" {
  description = "Assume this role to work as a bounded 'developer' - it cannot touch IAM, cannot disable logging, and cannot leave the allowed region"
  value       = module.iam_guardrails.developer_role_arn
}

output "break_glass_role_arn" {
  description = "Emergency admin role - requires MFA to assume, use only when the bounded roles genuinely aren't enough"
  value       = module.iam_guardrails.break_glass_role_arn
}

output "guardduty_detector_id" {
  value = module.threat_detection.guardduty_detector_id
}
