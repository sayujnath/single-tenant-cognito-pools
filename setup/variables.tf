variable "example_subdomain_certificate_arn"    {
    type = string
    description =  "ACM generated certificate arn for the domains used for the authentication and service to the example app. This certificate is based in us-east-1"
}

variable "auth_example_domain_host_zone_id"  {
    type    = string
    description = "The name of the host zone file for the authentication domain for the example User Pools"
}


variable "example_app_domain_host_zone_id"  {
    type    = string
    description = "The name of the host zone file used to direct users to the example Service"
}

variable "example_app_domain_internal_host_zone_id"  {
    type    = string
    description = "The name of the host zone file used to direct users to the example Service. Used for private requests via VPN only."
}

variable "example_primary_app_url" {
    type    = string
    description = "The customer facing url of the example application server"
}

variable "example_primary_app_domain" {
    type    = string
    description = "The customer facing root subdomain of the example application server"
}

variable "example_internal_app_urls" {
    type    = string
    description = "Base callback url to be used internally for testing and development purposes"
}

variable "example_primary_auth_domain" {
    type    = string
    description = "The root customer facing domain name of the example authentication server"
}