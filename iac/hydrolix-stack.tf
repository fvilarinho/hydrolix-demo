# Downloads the operator content.
data "http" "hydrolixOperator" {
  url    = local.hydrolixOperatorUrl
  method = "GET"
}

# Saves the operator file locally.
resource "local_sensitive_file" "hydrolixOperator" {
  filename   = local.hydrolixOperatorFilename
  content    = data.http.hydrolixOperator.response_body
  depends_on = [ data.http.hydrolixOperator ]
}

# Saves the stack file locally.
resource "local_sensitive_file" "hydrolixStack" {
  filename = local.hydrolixStackFilename
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
  db_bucket_region: ${linode_object_storage_bucket.hydrolix.region}
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

# Applies the stack in the LKE cluster.
resource "null_resource" "applyHydrolixStack" {
  provisioner "local-exec" {
    # Required variables.
    environment = {
      KUBECONFIG               = local.hydrolixKubeconfigFilename
      NAMESPACE                = var.settings.hydrolix.namespace
      OPERATOR_FILENAME        = local.hydrolixOperatorFilename
      STACK_FILENAME           = local.hydrolixStackFilename
      CERTIFICATE_FILENAME     = local.certificateFilename
      CERTIFICATE_KEY_FILENAME = local.certificateKeyFilename
    }

    quiet   = true
    command = local.hydrolixApplyStackScript
  }

  depends_on = [
    null_resource.certificateIssuance,
    local_sensitive_file.hydrolixKubeconfig,
    local_sensitive_file.hydrolixOperator,
    local_sensitive_file.hydrolixStack,
    null_resource.certificateIssuance
  ]
}

# Fetches the origin hostname.
data "external" "hydrolixOrigin" {
  program = [
    local.fetchHydrolixOriginScript,
    local.hydrolixKubeconfigFilename,
    var.settings.hydrolix.namespace
  ]

  depends_on = [ null_resource.applyHydrolixStack ]
}