# Test login Keycloak -> Google token exchange

## End user - workload identity federation

```
. ./generated/environment.sh
. ./generated/environment_keycloak.sh

curl \
  -d "username=jane" \
  -d "password=$TEST_USER_PASSWORD" \
  -d "client_id=$GOOGLE_WLOADIF_CLIENT_ID" \
  -d "client_secret=$GOOGLE_WLOADIF_CLIENT_SECRET" \
  -d "grant_type=password" \
  -d "audience=$GOOGLE_WLOADIF_AUD" \
  "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token"

curl https://sts.googleapis.com/v1/token \
    --data-urlencode "audience=$GOOGLE_WLOADIF_STS_AUD" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
    --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
    --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform" \
    --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:id_token" \
    --data-urlencode "subject_token=$KEYCLOAK_TOKEN"  \
    --data-urlencode "options={\"userProject\":\"$PROJECT_NUMBER_IDP\"}"
```

## Service account - workload identity federation

```
. ./generated/environment.sh
. ./generated/environment_keycloak.sh

curl \
  -d "client_id=$GOOGLE_WLOADIF_CLIENT_ID" \
  -d "client_secret=$GOOGLE_WLOADIF_CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  -d "audience=$GOOGLE_WLOADIF_AUD" \
  "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token"

curl https://sts.googleapis.com/v1/token \
    --data-urlencode "audience=$GOOGLE_WLOADIF_STS_AUD" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
    --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
    --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform" \
    --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:id_token" \
    --data-urlencode "subject_token=$KEYCLOAK_TOKEN"  \
    --data-urlencode "options={\"userProject\":\"$PROJECT_NUMBER_IDP\"}"

```

## End user - workforce identity federation

```
. ./generated/environment.sh
. ./generated/environment_keycloak.sh

curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$GOOGLE_WFIF_CLIENT_ID" \
  --data-urlencode "client_secret=$GOOGLE_WFIF_CLIENT_SECRET" \
  --data-urlencode 'grant_type=password' \
  --data-urlencode "scope=$GOOGLE_WFIF_CLIENT_SCOPE" \
  --data-urlencode 'username=john' \
  --data-urlencode "password=$TEST_USER_PASSWORD"

curl https://sts.googleapis.com/v1/token \
    --data-urlencode "audience=$GOOGLE_WFIF_AUD" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
    --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
    --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform" \
    --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:id_token" \
    --data-urlencode "subject_token=$KEYCLOAK_TOKEN"  \
    --data-urlencode "options={\"userProject\":\"$PROJECT_NUMBER_IDP\"}"

```

curl https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/jumphost-editor-jm5@isv-coe-predy-00.iam.gserviceaccount.com:generateAccessToken \
     -d '{"scope": ["https://www.googleapis.com/auth/cloud-platform"]}' \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $GOOGLE_TOKEN"
    -X POST 

export KEYCLOAK_TOKEN=$(curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded'   --data-urlencode "client_id=$GOOGLE_WIF_CLIENT_ID"   --data-urlencode "client_secret=$GOOGLE_WIF_CLIENT_SECRET"   --data-urlencode 'grant_type=client_credentials'   --data-urlencode 'scope=google-wif-client-scope' 2>/dev/null | jq -r .access_token)
export KEYCLOAK_TOKEN=$(curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded'   --data-urlencode "client_id=$GOOGLE_WIF_CLIENT_ID"   --data-urlencode "client_secret=$GOOGLE_WIF_CLIENT_SECRET"   --data-urlencode 'grant_type=password'   --data-urlencode 'scope=google-wif-client-scope'   --data-urlencode 'username=john'   --data-urlencode "password=$GOOGLE_WIF_USER_PASSWORD" 2>/dev/null | jq -r .access_token)
export KEYCLOAK_TOKEN=$(curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded'   --data-urlencode "client_id=$GOOGLE_WIF_CLIENT_ID"   --data-urlencode "client_secret=$GOOGLE_WIF_CLIENT_SECRET"   --data-urlencode 'grant_type=password'   --data-urlencode 'scope=google-wif-client-scope'   --data-urlencode 'username=jane'   --data-urlencode "password=$GOOGLE_WIF_USER_PASSWORD" 2>/dev/null | jq -r .access_token)
export GOOGLE_TOKEN=$(curl https://sts.googleapis.com/v1/token     --data-urlencode "audience=$GOOGLE_STS_AUD"     --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange"     --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token"     --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform"     --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:id_token"     --data-urlencode "subject_token=$KEYCLOAK_TOKEN"      --data-urlencode "options={\"userProject\":\"355411137489\"}" 2>/dev/null | jq -r .access_token)

TEST_URL="https://compute.googleapis.com/compute/v1/projects/$TEST_PROJECT_ID/zones/$TEST_VM_ZONE/instances/$TEST_VM_NAME?alt=json"
curl -H "Authorization: Bearer $GOOGLE_TOKEN" $TEST_URL
GOOGLE_SA_TOKEN=$(curl -d '{"scope": ["https://www.googleapis.com/auth/cloud-platform"]}' -H "Content-Type: application/json; charset=utf-8" -H "Authorization: Bearer $GOOGLE_TOKEN" -X POST https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$TEST_SA_EMAIL:generateAccessToken 2>/dev/null | jq -r .accessToken)
curl -H "Authorization: Bearer $GOOGLE_SA_TOKEN" $TEST_URL

client_credentials: principal://iam.googleapis.com/projects/355redacted89/locations/global/workloadIdentityPools/test-keycloak-oidc-pool/subject/6ecba3ca-de5d-4aad-95a3-6b0b638245bd
     password_john: principal://iam.googleapis.com/projects/355redacted89/locations/global/workloadIdentityPools/test-keycloak-oidc-pool/subject/06ef137a-17d5-4b8b-9767-6d03bfcbdcfc
     password_jane: principal://iam.googleapis.com/projects/355redacted89/locations/global/workloadIdentityPools/test-keycloak-oidc-pool/subject/1dcc6403-0169-409c-8d31-262812231107
             group: principalSet://iam.googleapis.com/locations/global/workforcePools/test-redacted-pool
