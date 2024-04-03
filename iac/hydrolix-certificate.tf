# Creates a TLS private key.
resource "tls_private_key" "hydrolix" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creates a TLS self-signed certificate using the TLS private key.
resource "tls_self_signed_cert" "hydrolix" {
  private_key_pem       = tls_private_key.hydrolix.private_key_pem
  validity_period_hours = var.settings.hydrolix.certificateValidityHours

  subject {
    common_name = var.settings.hydrolix.domain
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  depends_on = [ tls_private_key.hydrolix ]
}

# Saves the TLS private key file.
resource "local_sensitive_file" "hydrolixCertificateKey" {
  filename   = var.settings.hydrolix.certificateKeyFilename
  content    = tls_private_key.hydrolix.private_key_pem
  depends_on = [ tls_private_key.hydrolix ]
}

# Saves the TLS certificate file.
resource "local_sensitive_file" "hydrolixCertificate" {
  filename   = var.settings.hydrolix.certificateFilename
  content    = tls_self_signed_cert.hydrolix.cert_pem
  depends_on = [ tls_self_signed_cert.hydrolix ]
}