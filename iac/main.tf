terraform {
  # Remote state management.
  backend "s3" {
    bucket                      = "fvilarin-devops"
    key                         = "hydrolix-demo.tfstate"
    region                      = "us-east-1"
    endpoint                    = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }

  # Required providers definition.
  required_providers {
    linode = {
      source  = "linode/linode"
    }
    http = {
      source  = "hashicorp/http"
    }
  }
}

# Linode provider definition.
provider "linode" {
  token = var.credentials.linodeToken
}