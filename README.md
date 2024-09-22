# Hydrolix Demo - Sandbox for observability in Akamai Connected Cloud.

## 1. Introduction
This application has the intention to demonstrate how to enable observability (collection of metrics, traces & logs) in 
an application under Akamai (CDN) and store the data in Hydrolix.

It uses probes to generate traffic and to test security.

It provides some dashboards for data visualization in Grafana.

## 2. Maintainers
- [Felipe Vilarinho](https://www.linkedin.com/in/fvilarinho)

If you want to collaborate in this project, reach out us by e-Mail.

You can also fork and customize this project by yourself once it's opensource. Follow the requirements below to set up 
your build environment.

## 3. Requirements

### To Setup
- [Terraform 1.5.x](https://www.terraform.io/)
- [kubectl 1.31.x or later](https://kubernetes.io/docs/reference/kubectl/kubect)
- [jq 1.7.x or later](https://jqlang.github.io/jq/)
- [curl 8.x or later](https://curl.se/)
- [certbot 2.x or later with Linode DNS plugins](https://certbot.eff.org/)
- `Any linux distribution with Kernel 6.x or later` or
- `MacOS - Catalina or later` or
- `MS-Windows 10 or later with WSL2`

Please check the section [Settings and Scripts](#4-settings-and-scripts)  below to know how to customize the 
provisioning. You'll also need to define the credentials of Akamai Connected Cloud. Please check the section 
[Other resources](#5-other-resources) at the end of this document to know how to.

### To Deploy / Undeploy
After the credentials and settings were defined, just execute the shell script `deploy.sh` to start the provisioning.
To deprovison, execute the shell script `undeploy.sh`.

The provisioning state will be stored in Akamai Object Storage. To set the storage definition, please edit the file 
`iac/main.tf` and modify the section backend with your values.

### To Access
To access the Hydrolix UI, just open your browser and type the URL: `[http|https]://<hydrolix-prefix>.<domain>` and to 
access the Grafana UI, just open your browser and type the URL: `[http|https]://<grafana-prefix>.<domain>`.

The 

## 4. Settings and Scripts
If you want to customize the stack by yourself, just edit the following files:
- `etc/grafana/ingress.conf`: Defines the Grafana ingress settings (Created on provisioning).
- `etc/grafana/resources/*`: Stores the Grafana resources (Dashboards, Datasources, etc.).
- `etc/grafana/stack.yaml`: Defines the Grafana stack (Created on provisioning).
- `etc/hydrolix/operator.yaml`: Defines the Hydrolix operator (Created on provisioning).
- `etc/hydrolix/resources/*`: Stores the Hydrolix resources (Project, Table and Transformation structures).
- `etc/hydrolix/stack.yaml`: Defines the Hydrolix stack (Created on provisioning).
- `etc/tls/*`: Stores the TLS certificate files and requirements for the issuance (Created on provisioning).
- `iac/certificate.tf`: Defines the TLS certificate provisioning using Certbot.
- `iac/dns.tf`: Defines the Linode DNS provisioning.
- `iac/grafana*.tf`: Defines the Grafana provisioning.
- `iac/hydrolix*.tf`: Defines the Hydrolix provisioning.
- `iac/main.tf`: Defines the required provisioning providers and state management.
- `iac/variables.tf`: Defines the provisioning variables. There is sensitive data in this file so it's a best practice 
to use the `terraform.tfvars` file. Please use the file `iac/terraform.tfvars.template` as template.

#### PLEASE DON'T COMMIT ANY CREDENTIALS OR SENSITIVE INFORMATION

## 5. Other Resources
- [Akamai Connected Cloud](https://www.linode.com/docs/)
- [Akamai Techdocs](https://techdocs.akamai.com/)
- [Hydrolix](https://docs.hydrolix.io/docs/welcome/)
- [Grafana](https://www.grafana.com/)

Additionally, you can create an Akamai Property and enable [Akamai Datastream 2](https://techdocs.akamai.com/datastream2/docs/welcome-datastream2) and collect/receive the 
CDN traffic logs and/or [Akamai SIEM Integration](https://techdocs.akamai.com/siem-integration/docs/welcome-siem-integration) for security logs.

And that's it! Have fun!
