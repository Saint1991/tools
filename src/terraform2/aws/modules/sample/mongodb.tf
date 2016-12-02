
resource "aws_instance" "db" {

  count = "${var.mongodb_count}"
  tags {
    Name = "${format("mizuno-db%03d", count.index + 1)}"
  }

  ami = "${var.amazon_linux_ami}"
  instance_type = "${var.micro_instance}"

  key_name = "${aws_key_pair.mizuno_key.key_name}"

  disable_api_termination = false
  instance_initiated_shutdown_behavior = "terminate"

  monitoring = true
}

resource "aws_ebs_volume" "db_volume" {

  count = "${var.mongodb_count}"
  tags {
    Name = "${format("mizuno-volume%03d", count.index + 1)}"
  }

  availability_zone = "${var.tokyo_region}a"
  size = 10
  type = "${var.volume_type}"
}

resource "aws_volume_attachment" "volume_attachment" {
  count = "${var.mongodb_count}"
  device_name = "/dev/sdh"
  instance_id = "${element(aws_instance.db.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.db_volume.*.id, count.index)}"
}


resource "null_resource" "db_inventory" {
  provisioner  "local-exec" {
    command = "echo \"\n[db]\n${join("\n", formatlist("%s ansible_ssh_user=ec2-user ansible_ssh_private_key_file=%s", aws_instance.db.*.public_ip, var.private_key))}\" >> $$PWD/../ansible/aws/inventory"
  }
}

