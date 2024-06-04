# Definition of required local variables.
locals {
  datastreamProperties = [ for name in var.settings.akamai.datastream.properties : data.akamai_property.default[name].id ]
}

# Fetches all Akamai DataStream 2 fields available.
data "akamai_datastream_dataset_fields" "default" {
}

# Fetches the Properties to be attached to Akamai DataStream 2.
data "akamai_property" "default" {
  for_each = toset(var.settings.akamai.datastream.properties)
  name     = each.value
}

# Definition of the Akamai DataStream 2 configuration.
resource "akamai_datastream" "default" {
  contract_id    = var.settings.akamai.contract
  group_id       = var.settings.akamai.group
  stream_name    = var.settings.akamai.datastream.prefix
  dataset_fields = [ for dataset_field in data.akamai_datastream_dataset_fields.default.dataset_fields : dataset_field.dataset_field_id ]
  properties     = local.datastreamProperties
  active         = false

  delivery_configuration {
    format = "JSON"

    frequency {
      interval_in_secs = var.settings.akamai.datastream.pushInterval
    }
  }

  # Points to Hydrolix platform provisioned before.
  https_connector {
    display_name        = var.settings.hydrolix.prefix
    authentication_type = "BASIC"
    user_name           = var.settings.general.email
    password            = var.settings.hydrolix.password
    endpoint            = "${local.hydrolixUrl}/ingest/event?table=${local.hydrolixProjectStructure.name}.${local.hydrolixTableStructure.name}&transform=${local.hydrolixTransformStructure.name}"
    compress_logs       = true
    content_type        = "application/json"
  }

  # Only provision if all Hydrolix resources were created before.
  lifecycle {
    precondition {
      condition     = (length(local.hydrolixTransform) > 0 || length(data.http.createHydrolixTransform) > 0)
      error_message = "Please confirm in the Hydrolix platform if all resources (Project, Table and Transform) were created!"
    }
  }

  depends_on = [
    data.akamai_datastream_dataset_fields.default,
    data.akamai_property.default,
    data.http.hydrolixTransforms,
    data.http.createHydrolixTransform
  ]
}