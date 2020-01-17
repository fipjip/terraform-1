provider "aws" {
  region = "ap-southeast-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc = data.aws_vpc.default.id
}

resource "aws_launch_configuration" "example" {
  ami             = "ami-0c91f97cadcc8499e"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!bin/bash
              echo "Hello World" > /var/www/index.html
              nohup busybox httpd -f -p var.server_port &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terraform_asg" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 4

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true


}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
