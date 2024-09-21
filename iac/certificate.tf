locals {
  certificateIssuanceScript              = abspath(pathexpand("../bin/tls/certificateIssuance.sh"))
  certificateIssuanceCredentialsFilename = abspath(pathexpand("../etc/tls/certificateIssuance.properties"))
  certificateFilename                    = abspath(pathexpand("../etc/tls/fullchain.pem"))
  certificateKeyFilename                 = abspath(pathexpand("../etc/tls/privkey.pem"))
}

resource "local_sensitive_file" "certificateValidationCredentials" {
  filename = local.certificateIssuanceCredentialsFilename
  content  = <<EOT
dns_linode_key = ${var.credentials.linodeToken}
EOT
}

resource "null_resource" "certificateIssuance" {
  provisioner "local-exec" {
    environment = {
      CERTIFICATE_ISSUANCE_CREDENTIALS_FILENAME = local.certificateIssuanceCredentialsFilename
      DOMAIN                                    = var.settings.general.domain
      EMAIL                                     = var.settings.general.email
    }

    quiet   = true
    command = local.certificateIssuanceScript
  }

  depends_on = [ local_sensitive_file.certificateValidationCredentials ]
}

resource "local_sensitive_file" "certificate" {
  filename   = local.certificateFilename
  content    = file("/etc/letsencrypt/live/${var.settings.general.domain}/fullchain.pem")
  depends_on = [ null_resource.certificateIssuance ]
}

resource "local_sensitive_file" "certificateKey" {
  filename   = local.certificateKeyFilename
  content    = file("/etc/letsencrypt/live/${var.settings.general.domain}/privkey.pem")
  depends_on = [ null_resource.certificateIssuance ]
}