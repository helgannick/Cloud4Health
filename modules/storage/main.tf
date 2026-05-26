# ============================================================================
# S3 Buckets - Storage
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Bucket 1: Prontuários médicos
resource "aws_s3_bucket" "prontuarios" {
  bucket = "${var.project_name}-${var.environment}-prontuarios-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-prontuarios"
      Sensitive   = "true"
      DataType    = "medical-records"
    }
  )
}

resource "aws_s3_bucket_versioning" "prontuarios" {
  bucket = aws_s3_bucket.prontuarios.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prontuarios" {
  bucket = aws_s3_bucket.prontuarios.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "prontuarios" {
  bucket = aws_s3_bucket.prontuarios.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "prontuarios" {
  bucket = aws_s3_bucket.prontuarios.id

  rule {
    id     = "archive-old-records"
    status = "Enabled"

    filter {}  

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# Bucket 2: Backups
resource "aws_s3_bucket" "backups" {
  bucket = "${var.project_name}-${var.environment}-backups-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name     = "${var.project_name}-${var.environment}-backups"
      DataType = "backups"
    }
  )
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket 3: Logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-${var.environment}-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name     = "${var.project_name}-${var.environment}-logs"
      DataType = "logs"
    }
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}  

    expiration {
      days = 30
    }
  }
}