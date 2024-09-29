resource "aws_api_gateway_rest_api" "blog_api" {
  name        = "BlogAPI"
  description = "API for the serverless blog"
}

resource "aws_api_gateway_resource" "blog" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_rest_api.blog_api.root_resource_id
  path_part   = "blog"
}

resource "aws_api_gateway_resource" "post" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.blog.id
  path_part   = "{postId}"
}

resource "aws_api_gateway_method" "get_post" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.post.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.postId" = true
  }
}

resource "aws_api_gateway_method" "create_post" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.blog.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "update_post" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.post.id
  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.postId" = true
  }
}

resource "aws_api_gateway_method" "delete_post" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.post.id
  http_method   = "DELETE"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.postId" = true
  }
}

# Integrate Lambda with API Gateway methods
resource "aws_api_gateway_integration" "get_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  resource_id = aws_api_gateway_resource.post.id
  http_method = aws_api_gateway_method.get_post.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "create_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  resource_id = aws_api_gateway_resource.blog.id
  http_method = aws_api_gateway_method.create_post.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "update_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  resource_id = aws_api_gateway_resource.post.id
  http_method = aws_api_gateway_method.update_post.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "delete_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  resource_id = aws_api_gateway_resource.post.id
  http_method = aws_api_gateway_method.delete_post.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.blog_lambda.invoke_arn
}
