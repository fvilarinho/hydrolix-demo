# Definition of the probes test script.
resource "local_file" "probesTest" {
  for_each = { for test in var.settings.probes.tests : test.id => test }
  filename = "${var.settings.probes.prefix}-${each.value.region}-${each.key}.sh"
  content  = <<EOT
#!/bin/bash

# Required environment.
export WORK_DIR="${var.settings.probes.workDirectory}"
export CONF_DIR="$WORK_DIR/${var.settings.probes.configurationsDirectory}"
export LOGS_DIR="$WORK_DIR/${var.settings.probes.logsDirectory}"
export BROWSER="${each.value.browser}"
export URL="${each.value.url}"

# Run the test.
docker run --rm \
            sitespeedio/sitespeed.io:latest \
            --browser "$BROWSER" \
            --browsertime.iterations 1 \
            --browsertime.screenshot false \
            --browsertime.video false \
            --browsertime.visualMetrics false \
            "$URL" >> $LOGS_DIR/${var.settings.probes.prefix}.log
EOT
}