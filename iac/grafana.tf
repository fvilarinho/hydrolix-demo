locals {
  grafanaKubeconfigFilename = abspath(pathexpand("../etc/grafana/.kubeconfig"))
  grafanaApplyStackScript   = abspath(pathexpand("../bin/grafana/applyStack.sh"))
}

resource "linode_lke_cluster" "grafana" {
  k8s_version = "1.30"
  label       = var.settings.grafana.prefix
  tags        = var.settings.grafana.tags
  region      = var.settings.grafana.region

  pool {
    type  = var.settings.grafana.nodeType

    autoscaler {
      min = var.settings.grafana.minNodeCount
      max = var.settings.grafana.maxNodeCount
    }
  }

  control_plane {
    high_availability = true
  }
}

resource "local_sensitive_file" "grafanaKubeconfig" {
  filename       = local.grafanaKubeconfigFilename
  content_base64 = linode_lke_cluster.grafana.kubeconfig
  depends_on     = [ linode_lke_cluster.grafana ]
}

resource "null_resource" "applyGrafanaStack" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local.grafanaKubeconfigFilename
      NAMESPACE  = var.settings.grafana.namespace
    }

    quiet   = true
    command = local.grafanaApplyStackScript
  }

  depends_on = [
    local_sensitive_file.grafanaKubeconfig,
    null_resource.certificateIssuance
  ]
}