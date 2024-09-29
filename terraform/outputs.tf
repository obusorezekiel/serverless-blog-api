# Output API Gateway URL without a stage
output "api_url" {
  description = "The base URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.blog_api.id}.execute-api.${var.aws_region}.amazonaws.com"
}
