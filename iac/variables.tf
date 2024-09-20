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

#    akamai = {
#      contract = "<contract>"
#      group    = "<group>"

#      datastream = {
#        prefix       = "hydrolix-demo"
#        pushInterval = 30

#        properties = [
#          "<propertyName>"
#        ]
#      }
#    }

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

#    probes = {
#      prefix                = "probe"
#      tags                  = [ "probes", "observability" ]
#      nodeType              = "<nodeType>"
#      nodeImage             = "<nodeImage>"
#      sshPrivateKeyFilename = "~/.ssh/id_rsa"
#      sshPublicKeyFilename  = "~/.ssh/id_rsa.pub"
#      defaultPassword       = "<defaultPassword>"

#      storage = {
#        prefix                = "storage"
#        tags                  = [ "probes", "storage", "observability" ]
#        region                = "<region>"
#        nodeType              = "<nodeType>"
#        nodeImage             = "<nodeImage>"
#        sshPrivateKeyFilename = "~/.ssh/id_rsa"
#        sshPublicKeyFilename  = "~/.ssh/id_rsa.pub"
#      }

 #     securityTests = {
 #       prefix                = "security"
 #       tags                  = [ "probes", "security", "observability" ]
 #       region                = "<region>"
 #       nodeType              = "<nodeType>"
 #       nodeImage             = "<nodeImage>"
 #       sshPrivateKeyFilename = "~/.ssh/id_rsa"
 #       sshPublicKeyFilename  = "~/.ssh/id_rsa.pub"
 #     }

 #     tests = [
 #       {
 #         id          = 1
 #         region      = "<region>"
 #         url         = "<url>"
 #         browser     = "<browser>"
 #         pollingTime = 1
 #       }
 #     ]
 #   }
  }
}