# Creates the LKE cluster.
resource "linode_lke_cluster" "grafana" {
  k8s_version = "1.30"
  label       = var.settings.grafana.prefix
  tags        = var.settings.grafana.tags
  region      = var.settings.grafana.region

  # Node pools definition.
  pool {
    type  = var.settings.grafana.nodeType

    autoscaler {
      min = var.settings.grafana.minNodeCount
      max = var.settings.grafana.maxNodeCount
    }
  }

  # HA definition.
  control_plane {
    high_availability = true
  }
}

# Saves the kubeconfig locally.
resource "local_sensitive_file" "grafanaKubeconfig" {
  filename        = local.grafanaKubeconfigFilename
  content_base64  = linode_lke_cluster.grafana.kubeconfig
  file_permission = "600"
  depends_on      = [ linode_lke_cluster.grafana ]
}