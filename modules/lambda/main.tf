resource "aws_lambda_function" "function" {
  for_each = var.functions

  function_name = each.key
  package_type  = "Image"
  image_uri     = each.value.image_uri
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = merge(
      {
        ENVIRONMENT = each.value.environment
      },
      each.value.additional_environment_variables
    )
  }

  tags = merge(
    var.tags,
    {
      Environment = each.value.environment
    }
  )
}

resource "aws_iam_role" "lambda_exec_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "lambda-s3-access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = var.s3_bucket_arns
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_api_gateway" {
  for_each = var.functions

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
