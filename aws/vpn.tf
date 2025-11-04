# 1. Nuestro "Pilar" del Puente (El Gateway de AWS)
# Se adjunta a nuestra VPC-Hub
resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.hub.id # Se conecta al Hub
  tags = {
    Name = "VGW-AWS-to-Azure"
  }
}

# 2. La "Tarjeta de Contacto" de Azure (Customer Gateway)
resource "aws_customer_gateway" "cgw" {
  # (Requerido, aunque no usemos BGP)
  bgp_asn    = 65001 
  
  # ¡Aquí usamos la IP que nos dio el Team Azure!
  ip_address = var.azure_vpn_public_ip 
  type       = "ipsec.1"
  
  tags = {
    Name = "CGW-to-Azure"
  }
}

# 3. El "Túnel" VPN
resource "aws_vpn_connection" "to_azure" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  
  # ¡IMPORTANTE! Forzamos el enrutamiento estático
  static_routes_only  = true 
  
  # Configuración del túnel (incluye la clave secreta)
  tunnel1_preshared_key = var.vpn_shared_key
  tunnel2_preshared_key = var.vpn_shared_key
}

# 4. Ruta Estática (Hacia Azure)
# Le decimos a AWS qué redes están "al otro lado" del túnel
resource "aws_vpn_connection_route" "route_to_azure" {
  # ¡Aquí usamos el rango de red de Azure!
  destination_cidr_block = var.azure_vnet_cidr
  vpn_connection_id      = aws_vpn_connection.to_azure.id
}

# 5. ACTUALIZAR la Tabla de Rutas del Hub
# Le decimos a nuestra VPC-Hub:
# "Para llegar a la red de Azure, envía el tráfico al pilar (VGW)"
resource "aws_route" "route_hub_to_azure_gw" {
  # Asegúrate de que este es el nombre de tu tabla de rutas pública
  route_table_id            = aws_route_table.hub_public_rt.id
  destination_cidr_block    = var.azure_vnet_cidr # Red de Azure
  gateway_id                = aws_vpn_gateway.vgw.id
}