output "public_ip" {
  description = "Public IP"
  value = azurerm_public_ip.this.ip_address
}

output "private_ip" {
  description = "Private IP"
  value = azurerm_network_interface.this.private_ip_address
}

output "ssh" {
  description = "A shortcut for ssh command (assuming .pem extension)"
  value = "ssh -i ${split(".",basename(var.public_key_file))[0]}.pem ${var.admin_username}@${azurerm_public_ip.this.ip_address}"
}

output "instance_id" {
  description = "Instance ID"
  value = azurerm_linux_virtual_machine.this.id
}