## Provision AKS Cluster
#/*
#1. Add Basic Cluster Settings
#  - Get Latest Kubernetes Version from datasource (kubernetes_version)
#  - Add Node Resource Group (node_resource_group)
#2. Add Default Node Pool Settings
#  - orchestrator_version (latest kubernetes version using datasource)
#  - availability_zones
#  - enable_auto_scaling
#  - max_count, min_count
#  - os_disk_size_gb
#  - type
#  - node_labels
#  - tags
#3. Admin Profiles
#  - Windows Admin Profile
#  - Linux Profile
#4. Network Profile
#5. Cluster Tags
#*/
#
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"

  default_node_pool {
    name                 = "systempool"
    vm_size              = "Standard_D2s_v3"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    enable_auto_scaling  = true
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    # AKS Default Subnet ID
    vnet_subnet_id = azurerm_subnet.aks-default.id
    type           = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }

  # Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

  # RBAC and Azure AD Integration Block
  azure_active_directory_role_based_access_control {
    managed = true
  }

  # Windows Profile
  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  # Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  # Network Profile
  network_profile {
    network_plugin = "azure"
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [azurerm_virtual_network.aks_vn]
}
