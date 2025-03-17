output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = azurerm_subnet.public.name
}

output "public_ip_address" {
  description = "The public IP address"
  value       = azurerm_public_ip.main.ip_address
}
