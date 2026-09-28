variable "tag_header" {
  description = "tag header supplied by root module"
  type        = string
}

variable "vpc_id" {
  description = "vpc id supplied by root module"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cidr supplied by root module"
  type        = string
}


variable "nat_security_group_id" {
  description = "NAT instance SG, also permitted as an SSH jump host"
  type        = string
  default     = null
}
