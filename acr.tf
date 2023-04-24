resource "azurerm_container_registry" "aks_acr" {
  name                = "${var.environment}opsinfotitansacr"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

#  Attaching a Container Registry to a Kubernetes Cluster
#resource "azurerm_role_assignment" "example" {
#  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
#  role_definition_name             = "AcrPull"
#  scope                            = azurerm_container_registry.aks_acr.id
#  skip_service_principal_aad_check = true
#}
