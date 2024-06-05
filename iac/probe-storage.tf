# Definition of required local variables.
locals {
  probeStorageOriginHostname = "origin-${var.settings.probes.prefix}-${var.settings.probes.storage.prefix}.${var.settings.general.domain}"
}

# Definition of the probes storage instance.
resource "linode_instance" "probeStorage" {
  label           = "${var.settings.probes.prefix}-${var.settings.probes.storage.prefix}"
  tags            = var.settings.probes.storage.tags
  type            = var.settings.probes.storage.nodeType
  image           = var.settings.probes.storage.nodeImage
  region          = var.settings.probes.storage.region
  root_pass       = var.settings.probes.defaultPassword
  authorized_keys = [ chomp(file(pathexpand(var.settings.probes.storage.sshPublicKeyFilename))) ]

  # Initialization script.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.probes.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.probes.storage.sshPrivateKeyFilename)))
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
      "docker pull graphiteapp/graphite-statsd",
      "docker run --rm -d --name graphite -p 80:80 -p 2003-2004:2003-2004 -p 2023-2024:2023-2024 -p 8125:8125/udp -p 8126:8126 graphiteapp/graphite-statsd"
    ]
  }
}