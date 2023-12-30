resource "aws_db_instance" "main" {
  allocated_storage      = var.rds_allocated_storage
  db_name                = "${var.env}-mysql-rds"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = data.aws_ssm_parameter.username.value
  password               = data.aws_ssm_parameter.password.value
  parameter_group_name   = aws_db_parameter_group.main.name
  skip_final_snapshot    = true
  multi_az               = true
  identifier             = "${var.env}-mysql-rds"
  tags                   = merge(var.tags, { Name = "${var.env}-mysql-rds" })
  db_subnet_group_name   = aws_db_subnet_group.main.name
  storage_type           = "gp3"
  vpc_security_group_ids = [aws_db_subnet_group.main.id]
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.env}-mysql-rds"
  family = var.family
}



resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-mysql-rds"
  subnet_ids = var.subnets

  tags = merge(var.tags, { Name = "${var.env}-mysql-rds" })
}



resource "aws_security_group" "main" {
  name        = "${var.env}-mysql-rds"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.security_group_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.env}-mysql-rds" })
}


