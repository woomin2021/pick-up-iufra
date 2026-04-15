terraform {
  backend "s3" {
    bucket         = "pick-up-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "pick-up-terraform-lock-dev"
  }
}
