output "db_private_ip" {
  value       = azurerm_linux_virtual_machine.vm_privada.private_ip_address
  description = "La IP privada de la VM de Base de Datos"
}

output "public_ip" {
  description = "IP pública de la VM AZURE máquina virtual"
  value       = azurerm_public_ip.vm.ip_address
}

output "vpn_gateway_public_ip" {
  description = "IP pública del VPN Gateway para PONER EN AWS"
  value       = azurerm_public_ip.vpn_gateway.ip_address
}
