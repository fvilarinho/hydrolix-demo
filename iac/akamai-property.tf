# Definition of required local variables.
locals {
  certificateSha1FingerprintScriptFilename = "../bin/tls/fetchSha1Fingerprint.sh"
}

# Retrieve the TLS certificate fingerprint used in the pinning.
data "external" "certificateSha1Fingerprint" {
  program = [
    abspath(pathexpand(local.certificateSha1FingerprintScriptFilename)),
    abspath(pathexpand(var.settings.general.certificate.pemFilename))
  ]
}

# Process the Property rules.
data "akamai_property_rules_template" "hydrolix" {
  template_file = abspath(pathexpand(var.settings.akamai.property.rulesFilename))

  # Definition of the Hydrolix origin.
  variables {
    name  = "hydrolixOriginHostname"
    type  = "string"
    value = local.hydrolixOriginHostname
  }

  # Definition of the Hydrolix hostname.
  variables {
    name  = "hydrolixHostname"
    type  = "string"
    value = local.hydrolixHostname
  }

  # Definition of the Grafana origin.
  variables {
    name  = "grafanaOriginHostname"
    type  = "string"
    value = local.grafanaOriginHostname
  }

  # Definition of the Grafana hostname.
  variables {
    name  = "grafanaHostname"
    type  = "string"
    value = local.grafanaHostname
  }

  variables {
    name  = "cpCode"
    type  = "number"
    value = akamai_cp_code.hydrolix.id
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
    akamai_cp_code.hydrolix,
    data.external.certificateSha1Fingerprint
  ]
}

# Definition of the Property.
resource "akamai_property" "hydrolix" {
  name        = var.settings.akamai.property.name
  contract_id = var.settings.akamai.contract
  group_id    = var.settings.akamai.group
  product_id  = var.settings.akamai.property.product

  # Definition of the Grafana hostname/edge hostname.
  hostnames {
    cname_from             = local.grafanaHostname
    cname_to               = akamai_edge_hostname.hydrolix.edge_hostname
    cert_provisioning_type = "DEFAULT"
  }

  # Definition of the Hydrolix hostname/edge hostname.
  hostnames {
    cname_from             = local.hydrolixHostname
    cname_to               = akamai_edge_hostname.hydrolix.edge_hostname
    cert_provisioning_type = "DEFAULT"
  }

  rules = data.akamai_property_rules_template.hydrolix.json

  depends_on = [
    akamai_edge_hostname.hydrolix,
    data.akamai_property_rules_template.hydrolix
  ]
}

# Activates the Property in staging.
resource "akamai_property_activation" "staging" {
  property_id                    = akamai_property.hydrolix.id
  contact                        = [ var.settings.general.email ]
  version                        = akamai_property.hydrolix.latest_version
  network                        = "STAGING"
  auto_acknowledge_rule_warnings = true
  depends_on                     = [ akamai_property.hydrolix ]
}

# Activates the Property in staging.
resource "akamai_property_activation" "production" {
  property_id                    = akamai_property.hydrolix.id
  contact                        = [ var.settings.general.email ]
  version                        = akamai_property.hydrolix.latest_version
  network                        = "PRODUCTION"
  auto_acknowledge_rule_warnings = true

  compliance_record {
    noncompliance_reason_no_production_traffic {
    }
  }

  depends_on = [ akamai_property.hydrolix ]
}