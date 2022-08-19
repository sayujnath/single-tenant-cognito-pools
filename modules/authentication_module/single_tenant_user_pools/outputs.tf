output idp_params {
    value = [for k,pool in module.single_tenant_user_pools: {"idp" = k,"entity_id" = pool.entity_id,"client_id" = pool.client_id, auth_url = pool.idp_auth_url, "acs_url" = pool.acs_url}]
    description = "Output parameters of created user pools"
}