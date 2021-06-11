[
  {
    "name": "nginx-app",
    "image": "nginx",
    "essential": true,
    "cpu": 1,
    "memory": 256,
    "links": [],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "secrets": [{"name": "db_url","valueFrom": "arn:aws:ssm:ap-south-1:207880003428:parameter/production/myapp/db-host"},
                     {"name": "DATABASE_PASSWORD", "valueFrom": "arn:aws:ssm:ap-south-1:207880003428:parameter/production/myapp/rds-password"
    }],
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group":"true",
        "awslogs-group": "nginx-app",
        "awslogs-region": "ap-south-1",
        "awslogs-stream-prefix": "nginx-app-log-stream"
      }
    }
  }
]
