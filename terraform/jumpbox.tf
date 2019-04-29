resource "aws_internet_gateway" "public_igw" {
  vpc_id = "${aws_vpc.bosh.id}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.bosh.id}"

  tags = {
    Name = "public-route-table-${var.tag_name}"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route" "public_to_internet_route" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.public_igw.id}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }
}

resource "aws_security_group" "jumpbox_sg" {
  vpc_id = "${aws_vpc.bosh.id}"
  name   = "jumpbox-sg-${var.tag_name}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "jumpbox_key" {
  key_name   = "jumpbox_key"
  public_key = "${file("~/.ssh/jumpbox_key.pub")}"
}

resource "aws_instance" "jumpbox" {
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.jumpbox_sg.id}"]
  subnet_id              = "${aws_subnet.public.id}"
  key_name               = "${aws_key_pair.jumpbox_key.key_name}"

  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
yum install -y jq git
pip install yq
wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip -O terraform.zip
unzip terraform.zip
mv terraform /usr/local/bin/terraform
rm -f terraform.zip
EOF

  root_block_device {
    volume_size = 100
  }

  tags {
    Name = "jumpbox-${var.tag_name}"
  }
}