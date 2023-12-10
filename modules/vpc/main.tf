resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = merge(var.tags, {Name = var.env})
}

## subnet's creation

resource "aws_subnet" "public" {
  count = length(var.public_subnet)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = merge(var.tags, {Name = "public_subnet-${count.index}"})
}

resource "aws_subnet" "web" {
  count = length(var.web_subnet)
  vpc_id = aws_vpc.main.id
  cidr_block = var.web_subnet[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = merge(var.tags, {Name = "web_subnet-${count.index}"})
}

resource "aws_subnet" "app" {
  count = length(var.app_subnet)
  vpc_id = aws_vpc.main.id
  cidr_block = var.app_subnet[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = merge(var.tags, {Name = "app_subnet-${count.index}"})
}

resource "aws_subnet" "db" {
  count = length(var.db_subnet)
  vpc_id = aws_vpc.main.id
  cidr_block = var.db_subnet[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = merge(var.tags, {Name = "db_subnet-${count.index}"})
}



# route table creation..

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "public"})
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "web"})
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "app"})
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "db"})
}



## route table assocation

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web" {
  count          = length(aws_subnet.web)
  subnet_id      = aws_subnet.web.*.id[count.index]
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db)
  subnet_id      = aws_subnet.db.*.id[count.index]
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "app" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app.*.id[count.index]
  route_table_id = aws_route_table.app.id
}