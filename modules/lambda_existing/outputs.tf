output "functions" {
  description = "Map of Lambda function configurations"
  value = {
    for k, v in data.aws_lambda_function.function : k => {
      arn = v.arn
    }
  }
}
