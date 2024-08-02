output "vpc_id" {
  value = aws_vpc.kc-vpc
}

output "public_subnet_id" {
  value = aws_subnet.publicSubnet.id 
}

output "private_subnet_id" {
  value = aws_subnet.privateSubnet.id 
}

output "webserver_id" {
  value = aws_instance.webserver.id 
}

output "dbserver_id" {
  value = aws_instance.dbserver.id 
}

