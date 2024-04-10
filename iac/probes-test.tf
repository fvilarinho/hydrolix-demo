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
export LOG_FILENAME="${var.settings.probes.prefix}.log"
export BROWSER="${each.value.browser}"
export URL="${each.value.url}"
export STORAGE_HOSTNAME="${linode_instance.probeStorage.ip_address}"

# Run the test.
docker run --rm \
           sitespeedio/sitespeed.io:latest \
           --browser "$BROWSER" \
           --browsertime.iterations 1 \
           --browsertime.screenshot false \
           --browsertime.video false \
           --graphite.host="$STORAGE_HOSTNAME" \
           --graphite.port=2003 \
           --graphite.namespace=sitespeed \
           "$URL" >> "$LOGS_DIR/$LOG_FILENAME"
EOT
}