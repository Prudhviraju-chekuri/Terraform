# Secure Landing Zone Lab (single-account)

A hands-on Terraform lab that simulates the core guardrails of an AWS
landing zone — inside **one** AWS account, so it's cheap and safe to run
on a free-tier/credits account.

Real landing zones (AWS Control Tower + Organizations) spread these
controls across multiple accounts and enforce some of them with Service
Control Policies (SCPs), which only exist above an AWS Organization. This
lab reproduces the *effect* of those guardrails with tools that work in a
single account — see "How this maps to a real multi-account landing zone"
below.

## What gets built

| Module | What it does |
|---|---|
| `networking` | VPC with 2 public + 2 private subnets across 2 AZs, locked-down default security group, tiered security groups (web → app, SSH restricted to your IP), free S3 gateway endpoint, NAT Gateway **off** by default |
| `iam-guardrails` | Account password policy, a permission-boundary policy that stands in for an SCP (region lock, can't disable logging/detection, can't edit its own boundary), a bounded `developer` role, an unbounded MFA-only `break-glass-admin` role |
| `logging` | Encrypted, versioned, public-access-blocked S3 log archive; multi-region CloudTrail with log file validation; CloudTrail → CloudWatch Logs; 5 CIS-style metric filters/alarms (root usage, console sign-in without MFA, IAM policy changes, security group changes, unauthorized API calls) → SNS email; AWS Config recorder + 6 managed rules |
| `threat-detection` | GuardDuty detector; Security Hub with the AWS Foundational Security Best Practices standard; EventBridge rule forwarding medium+ severity GuardDuty findings to the same SNS topic |

## Prerequisites

- Terraform >= 1.5 (`terraform -version`)
- AWS CLI configured with credentials (`aws configure`) for an IAM user
  with admin rights on your free-tier account (you'll assume the
  Terraform-created roles for actual work afterward)
- Your public IP, for the SSH management security group:
  `curl https://checkip.amazonaws.com`

## Setup

```bash
cd landing-zone-lab
cp terraform.tfvars.example terraform.tfvars   # already done for you
# edit terraform.tfvars: set alert_email and trusted_ip_cidr

terraform init
terraform plan
terraform apply
```

Confirm the SNS email subscription (check your inbox) so alarms and
GuardDuty findings actually reach you.

## Cost — read this before you `apply`

Nothing here is fully "free forever," but at lab scale (near-zero real
traffic, short-lived) total cost is normally **well under $1-2** for a
few days of testing, IF you destroy it when done:

| Service | Cost driver | Lab-scale estimate |
|---|---|---|
| CloudTrail | Management-event trail is free; you pay only for S3 storage | Cents |
| S3 | Storage + requests | Cents |
| AWS Config | ~$0.003 per configuration item recorded + ~$0.001 per rule evaluation | A few cents to ~$1/day if you're actively changing resources |
| GuardDuty | 30-day free trial, then billed per GB of CloudTrail/VPC Flow/DNS logs analyzed | Cents/month at lab scale |
| Security Hub | ~$0.0010 per security check, first 100,000 checks/month free | Free at this scale |
| VPC, subnets, security groups, IGW | No charge | $0 |
| NAT Gateway | **~$0.045/hr + data processing — NOT free tier** | Left `false` by default for this reason |
| EventBridge, SNS | Free tier covers this scale | $0 |

**Set a billing alarm** regardless (AWS Console → Billing → Budgets) —
that's a landing-zone best practice you should have anyway.

## Cleanup

```bash
terraform destroy
```

GuardDuty, Config, and Security Hub keep billing per-hour/per-evaluation
even when idle, so don't leave this running when you're not actively
using it.

## How this maps to a real multi-account landing zone

| This lab (1 account) | Real landing zone (Control Tower / Organizations) |
|---|---|
| IAM permission boundary | Service Control Policy (SCP) — enforced above IAM, applies even to account admins, can't be bypassed from inside the account |
| Single S3 log archive bucket | Dedicated **Log Archive account**, so workload-account admins can't touch or delete the logs |
| `break-glass-admin` role in the same account | Dedicated **Security/Audit account** with cross-account read access into every workload account |
| One CloudTrail trail | Organization trail, created once, applied to every account automatically |
| Manually wired GuardDuty/Security Hub | GuardDuty/Security Hub **delegated administrator**, auto-enrolling every new account |
| One VPC | Each workload account gets its own VPC (or shared VPC via Resource Access Manager); blast radius is per-account, not per-VPC |

If you want to take this further, the natural next step is standing up
a second AWS account (free to create under an Organization), moving the
`logging` module's resources there, and replacing the permission
boundary with an actual SCP attached to an Organizational Unit.

## Learning exercises to try

1. Trip the "console sign-in without MFA" alarm by logging in without MFA.
2. Try to disable CloudTrail while assuming the `developer` role — the
   permission boundary should deny it. Then try it as `break-glass-admin`.
3. Add an S3 bucket with a public-read ACL and watch AWS Config flag it
   as `NON_COMPLIANT` within a few minutes.
4. Look at the GuardDuty console and manually generate sample findings
   (Settings → Sample findings) to see the SNS alert flow end-to-end
   without waiting for real malicious activity.
