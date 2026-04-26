data "aws_s3_bucket" "state" {
  bucket = "projects-tf-state-new"

}


data "aws_dynamodb_table" "lock" {
  name = "tf-state-lock"
}