output client_id {
    value = aws_cognito_user_pool_client.app_client.id
    description = "Client-id if application mapped with the identity provider"
}

output entity_id {
    value = "urn:amazon:cognito:sp:${aws_cognito_user_pool.this.id}"
    description = "List of all the userpool client-ids mapped with their identity providers"
}

output idp_auth_url {
    value = "https://${var.identity_provider["name"]}.${var.auth_subdomain}/oauth2/authorize?response_type=token&client_id=${aws_cognito_user_pool_client.app_client.id}&redirect_uri=https://${var.identity_provider["name"]}.${var.app_url}&scope=aws.cognito.signin.user.admin+openid+profile"

    description = "Authorize URL to access IdP"
}

output acs_url {
    value = "https://${var.identity_provider["name"]}.${var.auth_subdomain}/saml2/idpresponse"

    description = "Authorize URL to access IdP"
}