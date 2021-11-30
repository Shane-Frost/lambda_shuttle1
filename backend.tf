#This is my bucket. There are many like it. But this one is mine. 

#I need to set my bucket here, and tell it what filepath(key) to put inside the bucket to store the TFstates.

# BACKEND CONFIGURATION
terraform {
  backend "s3" {
    bucket = "talent-academy-539350506885"
    key    = "sprint2/lambda-test/terraform.tfstates"
  }
}