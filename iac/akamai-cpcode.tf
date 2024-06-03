# Definition of the CP Code used for reporting and billing.
resource "akamai_cp_code" "default" {
  contract_id = var.settings.akamai.contract
  group_id    = var.settings.akamai.group
  product_id  = var.settings.akamai.property.product
  name        = var.settings.akamai.property.name
}