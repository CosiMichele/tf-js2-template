output "share_export_path" {
  value = openstack_sharedfilesystem_share_v2.share_01.export_locations[0].path
}

output "share_access_to" {
  value = openstack_sharedfilesystem_share_access_v2.share_01_access.access_to
}

output "share_ceph_monitors" {
  value = trimsuffix(openstack_sharedfilesystem_share_v2.share_01.export_locations[0].path,":${local.share_ceph_root_path}")
}

output "share_ceph_root_path" {
  value = local.share_ceph_root_path
}

output "share_access_key" {
  value = openstack_sharedfilesystem_share_access_v2.share_01_access.access_key
  sensitive = true
}