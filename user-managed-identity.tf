# Create User Managed Identity for Role Based Access to AKS
resource "azurerm_user_assigned_identity" "aks_uai" {
  location            = azurerm_resource_group.aks_rg.location
  name                = "${azurerm_resource_group.aks_rg.name}-uai"
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Assigning role definition to the created identity
resource "azurerm_role_assignment" "aks_role_assignment" {
  scope                = azurerm_resource_group.aks_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_uai.principal_id
}

resource "azurerm_role_assignment" "aks_acr" {
  scope                = azurerm_container_registry.aks_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_uai.principal_id
}
