# Definition of the Edge DNS TLS certificate validation entries.
data "akamai_property_hostnames" "default" {
  contract_id = var.settings.akamai.contract
  group_id    = var.settings.akamai.group
  property_id = akamai_property.default.id
  version     = akamai_property.default.latest_version
  depends_on  = [ akamai_property.default ]
}

resource "akamai_dns_record" "certificateValidation" {
  for_each = { for hostname in data.akamai_property_hostnames.default.hostnames : hostname.cname_from => hostname }
  zone       = var.settings.general.domain
  name       = each.value.cert_status[0].hostname
  recordtype = "CNAME"
  ttl        = 30
  target     = [ each.value.cert_status[0].target ]
  depends_on = [ data.akamai_property_hostnames.default ]
}

# Definition of the Edge DNS Grafana entries.
resource "akamai_dns_record" "grafana" {
  zone       = var.settings.general.domain
  name       = local.grafanaHostname
  recordtype = "CNAME"
  ttl        = 30
  target     = [ akamai_edge_hostname.default.edge_hostname ]
  depends_on = [ akamai_edge_hostname.default ]
}

resource "akamai_dns_record" "grafanaOrigin" {
  zone       = var.settings.general.domain
  name       = local.grafanaOriginHostname
  recordtype = "A"
  ttl        = 30
  target     = [ linode_instance.grafana.ip_address ]
  depends_on = [ linode_instance.grafana ]
}

# Definition of the Edge DNS Hydrolix entries.
resource "akamai_dns_record" "hydrolix" {
  zone       = var.settings.general.domain
  name       = local.hydrolixHostname
  recordtype = "CNAME"
  ttl        = 30
  target     = [ akamai_edge_hostname.default.edge_hostname ]
  depends_on = [ akamai_edge_hostname.default ]
}

resource "akamai_dns_record" "hydrolixOrigin" {
  zone       = var.settings.general.domain
  name       = local.hydrolixOriginHostname
  recordtype = "CNAME"
  ttl        = 30
  target     = [ data.external.hydrolixOrigin.result.hostname ]
  depends_on = [ data.external.hydrolixOrigin ]
}