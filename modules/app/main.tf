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

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_workstation_cidr
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

## AWS lunch template ...
resource "aws_launch_template" "main" {
  name                   = "${var.env}-${var.component}"
  image_id               = data.aws_ami.image_name.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
      encrypted = true
      kms_key_id = var.kms_key_id
      delete_on_termination = true
    }
  }


  user_data              = base64encode(templatefile("${path.module}/user_data.sh", {
    role_name = var.component
    env       = var.env
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }
}


## AWS TARGET GROUP FOR LOAD BALANCER ...

resource "aws_lb_target_group" "main" {
  name     = "${var.env}-${var.component}"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    matcher = 200
    path = "/health"
    timeout = 2
  }
}




## AWS Auto Scaling Group ...
resource "aws_autoscaling_group" "main" {
  desired_capacity    = var.instance_capacity
  max_size            = var.instance_capacity + 3
  min_size            = var.instance_capacity
  vpc_zone_identifier = var.subnets
  target_group_arns   = [aws_lb_target_group.main.arn]

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


## AWS IAM ROLE CREATION
resource "aws_iam_role" "main" {
  name = "${var.env}-${var.component}"
  tags = merge(var.tags, { Name = "${var.env}-iAMrole-${var.component}" } )

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "ssm_read_access"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "ReadAccessParameter",
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameterHistory",
            "ssm:DescribeDocumentParameters",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource" : ["arn:aws:ssm:us-east-1:513840145359:parameter/${var.env}.${var.component}.*",
                        "arn:aws:ssm:us-east-1:513840145359:parameter/mysql",
                        "arn:aws:ssm:us-east-1:513840145359:parameter/mysqlpassword",
                        "arn:aws:ssm:us-east-1:513840145359:parameter/dev.rds.password",
                        "arn:aws:ssm:us-east-1:513840145359:parameter/dev.rds.username",
                        "arn:aws:ssm:us-east-1:513840145359:parameter/dev.mysql.endpoint"
          ]
        },
        {
          "Sid" : "ReadDesParameter",
          "Effect" : "Allow",
          "Action" : "ssm:DescribeParameters",
          "Resource" : "*"
        }
      ]
    })
  }

}

## instance profile
resource "aws_iam_instance_profile" "main" {
  name = "${var.env}-${var.component}"
  role = aws_iam_role.main.name
}
