provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

locals {
    availability_zones = "${keys(var.availbility_zones_cidr_map)}"
    az_cidr_blocks = "${values(var.availbility_zones_cidr_map)}"
}

resource "aws_vpc" "ecs_cluster_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_route_table" "external" {
    vpc_id = "${aws_vpc.ecs_cluster_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.ecs_cluster_vpc.id}"
    }
}

resource "aws_route_table_association" "external_ecs_cluster_vpc" {
    count = "${
              length(local.availability_zones) > 0 ? length(local.availability_zones) : 0
            }"

    subnet_id = "${aws_subnet.main.*.id[count.index]}"
    route_table_id = "${aws_route_table.external.id}"
}


resource "aws_subnet" "main" {
    count = "${
              length(local.availability_zones) > 0 ? length(local.availability_zones) : 0
            }"
    vpc_id = "${aws_vpc.ecs_cluster_vpc.id}"
    cidr_block = "${local.az_cidr_blocks[count.index]}"
    availability_zone = "${local.availability_zones[count.index]}"
}

resource "aws_internet_gateway" "ecs_cluster_vpc" {
    vpc_id = "${aws_vpc.ecs_cluster_vpc.id}"
}

resource "aws_security_group" "load_balancers_security_group" {
    name = "load_balancers"
    description = "Allows all traffic"
    vpc_id = "${aws_vpc.ecs_cluster_vpc.id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs" {
    name = "ecs"
    description = "Allows all traffic"
    vpc_id = "${aws_vpc.ecs_cluster_vpc.id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${aws_security_group.load_balancers_security_group.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_ecs_cluster" "main" {
    name = "${var.ecs_cluster_name}"
}

resource "aws_autoscaling_group" "ecs-cluster" {
    name = "ECS ${var.ecs_cluster_name}"
    min_size = "${var.autoscale_min}"
    max_size = "${var.autoscale_max}"
    desired_capacity = "${var.autoscale_desired}"
    health_check_type = "EC2"
    launch_configuration = "${aws_launch_configuration.ecs.name}"
    vpc_zone_identifier = "${aws_subnet.main.*.id}"
}

resource "aws_launch_configuration" "ecs" {
    name = "ECS ${var.ecs_cluster_name}"
    image_id = "${lookup(var.amis, var.region)}"
    instance_type = "${var.instance_type}"
    security_groups = ["${aws_security_group.ecs.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
    associate_public_ip_address = true
    user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"
}


resource "aws_iam_role" "ecs_host_role" {
    name = "ecs_host_role"
    assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
    name = "ecs_instance_role_policy"
    policy = "${file("policies/ecs-instance-role-policy.json")}"
    role = "${aws_iam_role.ecs_host_role.id}"
}

resource "aws_iam_role" "ecs_service_role" {
    name = "ecs_service_role"
    assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name = "ecs_service_role_policy"
    policy = "${file("policies/ecs-service-role-policy.json")}"
    role = "${aws_iam_role.ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "ecs" {
    name = "ecs-instance-profile"
    path = "/"
    role = "${aws_iam_role.ecs_host_role.name}"
}
