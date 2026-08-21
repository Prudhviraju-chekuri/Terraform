data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# Account-wide password policy
# ---------------------------------------------------------------------------
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention       = 24
}

# ---------------------------------------------------------------------------
# Permission boundary - this is the single-account stand-in for an SCP.
# Real Organizations SCPs are enforced above IAM and apply account-wide even
# to admins; a permission boundary only caps whatever role/user it's attached
# to. So: attach it to every non-break-glass role, and protect the boundary
# policy itself so a bounded role can't edit its way out.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "permission_boundary" {
  statement {
    sid       = "AllowMostThings"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyOutsideAllowedRegion"
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = [var.allowed_region, "us-east-1"] # us-east-1 needed for some global endpoints
    }
  }

  statement {
    sid    = "DenyDisablingSecurityServices"
    effect = "Deny"
    actions = [
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
      "cloudtrail:UpdateTrail",
      "config:DeleteConfigurationRecorder",
      "config:StopConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "guardduty:DeleteDetector",
      "guardduty:UpdateDetector",
      "guardduty:DisassociateFromMasterAccount",
      "securityhub:DisableSecurityHub",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyEditingIAMGuardrails"
    effect = "Deny"
    actions = [
      "iam:DeleteRolePermissionsBoundary",
      "iam:PutRolePermissionsBoundary",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/landing-zone-permission-boundary",
    ]
  }

  statement {
    sid       = "DenyLeavingTheAccountUnprotected"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization", "account:CloseAccount"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "permission_boundary" {
  name        = "landing-zone-permission-boundary"
  description = "Simulates an SCP guardrail for a single-account lab: keeps actions in-region and protects logging/detection services from being disabled"
  policy      = data.aws_iam_policy_document.permission_boundary.json
}

# ---------------------------------------------------------------------------
# Bounded "developer" role - day to day work, capped by the boundary above
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "developer_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "developer" {
  name                 = "landing-zone-developer"
  assume_role_policy    = data.aws_iam_policy_document.developer_assume.json
  permissions_boundary  = aws_iam_policy.permission_boundary.arn
  max_session_duration  = 3600
}

resource "aws_iam_role_policy_attachment" "developer_power_user" {
  role       = aws_iam_role.developer.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# ---------------------------------------------------------------------------
# Break-glass admin - full access, no boundary, MFA required to assume.
# This is the ONLY role that can touch the guardrails themselves.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "break_glass_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "break_glass" {
  name                = "landing-zone-break-glass-admin"
  assume_role_policy   = data.aws_iam_policy_document.break_glass_assume.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "break_glass_admin" {
  role       = aws_iam_role.break_glass.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
