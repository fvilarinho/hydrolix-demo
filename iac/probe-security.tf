# Definition of the probe security instance.
resource "linode_instance" "probeSecurity" {
  label           = "${var.settings.probes.prefix}-${var.settings.probes.securityTests.prefix}"
  tags            = var.settings.probes.securityTests.tags
  type            = var.settings.probes.securityTests.nodeType
  image           = var.settings.probes.securityTests.nodeImage
  region          = var.settings.probes.securityTests.region
  root_pass       = var.settings.probes.defaultPassword
  authorized_keys = [ chomp(file(pathexpand(var.settings.probes.securityTests.sshPublicKeyFilename))) ]
}

resource "linode_firewall_device" "probeSecurity" {
  entity_id   = linode_instance.probeSecurity.id
  firewall_id = linode_firewall.probes.id
  depends_on  = [
    linode_firewall.probes,
    linode_instance.probeSecurity
  ]
}