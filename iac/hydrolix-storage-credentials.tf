# Definition of the object storage access key.
resource "linode_object_storage_key" "hydrolix" {
  label = var.settings.hydrolix.prefix

  # Definition of the permissions.
  bucket_access {
    cluster     = data.linode_object_storage_cluster.hydrolix.id
    bucket_name = linode_object_storage_bucket.hydrolix.label
    permissions = "read_write"
  }

  depends_on = [ linode_object_storage_bucket.hydrolix ]
}