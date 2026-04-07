# instances.tf

resource "aws_launch_template" "innovatech_tpl" {
  name_prefix   = "innovatech-tpl-"
  image_id      = "ami-0c02fb55956c7d316" # Amazon Linux
  instance_type = "t2.micro"
  key_name      = "spa-key" 

  # Instalamos Docker y Git automáticamente con YUM (IE5)
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

# 1. CAPA FRONTEND
resource "aws_instance" "frontend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.public_front.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  
  # LÍNEA AGREGADA: Asocia el rol para permitir acceso por Session Manager
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = { Name = "EC2-Frontend" }
}

# 2. CAPA BACKEND
resource "aws_instance" "backend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  # LÍNEA AGREGADA: Asocia el rol para permitir acceso por Session Manager
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = { Name = "EC2-Backend" }
}

# 3. CAPA DATA (BASE DE DATOS)
resource "aws_instance" "database" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # LÍNEA AGREGADA: Asocia el rol para permitir acceso por Session Manager
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  # LÍNEA AGREGADA: Sobrescribimos el script para levantar MySQL y cumplir el requerimiento
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker run -d --name innovatech-db -e MYSQL_ROOT_PASSWORD=Admin123! -p 3306:3306 mysql:8.0
              EOF
  )

  tags = { Name = "EC2-Database" }
}