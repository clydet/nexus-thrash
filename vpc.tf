resource "aws_vpc" "nexus_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags {
    Name = "nexus"
  }
}

resource "aws_subnet" "public_for_the_time_being" {
  vpc_id                  = "${aws_vpc.nexus_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags {
    Name = "nexus_public_for_now"
  }
}

resource "aws_internet_gateway" "nexus_gw" {
  vpc_id = "${aws_vpc.nexus_vpc.id}"

  tags {
    Name = "nexus"
  }
}

resource "aws_route_table" "nexus_public" {
  vpc_id = "${aws_vpc.nexus_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.nexus_gw.id}"
  }

  tags {
    Name = "nexus public"
  }
}

resource "aws_route_table_association" "nexus_public" {
  subnet_id      = "${aws_subnet.public_for_the_time_being.id}"
  route_table_id = "${aws_route_table.nexus_public.id}"
}
