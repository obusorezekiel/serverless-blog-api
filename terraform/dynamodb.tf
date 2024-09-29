resource "aws_dynamodb_table" "blog_posts" {
  name         = "blog_posts"
  hash_key     = "postId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "postId"
    type = "S"
  }

  tags = {
    Name        = "BlogPostsTable"
    Environment = "Dev"
  }
}