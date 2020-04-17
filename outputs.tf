output "bucket_id" {
  description = "Name of the bucket"
  value = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "Arn of the bucket"
  value = aws_s3_bucket.main.arn
}

output "bucket_region" {
  description = "Name of the bucket"
  value = aws_s3_bucket.main.region
}

output "bucket_regional_domain_name" {
  description = "Name of the bucket"
  value = aws_s3_bucket.main.bucket_regional_domain_name
}
