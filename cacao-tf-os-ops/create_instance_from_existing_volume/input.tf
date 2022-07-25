
variable "volume_id" {
  type = string
  description = "bootable volume's uuid"
  default = "9f6c9431-99be-4f69-906e-4c4e9d2c614b"
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
