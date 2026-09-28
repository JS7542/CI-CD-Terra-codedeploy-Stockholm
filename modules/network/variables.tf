variable "tag_header" {
  description = "tag header supplied by root module"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cidr supplied by root module"
  type        = string
}

variable "subnet_cidr" {
  description = "subnet cidr supplied by root module"
  type        = list(map(string))
}


variable "key_name" {
  description = "Existing EC2 key pair in the deployment region"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID for the bastion host"
  type        = string
}

variable "nat_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "nat_ssh_allowed_cidrs" {
  type    = list(string)
  default = []
}
