output "ecs_service_role_arn" {
  value = "${aws_iam_role.ecs_service_role.arn}"
}



output "aws_ecs_cluster_id" {
  value = "${aws_ecs_cluster.main.id}"
}

output "ecs_cluster_subnet_list" {
  value = "${aws_subnet.main.*.id}"
}

output "load_balancers_security_grp_id" {
  value = "${aws_security_group.load_balancers_security_group.id}"
}
