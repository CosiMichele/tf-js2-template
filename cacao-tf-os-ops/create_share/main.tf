terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  # tenant_name = var.project
  region = var.share_region
}

resource "openstack_sharedfilesystem_share_v2" "share_01" {
  name             = var.share_name
  description      = var.share_description
  share_proto      = var.share_protocol
  size             = var.share_size

  lifecycle {
    ignore_changes = [export_locations]
  }
}

resource "openstack_sharedfilesystem_share_access_v2" "share_01_access" {
  share_id     = "${openstack_sharedfilesystem_share_v2.share_01.id}"
  access_type  = var.share_access_type
  access_to    = "${var.share_name}-access-${var.share_access_level}"
  access_level = var.share_access_level
}

# resource "random_string" "random_suffix" {
#   length   = 8
#   special  = false
#   upper    = false
# }

locals {
  # share_name = join("-",[lower(replace(replace(replace(var.share_name,".","-")," ","-"),"_","-")),random_string.random_suffix.result])
  share_path_splitted = try(split(":", openstack_sharedfilesystem_share_v2.share_01.export_locations[0].path),[])
  share_ceph_root_path = try(element(local.share_path_splitted,length(local.share_path_splitted)-1),"")
}