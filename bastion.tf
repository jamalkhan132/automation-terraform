

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "bastion" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "prod-bastion-sg"
    terraform="true"
  }
}

resource "aws_instance" "bastion" {
  ami  = "ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  subnet_id=aws_subnet.public[0].id
 vpc_security_group_ids = [aws_security_group.bastion.id]
 
  tags = {
    Name = "prod-bastion-ec2"
  }
}