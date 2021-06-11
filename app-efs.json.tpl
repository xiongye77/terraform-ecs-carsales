[
  {
    "name": "efs-app",
    "image": "coderaiser/cloudcmd:latest-alpine",
    "essential": true,
    "cpu": 1,
    "memory": 256,
    "links": [],
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "secrets": [{"name": "db_url","valueFrom": "arn:aws:ssm:ap-south-1:207880003428:parameter/production/myapp/db-host"},
                     {"name": "DATABASE_PASSWORD", "valueFrom": "arn:aws:ssm:ap-south-1:207880003428:parameter/production/myapp/rds-password"
    }],
    "mountPoints": [{ "containerPath" : "/mnt/efs", "sourceVolume" : "aws_efs_file_system.efs_volume.creation_token", "readOnly" : false }],
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group":"true",
        "awslogs-group": "efs-app",
        "awslogs-region": "ap-south-1",
        "awslogs-stream-prefix": "efs-app-log-stream"
      }
    }
  }
]
