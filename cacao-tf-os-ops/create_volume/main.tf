terraform {
  required_providers {
    openstack = {
      source = "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

resource "openstack_blockstorage_volume_v2" "create_volume_01" {
  name = var.volume_name
  size = var.volume_size
}
