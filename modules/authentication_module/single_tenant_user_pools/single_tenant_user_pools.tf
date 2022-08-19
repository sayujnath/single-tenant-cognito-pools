

############################################################

#   Title:          Multiple "Single tenant" identity providor Cognito User Pools
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use
#   Description:    Creates multiple Cognito User Pools with single tenant SAML or OICD Identity Provider (IdP)
#                   using the idendity providers found in the file ./saml_providers/<poolname>.json
#                   and ./oicd_providers/<poolname>.json
#
#   Design Report:  not published in public domain

###########################################################


locals{
  idp_pool_path = "${path.module}/../saml_metadata/${var.pool_name}"
  idp_metadata_file_names = fileset(local.idp_pool_path,"**.xml")
  idp_names = [for name in local.idp_metadata_file_names: trimsuffix(name,".xml")]
  pool_attributes = jsondecode(file("${path.module}/../saml_metadata/${var.pool_name}.json"))["pool_attributes"]
  pool_metadata_list = jsondecode(file("${path.module}/../saml_metadata/${var.pool_name}.json"))["identity_providers"]

  # List of all callback URLs which are suppored.
  callback_urls = flatten([[for provider in local.pool_metadata_list:   "https://${provider.name}.example-app.app"],
                            [for provider in local.pool_metadata_list:   "https://${provider.name}-example-app.example.com.au"],
                            [for provider in local.pool_metadata_list:   "https://${provider.name}.example-app.cloud"]])
}

output json {
  value = local.callback_urls
}

module "single_tenant_user_pools"  {
  
  source = "./../single_idp_user_pool"

  for_each = {for provider in local.pool_metadata_list:   provider["name"]=> provider}
  
  region = var.region
  type = var.type
  pool_name = "${var.pool_name}-${each.key}"
  
  auth_subdomain = var.auth_subdomain
  app_url = var.app_url
  internal_app_urls = var.internal_app_urls

  identity_provider = each.value

  # Route 53 DNS records for IdP subdomains. These point to the Load Balancer 
  # which route to the protected application
  external_alb_dns_app = var.external_alb_dns_app
  internal_alb_dns_app = var.internal_alb_dns_app

  external_alb_zone_id_app = var.external_alb_zone_id_app
  internal_alb_zone_id_app = var.internal_alb_zone_id_app

# Route 53 DNS records for Cognito Auth servers.
  zone_id_auth_external = var.zone_id_auth_external
  
  zone_id_app_external = var.pool_attributes["public_hostzone"]
  zone_id_app_internal = var.pool_attributes["private_hostzone"]

  zone_id_example_external = var.zone_id_example_external

  subdomain_certificate_arn = var.subdomain_certificate_arn
  
}

