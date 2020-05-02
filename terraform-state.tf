terraform {
    backend "local" {
      path = "/etc/terraform/ecs-terraform.tfstate"
    }
}