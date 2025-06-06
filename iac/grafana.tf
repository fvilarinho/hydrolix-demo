# Required variables.
locals {
  grafanaKubeconfigFilename      = abspath(pathexpand("../etc/grafana/.kubeconfig"))
  grafanaHostname                = "${var.settings.grafana.prefix}.${var.settings.general.domain}"
  grafanaUrl                     = "https://${local.grafanaHostname}"
  grafanaIngressSettingsFilename = abspath(pathexpand("../etc/grafana/ingress.conf"))
  grafanaStackFilename           = abspath(pathexpand("../etc/grafana/stack.yaml"))
  grafanaDatasourceFilename      = abspath(pathexpand("../etc/grafana/resources/grafana-clickhouse-datasource.json"))
  grafanaDashboardFilename       = abspath(pathexpand("../etc/grafana/resources/akamai-ds2-dashboard.json"))
  grafanaApplyStackScript        = abspath(pathexpand("../bin/grafana/applyStack.sh"))
  grafanaApplyResourcesScript    = abspath(pathexpand("../bin/grafana/applyResources.sh"))
  fetchGrafanaOriginScript       = abspath(pathexpand("../bin/grafana/fetchOrigin.sh"))
}