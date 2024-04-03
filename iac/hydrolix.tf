# Downloads the Hydrolix operator content.
data "http" "hydrolixOperator" {
  url = "https://www.hydrolix.io/operator/latest/operator-resources?namespace=${var.settings.hydrolix.namespace}"
}

# Saves the Hydrolix operator file.
resource "local_sensitive_file" "hydrolixOperator" {
  filename   = var.settings.hydrolix.operatorFilename
  content    = data.http.hydrolixOperator.response_body
  depends_on = [ data.http.hydrolixOperator ]
}

# Saves the Hydrolix manifest file.
resource "local_sensitive_file" "hydrolixManifest" {
  filename = var.settings.hydrolix.manifestFilename
  content  = <<EOT
---
apiVersion: hydrolix.io/v1
kind: HydrolixCluster
metadata:
  name: hdx
  namespace: ${var.settings.hydrolix.namespace}
spec:
  hydrolix_name: hdx
  hydrolix_url: https://${var.settings.hydrolix.domain}
  admin_email: ${var.settings.hydrolix.email}
  db_bucket_region: ${data.linode_object_storage_cluster.hydrolix.id}
  db_bucket_url: https://${linode_object_storage_bucket.hydrolix.hostname}
  env:
    AWS_ACCESS_KEY_ID: ${linode_object_storage_key.hydrolix.access_key}
    AWS_SECRET_ACCESS_KEY: ${linode_object_storage_key.hydrolix.secret_key}
  ip_allowlist:
  - 0.0.0.0/0
  kubernetes_namespace: ${var.settings.hydrolix.namespace}
  kubernetes_profile: lke
  scale:
    postgres:
      replicas: 1
  scale_profile: dev
EOT

  depends_on = [
    linode_object_storage_bucket.hydrolix,
    linode_object_storage_key.hydrolix
  ]
}

# Deploys Hydrolix in LKE.
resource "null_resource" "deployHydrolix" {
  provisioner "local-exec" {
    environment = {
      NAMESPACE=var.settings.hydrolix.namespace
      CONFIGURATION_FILENAME=var.settings.hydrolix.configurationFilename
      CERTIFICATE_KEY_FILENAME=var.settings.hydrolix.certificateKeyFilename
      CERTIFICATE_FILENAME=var.settings.hydrolix.certificateFilename
      OPERATOR_FILENAME=var.settings.hydrolix.operatorFilename
      MANIFEST_FILENAME=var.settings.hydrolix.manifestFilename
    }

    quiet   = true
    command = "./deployHydrolix.sh"
  }

  depends_on = [
    local_sensitive_file.hydrolixOperator,
    local_sensitive_file.hydrolixManifest,
    local_sensitive_file.hydrolixConfiguration
  ]
}