
############################################################

#   Title:          Single tenant identity providor Cognito User Pool
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use
#   Description:    Creates a Congnito User Pool SAML Service Provider
#                   using the idendity providers found in the file ./saml_providers/<poolname>.json
#                   and ./oicd_providers/<poolname>.json
#
#   Design Report:  not published in public domain

###########################################################

# create single tenant user pool with attributes specified below.
resource "aws_cognito_user_pool" "this" {

  name  = "${var.pool_name}"
  password_policy {
    minimum_length = 6
    require_lowercase = false
    require_numbers = false
    require_symbols = false
    require_uppercase = false
  }


    schema {
      name                     = "given_name"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true 
      required                 = true
      string_attribute_constraints {
          min_length = 0                 
          max_length = 2048
      }
    }
    schema {
      name                     = "family_name"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true 
      required                 = true
      string_attribute_constraints {
          min_length = 0                 
          max_length = 2048
      }
    }
    schema {
      name                     = "name"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true 
      required                 = true
      string_attribute_constraints {
          min_length = 0                 
          max_length = 2048
      }
    }
    schema {
      name                     = "profile"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true 
      required                 = true
      string_attribute_constraints {
          min_length = 0                 
          max_length = 2048
      }
  }
  

  lifecycle {
    ignore_changes = [
      password_policy
    ]
    prevent_destroy  = true
  }
  

      tags = {
        Environment = "all"
        GeneratedBy = "terraform"
        PreparedBy = "canditude"
    }
}


resource "aws_cognito_identity_provider" "id_provider" {

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = var.identity_provider["name"]
  provider_type = var.identity_provider["provider_type"]

# Only generate this block if the provider is SAML 
  dynamic provider_details  {
    for_each = var.provider_type["provider_type"] == "SAML" ? [1]: []
  
    content {
      MetadataURL = var.identity_provider["metadata_url"]
      SLORedirectBindingURI = "ignored"
      SSORedirectBindingURI = "ignored"
      IDPSignout = "false"
    }
  
  }

# Only generate this block if the provider is OIDC    dynamic provider_details  {
   dynamic provider_details  {
    for_each = var.provider_type["provider_type"] == "OIDC" ? [1]: []
  
    content {
      client_id = var.identity_provider["client_id"]
      client_secret = identity_provider["client_secret"]
      attributes_request_method = identity_provider["attributes_request_method"]
      oidc_issuer  = identity_provider["issuer_url"]
      authorize_scopes = identity_provider["allowed_oauth_scopes"]
    }
  }
  
  # SLORedirectBindingURI and SSORedirectBindingURI are only populated from MetadataURL
  # https://github.com/hashicorp/terraform-provider-aws/issues/4807
  lifecycle {
    ignore_changes = [
      provider_details["SLORedirectBindingURI"],
      provider_details["SSORedirectBindingURI"]
    ]
  }

  attribute_mapping = var.identity_provider["attribute_mapping"]
}


