
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }

    backend "s3" {
        bucket = "terraform-state-bucket-name"
        key    = "dev/terraform.tfstate"
        region = "ap-southeast-2"
        profile = "aws-profile-with-admin-access"
    }
}

# Configure the AWS Provider and region
provider "aws" {
    profile = "aws-profile-with-admin-access"
    region = var.region
}
