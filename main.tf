resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
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
  name       = "bootstrap"
  cluster_id = azurerm_kubernetes_cluster.this.id
  namespace  = "flux-system"

  git_repository {
    url             = "https://github.com/iscahomd/flux-bootstrap.git"
    reference_type  = "branch"
    reference_value = "main"

    sync_interval_in_seconds = 30
  }

  kustomizations {
    name = "infrastructure"
    path = "infrastructure"

    sync_interval_in_seconds = 30

    garbage_collection_enabled = true
  }

  kustomizations {
    name = "application"
    path = "application"

    sync_interval_in_seconds = 30

    garbage_collection_enabled = true

    depends_on = ["infrastructure"]
  }

  scope = "cluster"

  depends_on = [
    azurerm_kubernetes_cluster_extension.this
  ]

}

resource "random_password" "mysql_password" {
  length           = 8
  lower            = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}

resource "azurerm_mysql_server" "ghost_db" {
  name                = "ghost-db"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  administrator_login          = "admin"
  administrator_login_password = random_password.mysql_password.result

  version    = "8.0"
  storage_mb = 5120
  sku_name   = "B_Gen5_1"

  ssl_enforcement_enabled = false

  auto_grow_enabled                 = false
  backup_retention_days             = 1
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
}