resource "aws_cognito_user_pool_client" "app_client" {

  depends_on = [aws_cognito_identity_provider.id_provider ]

  name = "${var.pool_name}-client"

  user_pool_id = aws_cognito_user_pool.this.id
  
  supported_identity_providers = [var.identity_provider["name"]]
  
  callback_urls   =  [ 
        "https://dev.${var.identity_provider["name"]}.${var.internal_app_urls}",
        "https://test.${var.identity_provider["name"]}.${var.internal_app_urls}",
        "https://${var.identity_provider["name"]}.${var.internal_app_urls}",
        "https://${var.internal_app_urls}",
        "https://dev.${var.identity_provider["name"]}.${var.app_url}",
        "https://test.${var.identity_provider["name"]}.${var.app_url}",
        "https://${var.identity_provider["name"]}.${var.app_url}"
        ]

  logout_urls    =  [ 
        "https://dev.${var.identity_provider["name"]}.${var.internal_app_urls}",
        "https://test.${var.identity_provider["name"]}.${var.internal_app_urls}",
        "https://${var.identity_provider["name"]}.${var.internal_app_urls}",
        "https://${var.internal_app_urls}",
        "https://dev.${var.identity_provider["name"]}.${var.app_url}",
        "https://test.${var.identity_provider["name"]}.${var.app_url}",
        "https://${var.identity_provider["name"]}.${var.app_url}"
        ]

  default_redirect_uri  = "https://${var.identity_provider["name"]}.${var.app_url}"
  
  allowed_oauth_flows = var.identity_provider["allowed_oauth_flows"]
  generate_secret     = var.identity_provider["generate_secret"]
  explicit_auth_flows = var.identity_provider["explicit_auth_flows"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = var.identity_provider["allowed_oauth_scopes"]

  access_token_validity = 5
  id_token_validity = 5
  token_validity_units  {
    access_token = "minutes"
  }

}

##################### CLIENT SECRET STORAGE @@@@@@@@@@@@@@@@@@@@@
resource "aws_ssm_parameter" "OAuth_client_id" {
    name        = "/oauth/${var.identity_provider["name"]}/CLIENT_ID"
    type  = "String"
    description = "Application client ID for cognito Authorization"

    value = aws_cognito_user_pool_client.app_client.id

}
resource "aws_ssm_parameter" "OAuth_client_secret"   {
    name        = "/oauth/${var.identity_provider["name"]}/CLIENT_SECRET"
    description = "Application client secret for cognito Authorization"
    type        = "SecureString"

    value       = coalesce(aws_cognito_user_pool_client.app_client.client_secret,"none")

}


/////////////////////// DOMAIN MANAGEMENT ///////////////////////
// Below are three type of domians being creted in both the public
// and private route53 DNS servers
//
// 1. Assertion Consumer Enpoint (ACE) Custom domain - this is provided to
// idp. idp will direct any users who want to connect here.
//   ie. idp-auth-poolA.example.com.au
// This URL will connect the user to congnito, who in turn will redirect
// the user to thier IdP

// 2. Emulated prvate DNS only idp endpoint. This the an emulation of a idp.cloud
// domain which will direct use to the ACE.
// ie mpn1-uat.idp.cloud  --> idp-auth-poolA.example.com.au

// 3. The domian that will delgate idp users to the idp- app
//    ie. 1. mpn1-uat.example-domain.app --> 2. mpn1-uat-example-domain.example.com.au -->  3. internal or external ALB
//  In the example above (1) set by idp, (2) and (3) are handled by example


resource "aws_cognito_user_pool_domain" "auth_domain" {
  domain = "${var.identity_provider["name"]}.${var.auth_subdomain}"
  certificate_arn = var.subdomain_certificate_arn
  user_pool_id = aws_cognito_user_pool.this.id
}

// This is the assertion consumer endpoint aliased custom domain used by cognito for authentication
// This is in the public DNS
resource "aws_route53_record" "auth_dns_record_public" {
  depends_on = [aws_cognito_user_pool_domain.auth_domain]
  zone_id = var.zone_id_auth_external
  name    = var.identity_provider["name"]
  type    = "CNAME"
  ttl     = "60"

  records        = [aws_cognito_user_pool_domain.auth_domain.cloudfront_distribution_arn]
}

// This is a delegate that will connect with the idp Pay App.
// This is in the public DNS
resource "aws_route53_record" "app_dns_public" {
  
  zone_id = var.zone_id_app_external
  name    = "${var.identity_provider["name"]}"
  type    = "A"

      alias {
        name                   = var.external_alb_dns_app
        zone_id                = var.external_alb_zone_id_app

        evaluate_target_health = false
    }
}

// This is a delegate that will connect with the idp Pay App.
// This is in the private DNS
resource "aws_route53_record" "app_dns_private" {
  
  zone_id = var.zone_id_app_internal
  name    = "${var.identity_provider["name"]}"
  type    = "A"

      alias {
        name                   = var.internal_alb_dns_app
        zone_id                = var.internal_alb_zone_id_app

        evaluate_target_health = false
    }
}


// This will connect the example domain to the idp App running on the development server.
// This is in the public DNS
resource "aws_route53_record" "example_dev_app_public" {
  
  zone_id = var.zone_id_example_external
  name    = "dev.${var.identity_provider["name"]}.idp"
  type    = "A"

      alias {
        name                   = var.external_alb_dns_app
        zone_id                = var.external_alb_zone_id_app

        evaluate_target_health = false
    }
}

// This will connect the example domain to the idp App running on the development server.
// This is in the public DNS
resource "aws_route53_record" "example_test_app_public" {
  
  zone_id = var.zone_id_example_external
  name    = "test.${var.identity_provider["name"]}.generic"
  type    = "A"

      alias {
        name                   = var.external_alb_dns_app
        zone_id                = var.external_alb_zone_id_app

        evaluate_target_health = false
    }
}
