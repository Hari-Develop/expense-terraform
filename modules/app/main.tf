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
## AWS Security Group will end here and start on up from line two

## AWS lunch template will start here
resource "aws_launch_template" "main" {
  name                   = "${var.env}-${var.component}"
  image_id               = data.aws_ami.image_name.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data              = base64encode(templatefile("${path.module}/user_data.sh", {
    role_name = var.component
    env       = var.env
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }
}
## Launch template will end here


## AWS Auto Scaling Group will start from here
resource "aws_autoscaling_group" "main" {
  desired_capacity    = var.instance_capacity
  max_size            = var.instance_capacity + 3
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
