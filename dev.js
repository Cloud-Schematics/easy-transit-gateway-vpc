console.log(JSON.stringify({
    "vpcs": [
      {
        "prefix": "override-vpc",
        "classic_access": true,
        "use_manual_address_prefixes": false,
        "default_network_acl_name": "override_acl_name",
        "default_security_group_name": "override_sg_name",
        "use_public_gateways": {
          "zone-1": true,
          "zone-2": false,
          "zone-3": true
        },
        "subnets": {
          "zone-1": [
            {
              "acl_name": "override_acl",
              "cidr": "10.20.10.0/24",
              "name": "override-1",
              "public_gateway": true
            },
            {
              "acl_name": "bastion_subnet_acl",
              "cidr": "10.10.10.0/24",
              "name": "bastion",
              "public_gateway": false
            }
          ],
          "zone-2": [
            {
              "acl_name": "override_acl",
              "cidr": "10.80.10.0/24",
              "name": "override-subnet-2",
              "public_gateway": false
            }
          ],
          "zone-3": [
            {
              "acl_name": "override_acl",
              "cidr": "10.30.90.0/24",
              "name": "subnet-oberride-3",
              "public_gateway": false
            }
          ]
        },
        "network_acls": [
          {
            "name": "override_acl",
            "add_cluster_rules": true,
            "rules": [
              {
                "action": "allow",
                "destination": "0.0.0.0/0",
                "direction": "outbound",
                "name": "allow-outbound-8080",
                "source": "0.0.0.0/0",
                "tcp": {
                  "port_min": 8080,
                  "port_max": 8080
                }
              },
              {
                "action": "allow",
                "destination": "10.10.10.0/24",
                "direction": "outbound",
                "name": "allow-all-bastion-outbound",
                "source": "0.0.0.0/0"
              },
              {
                "action": "allow",
                "source": "10.10.10.0/24",
                "direction": "inbound",
                "name": "allow-all-bastion-inbound",
                "destination": "0.0.0.0/0"
              },
              {
                "action": "allow",
                "destination": "0.0.0.0/0",
                "direction": "inbound",
                "name": "allow-zone-1",
                "source": "10.20.10.0/24"
              },
              {
                "action": "allow",
                "destination": "10.20.10.0/24",
                "direction": "outbound",
                "name": "allow-outbound-zone-1",
                "source": "0.0.0.0/0"
              },
              {
                "action": "allow",
                "destination": "0.0.0.0/0",
                "direction": "inbound",
                "name": "allow-inbound-zone-2",
                "source": "10.80.10.0/24"
              },
              {
                "action": "allow",
                "destination": "10.80.10.0/24",
                "direction": "outbound",
                "name": "allow-outbound-2",
                "source": "0.0.0.0/0"
              },
              {
                "action": "allow",
                "destination": "0.0.0.0/0",
                "direction": "inbound",
                "name": "allow-inbound-zone-3",
                "source": "10.30.90.0/24"
              },
              {
                "action": "allow",
                "destination": "10.30.90.0/24",
                "direction": "outbound",
                "name": "allow-outbound-zone-3",
                "source": "0.0.0.0/0"
              }
            ]
          },
          {
            "name": "bastion_subnet_acl",
            "rules": [
              {
                "action": "allow",
                "destination": "0.0.0.0/0",
                "direction": "inbound",
                "name": "allow-zone-1",
                "source": "10.20.10.0/24"
              },
              {
                "action": "allow",
                "destination": "10.20.10.0/24",
                "direction": "outbound",
                "name": "allow-outbound-zone-1",
                "source": "0.0.0.0/0"
              },
              {
                "action": "allow",
                "destination": "0.0.0.0/0",
                "direction": "inbound",
                "name": "allow-inbound-zone-2",
                "source": "10.80.10.0/24"
              },
              {
                "action": "allow",
                "destination": "10.80.10.0/24",
                "direction": "outbound",
                "name": "allow-outbound-2",
                "source": "0.0.0.0/0"
              },
              {
                "action": "allow",
                "destination": "0.0.0.0/0",
                "direction": "inbound",
                "name": "allow-inbound-zone-3",
                "source": "10.30.90.0/24"
              },
              {
                "action": "allow",
                "destination": "10.30.90.0/24",
                "direction": "outbound",
                "name": "allow-outbound-zone-3",
                "source": "0.0.0.0/0"
              }
            ]
          }
        ],
        "security_group_rules": [
          {
            "name": "allow-all-tcp-8080-inbound",
            "direction": "inbound",
            "remote": "0.0.0.0/0"
          }
        ],
        "vpn_gateways": []
      }
    ]
  }
  ).replace(/\"/g, "\\\""))