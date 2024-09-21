# Creates the Linode DNS domain.
resource "linode_domain" "default" {
  domain    = var.settings.general.domain
  type      = "master"
  soa_email = var.settings.general.email
  ttl_sec   = 30
}

# Creates the Linode DNS domain record for Grafana.
resource "linode_domain_record" "grafana" {
  domain_id   = linode_domain.default.id
  name        = "${var.settings.grafana.prefix}.${var.settings.general.domain}"
  record_type = "CNAME"
  target      = data.external.grafanaOrigin.result.hostname
  ttl_sec     = 30
  depends_on  = [
    linode_domain.default,
    data.external.grafanaOrigin
  ]
}

# Creates the Linode DNS domain record for Hydrolix.
resource "linode_domain_record" "hydrolix" {
  domain_id   = linode_domain.default.id
  name        = "${var.settings.hydrolix.prefix}.${var.settings.general.domain}"
  record_type = "CNAME"
  target      = data.external.hydrolixOrigin.result.hostname
  ttl_sec     = 30
  depends_on  = [
    linode_domain.default,
    data.external.hydrolixOrigin
  ]
}