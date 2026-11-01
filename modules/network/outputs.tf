output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "public_subnet_name" {
  value = azurerm_subnet.public.name
}

output "private_subnet_name" {
  value = azurerm_subnet.private.name
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "public_subnet_nsg_association_id" {
  value = azurerm_subnet_network_security_group_association.public.id
}

output "private_subnet_nsg_association_id" {
  value = azurerm_subnet_network_security_group_association.private.id
}

output "nat_public_ip" {
  description = "Stable egress IP of the clusters, useful for allow-listing."
  value       = azurerm_public_ip.nat.ip_address
}
