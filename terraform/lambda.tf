resource "aws_lambda_function" "blog_lambda" {
  filename         = "../app/blog_handler.zip"
  function_name    = "blog_handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "blog_handler.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("../app/blog_handler.zip")

  environment {
    variables = {
      BLOG_TABLE = aws_dynamodb_table.blog_posts.name
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "lambda_dynamodb_access"
  role = aws_iam_role.lambda_exec.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = aws_dynamodb_table.blog_posts.arn
      }
    ]
  })
}