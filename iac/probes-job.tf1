# Definition of the probes job.
resource "local_file" "probesJob" {
  for_each = { for test in var.settings.probes.tests : test.id => test }
  filename = "${local.probesSourceConfigurationDirectory}/${var.settings.probes.prefix}-${each.value.region}-${each.key}.job"
  content  = <<EOT
*/${each.value.pollingTime} * * * * /bin/bash -c ${local.probesDestinationScriptsDirectory}/${var.settings.probes.prefix}.sh
EOT
}