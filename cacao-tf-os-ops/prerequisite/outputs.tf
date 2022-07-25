output "network_uuid" {
  value = openstack_networking_network_v2.user_network.id
}
output "subnet_uuid" {
  value = openstack_networking_subnet_v2.user_subnet.id
}
output "router_uuid" {
  value = openstack_networking_router_v2.user_router.id
}
output "secgroup_uuid" {
  value = openstack_networking_secgroup_v2.user_security_group.id
}
output "external_subnet_uuid" {
  value = openstack_networking_router_v2.user_router.external_fixed_ip[0].subnet_id
}

