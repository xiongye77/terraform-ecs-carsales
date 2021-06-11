resource "aws_security_group" "ecs" {
  name        = "ecs_security_group"
  description = "Allows inbound access from the ALB only"
  vpc_id      = aws_vpc.dfsc_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.dfsc_alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.dfsc_bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "ecs" {
  name                        = "${var.ecs_cluster_name}-cluster"
  image_id                    = "ami-0c42adb42b71cacfc"
  instance_type               = "t2.medium"
  security_groups             = [aws_security_group.ecs.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  key_name                    = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}-cluster' > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "ecs-cluster" {
  name                 = "${var.ecs_cluster_name}_auto_scaling_group"
  min_size             = 1
  max_size             = 4
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = [aws_subnet.dfsc-private-1a.id, aws_subnet.dfsc-private-1b.id]
}


data "template_file" "app" {
  template = file("app.json.tpl")
}

resource "aws_ecs_task_definition" "app" {
  family                = "nginx-app"
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-demo-task-role.arn
  container_definitions = data.template_file.app.rendered
  volume {
    name = aws_efs_file_system.efs_volume.creation_token
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs_volume.id
      root_directory = "/mnt/efs"
    }
  } 
}

data "template_file" "app-efs" {
  template = file("app-efs.json.tpl")
}

resource "aws_ecs_task_definition" "app-efs" {
  family                = "app-efs"
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-task-execution-role.arn
  container_definitions = data.template_file.app-efs.rendered
  volume {
    #name = "efs"
    name = aws_efs_file_system.efs_volume.creation_token
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs_volume.id
      root_directory = "/"
    }
  }
}

resource "aws_ecs_service" "efs-app"{
  name            = "${var.ecs_cluster_name}-efs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.app-efs.arn
  desired_count   = 2
}


resource "aws_ecs_service" "nginx-app"{
  name            = "${var.ecs_cluster_name}-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  iam_role        = aws_iam_role.ecs-service-role.arn
  desired_count   = 1
  
  load_balancer {
    target_group_arn = aws_lb_target_group.dfsc-back-end-tg.id
    container_name  = "nginx-app"
    container_port   = "80"
  }
}


