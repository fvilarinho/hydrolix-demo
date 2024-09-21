locals {
  hydrolixKubeconfigFilename = abspath(pathexpand("../etc/hydrolix/.kubeconfig"))
  hydrolixOperatorUrl        = "https://www.hydrolix.io/operator/latest/operator-resources?namespace=${var.settings.hydrolix.namespace}"
  hydrolixOperatorFilename   = abspath(pathexpand("../etc/hydrolix/operator.yaml"))
  hydrolixHostname           = "${var.settings.hydrolix.prefix}.${var.settings.general.domain}"
  hydrolixUrl                = "https://${local.hydrolixHostname}"
  hydrolixStackFilename      = abspath(pathexpand("../etc/hydrolix/stack.yaml"))
  hydrolixApplyStackScript   = abspath(pathexpand("../bin/hydrolix/applyStack.sh"))
  fetchHydrolixOriginScript  = abspath(pathexpand("../bin/hydrolix/fetchOrigin.sh"))
}