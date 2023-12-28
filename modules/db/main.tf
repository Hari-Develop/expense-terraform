resource "aws_db_instance" "main" {
  allocated_storage    = var.rds_allocated_storage
  db_name              = "${var.env}-${var.component}-RDS"
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = aws_db_parameter_group.main.name
  skip_final_snapshot  = true
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.env}-${var.component}-pg"
  family = var.engine_version
}


