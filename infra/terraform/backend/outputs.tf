output "bucket" { value = aws_s3_bucket.tfstate.bucket }
output "table"  { value = aws_dynamodb_table.tfstate_lock.name }
