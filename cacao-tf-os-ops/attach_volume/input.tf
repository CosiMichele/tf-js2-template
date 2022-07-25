variable "instance_id" {
  type = string
  description = "uuid of target instance"
}

variable "volume_id" {
  type = string
  description = "uuid of target volume"
}

variable "attach" {
  type = bool
  description = "whether or not to attach the volume to the specified instance"
  default = false
}

