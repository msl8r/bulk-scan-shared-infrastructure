resource "azurerm_frontdoor" "frontdoor" {
  name                                         = "${var.product}-${var.env}-frontdoor"
  location                                     = "${var.location}"
  resource_group_name                          = "${azurerm_resource_group.rg.name}"
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "storageRoutingRule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["storageFrontendEndpoint"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "storageBackend"
    }
  }

  backend_pool_load_balancing {
    name = "storageLoadBalancingSettings"
  }

  backend_pool_health_probe {
    name = "storageHealthProbeSetting"
  }

  backend_pool {
    name = "storageBackend"
    backend {
      host_header = "${var.frontdoor_backend}"
      address     = "${var.frontdoor_backend}"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "storageLoadBalancingSettings"
    health_probe_name   = "storageHealthProbeSetting"
  }

  frontend_endpoint {
    name                              = "storageFrontendEndpoint"
    host_name                         = "${var.external_hostname}"
    custom_https_provisioning_enabled = false
  }
  
  frontend_endpoint {
    name                              = "defaultFrontendEndpoint"
    host_name                         = "${var.product}-${var.env}-FrontDoor.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}

resource "azurerm_frontdoor_firewall_policy" "wafpolicy" {
  name                              = "bulkscan${replace(var.env, "-", "")}wafpolicy"
  resource_group_name               = "${azurerm_resource_group.rg.name}"
  enabled                           = true
  mode                              = "Prevention"

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
  }
  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
  }
}
