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
  component                = "backend"
  env                      = var.env
  instance_capacity        = var.frontend["instance_capacity"]
  instance_type            = var.frontend["instance_type"]
  security_group_cidr      = var.web_subnet
  subnets                  = module.vpc.public_subnet
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

