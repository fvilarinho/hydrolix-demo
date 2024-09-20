locals {
  fetchGrafanaOriginScript = abspath(pathexpand("../bin/grafana/fetchOrigin.sh"))
}

data "linode_domain" "default" {
  domain = var.settings.general.domain
}

data "external" "grafanaOrigin" {
  program = [
    local.fetchGrafanaOriginScript,
    local.grafanaKubeconfigFilename,
    var.settings.grafana.namespace
  ]

  depends_on = [
    linode_lke_cluster.grafana,
    null_resource.applyGrafanaStack
  ]
}

resource "linode_domain_record" "grafana" {
  domain_id   = data.linode_domain.default.id
  name        = "${var.settings.grafana.prefix}.${var.settings.general.domain}"
  record_type = "A"
  target      = data.external.grafanaOrigin.result.ip
  ttl_sec     = 30
  depends_on  = [
    data.linode_domain.default,
    data.external.grafanaOrigin
  ]
}