
resource "aws_security_group" "alb" {
  name        = "allow_endusers"
  description = "Allow endusers inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "endusers from admin"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "prod-alb-sg"
    terraform="true"
  }
}