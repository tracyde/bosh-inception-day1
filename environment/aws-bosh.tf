provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

module "vpc" {
  source = "github.com/cloudfoundry-community/terraform-aws-vpc"
  network = "${var.network}"
  aws_key_name = "${var.aws_key_name}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.aws_region}"
  aws_key_path = "${var.aws_key_path}"
}

output "aws_vpc_id" {
  value = "${module.vpc.aws_vpc_id}"
}

output "aws_internet_gateway_id" {
  value = "${module.vpc.aws_internet_gateway_id}"
}

output "aws_route_table_public_id" {
  value = "${module.vpc.aws_route_table_public_id}"
}

output "aws_route_table_private_id" {
  value = "${module.vpc.aws_route_table_private_id}"
}

output "aws_subnet_microbosh_id" {
  value = "${module.vpc.aws_subnet_microbosh_id}"
}

output "aws_subnet_bastion" {
  value = "${module.vpc.bastion_subnet}"
}

output "aws_subnet_bastion_availability_zone" {
  value = "${module.vpc.aws_subnet_bastion_availability_zone}"
}

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
  security_groups = ["${module.vpc.aws_security_group_bastion_id}"]
  subnet_id = "${module.vpc.bastion_subnet}"

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
        "/home/ubuntu/provision.sh ${var.aws_access_key} ${var.aws_secret_key} ${var.aws_region} ${module.vpc.aws_vpc_id} ${module.vpc.aws_subnet_microbosh_id} ${var.network} ${aws_instance.bastion.availability_zone} ${aws_instance.bastion.id} ${var.aws_key_name} ${aws_elb.concourse.dns_name}",
    ]
  }

}

output "bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
