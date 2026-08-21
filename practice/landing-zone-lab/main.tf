module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  trusted_ip_cidr    = var.trusted_ip_cidr
  enable_nat_gateway = var.enable_nat_gateway
}

module "logging" {
  source = "./modules/logging"

  alert_email = var.alert_email
}

module "iam_guardrails" {
  source = "./modules/iam-guardrails"

  allowed_region = var.aws_region
}

module "threat_detection" {
  source = "./modules/threat-detection"

  sns_topic_arn = module.logging.sns_topic_arn
}
