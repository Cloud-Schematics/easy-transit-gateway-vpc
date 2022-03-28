##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

##############################################################################


##############################################################################
# Create VPC
##############################################################################

module "vpc" {
  source = "./vpc"
  for_each = {
    for network in local.env.vpcs :
    (network.prefix) => network
  }
  resource_group_id           = data.ibm_resource_group.resource_group.id
  region                      = var.region
  tags                        = var.tags
  prefix                      = lookup(each.value, "prefix", each.value.prefix)
  vpc_name                    = lookup(each.value, "vpc_name", "${var.prefix}-${each.value.prefix}")
  network_acls                = each.value.network_acls
  use_public_gateways         = lookup(each.value, "use_public_gateways", each.value.use_public_gateways)
  subnets                     = lookup(each.value, "subnets", each.value.subnets)
  use_manual_address_prefixes = lookup(each.value, "use_manual_address_prefixes", null)
  default_network_acl_name    = lookup(each.value, "default_network_acl_name", null)
  default_security_group_name = lookup(each.value, "default_security_group_name", null)
  default_routing_table_name  = lookup(each.value, "default_routing_table_name", null)
  address_prefixes            = lookup(each.value, "address_prefixes", null)
  routes                      = lookup(each.value, "routes", [])
  vpn_gateways                = lookup(each.value, "vpn_gateways", [])
}

##############################################################################


##############################################################################
# Transit Gateway
##############################################################################

resource "ibm_tg_gateway" "transit_gateway" {
  name           = "${var.prefix}-transit-gateway"
  location       = var.region
  global         = false
  resource_group = data.ibm_resource_group.resource_group.id
}

##############################################################################


##############################################################################
# Transit Gateway Connections
##############################################################################

resource "ibm_tg_connection" "connection" {
  for_each     = module.vpc
  gateway      = ibm_tg_gateway.transit_gateway.id
  network_type = "vpc"
  name         = "${var.prefix}-${each.key}-hub-connection"
  network_id   = module.vpc[each.key].vpc_crn
}

##############################################################################