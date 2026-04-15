# instances.tf

resource "aws_launch_template" "innovatech_tpl" {
  name_prefix   = "innovatech-tpl-"
  image_id      = "ami-0c02fb55956c7d316" # Amazon Linux 2 (Correcta para el Lab)
  instance_type = "t2.micro"
  key_name      = "spa-key" 

  # Automatización Global (IE5): Instalación de Docker y Git
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker git
              systemctl start docker
              systemctl enable docker
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "innovatech-base" }
  }
}

# 1. CAPA FRONTEND (Pública)
resource "aws_instance" "frontend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.public_front.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  iam_instance_profile   = "LabInstanceProfile" # Acceso SSM (IE10)

  # Automatización específica del Front (IE5): Servidor Web automático
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              # Levantar Nginx automáticamente para la Demo Funcional (IE9)
              docker run -d --name web-front -p 80:80 nginx
              EOF
  )

  tags = { Name = "EC2-Frontend" }
}

# 2. CAPA BACKEND (Privada)
resource "aws_instance" "backend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  tags = { Name = "EC2-Backend" }
}

# 3. CAPA DATA (Base de Datos Privada)
resource "aws_instance" "database" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  # Automatización de Motor de BD MySQL (IE6, IE9)
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              # Levantar MySQL automáticamente
              docker run -d --name innovatech-db -e MYSQL_ROOT_PASSWORD=Admin123! -p 3306:3306 mysql:8.0
              EOF
  )

  tags = { Name = "EC2-Database" }
}