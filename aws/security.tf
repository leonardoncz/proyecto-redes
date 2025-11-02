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
    cidr_blocks = ["179.6.17.185/32"]
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