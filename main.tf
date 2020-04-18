#----vpc----

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "test" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "test"
  }
}


#Test Subnet

resource "aws_subnet" "test-public" {
  vpc_id = aws_vpc.test.id
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "test public"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.test.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "test private"
  }
}


# Test Internet Gateway

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test.id

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
  vpc_id = aws_vpc.test.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test-igw.id
        }
  tags = {
        Name = "public rtb test"
  }
}

resource "aws_default_route_table" "test-private-rtb" {
  default_route_table_id = aws_vpc.test.default_route_table_id
  tags = {
    Name = "private rtb test"
  }
}
