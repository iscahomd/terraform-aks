resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_extension" "this" {
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "this" {
  name                = "bootstrap"
  cluster_id          = azurerm_kubernetes_cluster.this.id
  namespace           = "default"

  git_repository {
    url             = "https://github.com/iscahomd/flux-bootstrap.git"
    reference_type  = "branch"
    reference_value = "main"
  }
}
