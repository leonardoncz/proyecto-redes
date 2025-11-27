#IP PÚBLICA DEL SERVIDOR WEB
output "web_server_ip" {
    description = "IP Publica del servidor web (HUB)"
    value = aws_instance.web_server.public_ip
}

output "vpn_tunnel1_address" {
    description = "IP Publica del Tunel 1 de la VPN"
    value       = aws_vpn_connection.to_azure.tunnel1_address
}

output "test_vm_prod_private_ip" {
    description = "IP Privada de la VM de prueba en PROD"
    value       = aws_instance.test_vm_prod.private_ip
}