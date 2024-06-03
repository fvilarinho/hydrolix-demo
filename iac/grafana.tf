# Creates the Grafana configuration file.
resource "local_file" "grafanaConfiguration" {
  filename = var.settings.grafana.configurationFilename
  content = <<EOT
[server]
cert_key       = /etc/grafana/${var.settings.general.certificate.keyFilename}
cert_file      = /etc/grafana/${var.settings.general.certificate.pemFilename}
enforce_domain = false
protocol       = https
EOT
}

# Definition of the Grafana instance.
resource "linode_instance" "grafana" {
  label           = var.settings.grafana.prefix
  tags            = var.settings.grafana.tags
  type            = var.settings.grafana.nodeType
  image           = var.settings.grafana.nodeImage
  region          = var.settings.grafana.region
  root_pass       = var.settings.grafana.defaultPassword
  authorized_keys = [chomp(file(pathexpand(var.settings.grafana.sshPublicKeyFilename)))]

  # Initialization script.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.grafana.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
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
      "docker volume create grafana_data",
      "docker pull grafana/grafana"
    ]
  }

  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.grafana.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    source      = var.settings.grafana.configurationFilename
    destination = "/root/${var.settings.grafana.configurationFilename}"
  }

  # Copies certificates files.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.grafana.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    source      = var.settings.general.certificate.keyFilename
    destination = "/root/${var.settings.general.certificate.keyFilename}"
  }

  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.grafana.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    source      = var.settings.general.certificate.pemFilename
    destination = "/root/${var.settings.general.certificate.pemFilename}"
  }

  # Starts Grafana.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      password    = var.settings.grafana.defaultPassword
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    inline = [ "docker run -d --name grafana -p 443:3000 -e GF_SECURITY_ADMIN_PASSWORD=\"${var.settings.grafana.defaultPassword}\" -v \"/root/${var.settings.grafana.configurationFilename}:/etc/grafana/grafana.ini\" -v \"/root/${var.settings.general.certificate.keyFilename}:/etc/grafana/${var.settings.general.certificate.keyFilename}\" -v \"/root/${var.settings.general.certificate.pemFilename}:/etc/grafana/${var.settings.general.certificate.pemFilename}\" -v grafana_data:/var/lib/grafana grafana/grafana" ]
  }

  depends_on = [
    local_file.grafanaConfiguration,
    tls_self_signed_cert.default
  ]
}