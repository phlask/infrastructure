terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "phlask-terraform-state"
    key            = "infra.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "phlask-terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
