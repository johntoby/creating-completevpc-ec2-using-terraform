
#create a vpc 

resource "aws_vpc" "kc-vpc" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "kc-vpc"
  }
}

# creating public subnet
resource "aws_subnet" "publicSubnet" {
  vpc_id     = aws_vpc.kc-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "PublicSubnet"
    Env = "Public"
  }
}

# creating private subnet
resource "aws_subnet" "privateSubnet" {
  vpc_id     = aws_vpc.kc-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "privateSubnet"
    Env = "private"
  }
}

#creating an internet gateway 

resource "aws_internet_gateway" "kc-igw" {
  vpc_id = aws_vpc.kc-vpc.id 

  tags = {
    Name = "kc-igw"
  }
}


# creating public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.kc-vpc.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kc-igw.id 
  }

  tags = {
    Name = "public_route_table"
  }
}


# creating private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.kc-vpc.id 
  
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kc-nat-gateway.id 
  }

  tags = {
    Name = "private_route_table"
  }
}


# creating route table association for public_route_table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.publicSubnet.id
  route_table_id = aws_route_table.public_route_table.id
}


# creating route table association for public_route_table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.privateSubnet.id
  route_table_id = aws_route_table.private_route_table.id
}



#creating elastic ip
resource "aws_eip" "kc-eip" {
    domain   = "vpc"
}


#creating nat gateway
resource "aws_nat_gateway" "kc-nat-gateway" {
  allocation_id = aws_eip.kc-eip.id
  subnet_id     = aws_subnet.publicSubnet.id 
  connectivity_type = "public"

  tags = {
    Name = "kc-nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.example]
}



# creating public security group 
resource "aws_security_group" "publicSG" {
  name        = "allow traffic"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.kc-vpc.id 

  tags = {
    Name = "publicSG"
  }
}

#creating ingress rules
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.publicSG.id 
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.publicSG.id 
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.publicSG.id 
  cidr_ipv4         = "105.112.123.53/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


#creating egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.publicSG.id 
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



# creating private security group 
resource "aws_security_group" "privateSG" {
  name        = "allow private traffic"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.kc-vpc.id 

  tags = {
    Name = "publicSG"
  }
}

#creating ingress rules
resource "aws_vpc_security_group_ingress_rule" "allow_postgresql" {
  security_group_id = aws_security_group.privateSG.id 
  cidr_ipv4         = "10.0.1.0/24"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

#creating egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.privateSG.id 
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#creating network ACL for the public subnet
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.kc-vpc.id 
  
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 5
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 7
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "public_nacl"
  }
}

# attaching public_nacl to the public subnet
resource "aws_network_acl_association" "public" {
  network_acl_id = aws_network_acl.public_nacl.id 
  subnet_id      = aws_subnet.publicSubnet.id 
}



#creating network ACL for the private subnet
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.kc-vpc.id 
  
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 4
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }
  
 
  tags = {
    Name = "private_nacl"
  }
}

# attaching public_nacl to the public subnet
resource "aws_network_acl_association" "private" {
  network_acl_id = aws_network_acl.private_nacl.id 
  subnet_id      = aws_subnet.privateSubnet.id 
}


#creating public ec2 instance named "webserver"
resource "aws_instance" "webserver" {
  ami                = var.ami
  instance_type      = var.instance_type
  key_name           = var.key_name
  subnet_id          = aws_subnet.publicSubnet.id 
  vpc_security_group_ids = [aws_security_group.publicSG.id]
  availability_zone  = "eu-west-1a"
  user_data  = file("${path.module}/scripts/install_nginx.sh")
  associate_public_ip_address = true
  
  tags = {
    Name = "webserver"
  }
}

#creating a private ec2 instance named "dbserver"
resource "aws_instance" "dbserver" {
  ami                = var.ami
  instance_type      = var.instance_type
  key_name           = var.key_name
  subnet_id          = aws_subnet.privateSubnet.id 
  vpc_security_group_ids = [aws_security_group.privateSG.id]
  availability_zone  = "eu-west-1a"
  associate_public_ip_address = false
  user_data          = file("${path.module}/scripts/install_postgresql.sh")

  tags = {
    Name = "dbserver"
  }
}

resource "aws_key_pair" "kc-terraform-keypair" {
  key_name   = var.key_name
  public_key = var.public_key_path
}

