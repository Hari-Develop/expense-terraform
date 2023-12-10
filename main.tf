module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  tags = var.tags
  env = var.env
  public_subnet = var.public_subnet
  web_subnet = var.web_subnet
  app_subnet = var.app_subnet
  db_subnet = var.db_subnet
  availability_zone = var.availability_zone
  account_id = var.account_id
  default_vpc_id = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_route_table_id = var.default_route_table_id
}