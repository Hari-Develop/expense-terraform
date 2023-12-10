module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  tags = merge(var.tags , {Name = var.env})
  env = var.env
}