# Required variables.
locals {
  grafanaKubeconfigFilename      = abspath(pathexpand("../etc/grafana/.kubeconfig"))
  grafanaIngressSettingsFilename = abspath(pathexpand("../etc/grafana/ingress.conf"))
  grafanaStackFilename           = abspath(pathexpand("../etc/grafana/stack.yaml"))
  grafanaApplyStackScript        = abspath(pathexpand("../bin/grafana/applyStack.sh"))
  fetchGrafanaOriginScript       = abspath(pathexpand("../bin/grafana/fetchOrigin.sh"))
}