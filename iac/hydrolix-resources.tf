# Required variables.
locals {
  hydrolixProjectStructure   = jsondecode(chomp(file(local.hydrolixProjectStructureFilename)))
  hydrolixTableStructure     = jsondecode(chomp(file(local.hydrolixTableStructureFilename)))
  hydrolixTransformStructure = jsondecode(chomp(file(local.hydrolixTransformStructureFilename)))
}

# Checks if all required resources exist. If don't, it will create them.
resource "null_resource" "applyHydrolixResources" {
  provisioner "local-exec" {
    # Required variables.
    environment = {
      URL                          = local.hydrolixUrl
      DOMAIN                       = var.settings.general.domain
      USERNAME                     = var.settings.general.email
      PASSWORD                     = var.settings.hydrolix.password
      PROJECT_STRUCTURE_FILENAME   = local.hydrolixProjectStructureFilename
      TABLE_STRUCTURE_FILENAME     = local.hydrolixTableStructureFilename
      TRANSFORM_STRUCTURE_FILENAME = local.hydrolixTransformStructureFilename
    }

    command = abspath(pathexpand(local.hydrolixApplyResourcesScript))
    quiet   = true
  }

  depends_on = [ linode_domain_record.hydrolix ]
}