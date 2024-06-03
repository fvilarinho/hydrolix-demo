# Definition of the Akamai EdgeGrid credentials.
provider "akamai" {
  config {
    account_key   = var.credentials.edgeGridAccountKey
    host          = var.credentials.edgeGridHost
    access_token  = var.credentials.edgeGridAccessToken
    client_token  = var.credentials.edgeGridClientToken
    client_secret = var.credentials.edgeGridClientSecret
  }
}