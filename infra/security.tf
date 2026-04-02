# security.tf

resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Permitir HTTP y SSH al Frontend"
  vpc_id      = aws_vpc.main.id

  # Acceso Web (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Acceso SSH (Administración)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # En producción esto sería tu IP específica
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Permitir trafico solo desde el Backend"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306 # Puerto para MySQL
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}