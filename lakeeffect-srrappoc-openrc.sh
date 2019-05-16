#!/usr/bin/env bash
unset OS_TOKEN
unset OS_AUTH_TYPE
echo "Please enter your CCR API Key: "
read -sr OS_API_KEY_INPUT
export OS_API_KEY=$OS_API_KEY_INPUT
export OS_AUTH_URL=https://lakeeffect.ccr.buffalo.edu:8770/v3
export OS_IDENTITY_API_VERSION=3
export OS_PROJECT_NAME="lakeeffect-srrappoc"
export OS_USERNAME="srrappoc"
export OS_PROJECT_DOMAIN_NAME="lakeeffect"
export OS_INTERFACE=public
export OS_REGION_NAME="buffalo"
export OS_TOKEN=`openstack --os-auth-type v3oidcmokeyapikey --os-identity-provider ccr --os-protocol openid --os-discovery-endpoint https://sso.ccr.buffalo.edu/.well-known/openid-configuration --os-client-id ccr-os-api --os-redirect-uri https://localhost/ccrauth token issue -f value -c id`
export OS_AUTH_TYPE=v3token