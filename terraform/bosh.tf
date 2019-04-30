resource "aws_security_group" "bosh" {
  vpc_id = "${aws_vpc.bosh.id}"
  name   = "bosh"

  ingress {
  }

  egress {
  }

  tags {
    Name = "bosh-${var.tag_name}"
  }
}