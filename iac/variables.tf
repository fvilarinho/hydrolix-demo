# Credentials filename definition.
variable "credentialsFilename" {
  type    = string
  default = ".credentials"
}

# Settings definition.
variable "settings" {
  default = {
    hydrolix = {
      tags                     = [ "hydrolix", "observability" ]
      email                    = "<email>"
      domain                   = "<domain>"
      certificateKeyFilename   = "cert.key"
      certificateFilename      = "cert.pem"
      certificateValidityHours = 86400
      namespace                = "hydrolix"
      label                    = "hydrolix"
      version                  = "1.28"
      region                   = "<region>"
      nodeType                 = "g6-standard-6"
      defaultNodeCount         = 6
      minNodeCount             = 3
      maxNodeCount             = 6
      configurationFilename    = ".kubeconfig"
      operatorFilename         = "operator.yaml"
      manifestFilename         = "manifest.yaml"
      deployScriptFilename     = "deployHydrolix.sh"
    }
    grafana = {
      prefix                  = "grafana"
      tags                    = [ "dataviz", "observability" ]
      region                  = "<region>"
      nodeType                = "g6-standard-2"
      nodeImage               = "linode/debian11"
      sshPrivateKeyFilename   = "~/.ssh/id_rsa"
      sshPublicKeyFilename    = "~/.ssh/id_rsa.pub"
    }
    probes = {
      prefix                  = "probe"
      tags                    = [ "probes", "observability" ]
      nodeType                = "g6-nanode-1"
      nodeImage               = "linode/debian11"
      sshPrivateKeyFilename   = "~/.ssh/id_rsa"
      sshPublicKeyFilename    = "~/.ssh/id_rsa.pub"
      workDirectory           = "/opt/probe"
      scriptsDirectory        = "bin"
      configurationsDirectory = "etc"
      logsDirectory           = "logs"
      storage                 = {
        prefix                = "storage"
        tags                  = [ "probes", "storage", "observability" ]
        region                = "<region>"
        nodeType              = "g6-standard-2"
        nodeImage             = "linode/debian11"
        sshPrivateKeyFilename = "~/.ssh/id_rsa"
        sshPublicKeyFilename  = "~/.ssh/id_rsa.pub"
      }
      securityTests           = {
        prefix                = "security"
        tags                  = [ "probes", "security", "observability" ]
        region                = "<region>"
        nodeType              = "g6-standard-2"
        nodeImage             = "linode/kali-linux"
        sshPrivateKeyFilename = "~/.ssh/id_rsa"
        sshPublicKeyFilename  = "~/.ssh/id_rsa.pub"
      }
      tests                   = [
        {
          id          = 1
          region      = "<region>"
          url         = "<url>"
          browser     = "<browser>"
          pollingTime = 1
        },
        {
          id          = 2
          region      = "<region>"
          url         = "<url>"
          browser     = "<browser>"
          pollingTime = 1
        },
        {
          id          = 3
          region      = "<region>"
          url         = "<url>"
          browser     = "<browser>"
          pollingTime = 1
        }
      ]
      allowedIps = [ "<ip>/<mask>" ]
    }
  }
}