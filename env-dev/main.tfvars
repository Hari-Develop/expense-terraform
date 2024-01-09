vpc_cidr_block = "10.0.0.0/16"

env = "dev"

tags = {
  company = "hari.co"
  bu-unit = "ecommerce"
  project = "ecommerce"
}

public_subnet = ["10.0.1.0/24", "10.0.2.0/24"]
web_subnet    = ["10.0.3.0/24", "10.0.4.0/24"]
app_subnet    = ["10.0.5.0/24", "10.0.6.0/24"]
db_subnet     = ["10.0.7.0/24", "10.0.8.0/24"]

availability_zone = ["us-east-1a", "us-east-1b"]

account_id             = "513840145359"
default_vpc_id         = "vpc-02f26d6a8715fbc70"
default_route_table_id = "rtb-01066c9b87d4f7f51"

default_vpc_cidr = "172.31.0.0/16"

backend = {
  app_port          = 8080
  instance_capacity = 1
  instance_type     = "t2.micro"
}

frontend = {
  app_port          = 80
  instance_capacity = 1
  instance_type     = "t2.micro"
}



bastion_workstation_cidr = ["172.31.42.115/32"]

engine_version = "5.7.44"
instance_class = "db.t3.micro"
rds_allocated_storage = 20
engine = "mysql"

frontend_lb = {
  internal = false
  lb_port = 80
  type =  "private"
}

backend_lb = {
  internal = true
  lb_port = 80
  type =  "private"
}

