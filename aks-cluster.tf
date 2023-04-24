resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                              = "${azurerm_resource_group.aks_rg.name}-cluster"
  location                          = azurerm_resource_group.aks_rg.location
  resource_group_name               = azurerm_resource_group.aks_rg.name
  dns_prefix                        = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version                = data.azurerm_kubernetes_service_versions.current.latest_version
#  node_resource_group               = "${azurerm_resource_group.aks_rg.name}-nrg"
  role_based_access_control_enabled = true

  default_node_pool {
    name                 = "default"
    vm_size              = var.node_type
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    enable_auto_scaling  = true
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30

    # AKS Default Subnet ID
    vnet_subnet_id = azurerm_subnet.aks-default.id
    node_labels = {
      "nodepool-type" = "default"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "default-apps"
    }
    tags = {
      "nodepool-type" = "default"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "default-apps"
    }
  }

  # Identity (System Assigned or Service Principal)
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_uai.id]
  }

  # Network Profile
  network_profile {
    network_plugin = "azure"
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [azurerm_virtual_network.aks_vn,
    azurerm_role_assignment.aks_role_assignment,
  azurerm_container_registry.aks_acr]
}
