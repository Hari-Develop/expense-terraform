## AWS security will start from here these security will define rules in the  launch templates
resource "aws_security_group" "main" {
  name        = "${var.env}-auto_scaling-${var.component}-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "app"
    from_port   = var.app_port
    to_port     = var.app_port
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

  tags = merge(var.tags, { Name = "${var.env}-auto_scaling-${var.component}-sg" } )
}
## AWS Security Group will end here and start on up from line two


## AWS lunch template will start here
resource "aws_launch_template" "main" {
  name_prefix            = "${var.env}-${var.component}"
  image_id               = data.aws_ami.image_name.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
}
## Launch template will end here


## AWS Auto Scaling Group will start from here
resource "aws_autoscaling_group" "main" {
  availability_zones  = ["us-east-1a"]
  desired_capacity    = var.instance_capacity
  max_size            = var.instance_type + 3
  min_size            = var.instance_capacity
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.env}-${var.component}"
  }
}
