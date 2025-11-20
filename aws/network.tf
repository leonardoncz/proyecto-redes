# La VPC principal que recibirá la VPN y los servicios web

resource "aws_vpc" "hub" {
  cidr_block           = "10.10.0.0/16" # Red 10.10.x.x
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-Hub"
  }
}

# La VPC privada para bases de datos (para el requisito de Peering)

resource "aws_vpc" "prod" {
  cidr_block           = "10.11.0.0/16" # Red 10.11.x.x
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-Prod"
  }
}

# --- Subredes para la VPC-Hub ---
resource "aws_subnet" "hub_public" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true # Importante ya que da IPs públicas a las VMs
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Subnet-Hub-Public"
  }
}

# --- Subredes para la VPC-Prod ---
resource "aws_subnet" "prod_private" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.11.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet-Prod-Private"
  }
}

# --- Internet Gateway (Solo para el Hub) ---
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.hub.id
  tags = {
    Name = "IGW-Hub"
  }
}

# --- Tabla de Rutas (Para hacer PÚBLICA la subred del Hub) ---
resource "aws_route_table" "hub_public_rt" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "RT-Hub-Public"
  }
}

resource "aws_route" "hub_internet_access" {
  route_table_id         = aws_route_table.hub_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# --- Asociación (Conecta la tabla de rutas a la subred pública) ---
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.hub_public.id
  route_table_id = aws_route_table.hub_public_rt.id
}

# --- Conexión de Peering (Conecta Hub <-> Prod) ---
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id   = aws_vpc.prod.id
  vpc_id        = aws_vpc.hub.id
  auto_accept   = true # Acepta automáticamente la conexión

  tags = {
    Name = "Peering-Hub-Prod"
  }
}

# --- Rutas para el Peering ---
# 1. Enseña al Hub cómo llegar a Prod
resource "aws_route" "hub_to_prod" {
  route_table_id            = aws_route_table.hub_public_rt.id
  destination_cidr_block    = aws_vpc.prod.cidr_block # (10.11.0.0/16)
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

# 2. Enseña a Prod cómo llegar al Hub
# (Necesitamos una tabla de rutas para Prod primero)
resource "aws_route_table" "prod_private_rt" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "RT-Prod-Private"
  }
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.prod_private.id
  route_table_id = aws_route_table.prod_private_rt.id
}
resource "aws_route" "prod_to_hub" {
  route_table_id            = aws_route_table.prod_private_rt.id
  destination_cidr_block    = aws_vpc.hub.cidr_block # (10.10.0.0/16)
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}