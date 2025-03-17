terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "pg" {
    conn_str = "postgres://atwlam@localhost:5432/terraform_state?sslmode=disable"
  }
}
