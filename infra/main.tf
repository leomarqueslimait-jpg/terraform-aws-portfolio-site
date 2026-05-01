locals {
    tags = {
        Project = "portfolio"
        environment = "prod"
        Owner = "LeonardoMarques"
        ManagedBy = "Terraform"
    }
}


module "s3" {
source = "../modules/s3"
website_bucket_name = var.website_bucket_name
tags = local.tags
}

module "cloudfront" {
    source = "../modules/cloudfront"
    bucket_regional_domain = module.s3.bucket_regional_domain
    bucket_arn = module.s3.bucket_arn
    bucket_id = module.s3.bucket_id
    tags = local.tags
  
}

module "dynamodb" {
    source = "../modules/dynamodb"
    contact_table_name = var.contact_table_name
    tags = local.tags
}

module "iam" {
    source = "../modules/iam"
    dynamodb_arn = module.dynamodb.table_arn
    tags = local.tags
  
}

module "lambda" {
  source = "../modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn
  dynamodb_table_name = module.dynamodb.table_name
  tags = local.tags

}

module "api_gateway" {
  source = "../modules/api_gateway"
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn = module.lambda.invoke_arn
  tags = local.tags
}