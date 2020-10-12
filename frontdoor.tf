resource "azurerm_frontdoor" "frontdoor" {
  name                          = "${local.env_name}-frontdoor"
  location                      = "global"
  resource_group_name           = "${azurerm_resource_group.postfix-rg.name}"
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "routing-rule"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["ctsc-webform-endpoint"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "backend-bulk-scan-${var.env"
    }
  }
  
  routing_rule {
    name               = "http-redirect-rule"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["bulk-scan-${var.env}-endpoint"]
    redirect_configuration {
      redirect_protocol = "HttpsOnly"
      redirect_type = "Found"
    }
  }

  backend_pool_load_balancing {
    name = "loadbalance-setting"
  }

  backend_pool_health_probe {
    name = "health-probe-setting"
  }

  backend_pool {
    name = "backend-bulk-scan-${var.env}"
    backend {
      host_header = "${var.frontdoor_url}"
      address     = "${var.frontdoor_url}"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "loadbalance-setting"
    health_probe_name   = "health-probe-setting"
  }

  frontend_endpoint {
    name                              = "bulk-scan-${var.env}-endpoint"
    host_name                         = "${var.frontdoor_url}"
    custom_https_provisioning_enabled = true
    web_application_firewall_policy_link_id = "${azurerm_frontdoor_firewall_policy.wafpolicy.id}"
    custom_https_configuration {
      certificate_source = "FrontDoor"
    }
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
