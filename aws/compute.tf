# Buscador de AMI: encuentra la última ID de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#VM, Instancia EC2 para el Servidor Web
resource "aws_instance" "web_server" {
  #Usa la ID que encontró el buscador de AMI
  ami           = data.aws_ami.amazon_linux_2.id
  
  #t2.micro que está en la capa gratuita
  instance_type = "t3.micro" 
  
  #Ponlo en nuestra subred pública
  subnet_id     = aws_subnet.hub_public.id
  
  #Asignará el firewall que fue creado
  vpc_security_group_ids = [aws_security_group.sg_web.id] 
  
  #Asigna una llave SSH para la conexión
  key_name      = "proyecto-redes-key" 
  
  tags = {
    Name = "WebServer-Hub"
  }
}

#VM de Prueba en Prod
resource "aws_instance" "test_vm_prod" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  #Deberá establecerse en la subred privada de Prod
  subnet_id     = aws_subnet.prod_private.id

  #Usa el nuevo firewall privado
  vpc_security_group_ids = [aws_security_group.sg_private.id]

  #Asigna la misma llave SSH para poder "saltar" a ella
  key_name      = "proyecto-redes-key"
  
  #Asegurarnos de que NO tenga IP pública
  associate_public_ip_address = false

  tags = {
    Name = "TestVM-Prod"
  }
}