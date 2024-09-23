# Checks if all required resources exist. If don't, it will create them.
resource "null_resource" "applyGrafanaResources" {
  provisioner "local-exec" {
    # Required variables.
    environment = {
      URL                 = local.grafanaUrl
      USERNAME            = var.settings.general.email
      PASSWORD            = var.settings.grafana.password
      DATASOURCE_FILENAME = local.grafanaDatasourceFilename
    }

    command = abspath(pathexpand(local.grafanaApplyResourcesScript))
    quiet   = true
  }

  depends_on = [ linode_domain_record.grafana ]
}