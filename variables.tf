variable "region" {
     default = "ap-south-1"
}

variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}

variable "my_first_ecr_repo" {
    default = "my_first_ecr_repo"
}

#variable "docker_image_url_django" {
#  description = "Docker image to run in the ECS cluster"
#  default     = "<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/django-app:latest"
#}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  default = "demo"
}
