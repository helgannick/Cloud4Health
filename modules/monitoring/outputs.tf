output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  value = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "monitoring_summary" {
  value = {
    dashboard_name = aws_cloudwatch_dashboard.main.dashboard_name
    sns_topic     = aws_sns_topic.alerts.name
    widgets_count = 7
  }
}