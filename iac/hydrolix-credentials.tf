# Check if the login in Hydrolix platform is working.
data "http" "hydrolixLogin" {
  url      = "${local.hydrolixUrl}/config/v1/login"
  method   = "POST"
  insecure = true

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
  }

  request_body = jsonencode({
    username: var.settings.general.email
    password: var.settings.hydrolix.password
  })

  depends_on = [
    akamai_property.default,
    akamai_dns_record.hydrolix
  ]
}