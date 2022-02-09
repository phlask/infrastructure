terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
      bucket = "phlask-tf-state"
      key    = "phlask.tfstate"
      region = "us-east-1"
      encrypt = true
      dynamodb_table = "phlask-tf-state-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}
