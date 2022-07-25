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

resource "openstack_compute_volume_attach_v2" "attach_volume_01" {
  instance_id = var.instance_id
  volume_id   = openstack_blockstorage_volume_v2.create_volume_01.id
  count       = var.attach ? 1 : 0
}
