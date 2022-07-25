terraform {
  required_providers {
    openstack = {
      source = "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

resource "openstack_compute_volume_attach_v2" "attach_volume_01" {
  instance_id = var.instance_id
  volume_id   = var.volume_id
  count       = var.attach ? 1 : 0
}
