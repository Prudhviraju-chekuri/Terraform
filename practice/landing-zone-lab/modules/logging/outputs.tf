output "log_bucket_name" {
  value = aws_s3_bucket.log_archive.id
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.this.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.security_alerts.arn
}

output "config_recorder_name" {
  value = aws_config_configuration_recorder.this.name
}
