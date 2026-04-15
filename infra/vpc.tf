# vpc.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # Requerido por pauta [cite: 21]
  enable_dns_hostnames = true
  tags = { Name = "vpc-innovatech" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}

# El NAT Gateway es obligatorio según la pauta [cite: 27, 59]
# Requiere una IP elástica (EIP)
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id # Se pone en la pública para dar internet a la privada
  tags          = { Name = "main-nat" }
}