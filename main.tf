module "vpc" {
  source                 = "./modules/vpc"
  vpc_cidr_block         = var.vpc_cidr_block
  tags                   = var.tags
  env                    = var.env
  public_subnet          = var.public_subnet
  web_subnet             = var.web_subnet
  app_subnet             = var.app_subnet
  db_subnet              = var.db_subnet
  availability_zone      = var.availability_zone
  account_id             = var.account_id
  default_vpc_id         = var.default_vpc_id
  default_route_table_id = var.default_route_table_id
  default_vpc_cidr       = var.default_vpc_cidr
}

module "backend" {
  source                   = "./modules/app"
  app_port                 = var.backend["app_port"]
  component                = "backend"
  env                      = var.env
  instance_capacity        = var.backend["instance_capacity"]
  instance_type            = var.backend["instance_type"]
  security_group_cidr      = var.web_subnet
  subnets                  = module.vpc.app_subnet
  tags                     = var.tags
  vpc_id                   = module.vpc.vpc_id
  bastion_workstation_cidr = var.bastion_workstation_cidr
}

module "frontend" {
  source                   = "./modules/app"
  app_port                 = var.frontend["app_port"]
  component                = "frontend"
  env                      = var.env
  instance_capacity        = var.frontend["instance_capacity"]
  instance_type            = var.frontend["instance_type"]
  security_group_cidr      = var.public_subnet
  subnets                  = module.vpc.web_subnet
  tags                     = var.tags
  vpc_id                   = module.vpc.vpc_id
  bastion_workstation_cidr = var.bastion_workstation_cidr
}

module "db" {
  source                = "./modules/db"
  engine                = var.engine
  engine_version        = var.engine_version
  env                   = var.env
  instance_class        = var.instance_class
  rds_allocated_storage = var.rds_allocated_storage
  subnets               = module.vpc.db_subnet
  tags                  = var.tags
  security_group_cidr   = var.app_subnet
  vpc_id                = module.vpc.vpc_id
}

module "pubilc_alb" {
  source   = "./modules/alb"
  internal = var.frontend_lb["internal"]
  env      = var.env
  subnets  = module.vpc.public_subnet
  lb_port  = var.frontend_lb["lb_port"]
  tags     = var.tags
  type     = var.frontend_lb["type"]
  vpc_id   = module.vpc.vpc_id
  sg_cidr  = ["0.0.0.0/0"]
  target_group_arn = module.frontend.target_group_arn
  component = var.frontend_lb["component"]
  route53_id = var.route53_id
}

module "backend_alb" {
  source   = "./modules/alb"
  internal = var.backend_lb["internal"]
  env      = var.env
  subnets  = module.vpc.app_subnet
  lb_port  = var.backend_lb["lb_port"]
  tags     = var.tags
  type     = var.backend_lb["type"]
  vpc_id   = module.vpc.vpc_id
  sg_cidr  = var.web_subnet
  target_group_arn = module.backend.target_group_arn
  component = var.backend_lb["component"]
  route53_id = var.route53_id
}

