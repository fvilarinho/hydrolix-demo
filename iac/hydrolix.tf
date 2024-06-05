# Definition of local variables.
locals {
  hydrolixHostname              = "${var.settings.hydrolix.prefix}.${var.settings.general.domain}"
  hydrolixUrl                   = "https://${local.hydrolixHostname}"
  hydrolixOriginUrl             = "https://${data.external.hydrolixOrigin.result.hostname}"
  hydrolixOriginHostname        = "origin-${local.hydrolixHostname}"
  hydrolixOperatorUrl           = "https://www.hydrolix.io/operator/latest/operator-resources?namespace=${var.settings.hydrolix.namespace}"
  hydrolixInstallScriptFilename = "../bin/hydrolix/install.sh"
  hydrolixOriginScriptFilename  = "../bin/hydrolix/fetchOrigin.sh"
}

# Downloads the Hydrolix operator content.
data "http" "hydrolixOperator" {
  url    = local.hydrolixOperatorUrl
  method = "GET"
}

# Saves the Hydrolix operator file.
resource "local_sensitive_file" "hydrolixOperator" {
  filename   = abspath(pathexpand(var.settings.hydrolix.operatorFilename))
  content    = data.http.hydrolixOperator.response_body
  depends_on = [ data.http.hydrolixOperator ]
}

# Saves the Hydrolix manifest file.
resource "local_sensitive_file" "hydrolixManifest" {
  filename = abspath(pathexpand(var.settings.hydrolix.manifestFilename))
  content  = <<EOT
---
apiVersion: hydrolix.io/v1
kind: HydrolixCluster
metadata:
  name: hdx
  namespace: ${var.settings.hydrolix.namespace}
spec:
  hydrolix_name: hdx
  hydrolix_url: ${local.hydrolixUrl}
  admin_email: ${var.settings.general.email}
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

# Installs Hydrolix in LKE.
resource "null_resource" "installHydrolix" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG=abspath(pathexpand(var.settings.hydrolix.kubeconfigFilename))
      NAMESPACE=var.settings.hydrolix.namespace
      OPERATOR_FILENAME=abspath(pathexpand(var.settings.hydrolix.operatorFilename))
      MANIFEST_FILENAME=abspath(pathexpand(var.settings.hydrolix.manifestFilename))
      CERTIFICATE_KEY_FILENAME=abspath(pathexpand(var.settings.general.certificate.keyFilename))
      CERTIFICATE_PEM_FILENAME=abspath(pathexpand(var.settings.general.certificate.pemFilename))
    }

    quiet   = true
    command = abspath(pathexpand(local.hydrolixInstallScriptFilename))
  }

  depends_on = [
    local_sensitive_file.hydrolixKubeconfig,
    local_sensitive_file.hydrolixOperator,
    local_sensitive_file.hydrolixManifest
  ]
}

# Fetches the Hydrolix origin.
data "external" "hydrolixOrigin" {
  program = [
    abspath(pathexpand(local.hydrolixOriginScriptFilename)),
    abspath(pathexpand(var.settings.hydrolix.kubeconfigFilename)),
    var.settings.hydrolix.namespace
  ]

  depends_on = [
    local_sensitive_file.hydrolixKubeconfig,
    linode_lke_cluster.hydrolix,
    null_resource.installHydrolix,
  ]
}