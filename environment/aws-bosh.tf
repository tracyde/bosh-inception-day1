output "aws_key_path" {
	value = "${var.aws_key_path}"
}

resource "aws_iam_role" "director" {
    name = "director"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": { "Service": "ec2.amazonaws.com"},
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "director-policy" {
    name = "director-policy"
    description = "Policy for bosh director"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": [
      "ec2:AssociateAddress",
      "ec2:AttachVolume",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DescribeAddresses",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:RegisterImage",
      "ec2:DeregisterImage",
      "iam:PassRole"
    ],
    "Effect": "Allow",
    "Resource": "*"
  },{
    "Effect": "Allow",
    "Action": "elasticloadbalancing:*",
    "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "director-attach" {
    role = "${aws_iam_role.director.name}"
    policy_arn = "${aws_iam_policy.director-policy.arn}"
}

resource "aws_iam_instance_profile" "director_profile" {
    name = "director_profile"
    roles = ["${aws_iam_role.director.name}"]
}

resource "aws_instance" "bastion" {
  ami = "${lookup(var.aws_ubuntu_ami, var.aws_region)}"
  iam_instance_profile = "${aws_iam_instance_profile.director_profile.name}"
  instance_type = "m3.xlarge"
  key_name = "${var.aws_key_name}"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.bastion.id}"]
  subnet_id = "${aws_subnet.bastion.id}"

  tags {
   Name = "bastion"
  }

  connection {
    user = "ubuntu"
    key_file = "${var.aws_key_path}"
  }

  provisioner "file" {
    source = "${path.module}/provision.sh"
    destination = "/home/ubuntu/provision.sh"
  }

  provisioner "file" {
    source = "${var.aws_key_path}"
    destination = "/home/ubuntu/.ssh/${var.aws_key_name}.pem"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod 0400 /home/ubuntu/.ssh/${var.aws_key_name}.pem",
        "chmod +x /home/ubuntu/provision.sh",
        "/home/ubuntu/provision.sh ${var.aws_access_key} ${var.aws_secret_key} ${var.aws_region} ${aws_vpc.default.id} ${aws_subnet.microbosh.id} ${var.network} ${aws_instance.bastion.availability_zone} ${aws_instance.bastion.id} ${var.aws_key_name} ${aws_elb.concourse.dns_name}",
    ]
  }

}

output "bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
