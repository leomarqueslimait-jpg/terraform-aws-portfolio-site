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
website_bucket_name = "leomarques-portfolio-site"
tags = local.tags
}

module "cloudfront" {
    source = "../modules/cloudfront"
    bucket_regional_domain = 
  
}