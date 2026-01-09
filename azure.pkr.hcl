
packer {
  required_version = ">= 1.9.0"

  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 2.0.0"
    }
  }
}

# ---- INPUT VARIABLES (env() allowed here) ----
variable "subscription_id" {
  type    = string
  default = env("ARM_SUBSCRIPTION_ID")
}

variable "client_id" {
  type    = string
  default = env("ARM_CLIENT_ID")
}

variable "client_secret" {
  type    = string
  default = env("ARM_CLIENT_SECRET")
}

variable "tenant_id" {
  type    = string
  default = env("ARM_TENANT_ID")
}

variable "location" {
  type    = string
  default = "eastus"
}

# ---- SOURCE (builder) ----
source "azure-arm" "UbuntuServer_18" {
  use_azure_cli_auth = true
  # Use variables (NOT env()) inside source/build
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = "azure-packer-rg"
  location                          = var.location

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "18.04-LTS"

  # vm_size = "Standard_B2s"
}

# ---- BUILD ----
build {
  sources = ["source.azure-arm.UbuntuServer_18"]


  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y htop",
      "echo 'Image built by Packer' | sudo tee /etc/motd",
    ]
  }

  # Emit a manifest with artifact metadata (image name, builder id, etc.)
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}

