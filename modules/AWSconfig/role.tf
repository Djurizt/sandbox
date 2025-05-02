# resource "aws_iam_policy" "config_dynamodb_policy" {
#   name        = format("%s-%s-dynamodbwritepolicy", var.tags["environment"], var.tags["project"])
#   description = "Allows AWS Config to write to the DynamoDB tracking table"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "dynamodb:PutItem",
#           "dynamodb:GetItem",
#           "dynamodb:Query",
#           "dynamodb:Scan",
#           "dynamodb:BatchWriteItem"
#         ]
#         Resource = [
#           aws_dynamodb_table.config_tracker.arn,
#           "${aws_dynamodb_table.config_tracker.arn}/index/*"
#         ]
#       }
#     ]
#   })
# }

resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# resource "aws_iam_role_policy_attachment" "config_dynamodb_policy" {
#   role       = aws_iam_role.config_role.name
#   policy_arn = aws_iam_policy.config_dynamodb_policy.arn
# }