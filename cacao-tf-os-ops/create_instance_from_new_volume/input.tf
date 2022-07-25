
variable "volume_name" {
  type = string
  description = "name of the boot volume"
  default = "ubuntu 20.04 test disk"
}

variable "volume_size" {
  type = string
  description = "size of the boot volume"
  default = "20"
}

variable "volume_image" {
  type = string
  description = "uuid of the image the volume will be made from"
  default = "8f27559a-9e63-4fb7-9704-09526793e2d2"
}

variable "instance_name" {
  type = string
  description = "name of the instance"
  default = "ubuntu 20.04 test instance"
}

variable "instance_flavor" {
  type = string
  description = "flavor of the instance"
  default = "m1.tiny"
}

variable "instance_keypair" {
  type = string
  description = "keypair to be injected into instance"
  default = "Frady"
}

variable "delete_on_termination" {
  type = string
  description = "boolean to determine if volume is deleted on server termination"
  default = "false"
}

variable "network" {
  type = string
  description = "uuid of the network the instance will be attached to"
  default = "acc263a3-25ea-4f4b-80e7-fd483f34b40e"
}
