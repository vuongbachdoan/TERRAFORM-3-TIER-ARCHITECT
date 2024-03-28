terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "variable_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = var.dynamo_db_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "lock_id"

  attribute {
    name = "lock_id"
    type = "S"
  }
}

module "network" {
  source = "./modules/network"
  providers = {
    aws = aws
  }
}

module "app_layer" {
  source = "./modules/app"
  providers = {
    aws = aws
  }
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  depends_on         = [module.network]
}
