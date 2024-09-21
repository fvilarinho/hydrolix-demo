# Creates the LKE cluster.
resource "linode_lke_cluster" "hydrolix" {
  k8s_version = "1.30"
  label       = var.settings.hydrolix.prefix
  tags        = var.settings.hydrolix.tags
  region      = var.settings.hydrolix.region

  # Node pool definition.
  pool {
    type = var.settings.hydrolix.nodeType

    autoscaler {
      max = var.settings.hydrolix.maxNodeCount
      min = var.settings.hydrolix.minNodeCount
    }
  }

  # HA definition.
  control_plane {
    high_availability = true
  }
}

# Downloads the kubeconfig file to be able to connect in the LKE cluster after the provisioning.
resource "local_sensitive_file" "hydrolixKubeconfig" {
  filename        = local.hydrolixKubeconfigFilename
  content_base64  = linode_lke_cluster.hydrolix.kubeconfig
  file_permission = "600"
  depends_on      = [ linode_lke_cluster.hydrolix ]
}