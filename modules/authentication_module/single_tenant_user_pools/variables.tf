
variable region {
    type    = string
    description = "Set this to the region to deploy resources. Ensure the region has at least three availiability zones."
        validation {
        condition     = contains(["us-east-1", "us-east-2", "ap-southeast-2"], var.region)
        error_message = "Allowed values for 'region' parameter are 'us-east-1' and 'ap-southeast-2'."
    }
}


variable type {
    type = string
    validation {
        condition     = contains(["dev", "test", "stage", "prod", "all", "sync"], var.type)
        error_message = "Allowed values for 'type' parameter are 'dev', 'test', 'prod' or all."
    }
}

variable "pool_name"  {
    type = string
    description = "This is the name of the user pool. This mane has to be URL friendly"
}

variable "auth_subdomain" {
    type    = string
    description = "The subdomain to be used for authorisation"
}

variable "app_url" {
    type    = string
    description = "The base callback url to be used direct the user to the service"
}

variable "internal_app_urls" {
    type    = string
    description = "base callback url to be used internally for testing and development purposes"
}

variable  "zone_id_auth_external" {
    type = string
    description = "This is the zone ID of the host zone in the public DNS for the User Pool authorisation service"
}


variable  "zone_id_app_external" {
    type = string
    description = "This is the zone ID of the host zone in the public DNS for the application service"
}

variable  "zone_id_app_internal" {
    type = string
    description = "This is the zone ID of the host zone  in the private DNS for the application service."
}

variable  "zone_id_example_external" {
    type = string
    description = "This is the zone ID of casdh domian in the public DNS for development purposes of application service"
}


variable  "external_alb_dns_app" {
    type = string
    description = "This is the ALB DNS which points to the app service in production"
}


variable  "internal_alb_dns_app" {
    type = string
    description = "This is the ALB DNS which points to the app service in for user acceptance testing"
}


variable  "external_alb_zone_id_app" {
    type = string
    description = "This is the ALB Zone ID which points to the app service in production"
}


variable  "internal_alb_zone_id_app" {
    type = string
    description = "This is the ALB Zone ID which points to the app service in for user acceptance testing"
}

variable "subdomain_certificate_arn"    {
    type = string
    description =  "ACM generated certificate arn for the domains used for the authentication and service. This certificate is based in us-east-1"
}