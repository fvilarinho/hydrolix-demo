# Creates a TLS private key.
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creates a TLS self-signed certificate using the TLS private key.
resource "tls_self_signed_cert" "default" {
  private_key_pem       = tls_private_key.default.private_key_pem
  validity_period_hours = var.settings.general.certificate.validityHours

  # Definition of the CN and certificate details.
  subject {
    common_name         = var.settings.general.domain
    organization        = var.settings.general.certificate.organization
    organizational_unit = var.settings.general.certificate.organizationUnit
    street_address      = [ var.settings.general.certificate.street ]
    postal_code         = var.settings.general.certificate.zipcode
    locality            = var.settings.general.certificate.city
    province            = var.settings.general.certificate.region
    country             = var.settings.general.certificate.country
  }

  # Definition of the certificate SAN.
  dns_names = [
    local.hydrolixHostname,
    local.hydrolixOriginHostname,
    local.grafanaHostname,
    local.grafanaOriginHostname
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  depends_on = [ tls_private_key.default ]
}

# Saves the TLS private key file.
resource "local_sensitive_file" "certificateKey" {
  filename   = abspath(pathexpand(var.settings.general.certificate.keyFilename))
  content    = tls_private_key.default.private_key_pem
  depends_on = [ tls_private_key.default ]
}

# Saves the TLS certificate PEM file.
resource "local_sensitive_file" "certificatePem" {
  filename   = abspath(pathexpand(var.settings.general.certificate.pemFilename))
  content    = tls_self_signed_cert.default.cert_pem
  depends_on = [ tls_self_signed_cert.default ]
}