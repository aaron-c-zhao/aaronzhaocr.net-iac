terraform {
  backend "s3" {
    bucket  = "personal-blog-terraform-backend-bucket"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
