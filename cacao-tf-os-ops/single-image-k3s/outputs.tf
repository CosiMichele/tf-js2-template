output "instance_uuids" {
  value = concat([openstack_compute_instance_v2.os_master_instance.0.id], tolist(openstack_compute_instance_v2.os_worker_instance.*.id))
}
