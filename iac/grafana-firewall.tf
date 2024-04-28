# Definition the grafana firewall.
resource "linode_firewall" "grafana" {
  label           = "${var.settings.grafana.prefix}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"
  linodes         = [ linode_instance.grafana.id ]

  inbound {
    label    = "allow_http_https"
    protocol = "TCP"
    ports    = "80,443"
    ipv4     = [ "0.0.0.0/0" ]
    action   = "ACCEPT"
  }

  inbound {
    label    = "allow_ssh"
    protocol = "TCP"
    ports    = "22"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
    action   = "ACCEPT"
  }

  inbound {
    label    = "allow_icmp"
    protocol = "ICMP"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
    action   = "ACCEPT"
  }

  depends_on = [
    data.http.myIp,
    linode_instance.grafana
  ]
}