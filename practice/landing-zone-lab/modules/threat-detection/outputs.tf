output "guardduty_detector_id" {
  value = aws_guardduty_detector.this.id
}

output "securityhub_account_id" {
  value = aws_securityhub_account.this.id
}
