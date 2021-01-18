resource "aws_vpc" "slackbot" {
  cidr_block = "10.10.10.0/24"

  tags = {
    Name = "slackbot-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.slackbot.id

  tags = {
    Name = "slackbot-igw"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_vpc.slackbot.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "slackbot" {
  vpc_id     = aws_vpc.slackbot.id
  cidr_block = "10.10.10.0/24"

  tags = {
    Name = "slackbot-subnet"
  }
}

resource "aws_security_group" "slackbot" {
  name   = "slackbot-sg"
  vpc_id = aws_vpc.slackbot.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


/*
// if you want to keep your slackbot service in a private subnet uncomment below and remove the above block
// be aware of NAT gateway pricing though, not my fault if you run your AWS bill up!

resource "aws_vpc" "slackbot" {
  cidr_block = "10.10.10.0/24"

  tags = {
    Name = "slackbot-vpc"
  }
}


resource "aws_subnet" "slackbotpublic" {
  vpc_id     = aws_vpc.slackbot.id
  cidr_block = "10.10.10.0/25"

  tags = {
    Name = "slackbot-publicsubnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.slackbot.id

  tags = {
    Name = "slackbot-igw"
  }
}

resource "aws_eip" "publicip" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  connectivity_type = "public"
  allocation_id     = aws_eip.publicip.allocation_id
  subnet_id         = aws_subnet.slackbotpublic.id
}

resource "aws_route" "internet" {
  route_table_id         = aws_vpc.slackbot.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route_table" "publicsubnet" {
  vpc_id = aws_vpc.slackbot.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "slackbot-publicsubnet-rtb"
  }
}

resource "aws_route_table_association" "publicsubnet" {
  subnet_id      = aws_subnet.slackbotpublic.id
  route_table_id = aws_route_table.publicsubnet.id
}

resource "aws_subnet" "slackbotprivate" {
  vpc_id     = aws_vpc.slackbot.id
  cidr_block = "10.10.10.128/25"

  tags = {
    Name = "slackbot-privatesubnet"
  }
}

resource "aws_security_group" "slackbot" {
  name   = "slackbot-sg"
  vpc_id = aws_vpc.slackbot.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/