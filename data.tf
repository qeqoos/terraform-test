data "aws_caller_identity" "name" {}
data "aws_region" "name" {}

data "aws_availability_zones" "azs" {
  state = "available"
}

# data "aws_availability_zone" "az" {
#   state = "available"
# }

data "aws_ami" "latest_ver" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }
}