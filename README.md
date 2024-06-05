# Hydrolix Demo - The Akamai Observability Platform

## 1. Introduction
This application has the intention to demonstrate how to enable observability (collection of metrics, traces & logs) in 
an application under Akamai and store the data in Hydrolix.

It uses probes to generate traffic and also test security.

It also provides some dashboards for Data Visualization tool Grafana. You just need to import 
them.

## 2. Maintainers
- [Felipe Vilarinho](https://www.linkedin.com/in/fvilarinho)

If you want to collaborate in this project, reach out us by e-Mail.

You can also fork and customize this project by yourself once it's opensource. Follow the requirements below to set up 
your build environment.

## 3. Requirements

### To setup
- [Terraform 1.5.x or later](https://www.terraform.io/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/kubect)
- `Any linux distribution with Kernel 5.x or later` or
- `MacOS - Catalina or later` or
- `MS-Windows 10 or later with WSL2`
- `Dedicated machine with at least 4 CPU cores and 8 GB of RAM`

All the settings are defined in the `iac/variables.tf`. If you want to customize, please create a file call 
`iac/terraform.tfvars` containing your settings.

### To deploy
First, you need to define the credentials of Akamai Connected Cloud. Please check the Settings / Resources sections 
below.
After the credentials are defined, just execute the shell script `deploy.sh` to start the provisioning, and execute 
`undeploy.sh` for de-provisioning.

### To access
To access the Hydrolix UI, just open your browser and type the URL: `[http|https]://<hydrolix-prefix>.<domain>` and to access the
Grafana UI, just open your browser and type the URL: `[http|https]://<grafana-prefix>.<domain>`. After that the login prompt will
appear. Please check these attributes in your provisioning variables.

## 4. Settings
If you want to customize the stack by yourself, just edit the following files:
- `iac/main.tf`: Defines the required provisioning providers.
- `iac/variables.tf`: Defines the provisioning variables. There is sensitive information in this file so it's a best
practice to use the `terraform.tfvars` file.
- `iac/terraform.tfvars`: Customize the provisioning variables. Please use the file `iac/terraform.tfvars.template` as 
template.
- `iac/linode.tf`: Defines the Akamai Connected Cloud provider settings.
- `iac/certificate.tf`: Defines the TLS certificate provisioning.
- `iac/akamai.tf`: Defines the Akamai EdgeGrid provider settings.
- `iac/akamai-cpcode.tf`: Defines the Akamai CPCode used by the Akamai Property.
- `iac/akamai-datastream.tf`: Defines the Akamai DataStream 2 used to push the Akamai Property logs to Hydrolix.
- `iac/akamai-edgedns.tf`: Defines the Akamai Edge DNS entries used by all provisioned resources.
- `iac/akamai-edgehostname.tf`: Defines the Akamai Edge Hostname used by Akamai Property.
- `iac/akamai-property.tf`: Defines the Akamai Property provisioning.
- `iac/grafana.tf`: Defines the Grafana instances.
- `iac/grafana-firewall.tf`: Defines the Grafana firewall rules.
- `iac/hydrolix.tf`: Defines the Hydrolix instances.
- `iac/hydrolix-lke.tf`: Defines the Hydrolix LKE cluster.
- `iac/hydrolix-resources.tf`: Defines the Hydrolix resources (Project, Table & Transform) provisioning.
- `iac/hydrolix-storage.tf`: Defines the Hydrolix storage.
- `iac/hydrolix-storage-credentials.tf`: Defines the Hydrolix storage credentials.
- `iac/probe.tf`: Defines the probes instances.
- `iac/probe-firewall.tf`: Defines the probes firewall rules.
- `iac/probe-security.tf`: Defines the security probe.
- `iac/probe-storage.tf`: Defines the storage of the probes.
- `iac/probe-job.tf`: Defines the jobs of the probes.
- `iac/probe-test.tf`: Defines the tests of the probes.
- `etc/akamai/property/rules/*.json`: Defines the ruletree for the Akamai Property.
- `etc/grafana/*_dashboard.json`: Defines the default dashboards for Grafana.
- `etc/grafana/grafana.ini`: Defines the default settings for Grafana.
- `etc/hydrolix/*.json`: Defines the Hydrolix resources (Project, Table & Transform).

#### PLEASE DON'T COMMIT ANY CREDENTIALS OR SENSITIVE INFORMATION

## 5. Other resources
- [Akamai Connected Cloud](https://www.linode.com/)
- [Hydrolix](https://www.hydrolix.io/)
- [Grafana](https://www.grafana.com/)

Additionally, you can create an Akamai Property and enable [Akamai Datastream 2](https://techdocs.akamai.com/datastream2/docs/welcome-datastream2)
to collect the CDN traffic logs and/or [Akamai SIEM Integration](https://techdocs.akamai.com/siem-integration/docs/welcome-siem-integration)
for security logs.

And that's it! Have fun!
