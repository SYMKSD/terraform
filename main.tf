terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.65.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "8.3.0"
    }
  }  
  backend "local" {}
  // backend "remote" {
  //   hostname = "app.terraform.io"
  //   organization = "sloopstash"
  //   workspaces {
  //     prefix = "sloopstash-"
  //   }
  // }
}
 