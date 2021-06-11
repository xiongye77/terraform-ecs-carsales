# CREATE RDS SECURITY GROUP

resource "aws_security_group" "dfsc_db_sg" {
  name = "DFSC RDS Security Group"
  vpc_id = aws_vpc.dfsc_vpc.id
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ecs-demo.id
    ]
  }
  tags = {
    Name        = "RDS Security Group"
    Terraform   = "true"
  }
}

# Create DFSC Database Subnet Group

resource "aws_db_subnet_group" "dfsc-db-subnet" {
  name = "dfsc-database-subnet-group"
  subnet_ids = [
    aws_subnet.dfsc-private-1a.id,
    aws_subnet.dfsc-private-1b.id
    ]

  tags = {
    Name        = "DB Subnet Group"
    Terraform   = "true"
  }
}

# Create DFSC Database Instance 

resource "aws_db_instance" "dfsc-db" {
  allocated_storage       = "10"
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "11.5"
  multi_az                = "true"
  instance_class          = "db.t2.micro"
  name                    = "magento"
  # Set the secrets from AWS Secrets Manager
  username = local.db_creds.username
  password = "${random_string.password.result}"  
  identifier              = "dfsc-database"
  skip_final_snapshot     = "true"
  backup_retention_period = "7"
  port                    = "3306"
  storage_encrypted       = "false"
  db_subnet_group_name    = aws_db_subnet_group.dfsc-db-subnet.name
  vpc_security_group_ids  = [aws_security_group.dfsc_db_sg.id]
   tags = {
    Name        = "DFSC Database"
    Terraform   = "true"
  }
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "rdspassword" {
  name = "/production/myapp/rds-password"
  type        = "SecureString"
  value = "${random_string.password.result}"
}
data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = "postgresdb-app1"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}
resource "aws_ssm_parameter" "db_host" {
  name  = "/production/myapp/db-host"
  type  = "String"
  value = aws_db_instance.dfsc-db.endpoint
}
