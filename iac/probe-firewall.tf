data "http" "myIp" {
  url = "https://ipinfo.io"
}

# Definition the probes firewalls.
resource "linode_firewall" "probes" {
  label           = "${var.settings.probes.prefix}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "allowed_ips_tcp"
    protocol = "TCP"
    ipv4     = concat(var.settings.probes.allowedIps, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    action   = "ACCEPT"
  }

  inbound {
    label    = "allowed_ips_udp"
    protocol = "UDP"
    ipv4     = concat(var.settings.probes.allowedIps, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    action   = "ACCEPT"
  }

  inbound {
    label    = "allowed_ips_icmp"
    protocol = "ICMP"
    ipv4     = concat(var.settings.probes.allowedIps, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    action   = "ACCEPT"
  }

  depends_on = [ data.http.myIp ]
}

resource "linode_firewall_device" "probes" {
  for_each    = {for test in var.settings.probes.tests : test.id => test}
  entity_id   = linode_instance.probes[each.key].id
  firewall_id = linode_firewall.probes.id
  depends_on  = [
    linode_firewall.probes,
    linode_instance.probes
  ]
}

resource "linode_firewall_device" "probeSecurity" {
  entity_id   = linode_instance.probeSecurity.id
  firewall_id = linode_firewall.probes.id
  depends_on  = [
    linode_firewall.probes,
    linode_instance.probeSecurity
  ]
}

resource "linode_firewall" "probeStorage" {
  label           = "${var.settings.probes.prefix}-${var.settings.probes.storage.prefix}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"
  linodes         = [ linode_instance.probeStorage.id ]

  inbound {
    label    = "allow_${var.settings.grafana.prefix}_tcp"
    protocol = "TCP"
    ipv4     = [ "${linode_instance.grafana.ip_address}/32" ]
    action   = "ACCEPT"
  }

  inbound {
    label    = "allow_${var.settings.grafana.prefix}_udp"
    protocol = "UDP"
    ipv4     = [ "${linode_instance.grafana.ip_address}/32" ]
    action   = "ACCEPT"
  }

  inbound {
    label    = "allow_${var.settings.grafana.prefix}_icmp"
    protocol = "ICMP"
    ipv4     = [ "${linode_instance.grafana.ip_address}/32" ]
    action   = "ACCEPT"
  }

  inbound {
    label    = "allow_ips_tcp"
    protocol = "TCP"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
    action   = "ACCEPT"
  }

  inbound {
    label    = "allow_ips_udp"
    protocol = "UDP"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
    action   = "ACCEPT"
  }

  inbound {
    label    = "allow_ips_icmp"
    protocol = "ICMP"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
    action   = "ACCEPT"
  }

  dynamic "inbound" {
    for_each = var.settings.probes.tests

    content {
      label    = "allow_${linode_instance.probes[inbound.value.id].label}_tcp"
      protocol = "TCP"
      ipv4     = [ "${linode_instance.probes[inbound.value.id].ip_address}/32" ]
      action   = "ACCEPT"
    }
  }

  dynamic "inbound" {
    for_each = var.settings.probes.tests

    content {
      label    = "allow_${linode_instance.probes[inbound.value.id].label}_udp"
      protocol = "UDP"
      ipv4     = [ "${linode_instance.probes[inbound.value.id].ip_address}/32" ]
      action   = "ACCEPT"
    }
  }

  dynamic "inbound" {
    for_each = var.settings.probes.tests

    content {
      label    = "allow_${linode_instance.probes[inbound.value.id].label}_icmp"
      protocol = "ICMP"
      ipv4     = [ "${linode_instance.probes[inbound.value.id].ip_address}/32" ]
      action   = "ACCEPT"
    }
  }

  depends_on = [
    data.http.myIp,
    linode_instance.grafana,
    linode_instance.probes
  ]
}