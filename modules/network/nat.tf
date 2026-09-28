# AMI IDs are regional. Resolve an official AL2023 x86_64 AMI locally.
data "aws_ami" "nat_al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "std20_nat_sg" {
  name        = "${var.tag_header}nat-sg"
  description = "Outbound NAT for private and cluster subnets; optional admin SSH"
  vpc_id      = aws_vpc.std20_vpc.id

  # NAT traffic must be allowed by source CIDR, not by the web/ALB SG.
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      for subnet in values(local.subnet_map) : subnet.cidr
      if contains(["private", "cluster"], subnet.type)
    ]
  }

  dynamic "ingress" {
    for_each = toset(var.nat_ssh_allowed_cidrs)
    content {
      description = "Administrator SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_header}nat-sg"
  }
}

resource "aws_instance" "std20_nat_instance" {
  ami                         = data.aws_ami.nat_al2023.id
  instance_type               = var.nat_instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.create_subnet["public-${local.azs[0]}"].id
  vpc_security_group_ids      = [aws_security_group.std20_nat_sg.id]
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = templatefile("${path.module}/templates/nat-user-data.sh", {
    vpc_cidr = var.vpc_cidr
  })
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Bootstrap needs internet before installing iptables. The initial public IP
  # is replaced by the EIP; package installation retries handle that transition.
  depends_on = [
    aws_route.std20_pub_rt_internet_access,
    aws_route_table_association.std20_pub_rt_assoc
  ]

  tags = {
    Name = "${var.tag_header}nat-instance"
  }
}
