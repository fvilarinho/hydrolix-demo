# Fetches the information from an object storage region.
data "linode_object_storage_cluster" "hydrolix" {
  id = "${var.settings.hydrolix.region}-1"
}

# Definition of the object storage bucket. This will be the origin hostname.
resource "linode_object_storage_bucket" "hydrolix" {
  label      = var.settings.hydrolix.prefix
  cluster    = data.linode_object_storage_cluster.hydrolix.id
  depends_on = [ data.linode_object_storage_cluster.hydrolix ]
}