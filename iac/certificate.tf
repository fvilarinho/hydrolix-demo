# Required variables.
locals {
  certificateIssuanceScript              = abspath(pathexpand("../bin/tls/certificateIssuance.sh"))
  certificateIssuanceCredentialsFilename = abspath(pathexpand("../etc/tls/certificateIssuance.properties"))
  certificateFilename                    = abspath(pathexpand("../etc/tls/fullchain.pem"))
  certificateKeyFilename                 = abspath(pathexpand("../etc/tls/privkey.pem"))
}

resource "linode_token" "certificateIssuance" {
  label  = "certificate-issuance"
  scopes = "domains:read_write"
}

# Creates the certificate issuance credentials.
resource "local_sensitive_file" "certificateIssuanceCredentials" {
  filename = local.certificateIssuanceCredentialsFilename
  content  = <<EOT
dns_linode_key = ${linode_token.certificateIssuance.token}
EOT
  depends_on = [ linode_token.certificateIssuance ]
}

# Issues the certificate using Certbot.
resource "null_resource" "certificateIssuance" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    # Required variables.
    environment = {
      CERTIFICATE_ISSUANCE_CREDENTIALS_FILENAME = local.certificateIssuanceCredentialsFilename
      CERTIFICATE_ISSUANCE_PROPAGATION_DELAY    = 600 // in seconds.
      DOMAIN                                    = var.settings.general.domain
      EMAIL                                     = var.settings.general.email
    }

    quiet   = true
    command = local.certificateIssuanceScript
  }

  depends_on = [ local_sensitive_file.certificateIssuanceCredentials ]
}