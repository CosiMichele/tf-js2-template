terraform {
  required_providers {
    openstack = {
      source = "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

provider "openstack" {
  tenant_name = var.project
}

resource "openstack_compute_instance_v2" "os_instances" {
  name = var.instance_count == 1 ? var.instance_name : "${var.instance_name}${count.index}"
  count = var.instance_count
  image_id = var.image
  flavor_name = var.flavor
  key_pair = var.keypair
  security_groups = ["${var.username}-api-sg"]
  power_state = var.power_state
  user_data = var.user_data

  network {
    name = "auto_allocated_network"
  }
}

resource "openstack_networking_floatingip_v2" "os_floatingips" {
  count = var.power_state == "active" ? var.instance_count : 0
  pool = var.ip_pool
  description = "floating ip for ${var.instance_name}, ${count.index}/${var.instance_count}"
}

resource "openstack_compute_floatingip_associate_v2" "os_floatingips_associate" {
  count = var.power_state == "active" ? var.instance_count : 0
  floating_ip = openstack_networking_floatingip_v2.os_floatingips[count.index].address
  instance_id = openstack_compute_instance_v2.os_instances[count.index].id
}
