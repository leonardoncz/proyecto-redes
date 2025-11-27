#1. Gateway de AWS
#Se adjunta a nuestra VPC-Hub
resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.hub.id #Se conecta al Hub
  tags = {
    Name = "VGW-AWS-to-Azure"
  }
}

#2. Contacto con Azure (Customer Gateway)
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65001 
  
  #IP que genera el equipo de Azure
  ip_address = var.azure_vpn_public_ip 
  type       = "ipsec.1"
  
  tags = {
    Name = "CGW-to-Azure"
  }
  lifecycle {
    create_before_destroy = true
  }
}

#3. El Túnel VPN
resource "aws_vpn_connection" "to_azure" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  
  #Forzamos enrutamiento estático
  static_routes_only  = true 
  
  #Configuración del túnel donde se incluye la clave secreta
  tunnel1_preshared_key = var.vpn_shared_key
  tunnel2_preshared_key = var.vpn_shared_key
}

#4. Ruta Estática (Hacia Azure)
#Le decimos a AWS qué redes están al otro lado del túnel
resource "aws_vpn_connection_route" "route_to_azure" {
  #usamos el rango de red de Azure
  destination_cidr_block = var.azure_vnet_cidr
  vpn_connection_id      = aws_vpn_connection.to_azure.id
}

#5. ACTUALIZAR Tabla de Rutas del Hub
#Establecemos que para llegar a la red de Azure, se necesita enviar el tráfico al VGW
resource "aws_route" "route_hub_to_azure_gw" {
  #Tabla de rutas pública
  route_table_id            = aws_route_table.hub_public_rt.id
  destination_cidr_block    = var.azure_vnet_cidr # Red de Azure
  gateway_id                = aws_vpn_gateway.vgw.id
}
