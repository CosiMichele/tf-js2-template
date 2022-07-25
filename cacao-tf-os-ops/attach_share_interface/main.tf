terraform {
  required_providers {
    openstack = {
      source = "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

resource "openstack_compute_interface_attach_v2" "interface_attachment_01" {
  instance_id = var.instance_uuid
  network_id  = var.share_network_uuid
}
