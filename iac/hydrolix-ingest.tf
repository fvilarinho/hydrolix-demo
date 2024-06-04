# Definition of the local variables.
locals {
  hydrolixLogin              = jsondecode(data.http.hydrolixLogin.response_body)
  hydrolixOrgs               = jsondecode(data.http.hydrolixOrgs.response_body)
  hydrolixOrg                = local.hydrolixOrgs.results[0].uuid
  hydrolixProjects           = compact([ for project in jsondecode(data.http.hydrolixProjects.response_body) : (project.name == local.hydrolixProjectStructure.name ? project.uuid : null)])
  hydrolixProject            = (length(local.hydrolixProjects) > 0 ? local.hydrolixProjects[0] : "")
  hydrolixProjectStructure   = jsondecode(chomp(file(abspath(pathexpand(var.settings.hydrolix.projectFilename)))))
  hydrolixTables             = compact([ for table in jsondecode(data.http.hydrolixTables.response_body) : (table.name == local.hydrolixTableStructure.name ? table.uuid : null)])
  hydrolixTable              = (length(local.hydrolixTables) > 0 ? local.hydrolixTables[0] : "")
  hydrolixTableStructure     = jsondecode(chomp(file(abspath(pathexpand(var.settings.hydrolix.tableFilename)))))
  hydrolixTransforms         = compact([ for transform in jsondecode(data.http.hydrolixTransforms.response_body) : (transform.name == local.hydrolixTransformStructure.name ? transform.uuid : null)])
  hydrolixTransform          = (length(local.hydrolixTransforms) > 0 ? local.hydrolixTransforms[0] : "")
  hydrolixTransformStructure = jsondecode(chomp(file(abspath(pathexpand(var.settings.hydrolix.transformFilename)))))
}

# Fetches Hydrolix orgs.
data "http" "hydrolixOrgs" {
  url    = "${local.hydrolixUrl}/config/v1/orgs"
  method = "GET"

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
    Authorization: "Bearer ${local.hydrolixLogin.auth_token.access_token}"
  }

  lifecycle {
    precondition {
      condition     = contains([200], data.http.hydrolixLogin.status_code)
      error_message = "Please confirm the credentials in Hydrolix platform to start the ingest provisioning!"
    }
  }

  depends_on = [ data.http.hydrolixLogin ]
}

# Fetches Hydrolix projects.
data "http" "hydrolixProjects" {
  url    = "${local.hydrolixUrl}/config/v1/orgs/${local.hydrolixOrg}/projects"
  method = "GET"

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
    Authorization: "Bearer ${local.hydrolixLogin.auth_token.access_token}"
  }

  lifecycle {
    precondition {
      condition     = length(local.hydrolixOrg) > 0
      error_message = "Please check your Hydrolix platform installation! The organization wasn't found!"
    }

    precondition {
      condition     = contains([200], data.http.hydrolixLogin.status_code)
      error_message = "Please confirm the credentials in Hydrolix platform to start the ingest provisioning!"
    }
  }

  depends_on = [ data.http.hydrolixOrgs ]
}

# Create the Hydrolix project when it doesn't exist.
data "http" "createHydrolixProject" {
  count  = (length(local.hydrolixProject) == 0 ? 1 : 0)
  url    = "${local.hydrolixUrl}/config/v1/orgs/${local.hydrolixOrg}/projects"
  method = "POST"

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
    Authorization: "Bearer ${local.hydrolixLogin.auth_token.access_token}"
  }

  request_body = jsonencode(local.hydrolixProjectStructure)

  lifecycle {
    precondition {
      condition     = length(local.hydrolixOrg) > 0
      error_message = "Please check your Hydrolix platform installation! The organization wasn't found!"
    }

    precondition {
      condition     = contains([200], data.http.hydrolixLogin.status_code)
      error_message = "Please confirm the credentials in Hydrolix platform to start the ingest provisioning!"
    }
  }

  depends_on = [ data.http.hydrolixProjects ]
}

# Fetches Hydrolix tables.
data "http" "hydrolixTables" {
  url    = "${local.hydrolixUrl}/config/v1/orgs/${local.hydrolixOrg}/projects/${(length(data.http.createHydrolixProject) > 0 ? jsondecode(data.http.createHydrolixProject[0].response_body).uuid : local.hydrolixProject)}/tables"
  method = "GET"

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
    Authorization: "Bearer ${local.hydrolixLogin.auth_token.access_token}"
  }

  lifecycle {
    precondition {
      condition     = (length(local.hydrolixProject) > 0 || length(data.http.createHydrolixProject) > 0)
      error_message = "Please check your Hydrolix platform installation! The project wasn't found!"
    }

    precondition {
      condition     = length(local.hydrolixOrg) > 0
      error_message = "Please check your Hydrolix platform installation! The organization wasn't found!"
    }

    precondition {
      condition     = contains([200], data.http.hydrolixLogin.status_code)
      error_message = "Please confirm the credentials in Hydrolix platform to start the ingest provisioning!"
    }
  }

  depends_on = [
    data.http.hydrolixProjects,
    data.http.createHydrolixProject
  ]
}

