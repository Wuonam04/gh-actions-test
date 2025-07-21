resource "azurerm_resource_group" "my_k8s_rg" {
  name     = "my-k8s-rg"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "my_k8s_cluster" {
  location            = azurerm_resource_group.my_k8s_rg.location
  name                = "my-k8s-cluster"
  resource_group_name = azurerm_resource_group.my_k8s_rg.name
  dns_prefix          = "my-k8s-cluster"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_A2_v2"
    node_count = 2
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}


output "rg_name" {
  value = azurerm_resource_group.my_k8s_rg.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.my_k8s_cluster.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.my_k8s_cluster.kube_config_raw
  sensitive = true
}
