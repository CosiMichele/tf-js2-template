terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
}

resource "openstack_networking_secgroup_v2" "user_security_group" {
  name        = "${var.username}-api-sg"
  description = "Security group for ${var.username}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rules" {
  for_each          = {for port_rule in var.port_rules: port_rule.name => port_rule}
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = openstack_networking_secgroup_v2.user_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.user_security_group.id
}

resource "openstack_networking_network_v2" "user_network" {
  name        = "${var.username}-api-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "user_subnet" {
  name        = "${var.username}-api-subnet"
  network_id = openstack_networking_network_v2.user_network.id
  cidr       = var.tenant_cidr
  ip_version = 4
}

resource "openstack_networking_router_v2" "user_router" {
  name                = "${var.username}-api-router"
  admin_state_up      = true
  external_network_id = var.external_network_uuid
}

resource "openstack_networking_router_interface_v2" "user_router_interface" {
  router_id = openstack_networking_router_v2.user_router.id
  subnet_id = openstack_networking_subnet_v2.user_subnet.id
}

resource "openstack_compute_keypair_v2" "cacao_keypair" {
  name       = var.keypair_name
  public_key = var.public_ssh_key
}
