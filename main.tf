data "http" "ip" {
  url = "https://ifconfig.me/ip"
}


resource "azurerm_public_ip" "this" {
  name                = "${var.vm_name}PublicIp"
  resource_group_name = var.resource_group_name
  location            = var.region
  allocation_method   = "Static"
  tags                = local.tags
}

resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "default"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
    # private_ip_address = var.private_ip_address
  }
  tags = local.tags
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.vm_name}-nsg"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${data.http.ip.response_body}/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ICMP-10"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP-172"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.16.0.0/12"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP-192"
    priority                   = 330
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "192.168.0.0/16"
    destination_address_prefix = "*"
  }



  security_rule {
    name                       = "HTTP"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "IPerf3-10"
    priority                   = 350
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5201"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "IPerf3-172"
    priority                   = 360
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5201"
    source_address_prefix      = "172.16.0.0/12"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Iperf3-192"
    priority                   = 370
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5201"
    source_address_prefix      = "192.168.0.0/16"
    destination_address_prefix = "*"
  }
  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}


resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = var.size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_file)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  custom_data = base64encode(local.custom_data)
  tags        = local.tags
}
