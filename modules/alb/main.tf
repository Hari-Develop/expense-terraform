resource "aws_lb" "main" {
  name               = "${var.env}-${var.type}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.subnets

  tags = merge(var.tags, { Name = "${var.env}-${var.type}-alb" })
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.lb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}


resource "aws_security_group" "main" {
  name        = "${var.env}-${var.type}-alb-sg"
  description = "${var.env}-${var.type}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.env}-${var.type}-alb" })
}

resource "aws_route53_record" "main" {
  name    = "${var.component}-${var.env}"
  type    = "CNAME"
  zone_id = var.route53_id
  ttl = 30
  records = [aws_lb.main.dns_name]
}
