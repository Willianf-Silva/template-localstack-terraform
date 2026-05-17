resource "aws_s3_bucket" "storage" {
  bucket = "${var.app_name}-storage"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "storage" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.storage.id

  versioning_configuration {
    status = "Enabled"
  }
}
