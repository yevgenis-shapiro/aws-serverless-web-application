
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.app_distribution.domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.app_bucket.id
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.app_user_pool.id
}

output "cognito_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.app_client.id
}

output "appsync_endpoint" {
  description = "AppSync GraphQL endpoint"
  value       = aws_appsync_graphql_api.app_api.uris["GRAPHQL"]
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.app_table.name
}

output "elasticsearch_endpoint" {
  description = "Elasticsearch domain endpoint"
  value       = aws_elasticsearch_domain.app_es.endpoint
}

output "pinpoint_app_id" {
  description = "Pinpoint application ID"
  value       = aws_pinpoint_app.app_pinpoint.application_id
}
