##############################################################################
# Dynamic Config
##############################################################################

locals {
  networks = {
    for network in var.vpc_names :
    (network) => {
      zone-1 = contains(var.allow_inbound_traffic, network) ? [
        {
          name           = "${network}-zone-1"
          cidr           = "10.${1 + (index(var.vpc_names, network) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, network)
          acl_name       = "${network}-acl"
        },
        {
          name = "allow-all"
          cidr = "0.0.0.0/0"
        }
        ] : [
        {
          name           = "${network}-zone-1"
          cidr           = "10.${1 + (index(var.vpc_names, network) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, network)
          acl_name       = "${network}-acl"
        }
      ],
      zone-2 = [
        {
          name           = "${network}-zone-2"
          cidr           = "10.${2 + (index(var.vpc_names, network) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, network)
          acl_name       = "${network}-acl"
        }
      ],
      zone-3 = [
        {
          name           = "${network}-zone-3"
          cidr           = "10.${3 + (index(var.vpc_names, network) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, network)
          acl_name       = "${network}-acl"
        }
      ]
    }
  }
}

module "dynamic_acl_allow_rules" {
  for_each = local.networks
  source   = "./dynamic_acl_allow_rules"
  subnets  = each.value
  prefix   = var.prefix
}

##############################################################################
# Local configuration
##############################################################################

locals {
  override = jsondecode(var.override_json)

  ##############################################################################
  # VPC config
  ##############################################################################
  config = {
    vpcs = [
      for network in var.vpc_names :
      {
        prefix = network
        subnets = {
          zone-1 = [
            {
              name           = "${network}-zone-1"
              cidr           = "10.${1 + (index(var.vpc_names, network) * 3)}0.10.0/24"
              public_gateway = contains(var.use_public_gateways, network)
              acl_name       = "${network}-acl"
            }
          ],
          zone-2 = [
            {
              name           = "${network}-zone-2"
              cidr           = "10.${2 + (index(var.vpc_names, network) * 3)}0.10.0/24"
              public_gateway = contains(var.use_public_gateways, network)
              acl_name       = "${network}-acl"
            }
          ],
          zone-3 = [
            {
              name           = "${network}-zone-3"
              cidr           = "10.${3 + (index(var.vpc_names, network) * 3)}0.10.0/24"
              public_gateway = contains(var.use_public_gateways, network)
              acl_name       = "${network}-acl"
            }
          ]
        }
        use_public_gateways = {
          zone-1 = length(var.use_public_gateways) > 0 ? true : false
          zone-2 = length(var.use_public_gateways) > 0 ? true : false
          zone-3 = length(var.use_public_gateways) > 0 ? true : false
        }
        security_group_rules = [
          {
            name      = "allow-all-inbound"
            direction = "inbound"
            remote    = "0.0.0.0/0"
          }
        ]
      }
    ]

    ##############################################################################
    # ACL rules
    ##############################################################################
    acl_rules = {
      for network in var.vpc_names :
      (network) => concat(module.dynamic_acl_allow_rules[network].rules, [
        {
          name        = "allow-all-outbound"
          action      = "allow"
          direction   = "outbound"
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        }
      ])
    }
    ##############################################################################
  }

  ##############################################################################
  # Create ACLS
  ##############################################################################
  acls = [
    for network in var.vpc_names :
    {
      name = "${network}-acl"
      rules = network == "management" ? distinct(
        flatten([
          for allow_rules in var.vpc_names :
          module.dynamic_acl_allow_rules[allow_rules].rules
        ])
        ) : distinct(
        flatten([
          for allow_rules in var.vpc_names :
          module.dynamic_acl_allow_rules[allow_rules].rules if allow_rules == network || allow_rules == "management"
        ])
      )
      add_cluster_rules = contains(var.add_cluster_rules, network)
    }
  ]

  acl_map = {
    for network_acl in local.acls :
    (network_acl.name) => [network_acl]
  }

  ##############################################################################
}

##############################################################################