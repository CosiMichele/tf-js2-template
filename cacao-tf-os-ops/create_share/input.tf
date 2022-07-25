variable "share_name" {
  type = string
  description = "string, name of share; no default"
}

variable "share_region" {
  type = string
  description = "string, region for share"
  default = "IU"
}

variable "share_description" {
  type = string
  description = "string, description of the share"
  default = "description of share"
}

variable "share_protocol" {
  type = string
  description = "string, the share protocol; default = CEPHFS"
  default = "CEPHFS"
}

variable "share_access_type" {
  type = string
  description = "string, the share type; default = cephx"
  default = "cephx"
}


variable "share_access_level" {
  type = string
  description = "string, the share access level, rw or ro; default = rw"
  default = "rw"
}

variable "share_size" {
  type = string
  description = "string, share size in gigabytes; no default"
}
