# Test login Keycloak -> Google token exchange

## Service account - Workload Identity Federation (`client_credentials` -> Google STS)

```bash
. ./generated/environment.sh
. ./generated/environment_keycloak.sh

export KEYCLOAK_TOKEN=$(curl -sS -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$GOOGLE_WLOADIF_CLIENT_ID" \
  --data-urlencode "client_secret=$GOOGLE_WLOADIF_CLIENT_SECRET" \
  --data-urlencode "scope=$GOOGLE_WLOADIF_CLIENT_SCOPE" \
  --data-urlencode "grant_type=client_credentials" | jq -r .access_token)

export GOOGLE_TOKEN=$(curl -sS https://sts.googleapis.com/v1/token \
  --data-urlencode "audience=$GOOGLE_WLOADIF_STS_AUD" \
  --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
  --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
  --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform" \
  --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:jwt" \
  --data-urlencode "subject_token=$KEYCLOAK_TOKEN" \
  --data-urlencode "options={\"userProject\":\"$PROJECT_NUMBER_IDP\"}" | jq -r .access_token)
```

## End user - Workforce Identity Federation (Browser Authorization Code Flow)

Direct Access Grants (Resource Owner Password Credentials, `grant_type=password`) and the OAuth 2.0 Implicit Flow are disabled on `google-wfif-client` and `google-wloadif-client`.

To test end-user federated login:
1. In the Google Cloud Console, navigate to **IAM & Admin -> Workforce Identity Federation** at the Organization level.
2. Open the pool and provider created by this stage and copy the **Sign-in URL**.
3. Open the Sign-in URL in an incognito browser window and sign in with a provisioned Keycloak user (see Section 6 in [../README.md](../README.md)).
