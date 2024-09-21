# Applies the stack in the LKE cluster.
resource "null_resource" "applyGrafanaStack" {
  provisioner "local-exec" {
    # Required variables.
    environment = {
      KUBECONFIG                = local.grafanaKubeconfigFilename
      NAMESPACE                 = var.settings.grafana.namespace
      INGRESS_SETTINGS_FILENAME = local.grafanaIngressSettingsFilename
      STACK_FILENAME            = local.grafanaStackFilename
      CERTIFICATE_FILENAME      = local.certificateFilename
      CERTIFICATE_KEY_FILENAME  = local.certificateKeyFilename
    }

    quiet   = true
    command = local.grafanaApplyStackScript
  }

  depends_on = [
    local_sensitive_file.grafanaKubeconfig,
    null_resource.certificateIssuance
  ]
}

# Fetches the origin hostname.
data "external" "grafanaOrigin" {
  program = [
    local.fetchGrafanaOriginScript,
    local.grafanaKubeconfigFilename,
    var.settings.grafana.namespace
  ]

  depends_on = [ null_resource.applyGrafanaStack ]
}