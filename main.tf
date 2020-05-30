#----vpc----

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "test"
  }
}


#Test Subnet

resource "aws_subnet" "test-public" {
  vpc_id = aws_vpc.test-vpc.id
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "test public"
  }
}

resource "aws_subnet" "test-private" {
  vpc_id = aws_vpc.test-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "test private"
  }
}


# Test Internet Gateway

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test igw"
  }
}


# Test NAT Gateway
## Get Elastic IP

resource "aws_eip" "nat" {
  vpc    = false
}

##Create NAT Gateway

resource "aws_nat_gateway" "test-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.test-public.id

  tags = {
    Name = "test NAT"
  }
}


# Test Route tables

resource "aws_route_table" "test-public-rtb" {
  vpc_id = aws_vpc.test-vpc.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test-igw.id
        }
  tags = {
        Name = "public rtb test"
  }
}

resource "aws_default_route_table" "test-private-rtb" {
  default_route_table_id = aws_vpc.test-vpc.default_route_table_id
  tags = {
    Name = "private rtb test"
  }
}

# Subnet Associations

resource "aws_route_table_association" "public_assoc" {
  subnet_id = "${aws_subnet.test-public.id}"
  route_table_id = "${aws_route_table.test-public-rtb.id}"
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id = "${aws_subnet.test-private.id}"
  route_table_id = "${aws_route_table.test-private-rtb.id}"
}

#Security groups
#Public
resource "aws_security_group" "test-public-sg" {
  name = "sg_public"
  description = "test security group for public instance"
  vpc_id = "${aws_vpc.test-vpc.id}"

  #SSH
  ingress {
    from_port 	= 22
    to_port 	= 22
    protocol 	= "tcp"
    cidr_blocks = ["${var.localip}"]
  }

###DB
###Uncheck if you will be using a regular EC2 Instance for DB rather than RDS
#  ingress {
#    from_port 	= 3306
#    to_port 	= 3306
#    protocol 	= "tcp"
#    cidr_blocks = ["${var.localip}"]
#  }

  #HTTP
  ingress {
    from_port 	= 80
    to_port 	= 80
    protocol 	= "tcp"
    cidr_blocks	= ["0.0.0.0/0"]
  }

  #Outbound internet access
  egress {
    from_port	= 0
    to_port 	= 0
    protocol	= "-1"
    cidr_blocks	= ["0.0.0.0/0"]
  }
}

#Private
resource "aws_security_group" "test-private-sg" {
  name        = "sg_private"
  description = "Used for private instances"
  vpc_id      = "${aws_vpc.test-vpc.id}"

#Access from other security groups
  ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["10.1.0.0/16"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

# SQL access from public/private security group

ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.test-public-sg.id}", "${aws_security_group.test-private-sg.id}"]
  }
}

#COMPUTE
