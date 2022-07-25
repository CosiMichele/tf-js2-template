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

resource "openstack_compute_instance_v2" "os_master_instance" {
  name = "${var.instance_name}-master"
  count = var.instance_count >= 1 ? 1 : 0
  image_id = var.image
  flavor_name = local.flavor_master
  key_pair = var.keypair
  security_groups = var.security_groups
  power_state = var.power_state
  user_data = var.user_data

  network {
        name = "${var.network}"
  }
}

resource "openstack_compute_instance_v2" "os_worker_instance" {
  name = "${var.instance_name}-worker${count.index}"
  count = var.instance_count >= 2 ? var.instance_count - 1 : 0
  image_id = var.image
  flavor_name = var.flavor
  key_pair = var.keypair
  security_groups = var.security_groups
  power_state = var.power_state
  user_data = var.user_data

  network {
    name = "${var.network}"
  }
}

resource "openstack_networking_floatingip_v2" "os_master_floatingip" {
  count = var.power_state == "active" && var.master_floating_ip == "" ? 1 : 0
  pool = var.ip_pool
  description = "floating ip for ${var.instance_name}-master"
}

resource "openstack_networking_floatingip_v2" "os_worker_floatingips" {
  count = var.power_state == "active" && var.instance_count >= 2 ? "${var.instance_count - 1}" : 0
  pool = var.ip_pool
  description = "floating ip for ${var.instance_name}-worker${count.index} of ${var.instance_count - 1}"
}

resource "openstack_compute_floatingip_associate_v2" "os_master_floatingip_associate" {
  count = var.power_state == "active" ? 1 : 0
  floating_ip = var.master_floating_ip == "" ? openstack_networking_floatingip_v2.os_master_floatingip.0.address : var.master_floating_ip
  instance_id = openstack_compute_instance_v2.os_master_instance.0.id
}

resource "openstack_compute_floatingip_associate_v2" "os_worker_floatingips_associate" {
  count = var.power_state == "active" && var.instance_count >= 2 ? "${var.instance_count - 1}" : 0
  floating_ip = openstack_networking_floatingip_v2.os_worker_floatingips[count.index].address
  instance_id = openstack_compute_instance_v2.os_worker_instance[count.index].id
}

# resource "openstack_sharedfilesystem_share_v2" "share_01" {
#   count = var.jh_storage_size <= 0 ? 0 : 1
#   name             = "${local.share_name_prefix}-share"
#   description      = "jupyterhub share"
#   share_proto      = "CEPHFS"
#   size             = var.jh_storage_size

#   lifecycle {
#     ignore_changes = [export_locations]
#   }

# }
# resource "openstack_sharedfilesystem_share_access_v2" "share_01_access" {
#   share_id     = "${openstack_sharedfilesystem_share_v2.share_01.0.id}"
#   access_type  = "cephx"
#   access_to    = "${local.share_name_prefix}-share-access"
#   access_level = "rw"
# }

locals {
  flavor_master = var.flavor

  # t
  split_username = split("@", var.username)
  real_username = local.split_username[0]
}