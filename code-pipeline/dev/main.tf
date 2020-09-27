provider "aws" {
  profile = "default"
}

terraform {
  required_version = "~> 0.13.0"

  backend "s3" {
    bucket = "shimpeiws-code-pipeline-deployment"
    key    = "dev/terraform.tfstate"
  }
}

module "code-pipeline" {
  source   = "../modules/code-pipeline"
  env_name = "dev"
}
