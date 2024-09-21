variable "credentials" {
  default = {
    linodeToken = "<linodeToken>"
  }
}

# Settings definition.
variable "settings" {
  default = {
    general = {
      email  = "<email>"
      domain = "<domain>"
    }

#    hydrolix = {
#      prefix             = "hydrolix-demo"
#      tags               = [ "hydrolix", "observability" ]
#      namespace          = "hydrolix"
#      region             = "<region>"
#      nodeType           = "<nodeType>"
#      minNodeCount       = 4
#      maxNodeCount       = 10
#      kubeconfigFilename = "../etc/hydrolix/.kubeconfig"
#      operatorFilename   = "../etc/hydrolix/operator.yml"
#      manifestFilename   = "../etc/hydrolix/manifest.yml"
#      projectFilename    = "../etc/hydrolix/project.json"
#      tableFilename      = "../etc/hydrolix/table.json"
#      transformFilename  = "../etc/hydrolix/transform.json"
#      password           = "<password>"
#    }

    grafana = {
      namespace    = "grafana"
      prefix       = "grafana"
      tags         = [ "dataviz", "observability" ]
      region       = "<region>"
      nodeType     = "<nodeType>"
      minNodeCount = 1
      maxNodeCount = 3
    }
  }
}