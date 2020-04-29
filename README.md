# ECS + Terraform

This repo contains a set of [Terraform](https://terraform.io/) modules for
provisioning an [AWS ECS](https://aws.amazon.com/ecs/) cluster and registering
services with it.

### Terraform version:
* Terraform v0.12.24 + provider.aws v2.59.0


### If you want to onboard a new application on ECS, add a `<app-name>-service.tf` with services which describe containers you want to run and the corresponding task definition in task-definitions/ 


### Note: Right now this provisions _everything_, including its own VPC and related networking accoutrements. It does not handle setting up a Docker Registry. It does not do anything about attaching other AWS services (e.g. RDS) to a container.

## Creating the cluster and service

* Install Terroform on the local machine and follow the steps below (you must pass AWS_ACCESS_KEY_ID and SECRET_ACCESS_KEY). It is recommended to run `terraform plan` before `terraform apply`
```
$ terraform init
$ terraform apply -var="aws_access_key=<AWS_ACCESS_KEY_ID>" -var="aws_secret_key=<SECRET_ACCESS_KEY>"
```

## Deploying

To deploy a container application to the ECS service update the image in the corresponding app's task definition located in task-definitions/

A CICD pipeline is setup in https://github.com/praddevops/Jenkins-docker-ecs to build and deploy the image
