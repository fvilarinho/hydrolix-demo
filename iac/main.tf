# Required providers definition.
terraform {
  backend "s3" {
    bucket                      = "fvilarin-devops"
    key                         = "hydrolix-demo.tfstate"
    region                      = "us-east-1"
    endpoint                    = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.19.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
    http = {
      source  = "hashicorp/http"
    }
    akamai = {
      source  = "akamai/akamai"
    }
  }
}

# Retrieve the local machine public IP.
data "http" "myIp" {
  url    = "https://ipinfo.io"
  method = "GET"
}