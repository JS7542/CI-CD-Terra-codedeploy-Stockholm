# 아래 기존 조회는 비활성화 상태로 보존하며, 파일 끝에서 키페어만 조회합니다.
# =============================================================================
# Data Sources
# =============================================================================

data "aws_availability_zones" "available_az" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Ubuntu Server 24.04 LTS
data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# backend에서 사용 중인 Terraform state bucket
data "aws_s3_bucket" "terraform_state" {
  bucket = "std20-terraform-state-s3-bucket"
}

# 기존 키페어를 조회만 합니다. 키/개인키를 새로 생성하지 않습니다.
data "aws_key_pair" "existing" {
  key_name = var.key_name
}
