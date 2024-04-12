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
To access the Hydrolix UI, just open your browser and type the URL: `[http|https]://<hydrolix-node-balancer-ip>` and to access the
Grafana UI, just open your browser and type the URL: `[http|https]://<grafana-ip>`. After that the login prompt will
appear.

## 4. Settings
If you want to customize the stack by yourself, just edit the following files:
- `iac/.credentials`: Defines the Akamai Connected Cloud credentials. Please use the file `iac/.credentials.template` as
template.
as template.
- `iac/main.tf`: Defines the required provisioning providers.
- `iac/variables.tf`: Defines the provisioning variables. There is sensitive information in this file so it's a best
practice to use the `terraform.tfvars` file.
- `iac/terraform.tfvars`: Customize the provisioning variables. Please use the file `iac/terraform.tfvars.template` as 
template.
- `iac/linode.tf`: Defines the Akamai Connected Cloud provider.
- `iac/grafana.tf`: Defines the Grafana instances.
- `iac/hydrolix.tf`: Defines the Hydrolix instances.
- `iac/hydrolix-certificate.tf`: Defines the Hydrolix certificates.
- `iac/hydrolix-lke.tf`: Defines the Hydrolix kubernetes cluster.
- `iac/hydrolix-storage.tf`: Defines the Hydrolix storage.
- `iac/hydrolix-storage-credentials.tf`: Defines the Hydrolix storage credentials.
- `iac/probe.tf`: Defines the probes instances.
- `iac/probe-security.tf`: Defines the security probe.
- `iac/probe-storage.tf`: Defines the storage of the probes.
- `iac/probe-job.tf`: Defines the jobs of the probes.
- `iac/probe-test.tf`: Defines the tests of the probes.
- `iac/akamai_ds2_*.json`: Defines the Dashboards and ingest configurations for Hydrolix.

#### PLEASE DON'T COMMIT ANY CREDENTIALS OR SENSITIVE INFORMATION

## 5. Other resources
- [Akamai Connected Cloud](https://www.linode.com/)
- [Hydrolix](https://www.hydrolix.io/)
- [Grafana](https://www.grafana.com/)

Additionally, you can create an Akamai Property and enable [Akamai Datastream 2](https://techdocs.akamai.com/datastream2/docs/welcome-datastream2)
to collect the CDN traffic logs and/or [Akamai SIEM Integration](https://techdocs.akamai.com/siem-integration/docs/welcome-siem-integration)
for security logs.

And that's it! Have fun!
