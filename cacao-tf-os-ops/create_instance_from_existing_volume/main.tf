terraform {
  required_providers {
    openstack = {
      source = "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2#boot-from-an-existing-volume

resource "openstack_compute_instance_v2" "os_instance" {
  name            = var.instance_name
  flavor_name     = var.instance_flavor
  key_pair        = var.instance_keypair

  block_device {
    uuid                  = var.volume_id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  network {
    uuid = var.network
  }
}
