# Retrieve the TLS certificate fingerprint used in the pinning.
data "external" "certificateSha1Fingerprint" {
  program = [ abspath(pathexpand("./certificateSha1Fingerprint.sh")) ]
  query   = {
    CERTIFICATE_PEM_FILENAME = abspath(pathexpand(var.settings.general.certificate.pemFilename))
  }
}

# Process the Property rules.
data "akamai_property_rules_template" "rules" {
  template_file = abspath("property/rules/main.json")

  # Definition of the Hydrolix origin.
  variables {
    name  = "hydrolixOrigin"
    type  = "string"
    value = local.hydrolixOrigin
  }

  # Definition of the Hydrolix hostname.
  variables {
    name  = "hydrolixHost"
    type  = "string"
    value = local.hydrolixHost
  }

  # Definition of the Grafana origin.
  variables {
    name  = "grafanaOrigin"
    type  = "string"
    value = local.grafanaOrigin
  }

  # Definition of the Grafana hostname.
  variables {
    name  = "grafanaHost"
    type  = "string"
    value = local.grafanaHost
  }

  variables {
    name  = "cpCode"
    type  = "number"
    value = akamai_cp_code.default.id
  }

  # Definition of the TLS certificate common name used in the pinning.
  variables {
    name  = "certificateCommonName"
    type  = "string"
    value = var.settings.general.domain
  }

  # Definition of the TLS certificate PEM used in the pinning.
  variables {
    name  = "certificatePem"
    type  = "string"
    value = replace(tls_self_signed_cert.default.cert_pem, "\n", "\\n")
  }

  # Definition of the TLS certificate fingerprint used in the pinning.
  variables {
    name  = "certificateSha1Fingerprint"
    type  = "string"
    value = data.external.certificateSha1Fingerprint.result.fingerprint
  }

  depends_on = [
    tls_self_signed_cert.default,
    akamai_cp_code.default,
    data.external.certificateSha1Fingerprint
  ]
}

# Definition of the Property.
resource "akamai_property" "default" {
  name        = var.settings.akamai.property.name
  contract_id = var.settings.akamai.contract
  group_id    = var.settings.akamai.group
  product_id  = var.settings.akamai.property.product

  # Definition of the Grafana hostname/edge hostname.
  hostnames {
    cname_from             = local.grafanaHost
    cname_to               = akamai_edge_hostname.default.edge_hostname
    cert_provisioning_type = "DEFAULT"
  }

  # Definition of the Hydrolix hostname/edge hostname.
  hostnames {
    cname_from             = local.hydrolixHost
    cname_to               = akamai_edge_hostname.default.edge_hostname
    cert_provisioning_type = "DEFAULT"
  }

  rules = data.akamai_property_rules_template.rules.json

  depends_on = [
    akamai_edge_hostname.default,
    data.akamai_property_rules_template.rules
  ]
}

# Activates the Property in staging.
resource "akamai_property_activation" "default" {
  property_id                    = akamai_property.default.id
  contact                        = [ var.settings.general.email ]
  version                        = akamai_property.default.latest_version
  network                        = "STAGING"
  auto_acknowledge_rule_warnings = true
  depends_on                     = [
    akamai_property.default,
    akamai_dns_record.certificateValidation
  ]
}