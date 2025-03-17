# Create a resource group
resource "azurerm_resource_group" "main" {
  name = "rg-${var.project_name}"
  # location = var.location
  location = "westus2"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Create a subnet
resource "azurerm_subnet" "public" {
  name                 = "subnet-${var.project_name}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_cidr]
}

# Create a public IP
resource "azurerm_public_ip" "main" {
  name                = "ip-${var.project_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

