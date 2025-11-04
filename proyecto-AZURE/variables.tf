variable "location" {
  default = "eastus2"
}

variable "vpn_shared_key" {
  description = "La clave secreta para la conexión VPN S2S con AWS."
  type        = string
  # Esto evita que el valor se imprima en la salida de 'terraform apply'
  sensitive   = true 
  # ¡IMPORTANTE! NO poner un valor 'default' aquí.
}