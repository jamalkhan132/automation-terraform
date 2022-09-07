data "aws_availability_zones" "available" {
  state = "available"
}
output "zones" {
  value = data.aws_availability_zones.available.names
}

output "name" {
  value = aws_vpc.vpc.id
}

