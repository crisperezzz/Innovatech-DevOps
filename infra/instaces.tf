# instances.tf

resource "aws_launch_template" "innovatech_tpl" {
  name_prefix   = "innovatech-tpl-"
  image_id      = "ami-0c02fb55956c7d316" # Ubuntu 22.04 (o la que use tu profe)
  instance_type = "t2.micro"
  key_name      = "spa-key" # La llave que ya tienes

  # Aquí instalamos Docker y Git automáticamente (IE5)
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io git
              systemctl start docker
              systemctl enable docker
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "innovatech-base" }
  }
}
resource "aws_instance" "frontend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.public_front.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  tags = { Name = "EC2-Frontend" }
}
resource "aws_instance" "backend" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = { Name = "EC2-Backend" }
}
resource "aws_instance" "database" {
  launch_template {
    id      = aws_launch_template.innovatech_tpl.id
    version = "$Latest"
  }
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = { Name = "EC2-Database" }
}
