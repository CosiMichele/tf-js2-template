terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  tenant_name = var.project
  # region = var.region
}

resource "openstack_compute_instance_v2" "instructor_instance" {
  name = var.instance_instructor_count == 1 ? "${var.instance_name}-instructor" : "${var.instance_name}-instructor${count.index}"
  count = var.instance_instructor_count
  image_id = var.image
  image_name = var.image_name
  flavor_name = var.flavor
  key_pair = var.keypair
  security_groups = var.security_groups
  power_state = var.power_state
  user_data = var.user_data
  tags = ["project=${var.project}","actor=${var.username}","template=vms4workshop","cacao"]

  network {
    name = "auto_allocated_network"
  }

  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource "openstack_compute_instance_v2" "student_instance" {
  name = local.instance_student_count == 1 ? "${var.instance_name}-student" : "${var.instance_name}-student${count.index}"
  count = local.instance_student_count
  image_id = var.image
  image_name = var.image_name
  flavor_name = var.flavor
  key_pair = var.keypair
  security_groups = var.security_groups
  power_state = var.power_state
  user_data = var.user_data
  # user_data = <<EOF
  #   #cloud-config
  #   locale: en_US.UTF-8
  # EOF
  tags = ["project=${var.project}","actor=${var.username}","template=vms4workshop","cacao"]

  network {
    name = "auto_allocated_network"
  }

  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource "openstack_networking_floatingip_v2" "instructor_floatingips" {
  count = var.instance_instructor_count
  pool = var.ip_pool
  description = "floating ip for ${var.instance_name}-instructor, ${count.index}/${var.instance_instructor_count}"
  tags = ["project=${var.project}","actor=${var.username}","template=vms4workshop","cacao"]
}

resource "openstack_networking_floatingip_v2" "student_floatingips" {
  count = local.instance_student_count
  pool = var.ip_pool
  description = "floating ip for ${var.instance_name}-student, ${count.index}/${local.instance_student_count}"
  tags = ["project=${var.project}","actor=${var.username}","template=vms4workshop","cacao"]
}

resource "openstack_compute_floatingip_associate_v2" "instructor_floatingips_associate" {
  count = var.instance_instructor_count
  floating_ip = openstack_networking_floatingip_v2.instructor_floatingips[count.index].address
  instance_id = openstack_compute_instance_v2.instructor_instance[count.index].id
}

resource "openstack_compute_floatingip_associate_v2" "student_floatingips_associate" {
  count = local.instance_student_count
  floating_ip = openstack_networking_floatingip_v2.student_floatingips[count.index].address
  instance_id = openstack_compute_instance_v2.student_instance[count.index].id
}

data "openstack_sharedfilesystem_share_v2" "share_01" {
  count = var.share_name == "" ? 0 : 1
  name = var.share_name
}

resource "random_string" "password_random_separator" {
  # count = length(var.student_usernames)
  length = 1
  override_special = "~!@#$^&*-_+=:;<>"
  upper = false
  lower = false
  number = false
  keepers = {
    instance_uuid = openstack_compute_instance_v2.instructor_instance.0.id
    username = var.username
  }
}

resource "random_string" "random_password_prefix" {
  count = length(var.student_usernames)
  length = 5
  special = false
  keepers = {
    instance_uuid = openstack_compute_instance_v2.student_instance[floor(count.index/var.students_per_instance)].id
    username = var.student_usernames[count.index]
  }
}

resource "random_pet" "random_password_student" {
  count = length(var.student_usernames)
  length = 3
  prefix = random_string.random_password_prefix[count.index].result
  separator = random_string.password_random_separator.result
  keepers = {
    instance_uuid = openstack_compute_instance_v2.student_instance[floor(count.index/var.students_per_instance)].id
    username = var.student_usernames[count.index]
  }
}
resource "random_string" "random_instructor_password_prefix" {
  length = 5
  special = false
  keepers = {
    instance_uuid = openstack_compute_instance_v2.instructor_instance.0.id
    username = var.username
  }
}

resource "random_pet" "random_instructor_password" {
  length = 3
  prefix = random_string.random_instructor_password_prefix.result
  separator = random_string.password_random_separator.result
  keepers = {
    instance_uuid = openstack_compute_instance_v2.instructor_instance.0.id
    username = var.username
  }
}

resource "local_file" "student_assignments_csv" {
  count = var.do_generate_local_csv ? 1 : 0
  content = local.csv_content
  filename = "${path.module}/student_assignments.csv"
}

locals {
  share_export_path = try(data.openstack_sharedfilesystem_share_v2.share_01.0.export_locations[0].path,"")
  share_access_to = var.share_access_to == "" ? "${var.share_name}-access-${var.share_access_level}" : "var.share_access_to"  # this will work with 'user1' and 'user1@example.com'

  # identify the system user
  split_username = split("@", var.username)
  system_user = local.split_username[0]

  student_usernames = try (
    split(",", var.student_usernames),
    tolist(var.student_usernames),
    []
  )

  instance_student_count = max(var.min_instances,ceil(length(var.student_usernames)/var.students_per_instance))
  

  combined_student_list = length(var.student_usernames) == 0 ? [["none","na",openstack_compute_instance_v2.student_instance[0].name,openstack_networking_floatingip_v2.student_floatingips[0].address,0]] : [for i in range(length(var.student_usernames)): [var.student_usernames[i], 
      random_pet.random_password_student[i].id, 
      openstack_compute_instance_v2.student_instance[floor(i/var.students_per_instance)].name,
      openstack_networking_floatingip_v2.student_floatingips[floor(i/var.students_per_instance)].address,
      i % var.students_per_instance + 5906]]

  instructors_ssh_keys_base64 = try (
    split(",", var.instructors_ssh_keys_base64),
    tolist(var.instructors_ssh_keys_base64),
    []
  )

  csv_content = templatefile ("${path.module}/student_assignments.csv.tftpl",
    {
      slist = concat(
        [for i in range(var.instance_instructor_count): ["${var.instructor_username}","${random_pet.random_instructor_password.id}",openstack_compute_instance_v2.instructor_instance[i].name,openstack_networking_floatingip_v2.instructor_floatingips[i].address,5906]],
        local.combined_student_list
        )
      students_per_instance = var.students_per_instance
    }
  )

}