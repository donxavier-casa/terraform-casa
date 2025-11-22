terraform {
  backend "s3" {
    bucket = "casa-state-file"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
