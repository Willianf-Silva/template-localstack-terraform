# --- STORAGE (S3) ---
resource "aws_s3_bucket" "app_storage" {
  bucket = "local-app-storage"
}