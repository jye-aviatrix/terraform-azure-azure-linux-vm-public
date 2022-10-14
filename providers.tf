terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    http = {
        source = "hashicorp/http"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}