resource "aws_vpc" "bosh" {
  cidr_block = "${var.bosh_vpc_cidr}"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"

  tags = {
    Name = "${var.tag_name}"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.bosh.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.bosh_availability_zone}"

  tags = {
    Name = "${var.tag_name}"
  }
}