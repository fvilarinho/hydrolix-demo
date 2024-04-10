# Definition of the grafana instance.
resource "linode_instance" "grafana" {
  label           = var.settings.grafana.prefix
  tags            = var.settings.grafana.tags
  type            = var.settings.grafana.nodeType
  image           = var.settings.grafana.nodeImage
  region          = var.settings.grafana.region
  authorized_keys = [chomp(file(pathexpand(var.settings.grafana.sshPublicKeyFilename)))]

  # Initialization script.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
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
      "docker pull grafana/grafana"
    ]
  }
}

resource "null_resource" "grafanaFiles" {
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.grafana.ip_address
      user        = "root"
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    source      = "grafana.ini"
    destination = "/root/grafana.ini"
  }

  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.grafana.ip_address
      user        = "root"
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    source      = "cert.key"
    destination = "/root/cert.key"
  }

  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.grafana.ip_address
      user        = "root"
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    source      = "cert.pem"
    destination = "/root/cert.pem"
  }

  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.grafana.ip_address
      user        = "root"
      private_key = chomp(file(pathexpand(var.settings.grafana.sshPrivateKeyFilename)))
    }

    inline = [
      "docker run --rm -d --name grafana -p 443:3000 -v /root/grafana.ini:/etc/grafana/grafana.ini -v /root/cert.key:/etc/grafana/cert.key -v /root/cert.pem:/etc/grafana/cert.pem grafana/grafana"
    ]
  }

  depends_on = [
    linode_instance.grafana,
    tls_self_signed_cert.hydrolix
  ]
}