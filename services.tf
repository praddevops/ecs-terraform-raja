
resource "aws_elb" "node-app-lb" {
    name = "node-app-lb"
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

resource "aws_ecs_task_definition" "node-app" {
    family = "node-app"
    container_definitions = "${file("task-definitions/node-app.json")}"
}

resource "aws_ecs_service" "node-app" {
    name = "node-app"
    cluster = "${aws_ecs_cluster.main.id}"
    task_definition = "${aws_ecs_task_definition.node-app.arn}"
    iam_role = "${aws_iam_role.ecs_service_role.arn}"
    desired_count = 2
    depends_on = [aws_iam_role_policy.ecs_service_role_policy]

    load_balancer {
        elb_name = "${aws_elb.node-app-lb.id}"
        container_name = "node-app"
        container_port = 8080
    }
}
