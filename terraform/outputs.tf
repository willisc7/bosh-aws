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