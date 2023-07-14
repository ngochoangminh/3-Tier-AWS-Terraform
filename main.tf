terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "-> 3.27"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
    profile = "default"
    region = "ap-southeast-1"
}
