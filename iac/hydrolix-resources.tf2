# Definition of the local variables.
locals {
  hydrolixResourcesScriptFilename = "../bin/hydrolix/resources.sh"
  hydrolixProjectStructure        = jsondecode(chomp(file(abspath(pathexpand(var.settings.hydrolix.projectFilename)))))
  hydrolixTableStructure          = jsondecode(chomp(file(abspath(pathexpand(var.settings.hydrolix.tableFilename)))))
  hydrolixTransformStructure      = jsondecode(chomp(file(abspath(pathexpand(var.settings.hydrolix.transformFilename)))))
}

# Checks if all required resources exist. If don't, it will create them.
resource "null_resource" "hydrolixResources" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = abspath(pathexpand(local.hydrolixResourcesScriptFilename))
    quiet   = true

    environment = {
      url                        = local.hydrolixOriginUrl
      username                   = var.settings.general.email
      password                   = var.settings.hydrolix.password
      projectStructureFilename   = abspath(pathexpand(var.settings.hydrolix.projectFilename))
      tableStructureFilename     = abspath(pathexpand(var.settings.hydrolix.tableFilename))
      transformStructureFilename = abspath(pathexpand(var.settings.hydrolix.transformFilename))
    }
  }

  depends_on = [
    data.external.hydrolixOrigin,
    akamai_property.hydrolix,
    akamai_property_activation.staging
  ]
}