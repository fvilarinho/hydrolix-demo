# Definition of the probes firewall.
resource "linode_firewall" "probes" {
  label           = "${var.settings.probes.prefix}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    action   = "ACCEPT"
    label    = "ssh"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.settings.probes.allowedIps
  }
}

# Assigns all probes to the firewall.
resource "linode_firewall_device" "probes" {
  for_each    = { for test in var.settings.probes.tests : test.id => test }
  entity_id   = linode_instance.probes[each.key].id
  firewall_id = linode_firewall.probes.id
  depends_on  = [
    linode_instance.probes,
    linode_firewall.probes
  ]
}