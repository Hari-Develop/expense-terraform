vpc_cidr_block = "10.0.0.0/16"

env = "dev"

tags = {
  company = "hari.co"
  bu-unit = "ecommerce"
  project = "ecommerce"
}

public_subnet = ["10.0.1.0/24" , "10.0.2.0/24"]
web_subnet = ["10.0.3.0/24" , "10.0.4.0/24"]
app_subnet = ["10.0.5.0/24" , "10.0.6.0/24"]
db_subnet = ["10.0.7.0/24" , "10.0.8.0/24"]
