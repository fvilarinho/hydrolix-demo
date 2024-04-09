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
      storageHostname         = "<storageHostname>"
      tests                   = [
        {
          id      = 1
          region  = "<region>"
          url     = "<url>"
          browser = "<browser>"
        },
        {
          id      = 2
          region  = "<region>"
          url     = "<url>"
          browser = "<browser>"
        },
        {
          id      = 3
          region  = "<region>"
          url     = "<url>"
          browser = "<browser>"
        }
      ]
      allowedIps = [ "<ip>/<mask>" ]
    }
  }
}