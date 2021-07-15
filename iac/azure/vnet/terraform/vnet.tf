# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "azurerm_resource_group" "vnet" {
  name     = local.service_name
  location = var.resource_group_location
  tags     = var.tags
}

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "2.5.0"

  vnet_name           = var.vnet_name
  resource_group_name = azurerm_resource_group.vnet.name

  address_space   = var.address_space
  subnet_prefixes = var.subnet_prefixes
  subnet_names    = var.subnet_names

  # subnet_service_endpoints = {
  #   subnet2 = ["Microsoft.Storage", "Microsoft.Sql"],
  #   subnet3 = ["Microsoft.AzureActiveDirectory"]
  # }

  tags = var.tags

  depends_on = [azurerm_resource_group.vnet]
}

resource "azurerm_network_security_group" "ssh" {
  name                = "allow-ssh"

  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.authorized_ip_ranges
    destination_address_prefix = "*"
  }

  tags = var.tags
}
