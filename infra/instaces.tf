# instances.tf

# 1. TEMPLATE DE LANZAMIENTO (HARDWARE BASE)
resource "aws_launch_template" "innovatech_tpl" {
  name_prefix   = "innovatech-tpl-"
  image_id      = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "spa-key" 

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "innovatech-base" }
  }
}

# 2. CAPA FRONTEND (PÚBLICA)
resource "aws_instance" "frontend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.public_front.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Reintentar actualización hasta que el gestor de paquetes esté libre
              until yum update -y; do sleep 5; done
              until yum install -y docker; do sleep 5; done
              
              systemctl start docker
              systemctl enable docker
              
              # Reintentar descarga y ejecución de Nginx (IE9)
              until docker run -d --name web-front -p 80:80 nginx; do
                sleep 10
              done
              EOF
  )

  tags = { Name = "EC2-Frontend" }
}

# 3. CAPA BACKEND (PRIVADA)
resource "aws_instance" "backend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              until ping -c 1 google.com; do sleep 5; done
              until yum update -y; do sleep 5; done
              until yum install -y docker git; do sleep 5; done
              
              systemctl start docker
              systemctl enable docker
              EOF
  )

  tags = { Name = "EC2-Backend" }
}

# 4. CAPA DATA (BASE DE DATOS PRIVADA)
resource "aws_instance" "database" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Esperar conexión a Internet vía NAT Gateway
              until ping -c 1 google.com; do sleep 5; done
              
              until yum update -y; do sleep 5; done
              until yum install -y docker; do sleep 5; done
              
              systemctl start docker
              systemctl enable docker
              
              # Reintentar despliegue de MySQL (IE6)
              until docker run -d --name innovatech-db -e MYSQL_ROOT_PASSWORD=Admin123! -p 3306:3306 mysql:8.0; do
                sleep 15
              done
              EOF
  )

  tags = { Name = "EC2-Database" }
}