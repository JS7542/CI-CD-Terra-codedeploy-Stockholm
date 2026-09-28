variable "tag_header" {
  type = string
}
variable "security_group_ids" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}
variable "github_repository" {
  type = string
}
variable "github_branch" {
  type = string
}

variable "region" {
  description = "Deployment region for CodeDeploy agent download"
  type        = string
  default     = "eu-north-1"
}

variable "key_name" {
  description = "Existing EC2 key pair in the deployment region"
  type        = string
  default     = "std20-keypair"
}
