# subredes.tf

# Subred Pública (Frontend)
resource "aws_subnet" "public_front" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Importante para que el Front tenga IP pública
  availability_zone       = "us-east-1a"
  tags = { Name = "subnet-public-frontend" }
}

# Subred Privada (Backend y Data)
resource "aws_subnet" "private_app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "subnet-private-backend-data" }
}
# Tabla para la subred pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-route-table" }
}

# Asociación de la subred pública
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_front.id
  route_table_id = aws_route_table.public_rt.id
}

# Tabla para la subred privada (vía NAT Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-route-table" }
}

# Asociación de la subred privada
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_app.id
  route_table_id = aws_route_table.private_rt.id
}
