locals {
  tag_header = "${var.default_name}-"
  web_user_data = file("${path.module}/templates/ec2-user-data.sh")
}
