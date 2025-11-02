# Buscador de AMI: encuentra la última ID de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VM (Instancia EC2) para el Servidor Web
resource "aws_instance" "web_server" {
  # Usa la ID que encontró el buscador de AMI
  ami           = data.aws_ami.amazon_linux_2.id
  
  # t2.micro está en la capa gratuita
  instance_type = "t3.micro" 
  
  # Ponlo en nuestra subred pública
  subnet_id     = aws_subnet.hub_public.id
  
  # Asigna el firewall que acabamos de crear
  vpc_security_group_ids = [aws_security_group.sg_web.id] 
  
  # Asigna una llave SSH para conectarte
  key_name      = "proyecto-redes-key" 

  tags = {
    Name = "WebServer-Hub"
  }
}

# (Opcional) Muestra la IP pública de la VM al final
output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}