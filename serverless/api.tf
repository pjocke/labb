resource "aws_api_gateway_rest_api" "send" {
  name = "send"
}

resource "aws_api_gateway_resource" "send" {
  rest_api_id = aws_api_gateway_rest_api.send.id
  parent_id   = aws_api_gateway_rest_api.send.root_resource_id
  path_part   = "send"
}

resource "aws_api_gateway_method" "send" {
  rest_api_id      = aws_api_gateway_rest_api.send.id
  resource_id      = aws_api_gateway_resource.send.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
  request_models = {
    "application/json" = aws_api_gateway_model.send.name
  }
  request_validator_id = aws_api_gateway_request_validator.send.id
}

resource "aws_api_gateway_method_response" "send" {
  rest_api_id = aws_api_gateway_rest_api.send.id
  resource_id = aws_api_gateway_resource.send.id
  http_method = aws_api_gateway_method.send.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_request_validator" "send" {
  name                  = "send"
  rest_api_id           = aws_api_gateway_rest_api.send.id
  validate_request_body = true
}

resource "aws_api_gateway_integration" "send" {
  rest_api_id             = aws_api_gateway_rest_api.send.id
  resource_id             = aws_api_gateway_resource.send.id
  http_method             = aws_api_gateway_method.send.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.send.invoke_arn
}

resource "aws_api_gateway_deployment" "send" {
  rest_api_id = aws_api_gateway_rest_api.send.id

  triggers = {
    redployment = sha1(jsonencode(aws_api_gateway_model.send.schema))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  stage_name = "dev"
  deployment_id = aws_api_gateway_deployment.send.id
  rest_api_id = aws_api_gateway_rest_api.send.id 
}

resource "aws_api_gateway_model" "send" {
  rest_api_id = aws_api_gateway_rest_api.send.id
  name = "send"
  description = "Test schema"
  content_type = "application/json"
  schema = jsonencode({
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title" : "Test schema",
    "type": "object",
    "properties": {
      "message": {
        "description": "Arbitrary data",
        "type": "string"
      }
    },
    "required": ["message"]
  })
}
