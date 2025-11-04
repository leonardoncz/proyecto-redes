output "public_ip" {
  description = "IP pública de la máquina virtual"
  value       = azurerm_public_ip.vm.ip_address
}

output "vpn_gateway_public_ip" {
  description = "IP pública del VPN Gateway (para poner en AWS)"
  value       = azurerm_public_ip.vpn_gateway.ip_address
}
