resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  # BUG: this should be coming from variables.tf
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
  cluster_id     = azurerm_kubernetes_cluster.this.id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "this" {
  name                = "bootstrap"
  cluster_id          = azurerm_kubernetes_cluster.this.id
  namespace           = "flux-system"

  git_repository {
    url             = "https://github.com/iscahomd/flux-bootstrap.git"
    reference_type  = "branch"
    reference_value = "main"

    sync_interval_in_seconds = 120
  }

  kustomizations {
    name = "example"
    path = "example"

    sync_interval_in_seconds = 120
  }

  scope = "namespace"

  depends_on = [
    azurerm_kubernetes_cluster_extension.this
  ]

}
