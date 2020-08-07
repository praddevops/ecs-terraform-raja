resource "aws_elb" "petstore3-lb" {
    name = "petstore3-lb"
    security_groups = ["${aws_security_group.load_balancers_security_group.id}"]
    subnets = "${aws_subnet.main.*.id}"

    listener {
        lb_protocol = "http"
        lb_port = 80

        instance_protocol = "http"
        instance_port = 8080
    }

    health_check {
        healthy_threshold = 3
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:8080/"
        interval = 5
    }

    cross_zone_load_balancing = true
}

resource "aws_ecs_task_definition" "petstore3" {
    family = "petstore3"
    container_definitions = "${file("task-definitions/petstore3.json")}"
}

resource "aws_ecs_service" "petstore3" {
    name = "petstore3"
    cluster = "${aws_ecs_cluster.main.id}"
    task_definition = "${aws_ecs_task_definition.petstore3.arn}"
    iam_role = "${aws_iam_role.ecs_service_role.arn}"
    desired_count = 2
    depends_on = [aws_iam_role_policy.ecs_service_role_policy]

    load_balancer {
        elb_name = "${aws_elb.petstore3-lb.id}"
        container_name = "petstore3"
        container_port = 8080
    }
}
