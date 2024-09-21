# Required providers definition.
terraform {
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