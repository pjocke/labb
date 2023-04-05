data "archive_file" "function" {
  type        = "zip"
  source_file = "functions/function.py"
  output_path = "function.zip"
}

resource "aws_lambda_function" "receive" {
  filename      = data.archive_file.function.output_path
  function_name = "receive"
  role          = aws_iam_role.lambda.arn

  source_code_hash = data.archive_file.function.output_base64sha256

  runtime = "python3.7"
  handler = "function.receive_handler"

  timeout = 150
}

resource "aws_lambda_event_source_mapping" "receive" {
  event_source_arn        = aws_sqs_queue.q.arn
  function_name           = aws_lambda_function.receive.arn
  function_response_types = ["ReportBatchItemFailures"]
}

resource "aws_lambda_function" "send" {
  filename      = data.archive_file.function.output_path
  function_name = "send"
  role          = aws_iam_role.lambda.arn

  source_code_hash = data.archive_file.function.output_base64sha256

  runtime = "python3.7"
  handler = "function.send_handler"

  environment {
    variables = {
      SQS_URL = aws_sqs_queue.q.url
    }
  }
}

resource "aws_lambda_permission" "api" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send.function_name
  principal     = "apigateway.amazonaws.com"
}
