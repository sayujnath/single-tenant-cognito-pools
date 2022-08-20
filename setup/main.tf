######################################################################
#
#   Title:          CIS Hardened Ubuntu AMI with Node.js
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Company:        Canditude
#   Prepared for    Public non-commercial use
#   Description:   This file does the following:
#                   1. Creates many AWS Cognito userpools where 
#                   2. Each user pool authenticated by an external SAML or OICD IdP providor 
#                   3. Creates application and authorization server subdomains(both public and private), unique to each IdP. 
#
#                   This version of the code is incomplete &untested and specially released 
#                   for non-commecial public consumption. Runninng this code also requires
#                   additional modules for creating loadbalancers and route53 hostzones

#                   For a production ready version,
#                   please contact the author at info@canditude.com
#                   Additional middleware is also required in application code to interact
#                   with the authorizaion servers 
#
######################################################################


module "cognito_user_pools"    {
    source = "../modules/authentication_example/single_tenant_user_pools"
    
    region = var.region
    type = "prod"
    pool_name = "example-pool-name"
    
    auth_subdomain = var.example_primary_auth_domain
    app_url = var.example_primary_app_url
    internal_app_urls = var.example_internal_app_urls

    external_alb_dns_app = module.loadbalancer_external.alb_dns
    internal_alb_dns_app = module.uat_loadbalancer_internal.alb_dns

    external_alb_zone_id_app = module.loadbalancer_external.alb_zone_id
    internal_alb_zone_id_app = module.uat_loadbalancer_internal.alb_zone_id

    zone_id_auth_external = var.auth_example_domain_host_zone_id
    
    zone_id_app_external = var.example_app_domain_host_zone_id
    zone_id_app_internal = var.example_app_domain_internal_host_zone_id

    zone_id_example_external = var.primary_domain_host_zone_id

    subdomain_certificate_arn = var.example_subdomain_certificate_arn

}

