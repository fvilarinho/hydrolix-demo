# Creates the object storage bucket to storage the data.
resource "linode_object_storage_bucket" "hydrolix" {
  label  = var.settings.hydrolix.prefix
  region = var.settings.hydrolix.region
}

# Creates the object storage bucket credentials.
resource "linode_object_storage_key" "hydrolix" {
  label = var.settings.hydrolix.prefix

  # Definition of the permissions.
  bucket_access {
    region      = linode_object_storage_bucket.hydrolix.region
    bucket_name = linode_object_storage_bucket.hydrolix.label
    permissions = "read_write"
  }

  depends_on = [ linode_object_storage_bucket.hydrolix ]
}