provider "azurerm" {
  subscription_id = var.subscription_id
  resource_provider_registrations = "none"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = "sloopstash-${var.environment}"
  location = "Central India"
  tags = {
    Name = "sloopstash-${var.environment}"
    Environment = var.environment
    Region = "centralindia"
    Organization = "sloopstash"
  }
}
resource "azurerm_virtual_network" "vnet" {
  depends_on = [azurerm_resource_group.rg]
  name = "vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  address_space = [var.environment == "prd" ? "11.1.0.0/16" : "12.1.0.0/16"]
  encryption {
    enforcement = "AllowUnencrypted"
  }
  tags = {
    Name = "vnet"
    Environment = var.environment
    Region = "centralindia"
    Organization = "sloopstash"
  }
}
resource "azurerm_subnet" "vnet_bastion_sn_1" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "vnet-bastion-sn-1"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.1.0/24" : "12.1.1.0/24"]
}
resource "azurerm_subnet" "vnet_bastion_sn_2" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "vnet-bastion-sn-2"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.2.0/24" : "12.1.2.0/24"]
}
resource "azurerm_subnet" "vnet_nat_sn_1" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "vnet-nat-sn-1"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.3.0/24" : "12.1.3.0/24"]
}
resource "azurerm_subnet" "vnet_nat_sn_2" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "vnet-nat-sn-2"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.4.0/24" : "12.1.4.0/24"]
}
resource "azurerm_subnet" "vnet_loadbalancer_sn_1" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "vnet-loadbalancer-sn-1"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.5.0/24" : "12.1.5.0/24"]
}
resource "azurerm_subnet" "vnet_loadbalancer_sn_2" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "vnet-loadbalancer-sn-2"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.6.0/24" : "12.1.6.0/24"]
}
resource "azurerm_public_ip" "nat_pip" {
  depends_on = [azurerm_resource_group.rg]
  name = "nat-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Static"
  sku = "Standard"
  sku_tier = "Regional"
  idle_timeout_in_minutes = 4
  tags = {
    Name = "nat-pip"
    Environment = var.environment
    Region = "centralindia"
    Organization = "sloopstash"
  }
}
resource "azurerm_nat_gateway" "ng" {
  depends_on = [azurerm_resource_group.rg]
  name = "ng"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku_name = "Standard"
  idle_timeout_in_minutes = 4
  tags = {
    Name = "ng"
    Environment = var.environment
    Region = "centralindia"
    Organization = "sloopstash"
  }
}
resource "azurerm_nat_gateway_public_ip_association" "ng_pip_ass" {
  depends_on = [
    azurerm_public_ip.nat_pip,
    azurerm_nat_gateway.ng
  ]
  public_ip_address_id = azurerm_public_ip.nat_pip.id
  nat_gateway_id = azurerm_nat_gateway.ng.id
}
resource "azurerm_network_security_group" "bastion_nsg" {
  depends_on = [azurerm_resource_group.rg]
  name = "bastion-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  security_rule {
    name = "AllowAnyIpAddressSSHInbound"
    direction = "Inbound"
    access = "Allow"
    priority = 110
    protocol = "Tcp"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = 22
  }
  tags = {
    Name = "bastion-nsg"
    Environment = var.environment
    Region = "centralindia"
    Organization = "sloopstash"
  }
}
/* Kubernetes specific Azure resources*/
resource "azurerm_subnet" "container_s2_vnet_kubernetes_sn_1" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "container-s2-vnet-kubernetes-sn-1"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.9.0/24" : "12.1.9.0/24"]
}
resource "azurerm_subnet" "container_s2_vnet_kubernetes_sn_2" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet
  ]
  name = "container-s2-vnet-kubernetes-sn-2"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.environment == "prd" ? "11.1.10.0/24" : "12.1.10.0/24"]
}
resource "azurerm_subnet_nat_gateway_association" "container_s2_vnet_kubernetes_sn_1_ng_ass" {
  depends_on = [
    azurerm_subnet.container_s2_vnet_kubernetes_sn_1,
    azurerm_nat_gateway.ng
  ]
  subnet_id = azurerm_subnet.container_s2_vnet_kubernetes_sn_1.id
  nat_gateway_id = azurerm_nat_gateway.ng.id
}
resource "azurerm_subnet_nat_gateway_association" "container_s2_vnet_kubernetes_sn_2_ng_ass" {
  depends_on = [
    azurerm_subnet.container_s2_vnet_kubernetes_sn_2,
    azurerm_nat_gateway.ng
  ]
  subnet_id = azurerm_subnet.container_s2_vnet_kubernetes_sn_2.id
  nat_gateway_id = azurerm_nat_gateway.ng.id
}
resource "azurerm_network_security_group" "container_s2_kubernetes_nsg" {
  depends_on = [azurerm_resource_group.rg]
  name = "container-s2-kubernetes-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  tags = {
    Name = "container-s2-kubernetes-nsg"
    Environment = var.environment
    Region = "centralindia"
    Organization = "sloopstash"
  }
}
resource "azurerm_kubernetes_cluster" "aks_ct" {
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_subnet.container_s2_vnet_kubernetes_sn_1,
    azurerm_subnet.container_s2_vnet_kubernetes_sn_2
  ]
  name = "aks-ct"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  kubernetes_version = "1.36"
  sku_tier = "Free"
  identity {
    type = "SystemAssigned"
  }
  open_service_mesh_enabled = false
  private_cluster_enabled = false
  dns_prefix = "aks-ct-api-endpoint"
  api_server_access_profile {
    authorized_ip_ranges = ["0.0.0.0/0"]
  }
  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
    ip_versions = ["IPv4"]
    load_balancer_sku = "standard"
  }
  node_resource_group = "aks-ct-rg"
  default_node_pool {
    name = "nodepool1"
    vm_size = "Standard_D2as_v4"
    type = "VirtualMachineScaleSets"
    os_sku = "AzureLinux"
    vnet_subnet_id = azurerm_subnet.container_s2_vnet_kubernetes_sn_1.id
    node_public_ip_enabled = false
    ultra_ssd_enabled = false
    host_encryption_enabled = false
    orchestrator_version = "1.36"
    workload_runtime = "OCIContainer"
    auto_scaling_enabled = true
    max_count = 1
    min_count = 1
    node_count = 1
    max_pods = 50
  }
  node_provisioning_profile {
    mode = "Manual"
  }
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel = "NodeImage"
  maintenance_window {
    allowed {
      day = "Sunday"
      hours = [1,2]
    }
  }
  role_based_access_control_enabled = true
  azure_policy_enabled = false
  image_cleaner_enabled = false
  oidc_issuer_enabled = false
  run_command_enabled = true
  tags = {
    Name = "aks-ct"
    Environment = var.environment
    Stack = "container-s2/kubernetes"
    Region = "centralindia"
    Organization = "sloopstash"
  }
}
 