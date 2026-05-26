output "prontuarios_bucket_id" {
  value = aws_s3_bucket.prontuarios.id
}

output "prontuarios_bucket_arn" {
  value = aws_s3_bucket.prontuarios.arn
}

output "backups_bucket_id" {
  value = aws_s3_bucket.backups.id
}

output "backups_bucket_arn" {
  value = aws_s3_bucket.backups.arn
}

output "logs_bucket_id" {
  value = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}

output "storage_summary" {
  value = {
    prontuarios = {
      bucket     = aws_s3_bucket.prontuarios.id
      encrypted  = true
      versioning = true
      lifecycle  = "90d → Glacier"
    }
    backups = {
      bucket     = aws_s3_bucket.backups.id
      encrypted  = true
      versioning = true
    }
    logs = {
      bucket    = aws_s3_bucket.logs.id
      encrypted = true
      lifecycle = "30d → Delete"
    }
  }
}