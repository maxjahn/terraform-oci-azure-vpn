
resource "oci_core_virtual_network" "vpn_vcn" {
  cidr_block     = "${var.oci_cidr_vpn_vcn}"
  dns_label      = "vpnvcn"
  compartment_id = "${var.oci_compartment_ocid}"
  display_name   = "vpn-vcn"
}

resource "oci_core_subnet" "vpn_subnet" {
  cidr_block        = "${var.oci_cidr_vpn_subnet}"
  compartment_id    = "${var.oci_compartment_ocid}"
  vcn_id            = "${oci_core_virtual_network.vpn_vcn.id}"
  display_name      = "vpn-subnet"
  dns_label      = "vpnsubnet"
  security_list_ids = ["${oci_core_security_list.vpn_sl.id}"]
}

resource "oci_core_internet_gateway" "vpn_igw" {
  display_name   = "vpn-internet-gateway"
  compartment_id = "${var.oci_compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vpn_vcn.id}"
}

resource "oci_core_default_route_table" "vpn_default_route_table" {
  manage_default_resource_id = "${oci_core_virtual_network.vpn_vcn.default_route_table_id}"

  route_rules {
    network_entity_id = "${oci_core_internet_gateway.vpn_igw.id}"
    destination       = "0.0.0.0/0"
  }

  route_rules {
    network_entity_id = "${module.vpn.oci_vpn_drg_id}"
    destination       = "${var.arm_cidr_vpn_vnet}"
  }
}

resource "oci_core_security_list" "vpn_sl" {
  compartment_id = "${var.oci_compartment_ocid}"
  vcn_id            = "${oci_core_virtual_network.vpn_vcn.id}"
  display_name   = "connect-security-list"

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1"
  }

ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = "22"
      max = "22"
    }
  }

  # azure
  ingress_security_rules {
    source   = "${var.arm_cidr_vpn_vnet}"
    description = "Azure VPN test VNet"
    protocol = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source   = "${var.arm_cidr_vpn_vnet}"
    description = "Azure VPN test VNet"
    protocol = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  egress_security_rules {
    destination   = "0.0.0.0/0"
    protocol = "all"
    }
}

resource "azurerm_virtual_network" "vpn_vnet" {
  name                = "vpn-network"
  resource_group_name  = "${azurerm_resource_group.connect.name}"
  location            = "${azurerm_resource_group.connect.location}"
  address_space       = ["${var.arm_cidr_vpn_vnet}"]
}

resource "azurerm_subnet" "vpn_subnet" {
  name                 = "vpn-subnet"
  resource_group_name  = "${azurerm_resource_group.connect.name}"
  virtual_network_name = "${azurerm_virtual_network.vpn_vnet.name}"
  address_prefix       = "${var.arm_cidr_vpn_subnet}"
}

resource "azurerm_subnet" "vpn_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.connect.name}"
  virtual_network_name = "${azurerm_virtual_network.vpn_vnet.name}"
  address_prefix       = "${var.arm_cidr_vpn_gw_subnet}"
}

resource "azurerm_resource_group" "connect" {
  name     = "connect"
  location = "${var.arm_region}"
}

data "oci_identity_availability_domains" "connect_ads" {
  compartment_id = "${var.oci_compartment_ocid}"
}

## modules 

module "vpn" {
	source = "./modules/vpn"
	
	oci_compartment_ocid = "${var.oci_compartment_ocid}"
	
	oci_vpn_vcn_id = "${oci_core_virtual_network.vpn_vcn.id}"
	oci_vpn_subnet_cidr = "${var.oci_cidr_vpn_subnet}"
	
 	arm_resource_group_location = "${azurerm_resource_group.connect.location}"
 	arm_resource_group_name = "${azurerm_resource_group.connect.name}"
	
	arm_vpn_vnet_cidr = "${var.arm_cidr_vpn_vnet}"
	arm_vpn_subnet_cidr = "${var.arm_cidr_vpn_subnet}"
	arm_vpn_gw_subnet_id = "${azurerm_subnet.vpn_gateway_subnet.id}"
	
	peering_net = "${var.peering_net}"
}






