locals {
  fetchGrafanaOriginScript       = abspath(pathexpand("../bin/grafana/fetchOrigin.sh"))
  fetchGrafanaDnsChallengesScript = abspath(pathexpand("../bin/grafana/fetchDnsChallenges.sh"))
}

resource "linode_domain" "default" {
  domain    = var.settings.general.domain
  type      = "master"
  soa_email = var.settings.general.email
}

data "external" "grafanaOrigin" {
  program = [ local.fetchGrafanaOriginScript, local.grafanaKubeconfigFilename, var.settings.grafana.namespace ]
}

resource "linode_domain_record" "grafana" {
  domain_id   = linode_domain.default.id
  name        = "${var.settings.grafana.prefix}.${var.settings.general.domain}"
  record_type = "CNAME"
  target      = data.external.grafanaOrigin.result.hostname
  ttl_sec     = 30
  depends_on  = [
    linode_domain.default,
    linode_lke_cluster.grafana,
    null_resource.applyGrafanaStack,
    data.external.grafanaOrigin
  ]
}

data "external" "grafanaDnsChallenges" {
  program = [ local.fetchGrafanaDnsChallengesScript, var.settings.general.email, "${var.settings.grafana.prefix}.${var.settings.general.domain}" ]
}