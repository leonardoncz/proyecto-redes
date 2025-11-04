output "public_ip" {
  description = "IP pública de la máquina virtual"
  value       = azurerm_public_ip.vm.ip_address
}
