# Definition of the Edge Hostname used by the Property.
resource "akamai_edge_hostname" "hydrolix" {
  contract_id   = var.settings.akamai.contract
  group_id      = var.settings.akamai.group
  product_id    = var.settings.akamai.property.product
  ip_behavior   = var.settings.akamai.property.ipVersion
  edge_hostname = "${var.settings.akamai.property.name}.edgesuite.net"
}