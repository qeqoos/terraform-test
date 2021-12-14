resource "aws_vpc" "default_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.curr_env_tags, {
    "Name" = var.vpc_name
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = var.subnet_cidr_blocks["public1"]
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true
  tags = merge(local.curr_env_tags, {
    "Name" = "public1"
  })
}

# resource "aws_subnet" "private1" {
#   vpc_id = aws_vpc.default_vpc.id
#   cidr_block = var.subnet_cidr_blocks["private1"]
#   availability_zone = data.aws_availability_zones.azs.names[0]
#   tags = {
#     "Name" = "private1"
#   }
# }

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = var.subnet_cidr_blocks["public2"]
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true
  tags = merge(local.curr_env_tags,{
    "Name" = "public2"
  })
}

# resource "aws_subnet" "private2" {
#   vpc_id = aws_vpc.default_vpc.id
#   cidr_block = var.subnet_cidr_blocks["private2"]
#   availability_zone = data.aws_availability_zones.azs.names[1]
#   tags = {
#     "Name" = "private2"
#   }
# }

# resource "aws_eip" "nat1_eip" {
#   vpc = true
#   depends_on = [
#     aws_internet_gateway.igw
#   ]
# }

# resource "aws_eip" "nat2_eip" {
#   vpc = true
#   depends_on = [
#     aws_internet_gateway.igw
#   ]
# }

# resource "aws_nat_gateway" "nat1" {
#   allocation_id = aws_eip.nat1_eip.id
#   subnet_id = aws_subnet.public1.id
#   connectivity_type = "public"
#   tags = {
#     "Name" = "nat1"
#   }
# }

# resource "aws_nat_gateway" "nat2" {
#   allocation_id = aws_eip.nat2_eip.id
#   subnet_id = aws_subnet.public2.id
#   connectivity_type = "public"
#   tags = {
#     "Name" = "nat2"
#   }
# }

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.default_vpc.id

  depends_on = [
    aws_internet_gateway.igw
  ]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.curr_env_tags,{
    "Name" = "publicRT"
  })
}

resource "aws_route_table_association" "to-publicRT1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_route_table_association" "to-publicRT2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.publicRT.id
}

# resource "aws_route_table" "privateRT1" {
#   vpc_id = aws_vpc.default_vpc.id
#   depends_on = [
#     aws_nat_gateway.nat1
#   ]
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat1.id
#   }

#   tags = {
#     "Name" = "privateRT1"
#   }
# }

# resource "aws_route_table" "privateRT2" {
#   vpc_id = aws_vpc.default_vpc.id
#   depends_on = [
#     aws_nat_gateway.nat2
#   ]
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat2.id
#   }
#   tags = {
#     "Name" = "privateRT2"
#   }
# }


resource "aws_security_group" "web_asg" {
  name        = "web"
  description = "Dynamic SG"
  vpc_id      = aws_vpc.default_vpc.id
  dynamic "ingress" {
    for_each = concat(var.instance_ports_to_open, ["443"])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.curr_env_tags
}

