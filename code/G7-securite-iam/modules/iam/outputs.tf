output "role_api_app_arn"        { value = aws_iam_role.api_app.arn }
output "role_cicd_arn"           { value = aws_iam_role.cicd.arn }
output "role_monitoring_arn"     { value = aws_iam_role.monitoring.arn }
output "instance_profile_api_app" { value = aws_iam_instance_profile.api_app.name }
