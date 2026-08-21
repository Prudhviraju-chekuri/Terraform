data "aws_region" "current" {}
data "aws_partition" "current" {}

# ---------------------------------------------------------------------------
# GuardDuty - free for 30 days, then billed per GB of logs analyzed.
# Lab-scale traffic is a few cents/month at most; destroy when done.
# ---------------------------------------------------------------------------
resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

# ---------------------------------------------------------------------------
# Security Hub - foundational best-practices standard only (keeps the
# per-check cost down instead of enabling every available standard)
# ---------------------------------------------------------------------------
resource "aws_securityhub_account" "this" {
  enable_default_standards = false
}

resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}

# ---------------------------------------------------------------------------
# Route GuardDuty findings (medium severity and up) to the same SNS topic
# used for CloudTrail alarms, so you get one inbox for all security signal
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "landing-zone-guardduty-findings"
  description = "Routes medium+ severity GuardDuty findings to the security alerts topic"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 4] }]
    }
  })
}

resource "aws_cloudwatch_event_target" "guardduty_to_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "sns"
  arn       = var.sns_topic_arn
}
