# Test login

## End-user

```
curl \
  -d "username=jane" \
  -d "password=$TEST_USER_PASSWORD" \
  -d "client_id=$GOOGLE_WLOADIF_CLIENT_ID" \
  -d "client_secret=$GOOGLE_WLOADIF_CLIENT_SECRET" \
  -d "grant_type=password" \
  -d "audience=$GOOGLE_WLOADIF_AUD" \
  "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token"
```

## Service Account (client_id / client_secret)

```
curl \
  -d "client_id=$GOOGLE_WLOADIF_CLIENT_ID" \
  -d "client_secret=$GOOGLE_WLOADIF_CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  -d "audience=$GOOGLE_WLOADIF_AUD" \
  "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token"
```

## Dumpster

```
curl -X GET \
  "https://$KEYCLOAK_DNS_NAME/realms/master/protocol/openid-connect/token?username=admin&password=$KEYCLOAK_ADMIN_PW&client_id=admin-cli&client_secret=admin-cli&grant_type=password"

curl \
  -d "username=admin" \
  -d "password=$KEYCLOAK_ADMIN_PW" \
  -d "client_id=admin-cli" \
  -d "client_secret=admin-cli" \
  -d "grant_type=password" \
  "https://$KEYCLOAK_DNS_NAME/realms/master/protocol/openid-connect/token"

curl -v \
  -d "username=john" \
  -d "password=$GOOGLE_WIF_USER_PASSWORD" \
  -d "client_id=admin-cli" \
  -d "grant_type=password" \
  "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" 2>/dev/null

curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$GOOGLE_WLOADIF_CLIENT_ID" \
  --data-urlencode "client_secret=$GOOGLE_WLOADIF_CLIENT_SECRET" \
  --data-urlencode "scope=$GOOGLE_WLOADIF_CLIENT_SCOPE" \
  --data-urlencode 'grant_type=client_credentials'

curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$GOOGLE_WFIF_CLIENT_ID" \
  --data-urlencode "client_secret=$GOOGLE_WFIF_CLIENT_SECRET" \
  --data-urlencode "scope=$GOOGLE_WFIF_CLIENT_SCOPE" \
  --data-urlencode 'grant_type=client_credentials'

curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$GOOGLE_WFIF_CLIENT_ID" \
  --data-urlencode "client_secret=$GOOGLE_WFIF_CLIENT_SECRET" \
  --data-urlencode 'grant_type=password' \
  --data-urlencode "scope=$GOOGLE_WFIF_CLIENT_SCOPE" \
  --data-urlencode 'username=john' \
  --data-urlencode "password=$TEST_USER_PASSWORD"

curl -L -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$GOOGLE_WFIF_CLIENT_ID" \
  --data-urlencode "client_secret=$GOOGLE_WFIF_CLIENT_SECRET" \
  --data-urlencode 'grant_type=password' \
  --data-urlencode 'scope=openid' \
  --data-urlencode 'username=john' \
  --data-urlencode "password=$TEST_USER_PASSWORD"
```
