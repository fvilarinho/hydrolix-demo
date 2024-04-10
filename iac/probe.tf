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
      "mkdir -p ${var.settings.probes.workDirectory}/${var.settings.probes.scriptsDirectory}",
      "mkdir -p ${var.settings.probes.workDirectory}/${var.settings.probes.configurationsDirectory}",
      "mkdir -p ${var.settings.probes.workDirectory}/${var.settings.probes.logsDirectory}"
    ]
  }
}

resource "null_resource" "probeFiles" {
  for_each = {for test in var.settings.probes.tests : test.id => test}

  # Copies the cron job.
  provisioner "file" {
    connection {
      host        = linode_instance.probes[each.key].ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.sshPrivateKeyFilename)))
    }

    source      = "${var.settings.probes.prefix}-${each.value.region}-${each.key}.job"
    destination = "${var.settings.probes.workDirectory}/${var.settings.probes.configurationsDirectory}/${var.settings.probes.prefix}.job"
  }

  # Copies the job script.
  provisioner "file" {
    connection {
      host        = linode_instance.probes[each.key].ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.sshPrivateKeyFilename)))
    }

    source      = "${var.settings.probes.prefix}-${each.value.region}-${each.key}.sh"
    destination = "${var.settings.probes.workDirectory}/${var.settings.probes.scriptsDirectory}/${var.settings.probes.prefix}.sh"
  }

  # Gives the execution permissions.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.probes[each.key].ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.sshPrivateKeyFilename)))
    }

    inline = [
      "chmod +x ${var.settings.probes.workDirectory}/${var.settings.probes.scriptsDirectory}/*.sh",
      "crontab ${var.settings.probes.workDirectory}/${var.settings.probes.configurationsDirectory}/${var.settings.probes.prefix}.job"
    ]
  }

  depends_on = [
    linode_instance.probeStorage,
    local_file.probesJob,
    local_file.probesTest
  ]
}

resource "linode_firewall" "probes" {
  label           = "${var.settings.probes.prefix}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "allowed_ips"
    protocol = "TCP"
    ipv4     = var.settings.probes.allowedIps
    action   = "ACCEPT"
  }
}

resource "linode_firewall_device" "probes" {
  for_each    = {for test in var.settings.probes.tests : test.id => test}
  entity_id   = linode_instance.probes[each.key].id
  firewall_id = linode_firewall.probes.id
  depends_on  = [
    linode_firewall.probes,
    linode_instance.probes
  ]
}