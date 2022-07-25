terraform {
  required_providers {
    openstack = {
      source = "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2#boot-from-volume

resource "openstack_blockstorage_volume_v1" "os_boot_volume" {
  name     = var.volume_name
  size     = var.volume_size
  image_id = var.volume_image
}

resource "openstack_compute_instance_v2" "os_instance" {
  name            = var.instance_name
  flavor_name     = var.instance_flavor
  key_pair        = var.instance_keypair

  block_device {
    uuid                  = openstack_blockstorage_volume_v1.os_boot_volume.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = var.delete_on_termination
  }

  network {
    uuid = var.network
  }
}
