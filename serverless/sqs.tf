resource "aws_sqs_queue" "dlq" {
  name = "test-dlq"
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.url

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.q.arn]
  })
}

resource "aws_sqs_queue" "q" {
  name                       = "test"
  visibility_timeout_seconds = 900
}

resource "aws_sqs_queue_redrive_policy" "q" {
  queue_url = aws_sqs_queue.q.url

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn,
    maxReceiveCount     = 5
  })
}
