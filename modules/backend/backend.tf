/*
This is later uncommented after creating the tf state bucket to store the tfstate

*/


terraform {
  backend "s3" {
    bucket = "michael-tfstate-devsecops"
    key    = "michael-tfstate-devsecops/terraform.tfstate"
    region = "eu-west-1"
    # Include other necessary configurations such as encrypt, profile, etc.
  }
}


