# Definition of the Edge DNS Grafana entries.
resource "akamai_dns_record" "grafana" {
  zone       = var.settings.general.domain
  name       = local.grafanaHostname
  recordtype = "CNAME"
  ttl        = 30
  target     = [ akamai_edge_hostname.hydrolix.edge_hostname ]
  depends_on = [ akamai_edge_hostname.hydrolix ]
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
  target     = [ akamai_edge_hostname.hydrolix.edge_hostname ]
  depends_on = [ akamai_edge_hostname.hydrolix ]
}

resource "akamai_dns_record" "hydrolixOrigin" {
  zone       = var.settings.general.domain
  name       = local.hydrolixOriginHostname
  recordtype = "CNAME"
  ttl        = 30
  target     = [ data.external.hydrolixOrigin.result.hostname ]
  depends_on = [ data.external.hydrolixOrigin ]
}