variable "username" {
  type        = string
  description = "name of user"
}

variable "external_network_uuid" {
  type        = string
  description = "uuid of the external network"
}

variable "tenant_cidr" {
  type        = string
  description = "private cidr to use for tenant network"
  default     = "10.0.0.0/24"
}

variable "port_rules" {
  type = list(object({
    name             = string
    direction        = string
    ethertype        = string
    protocol         = string
    port_range_min   = number
    port_range_max   = number
    remote_ip_prefix = string
  }))
  description = "set of ports rules"
  default = [
    {
      name             = "tcp22open"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 22
      port_range_max   = 22
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      name             = "tcp80open"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 80
      port_range_max   = 80
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      name             = "tcp443open"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 443
      port_range_max   = 443
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      name             = "tcp1024-5899open"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 1024
      port_range_max   = 5899
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      name             = "tcp5910-6442open"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 5910
      port_range_max   = 6442
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      name             = "tcp6445-10249open"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 6445
      port_range_max   = 10249
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      name             = "tcp10251-65535open"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 10251
      port_range_max   = 65535
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      name             = "tcp6443-6444restricted"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 6443
      port_range_max   = 6444
      remote_ip_prefix = "10.0.0.0/8"
    },
    {
      name             = "tcp6443restricted"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 10250
      port_range_max   = 10250
      remote_ip_prefix = "10.0.0.0/8"
    },
    {
      name             = "tcp10"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 1
      port_range_max   = 65535
      remote_ip_prefix = "10.0.0.0/8"
    },
    {
      name             = "udp10"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "udp"
      port_range_min   = 1
      port_range_max   = 65535
      remote_ip_prefix = "10.0.0.0/8"
    },
    {
      name             = "vnc"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 5901
      port_range_max   = 5905
      remote_ip_prefix = "0.0.0.0/0" // TODO restrict the IP range
    }
  ]
}

variable "keypair_name" {
  type        = string
  description = "name of the keypair"
  default     = "cacao-ssh-key"
}

variable "public_ssh_key" {
  type        = string
  description = "public ssh key to use to create keypair"
}
