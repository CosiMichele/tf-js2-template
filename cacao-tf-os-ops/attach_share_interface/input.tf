variable "instance_uuid" {
  type = string
  description = "uuid of the instance getting a share"
}

variable "share_network_uuid" {
  type = string
  description = "uuid of the network supporting a new share"
  default = "cfff7743-0b83-41b7-a91c-c5ac3747bbcf"
}
