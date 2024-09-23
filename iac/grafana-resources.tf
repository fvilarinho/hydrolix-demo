resource "local_sensitive_file" "grafanaDatasource" {
  filename = local.grafanaDatasourceFilename
  content  = <<EOT
{
  "orgId": 1,
  "name": "grafana-clickhouse-datasource",
  "type": "grafana-clickhouse-datasource",
  "typeLogoUrl": "public/plugins/grafana-clickhouse-datasource/img/logo.svg",
  "basicAuth": false,
  "withCredentials": false,
  "isDefault": true,
  "jsonData": {
    "protocol": "native",
    "host": "${local.hydrolixHostname}",
    "port": 9440,
    "secure": true,
    "username": "${var.settings.general.email}"
  },
  "secureJsonData": {
    "password": "${var.settings.hydrolix.password}"
  },
  "readOnly": false,
  "accessControl": {
    "alert.instances.external:read": true,
    "alert.instances.external:write": true,
    "alert.notifications.external:read": true,
    "alert.notifications.external:write": true,
    "alert.rules.external:read": true,
    "alert.rules.external:write": true,
    "datasources.id:read": true,
    "datasources:delete": true,
    "datasources:query": true,
    "datasources:read": true,
    "datasources:write": true
  }
}
EOT
}

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

  depends_on = [
    linode_domain_record.grafana,
    local_sensitive_file.grafanaDatasource
  ]
}