output "volume_id" {
  value = openstack_blockstorage_volume_v1.os_boot_volume.id
}

output "instance_id" {
  value = openstack_compute_instance_v2.os_instance.id
}
