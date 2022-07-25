resource "local_file" "ansible-inventory" {
    content = templatefile("${path.module}/hosts.yml.tmpl",
    {
        master_ip = openstack_compute_floatingip_associate_v2.os_master_floatingip_associate.0.floating_ip
        master_name = openstack_compute_instance_v2.os_master_instance.0.name
        worker_ips = openstack_compute_floatingip_associate_v2.os_worker_floatingips_associate.*.floating_ip
        worker_names = openstack_compute_instance_v2.os_worker_instance.*.name # we could use this instead of an generically generated index name
        k3s_hostname = var.master_hostname == "" ? openstack_compute_floatingip_associate_v2.os_master_floatingip_associate.0.floating_ip : var.master_hostname
        gpu_enable = var.gpu_enable
        traefik_disable = var.k3s_traefik_disable
        cacao_user = local.real_username
        # do_share_enable = var.jh_storage_size > 0 ? true : false
        # share_size = var.jh_storage_size
        # share_access_key = openstack_sharedfilesystem_share_access_v2.share_01_access.access_key
        # share_export_path = openstack_sharedfilesystem_share_v2.share_01.0.export_locations[0].path
        # share_access_to = openstack_sharedfilesystem_share_access_v2.share_01_access.access_to
        # share_ceph_monitors = trimsuffix(openstack_sharedfilesystem_share_v2.share_01.0.export_locations[0].path,":${local.share_ceph_root_path}")
        # share_ceph_root_path = local.share_ceph_root_path
        # share_readonly = var.jh_storage_readonly
    })
    filename = "${path.module}/ansible/hosts.yml"
}

resource "null_resource" "ansible-execution" {
    count = var.do_ansible_execution ? 1 : 0

    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        command = "ansible-galaxy install -r requirements.yaml"
        working_dir = "${path.module}/ansible"
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_PIPELINING=1 ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i hosts.yml playbook.yaml"
        working_dir = "${path.module}/ansible"
    }

    depends_on = [
        local_file.ansible-inventory
    ]
}
