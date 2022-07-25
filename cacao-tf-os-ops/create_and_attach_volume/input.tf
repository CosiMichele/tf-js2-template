variable "instance_id" {
  type = string
  description = "uuid of target instance, only required if attach is true"
  default = ""
  validation {
    condition     = can(regex("^$|^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.instance_id))
    error_message = "The instance_id is not a uuid."
  }
}

variable "volume_name" {
  type = string
  description = "name of volume as seen in openstack cli"
}

variable "volume_size" {
  type = number
  description = "size of volume in gb"
}

variable "attach" {
  type = bool
  description = "whether or not to attach the volume to the specified instance"
  default = false
}
