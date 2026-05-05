#The container
resource "aws_api_gateway_rest_api" "contacts" {
  name        = "portfolio-contact-api"
  description = "Contact form API for portfolio site"

  tags = merge(var.tags, { Name = "contact-api" })
}
#URL path/endpoint
resource "aws_api_gateway_resource" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.contacts.id
  parent_id   = aws_api_gateway_rest_api.contacts.root_resource_id
  path_part   = "contacts"

}

#POST method
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.contacts.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "POST"
  authorization = "NONE"

}

# OPTIONS method for CORS preflight
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.contacts.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "OPTIONS"
  authorization = "NONE"

}

# POST integratetion - calls Lambda
resource "aws_api_gateway_integration" "lambda_post" {
  rest_api_id             = aws_api_gateway_rest_api.contacts.id
  resource_id             = aws_api_gateway_resource.contacts.id
  integration_http_method = "POST"
  http_method             = aws_api_gateway_method.post.http_method
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_integration" "lambda_options" {
  rest_api_id = aws_api_gateway_rest_api.contacts.id
  resource_id             = aws_api_gateway_resource.contacts.id
  integration_http_method = "POST"
  http_method             = aws_api_gateway_method.options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# OPTIONS method response -tells browser which CORS headers to expect
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.contacts.id
resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.contacts.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.lambda_options]

}

# Permission — allows API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contacts.arn}/prod/POST/contact"
}

# Deployment - locks in the current API configuration
resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.contacts.id

  depends_on = [aws_api_gateway_integration.lambda_options, aws_api_gateway_integration.lambda_post]
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.contacts.id
  stage_name    = "prod"

  tags = merge(var.tags, { Name = "contact-api-prod-stage" })
}