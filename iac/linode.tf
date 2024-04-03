# Linode provider definition.
provider "linode" {
  config_path    = var.credentialsFilename
  config_profile = "linode"
}