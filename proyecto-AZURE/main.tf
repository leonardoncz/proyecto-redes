terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

# 1️⃣ Grupo de recursos
resource "azurerm_resource_group" "main" {
  name     = "rg-proyecto-azure"
  location = "East US 2"
}

# 2️⃣ Red virtual
resource "azurerm_virtual_network" "main" {
  name                = "vnet-principal"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# 3️⃣ Subred pública
resource "azurerm_subnet" "publica" {
  name                 = "subnet-publica"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4️⃣ Subred privada
resource "azurerm_subnet" "privada" {
  name                 = "subnet-privada"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 5️⃣ NSG para la subred pública
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg-public"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# 6️⃣ Regla SSH para el NSG
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsg_public.name
}

# 7️⃣ Regla HTTP para el NSG
resource "azurerm_network_security_rule" "http" {
  name                        = "Allow-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsg_public.name
}

# 8️⃣ Asociar NSG a subred pública
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.publica.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

# 9️⃣ IP pública para la VM pública
resource "azurerm_public_ip" "vm" {
  name                = "ip-publica-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 🔟 Interfaz de red para VM pública
resource "azurerm_network_interface" "vm" {
  name                = "nic-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.publica.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# 1️⃣1️⃣ VM pública
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-webserver"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B1ls"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# 1️⃣2️⃣ Interfaz de red para VM privada
resource "azurerm_network_interface" "vm_privada" {
  name                = "nic-vm-privada"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig-privada"
    subnet_id                     = azurerm_subnet.privada.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 1️⃣3️⃣ VM privada
resource "azurerm_linux_virtual_machine" "vm_privada" {
  name                  = "vm-privada"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B1ls"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm_privada.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-vm-privada"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# ==========================================================
# 🛑 INICIO: RECURSOS PARA LA VPN S2S
# ==========================================================

# 1️⃣4️⃣ Subred OBLIGATORIA para el Gateway
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet" # El nombre DEBE ser este
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"] # Un nuevo rango
}

# 1️⃣5️⃣ IP Pública para el VPN Gateway
resource "azurerm_public_ip" "vpn_gateway" {
  name                = "pip-vpn-gateway"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 1️⃣6️⃣ El Virtual Network Gateway (¡El que gasta créditos!)
resource "azurerm_virtual_network_gateway" "main" {
  name                = "vng-azure-a-aws"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1" # El SKU base de pago

  ip_configuration {
    name                          = "vng-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

# 1️⃣7️⃣ El "Puntero" a AWS (Gateway de Red Local)
resource "azurerm_local_network_gateway" "aws" {
  name                = "lng-hacia-aws"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # !! MARCADOR DE POSICIÓN 1 !!
  # Aquí va la IP PÚBLICA del pilar de AWS (TUNEL 1)
  gateway_address = "34.238.209.136"

  # Las redes que queremos alcanzar en AWS (VPC-Hub y VPC-Prod)
  address_space = ["10.10.0.0/16", "10.11.0.0/16"]
}

# 1️⃣8️⃣ La Conexión S2S (El "apretón de manos")
resource "azurerm_virtual_network_gateway_connection" "azure_a_aws" {
  name                       = "conn-azure-aws"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  type                       = "IPsec"
  connection_protocol        = "IKEv2"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws.id

  # !! IMPORTANTE !!
  # Esta clave debe ser IDÉNTICA a la que pusiste en 'aws_vpn_connection'
  shared_key = "ProyectoRedes_2025_Secreto"
}

# 1️⃣9️⃣ Tabla de Rutas (Para enseñar a las VMs cómo llegar a AWS)
resource "azurerm_route_table" "to_aws" {
  name                = "rt-hacia-aws"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Ruta 1: Hacia la VPC-Hub de AWS
  route {
    name           = "ruta-aws-hub"
    address_prefix = "10.10.0.0/16" # VPC-Hub
    next_hop_type  = "VirtualNetworkGateway"
  }

  # Ruta 2: Hacia la VPC-Prod de AWS
  route {
    name           = "ruta-aws-prod"
    address_prefix = "10.11.0.0/16" # VPC-Prod
    next_hop_type  = "VirtualNetworkGateway"
  }
}

# 2️⃣0️⃣ Asociar la Tabla de Rutas a las subredes
resource "azurerm_subnet_route_table_association" "publica_rt" {
  subnet_id      = azurerm_subnet.publica.id
  route_table_id = azurerm_route_table.to_aws.id
}

resource "azurerm_subnet_route_table_association" "privada_rt" {
  subnet_id      = azurerm_subnet.privada.id
  route_table_id = azurerm_route_table.to_aws.id
}

# ==========================================================
# 🛑 FIN: RECURSOS VPN S2S
# ==========================================================
