# Definition of the probe cron job.
resource "local_file" "probesJob" {
  for_each = { for test in var.settings.probes.tests : test.id => test }
  filename = "${var.settings.probes.prefix}-${each.value.region}-${each.key}.job"
  content  = <<EOT
* * * * * /bin/bash -c ${var.settings.probes.workDirectory}/${var.settings.probes.scriptsDirectory}/${var.settings.probes.prefix}.sh
EOT
}