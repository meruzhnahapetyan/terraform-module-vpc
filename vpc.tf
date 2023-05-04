resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name        = "${data.aws_caller_identity.current.account_id}-${local.env}-lab-vpc"
    Environment = "${local.env}"
  }
}

data "aws_caller_identity" "current" {
}

resource "aws_subnet" "public_subnet" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "igw-vpc"
  }
}

resource "aws_route_table" "public_route_table" {
  count  = var.subnet_count
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table-${count.index + 1}"
  }
}


resource "aws_route_table_association" "public_route_association" {
  count = var.subnet_count

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}


resource "aws_subnet" "private_subnet" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}



resource "aws_eip" "nat_eip" {
  count = var.subnet_count
  vpc   = true
}


resource "aws_nat_gateway" "nat_gateway" {
  count         = var.subnet_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}


resource "aws_route_table" "private_route_table" {
  count  = var.subnet_count
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "private-route-table-${count.index + 1}"
  }
}



resource "aws_route_table_association" "private_route_association" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

