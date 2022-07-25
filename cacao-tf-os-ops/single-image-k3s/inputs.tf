variable "username" {
  type = string
  description = "username"
}

variable "project" {
  type = string
  description = "project name"
}

variable "network" {
  type = string
  description = "network to use for vms"
  default = "auto_allocated_network"
}

variable "instance_name" {
  type = string
  description = "name of jupyterhub instance"
}

variable "instance_count" {
  type = number
  description = "number of instances to launch"
  default = 1
}

variable "image" {
  type = string
  description = "image id or name to launch"
}

variable "flavor" {
  type = string
  description = "flavor or size for the worker instances to launch"
  default = "m1.tiny"
}

# variable "flavor_master" {
#   type = string
#   description = "flavor or size for the master instance to launch"
#   default = "m3.medium"
# }

variable "keypair" {
  type = string
  description = "keypair to use when launching"
  default = ""
}

variable "power_state" {
  type = string
  description = "power state of instance"
  default = "active"
}

variable "ip_pool" {
  type = string
  description = "pool from which floating ip is allocated"
}

variable "user_data" {
  type = string
  description = "cloud init script"
  default = ""
}

variable "security_groups" {
  type = list(string)
  description = "array of security group names, either as a a comma-separated string or a list(string). The default is ['default', 'cacao-default']. See local.security_groups"
  default = ["default", "cacao-default"]
}

variable "master_floating_ip" {
  type = string
  description = "floating ip to assign, if one was pre-created; otherwise terraform will auto create one"
  default = ""
}

variable "master_hostname" {
  type = string
  description = "public facing hostname, if set, will be used for the callback url; default is not use set one, which will then use the floating ip"
  default = ""
}

variable "gpu_enable" {
  type = bool
  description = "boolean, whether to enable gpu components"
  default = false
}

variable "do_ansible_execution" {
  type = bool
  description = "boolean, whether to execute ansible"
  default = true
}

variable "ansible_execution_dir" {
  type = string
  description = "string, directory to execute ansible, including location to create the inventory file, where the requirements file is, etc"
  default = "./ansible"
}

variable "k3s_traefik_disable" {
  type = bool
  description = "bool, if true will disable traefik"
  default = false
}

# variable "jh_storage_size" {
#   type = number
#   description = "integer, size in gigabytes for shared files"
#   default = -1
# }

# variable "jh_storage_mount_dir" {
#   type = string
#   description = "string, the path inside of the container to mount the shared storage"
#   default = "/home/shared"
# }

# variable "jh_storage_readonly" {
#   type = bool
#   description = "bool, will the storage be readonly (currently not used)"
#   default = false
# }