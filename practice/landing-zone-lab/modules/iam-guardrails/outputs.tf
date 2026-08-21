output "permission_boundary_arn" {
  value = aws_iam_policy.permission_boundary.arn
}

output "developer_role_arn" {
  value = aws_iam_role.developer.arn
}

output "break_glass_role_arn" {
  value = aws_iam_role.break_glass.arn
}
