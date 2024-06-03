# Creates a LKE cluster.
resource "linode_lke_cluster" "hydrolix" {
  label       = var.settings.hydrolix.prefix
  tags        = var.settings.hydrolix.tags
  k8s_version = var.settings.hydrolix.version
  region      = var.settings.hydrolix.region

  # Pool definition.
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
resource "local_sensitive_file" "hydrolixConfiguration" {
  filename        = var.settings.hydrolix.configurationFilename
  content_base64  = linode_lke_cluster.hydrolix.kubeconfig
  file_permission = "600"
  depends_on      = [ linode_lke_cluster.hydrolix ]
}