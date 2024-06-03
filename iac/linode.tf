# Linode provider definition.
provider "linode" {
  token = var.credentials.linodeToken
}