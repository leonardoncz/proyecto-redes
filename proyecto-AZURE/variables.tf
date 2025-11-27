variable "location" {
  default = "eastus2"
}

variable "aws_vpn_ip_address" {
  description = "La IP pública del VPN Gateway de AWS la cual será inyectada por el pipeline"
  type        = string
}

variable "vpn_shared_key" {
  description = "Clave secreta para la conexión VPN S2S con AWS."
  type        = string
  sensitive   = true 
}