variable "azure_vpn_public_ip" {
  description = "La IP pública del VPN Gateway de Azure (placeholder)"
  type        = string
  # IP de Azure 
  default     = "172.172.43.2" 
}

variable "azure_vnet_cidr" {
  description = "El rango de red de la VNet de Azure"
  type        = string
  default     = "10.0.0.0/16" 
}

variable "vpn_shared_key" {
  description = "La clave secreta acordada por ambos AWS y AZURE"
  type        = string
  sensitive   = true
}