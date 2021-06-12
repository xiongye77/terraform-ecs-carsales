data "aws_ami" "ecs" {
  most_recent = true # get the latest version
  filter {
    name = "name"
    values = [
      "amzn2-ami-ecs-*"] # ECS optimized image
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }
  owners = [
    "amazon" # Only official images
  ]
}

data "aws_ami" "bastion_host" {
  # pick the most recent version of the AMI
  most_recent = true

  # Find the 20.04 image
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  # With the right virtualization type
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

