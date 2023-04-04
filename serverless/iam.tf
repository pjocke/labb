data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "basic" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "sqs" {
  name = "AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = data.aws_iam_policy.basic.arn
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.lambda.name
  policy_arn = data.aws_iam_policy.sqs.arn
}
