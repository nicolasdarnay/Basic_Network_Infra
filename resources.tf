# NETWORK #
# vpc
resource "aws_vpc" "vpc_1" {
    cidr_block = var.VPC_cidr_block
    enable_dns_hostnames = "true"

    tags = {
      Name = "VPC-1-${local.common_tags.Project}"
    }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc_1.id

    tags = {
      Name = "igw-VPC-1-${local.common_tags.Project}"
    }  
}

# Public Subnet
resource "aws_subnet" "public_subnets" {
    count = var.subnets_quantity
    vpc_id = aws_vpc.vpc_1.id
    cidr_block = cidrsubnet(var.VPC_cidr_block,8,count.index+1)
    availability_zone = var.av_zones[count.index]
    map_public_ip_on_launch = "true"

    tags = {
        Name = "Public_subnet-${count.index}-VPC-1-${local.common_tags.Project}"
    }  
}
# Private Subnet
resource "aws_subnet" "private_subnets" {
    count = var.subnets_quantity
    vpc_id = aws_vpc.vpc_1.id
    cidr_block = var.subnet_private_cidr_block[count.index]
    availability_zone = var.av_zones[count.index]
    map_public_ip_on_launch = "false"

    tags = {
        Name = "Private_subnet-${count.index}-VPC-1-${local.common_tags.Project}"
    }  
}

# Route table
resource "aws_route_table" "rt_1" {
    vpc_id = aws_vpc.vpc_1.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }
}
# Route table association
resource "aws_route_table_association" "rt_subnet" {
  count = var.subnets_quantity
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.rt_1.id  
}

# Security group
resource "aws_security_group" "security_group_http" {
    name = "http_security_group"
    description = "Security group for HTTP and HTTPS"
    vpc_id = aws_vpc.vpc_1.id
    dynamic "ingress" {
      for_each = var.security
      content {
        from_port = ingress.value["port"]
        to_port = ingress.value["port"]
        protocol=ingress.value["protocol"]
        cidr_blocks=ingress.value["cidr_block"]
      }
    }

    egress {
      from_port = 0
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
      protocol = "-1"
    }

    tags = {
      Name = "HTTP-Security_group"
    }
}
