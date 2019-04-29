output "public_subnet_id" {
    value = "${aws_subnet.public.id}"
}

output "public_subnet_az" {
    value = "${aws_subnet.public.availability_zone}"
}

output "public_subnet_region" {
    value = "${var.aws_region}"
}

output "jumpbox_eip" {
    value = "${aws_instance.jumpbox.public_ip}"
}

output "tag_name" {
    value = "${var.tag_name}"
}

output "bosh_vpc_cidr" {
    value = "${aws_vpc.bosh.cidr_block}"
}

output "bosh_vpc_gw" {
    value = "${var.bosh_vpc_gw}"
}

output "bosh_internal_ip" {
    value = "${var.bosh_internal_ip}"
}

output "aws_region" {
    value = "${var.aws_region}"
}