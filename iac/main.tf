# Required providers definition.
terraform {
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
  url = "https://ipinfo.io"
}

locals {
  grafanaHost    = "${var.settings.grafana.prefix}.${var.settings.general.domain}"
  grafanaOrigin  = "origin-${local.grafanaHost}"
  hydrolixHost   = "${var.settings.hydrolix.prefix}.${var.settings.general.domain}"
  hydrolixOrigin = "origin-${local.hydrolixHost}"
}