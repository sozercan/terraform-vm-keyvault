# create a resource group if it doesn't exist
resource "azurerm_resource_group" "demoterraform" {
  name     = "demoterraformvm"
  location = "${var.terraform_azure_region}"
}

# create virtual network
resource "azurerm_virtual_network" "demoterraformnetwork" {
  name                = "tfvn"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.terraform_azure_region}"
  resource_group_name = "${azurerm_resource_group.demoterraform.name}"
}

# create subnet
resource "azurerm_subnet" "demoterraformsubnet" {
  name                 = "tfsub"
  resource_group_name  = "${azurerm_resource_group.demoterraform.name}"
  virtual_network_name = "${azurerm_virtual_network.demoterraformnetwork.name}"
  address_prefix       = "10.0.2.0/24"
}

# create public IPs
resource "azurerm_public_ip" "demoterraformips" {
  name                         = "demoterraformip"
  location                     = "${var.terraform_azure_region}"
  resource_group_name          = "${azurerm_resource_group.demoterraform.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.resource_group_name}"

  tags {
    environment = "TerraformDemo"
  }
}

# create network interface
resource "azurerm_network_interface" "demoterraformnic" {
  name                = "tfni"
  location            = "${var.terraform_azure_region}"
  resource_group_name = "${azurerm_resource_group.demoterraform.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.demoterraformsubnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = "${azurerm_public_ip.demoterraformips.id}"
  }
}

resource "random_id" "storage" {
  byte_length = 4
}

# create storage account
resource "azurerm_storage_account" "demoterraformstorage" {
  name                = "${random_id.storage.hex}"
  resource_group_name = "${azurerm_resource_group.demoterraform.name}"
  location            = "${var.terraform_azure_region}"
  account_type        = "Standard_LRS"

  tags {
    environment = "staging"
  }
}

# create storage container
resource "azurerm_storage_container" "demoterraformstoragestoragecontainer" {
  name                  = "vhd"
  resource_group_name   = "${azurerm_resource_group.demoterraform.name}"
  storage_account_name  = "${azurerm_storage_account.demoterraformstorage.name}"
  container_access_type = "private"
  depends_on            = ["azurerm_storage_account.demoterraformstorage"]
}

# create virtual machine
resource "azurerm_virtual_machine" "demoterraformvm" {
  name                  = "terraformvm"
  location              = "${var.terraform_azure_region}"
  resource_group_name   = "${azurerm_resource_group.demoterraform.name}"
  network_interface_ids = ["${azurerm_network_interface.demoterraformnic.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk"
    vhd_uri       = "${azurerm_storage_account.demoterraformstorage.primary_blob_endpoint}${azurerm_storage_container.demoterraformstoragestoragecontainer.name}/myosdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "core"
    admin_username = "core"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  os_profile_secrets {
    source_vault_id = "${var.terraform_keyvault_source_vault_id}"

    vault_certificates = {
      certificate_url = "${var.terraform_keyvault_certificate_url}"
    }
  }

  tags {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_extension" "test" {
  name                       = "terraformvmextension"
  location                   = "${var.terraform_azure_region}"
  resource_group_name        = "${azurerm_resource_group.demoterraform.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.demoterraformvm.name}"
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": ""
    }
SETTINGS
}
