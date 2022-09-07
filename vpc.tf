#create vpc
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
 
  tags = {
    Name      = "prod-vpc"
    terraform = "true"
  }
}

#create iternet_gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "prod_igw"
  }
  depends_on = [
    aws_vpc.vpc
]
}

#creating subnets

resource "aws_subnet" "public" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.pub_cidr,count.index)
map_public_ip_on_launch="true"
availability_zone= element(data.aws_availability_zones.available.names,count.index)
  tags = {
    Name = "prod-public-${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.private_cidr,count.index)
map_public_ip_on_launch="true"
availability_zone= element(data.aws_availability_zones.available.names,count.index)
  tags = {
    Name = "prod-private-${count.index+1}"
  }
}

resource "aws_subnet" "app" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.app_cidr,count.index)
map_public_ip_on_launch="true"
 availability_zone= element(data.aws_availability_zones.available.names,count.index)
  tags = {
    Name = "prod-app-${count.index+1}"
  }
}

#creating elastic ip

resource "aws_eip" "eip" {
  vpc      = true
}

# creating a nategateway

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "prod_ngw"
  }

  depends_on = [
                 aws_eip.eip
  ]
}

# creating a route table for public

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "prod-public-route"
  }
}

# creating a route table for private

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "prod-private-route"
  }
}

# creating a subnet associartion with public

resource "aws_route_table_association" "public" {
  count=length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

# # creating a subnet associartion with private

resource "aws_route_table_association" "private" {
  count=length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}


# # creating a subnet associartion with app

resource "aws_route_table_association" "app" {
  count=length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.app[*].id,count.index)
  route_table_id = aws_route_table.private.id
}

