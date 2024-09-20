locals {
  probesSourceConfigurationDirectory      = "../etc/probes"
  probesSourceScriptsDirectory            = "../bin/probes"
  probesDestinationWorkingDirectory       = "/opt/probe"
  probesDestinationScriptsDirectory       = "${local.probesDestinationWorkingDirectory}/bin"
  probesDestinationConfigurationDirectory = "${local.probesDestinationWorkingDirectory}/etc"
  probesDestinationLogsDirectory          = "${local.probesDestinationWorkingDirectory}/logs"
}

# Definition of the probes instances.
resource "linode_instance" "probes" {
  for_each        = {for test in var.settings.probes.tests : test.id => test}
  label           = "${var.settings.probes.prefix}-${each.value.region}-${each.key}"
  tags            = var.settings.probes.tags
  type            = var.settings.probes.nodeType
  image           = var.settings.probes.nodeImage
  region          = each.value.region
  root_pass       = var.settings.probes.defaultPassword
  authorized_keys = [chomp(file(pathexpand(var.settings.probes.sshPublicKeyFilename)))]

  # Initialization script.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.sshPrivateKeyFilename)))
    }

    inline = [
      "hostnamectl set-hostname ${self.label}",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim htop",
      "systemctl enable cron",
      "curl https://get.docker.com | bash",
      "systemctl enable docker",
      "docker pull sitespeedio/sitespeed.io",
      "mkdir -p ${local.probesDestinationScriptsDirectory}",
      "mkdir -p ${local.probesDestinationConfigurationDirectory}",
      "mkdir -p ${local.probesDestinationLogsDirectory}"
    ]
  }

  # Copies the cron job.
  provisioner "file" {
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.sshPrivateKeyFilename)))
    }

    source      = "${abspath(pathexpand(local.probesSourceConfigurationDirectory))}/${var.settings.probes.prefix}-${each.value.region}-${each.key}.job"
    destination = "${local.probesDestinationConfigurationDirectory}/${var.settings.probes.prefix}.job"
  }

  # Copies the job script.
  provisioner "file" {
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.sshPrivateKeyFilename)))
    }

    source      = "${abspath(pathexpand(local.probesSourceScriptsDirectory))}/${var.settings.probes.prefix}-${each.value.region}-${each.key}.sh"
    destination = "${local.probesDestinationScriptsDirectory}/${var.settings.probes.prefix}.sh"
  }

  # Gives the execution permissions.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.sshPrivateKeyFilename)))
    }

    inline = [
      "chmod +x ${local.probesDestinationScriptsDirectory}/*.sh",
      "crontab ${local.probesDestinationConfigurationDirectory}/${var.settings.probes.prefix}.job"
    ]
  }

  depends_on = [
    linode_instance.probeStorage,
    linode_firewall.probes,
    local_file.probesJob,
    local_file.probesTest
  ]
}