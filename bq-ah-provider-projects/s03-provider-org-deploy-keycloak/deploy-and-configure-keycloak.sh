#!/bin/bash

# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ ! -f ../generated/environment.sh ]
then
  echo "Run the previous stages in sequence first - ../generated/environment.sh does not exist"
fi

. ../generated/environment.sh

gcloud container clusters get-credentials --location $GKE_CLUSTER_LOCATION $GKE_CLUSTER_NAME --project $PROJECT_ID
kubectl --context $GKE_CONTEXT apply -f ../generated/keycloak.yml

while true
do
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$KEYCLOAK_DNS_NAME/health)
  echo "Waiting for keycloak to be live - got status $HTTP_STATUS, want 200"
  sleep 10
  if [ "x$HTTP_STATUS" == "x200" ]
  then
    break
  fi
done

echo "Getting keycloak admin access token ..."
curl \
  --data-urlencode "username=$KEYCLOAK_ADMIN_USER" \
  --data-urlencode "password=$KEYCLOAK_ADMIN_PW" \
  -d "client_id=admin-cli" \
  -d "client_secret=admin-cli" \
  -d "grant_type=password" \
  "https://$KEYCLOAK_DNS_NAME/realms/master/protocol/openid-connect/token" 2>/dev/null > ../temp/admin-token.json

TOKEN=$(cat ../temp/admin-token.json | jq -r .access_token)

echo -n "Checking if client 'terraform-client' exists ... "
COUNT=$(curl -H "Authorization: Bearer $TOKEN" --header 'Accept: application/json' "https://$KEYCLOAK_DNS_NAME/admin/realms/master/clients?clientId=terraform-client" 2>/dev/null | jq '. | length')
if [ "$COUNT" == "1" ]
then
  echo "EXISTS"
else
  echo "NO"
  echo -n "Creating client 'terraform-client' ... "
  CREATE_CLIENT_REQUEST='{
    "protocol": "openid-connect",
    "clientId": "terraform-client",
    "enabled": "true",
    "publicClient": "false",
    "standardFlowEnabled": "false",
    "serviceAccountsEnabled": "true",
    "directAccessGrantsEnabled": "false"
}'
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -X POST \
  -d "$CREATE_CLIENT_REQUEST" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  "https://$KEYCLOAK_DNS_NAME/admin/realms/master/clients")
  if [ "x$HTTP_STATUS" == "x200" ]
  then
    echo "OK"
  else
    echo "ERROR: $HTTP_STATUS"
  fi
fi
echo -n "Get client 'terraform-client' ... "
curl -H "Authorization: Bearer $TOKEN" --header 'Accept: application/json' "https://$KEYCLOAK_DNS_NAME/admin/realms/master/clients?clientId=terraform-client" 2>/dev/null > ../temp/client-terraform-client.json
CLIENT_ID=$(cat ../temp/client-terraform-client.json | jq -r .[0].id)
CLIENT_CLIENT_ID=$(cat ../temp/client-terraform-client.json | jq -r .[0].clientId)
CLIENT_SECRET=$(cat ../temp/client-terraform-client.json | jq -r .[0].secret)
echo "OK: $CLIENT_ID $CLIENT_CLIENT_ID $CLIENT_SECRET"


echo -n "Get user 'service-account-terraform-client' ... "
curl -H "Authorization: Bearer $TOKEN" --header 'Accept: application/json' "https://$KEYCLOAK_DNS_NAME/admin/realms/master/users?username=service-account-terraform-client&exact=true" 2>/dev/null > ../temp/user-service-account-terraform-client.json
USER_ID=$(cat ../temp/user-service-account-terraform-client.json | jq -r .[0].id)
echo "OK: $USER_ID"

echo -n "Get available roles 'admin' 'create-realm' ... "
curl -H "Authorization: Bearer $TOKEN" --header 'Accept: application/json' "https://$KEYCLOAK_DNS_NAME/admin/realms/master/users/$USER_ID/role-mappings/realm/available" 2>/dev/null > ../temp/user-available-roles.json
echo "OK"

echo -n "Add available user roles"
ADD_USER_ROLES_REQUEST=$(cat ../temp/user-available-roles.json | jq '[.[] | select(.name == "create-realm" or .name == "admin")]')
HTTP_STATUS=$(curl \
  -H "Authorization: Bearer $TOKEN" \
  -X POST \
  -d "$ADD_USER_ROLES_REQUEST" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
"https://$KEYCLOAK_DNS_NAME/admin/realms/master/users/$USER_ID/role-mappings/realm" 2>/dev/null)
echo "OK"

echo -n "Get client 'master-realm' ... "
curl -H "Authorization: Bearer $TOKEN" --header 'Accept: application/json' "https://$KEYCLOAK_DNS_NAME/admin/realms/master/clients?clientId=master-realm" 2>/dev/null > ../temp/client-master-realm.json
MASTER_REALM_CLIENT_ID=$(cat ../temp/client-master-realm.json | jq -r .[0].id)
MASTER_REALM_CLIENT_CLIENT_ID=$(cat ../temp/client-master-realm.json | jq -r .[0].clientId)
echo "OK"

echo -n "Get available 'master-realm' client roles 'create-clients' 'manage-clients' ... "
curl -H "Authorization: Bearer $TOKEN" --header 'Accept: application/json' "https://$KEYCLOAK_DNS_NAME/admin/realms/master/users/$USER_ID/role-mappings/clients/$MASTER_REALM_CLIENT_ID/available" 2>/dev/null > ../temp/client-available-roles.json
echo "OK"

echo -n "Add available 'master-realm' client roles"
ADD_USER_CLIENT_ROLES_REQUEST=$(cat ../temp/client-available-roles.json | jq '[.[] | select(.name == "create-client" or .name == "manage-clients" or .name == "manage-users" or .name == "manage-realm")]')
HTTP_STATUS=$(curl \
  -H "Authorization: Bearer $TOKEN" \
  -X POST \
  -d "$ADD_USER_CLIENT_ROLES_REQUEST" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
"https://$KEYCLOAK_DNS_NAME/admin/realms/master/users/$USER_ID/role-mappings/clients/$MASTER_REALM_CLIENT_ID" 2>/dev/null)
echo "OK"

cat > ../generated/provider.keycloak.generated.tf << EOF
provider "keycloak" {
    client_id     = "$CLIENT_CLIENT_ID"
    client_secret = "$CLIENT_SECRET"
    url           = "https://$KEYCLOAK_DNS_NAME"
}
EOF
cp ../generated/provider.keycloak.generated.tf ../step-3-keycloak-realm-client-users/provider.keycloak.generated.tf
