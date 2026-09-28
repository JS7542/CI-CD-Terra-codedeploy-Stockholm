# =============================================================================
# Variables
# =============================================================================

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "default_name" {
  description = "Resource name prefix"
  type        = string
  default     = "std20-cicd"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_cidr" {
  description = "Public / Private / Cluster subnet CIDRs"
  type        = list(map(string))

  default = [
    {
      "eu-north-1a" = "10.20.1.0/24"
      "eu-north-1b" = "10.20.2.0/24"
      "eu-north-1c" = "10.20.3.0/24"
    },
    {
      "eu-north-1a" = "10.20.11.0/24"
      "eu-north-1b" = "10.20.12.0/24"
      "eu-north-1c" = "10.20.13.0/24"
    },
    {
      "eu-north-1a" = "10.20.21.0/24"
      "eu-north-1b" = "10.20.22.0/24"
      "eu-north-1c" = "10.20.23.0/24"
    }
  ]
}

variable "key_name" {
  description = "배포 리전에 이미 존재하는 AWS EC2 Key Pair 이름"
  type        = string
  default     = "std20-keypair"
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.35"
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "testdb"
}

variable "db_username" {
  description = "MySQL master username"
  type        = string
  default     = "std20"
}

# 추가: 제공한 파이프라인의 GitHub Source 설정
variable "github_repository" {
  description = "GitHub 소유자/저장소 이름"
  type        = string
}
variable "github_branch" {
  description = "GitHub 배포 브랜치"
  type        = string
}

variable "nat_instance_type" {
  description = "NAT instance type (x86_64 Amazon Linux 2023)"
  type        = string
  default     = "t3.micro"
}

variable "nat_ssh_allowed_cidrs" {
  description = "NAT 인스턴스 SSH 접속을 허용할 관리자의 IPv4 CIDR 목록 (예: 본인 공인 IP/32)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.nat_ssh_allowed_cidrs : can(cidrnetmask(cidr))])
    error_message = "SSH 접속 허용 주소는 유효한 IPv4 CIDR이어야 합니다."
  }
}