# Create the Hydrolix table when it doesn't exist.
data "http" "createHydrolixTable" {
  count  = (length(local.hydrolixTable) == 0 ? 1 : 0)
  url    = "${local.hydrolixUrl}/config/v1/orgs/${local.hydrolixOrg}/projects/${(length(data.http.createHydrolixProject) > 0 ? jsondecode(data.http.createHydrolixProject[0].response_body).uuid : local.hydrolixProject)}/tables"
  method = "POST"

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
    Authorization: "Bearer ${local.hydrolixLogin.auth_token.access_token}"
  }

  request_body = jsonencode(local.hydrolixTableStructure)

  lifecycle {
    precondition {
      condition     = (length(local.hydrolixProject) > 0 || length(data.http.createHydrolixProject) > 0)
      error_message = "Please check your Hydrolix platform installation! The project wasn't found!"
    }

    precondition {
      condition     = length(local.hydrolixOrg) > 0
      error_message = "Please check your Hydrolix platform installation! The organization wasn't found!"
    }

    precondition {
      condition     = contains([200], data.http.hydrolixLogin.status_code)
      error_message = "Please confirm the credentials in Hydrolix platform to start the ingest provisioning!"
    }
  }

  depends_on = [ data.http.hydrolixTables ]
}

# Fetches Hydrolix transforms.
data "http" "hydrolixTransforms" {
  url    = "${local.hydrolixUrl}/config/v1/orgs/${local.hydrolixOrg}/projects/${(length(data.http.createHydrolixProject) > 0 ? jsondecode(data.http.createHydrolixProject[0].response_body).uuid : local.hydrolixProject)}/tables/${(length(data.http.createHydrolixTable) > 0 ? jsondecode(data.http.createHydrolixTable[0].response_body).uuid : local.hydrolixTable)}/transforms"
  method = "GET"

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
    Authorization: "Bearer ${local.hydrolixLogin.auth_token.access_token}"
  }

  lifecycle {
    precondition {
      condition     = (length(local.hydrolixTable) > 0 || length(data.http.createHydrolixTable) > 0)
      error_message = "Please check your Hydrolix platform installation! The table wasn't found!"
    }

    precondition {
      condition     = (length(local.hydrolixProject) > 0 || length(data.http.createHydrolixProject) > 0)
      error_message = "Please check your Hydrolix platform installation! The project wasn't found!"
    }

    precondition {
      condition     = length(local.hydrolixOrg) > 0
      error_message = "Please check your Hydrolix platform installation! The organization wasn't found!"
    }

    precondition {
      condition     = contains([200], data.http.hydrolixLogin.status_code)
      error_message = "Please confirm the credentials in Hydrolix platform to start the ingest provisioning!"
    }
  }

  depends_on = [
    data.http.hydrolixTables,
    data.http.createHydrolixTable
  ]
}

# Create the Hydrolix transform when it doesn't exist.
data "http" "createHydrolixTransform" {
  count    = (length(local.hydrolixTransform) == 0 ? 1 : 0)
  url      = "${local.hydrolixUrl}/config/v1/orgs/${local.hydrolixOrg}/projects/${(length(data.http.createHydrolixProject) > 0 ? jsondecode(data.http.createHydrolixProject[0].response_body).uuid : local.hydrolixProject)}/tables/${(length(data.http.createHydrolixTable) > 0 ? jsondecode(data.http.createHydrolixTable[0].response_body).uuid : local.hydrolixTable)}/transforms"
  method   = "POST"

  request_headers = {
    Accept: "application/json"
    Content-Type: "application/json"
    Authorization: "Bearer ${local.hydrolixLogin.auth_token.access_token}"
  }

  request_body = jsonencode(local.hydrolixTransformStructure)

  lifecycle {
    precondition {
      condition     = (length(local.hydrolixTable) > 0 || length(data.http.createHydrolixTable) > 0)
      error_message = "Please check your Hydrolix platform installation! The table wasn't found!"
    }

    precondition {
      condition     = (length(local.hydrolixProject) > 0 || length(data.http.createHydrolixProject) > 0)
      error_message = "Please check your Hydrolix platform installation! The project wasn't found!"
    }

    precondition {
      condition     = length(local.hydrolixOrg) > 0
      error_message = "Please check your Hydrolix platform installation! The organization wasn't found!"
    }

    precondition {
      condition     = contains([200], data.http.hydrolixLogin.status_code)
      error_message = "Please confirm the credentials in Hydrolix platform to start the ingest provisioning!"
    }
  }

  depends_on = [ data.http.hydrolixTransforms ]
}