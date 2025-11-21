# Firewall para el Servidor Web (en el Hub)
resource "aws_security_group" "sg_web" {
  name        = "web-public-sg"
  description = "Permite SSH y HTTP"
  vpc_id      = aws_vpc.hub.id # Se conecta a la VPC 'hub'

  # Regla 1: Permitir SSH (Puerto 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #permitimos cualquier ip, práctica no recomendada pero por cuestiones académicas será así
  }

  # Regla 2: Permitir HTTP (Puerto 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Abierto al mundo para la web
  }
  
  # Regla 3: Permitir ICMP (Ping)
  # Para que el otro equipo (Azure/GCP) pueda probarnos
  ingress {
    from_port   = -1 # -1 significa "todos los tipos" de ICMP
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # Abierto al mundo
  }

  # Regla de Salida: Permitir todo
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 significa "todo el tráfico"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-WebServer"
  }
}


# ------------------------------------------------
# Firewall para la VM de Prueba (en Prod)
# ------------------------------------------------
resource "aws_security_group" "sg_private" {
  name        = "private-vm-sg"
  description = "Permite Ping y SSH solo desde la VPC-Hub"
  vpc_id      = aws_vpc.prod.id # ¡Importante! Vive en la VPC-Prod

  # Regla 1: Permitir Ping (ICMP)
  # Solo desde el rango de IP de la VPC-Hub (10.10.0.0/16)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.hub.cidr_block] # "10.10.0.0/16"
  }

  # Regla 2: Permitir SSH (Puerto 22)
  # Solo desde la VPC-Hub. 
  # (No podemos entrar desde internet, tenemos que "saltar" desde la VM del Hub)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.hub.cidr_block] # "10.10.0.0/16"
  }

  # Regla de Salida: Permitir todo
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Private-Test-VM"
  }
}