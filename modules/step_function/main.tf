resource "aws_sfn_state_machine" "scraper_fanout" {
  name     = "${var.environment_prefix}-scraper-fanout-state-machine"
  role_arn = aws_iam_role.step_function_exec.arn
  definition = jsonencode({
    Comment = "Fan-out scrape events"
    StartAt = "ScrapeDates"
    States = {
      ScrapeDates = {
        Type = "Map"
        ItemsPath = "$.dates"
        Iterator = {
          StartAt = "ScrapeDate"
          States = {
            ScrapeDate = {
              Type = "Task"
              Resource = var.lambda_arn
              Parameters = {
                "httpMethod" = "POST"
                "queryStringParameters" = {
                  "date.$" = "$$.Map.Item.Value"
                }
              }
              End = true
            }
          }
        }
        End = true
      }
    }
  })
}

resource "aws_cloudwatch_event_rule" "daily_scrape_trigger" {
  name                = "${var.environment_prefix}-daily-scrape-trigger"
  description         = "Triggers the scraper Step Function daily"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "step_function_trigger" {
  rule      = aws_cloudwatch_event_rule.daily_scrape_trigger.name
  arn       = aws_sfn_state_machine.scraper_fanout.arn
  role_arn  = aws_iam_role.eventbridge_invoke_step.arn
  input     = jsonencode({
    dates = [
      "2025-04-10", "2025-04-11", "2025-04-12"  # This should be generated dynamically
    ]
  })
}

# IAM Roles and Policies
resource "aws_iam_role" "step_function_exec" {
  name = "${var.environment_prefix}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_function_lambda_invoke" {
  name = "${var.environment_prefix}-step-function-lambda-invoke"
  role = aws_iam_role.step_function_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = var.lambda_arn
      }
    ]
  })
}

resource "aws_iam_role" "eventbridge_invoke_step" {
  name = "${var.environment_prefix}-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_step_function_invoke" {
  name = "${var.environment_prefix}-eventbridge-step-function-invoke"
  role = aws_iam_role.eventbridge_invoke_step.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = aws_sfn_state_machine.scraper_fanout.arn
      }
    ]
  })
}
