# Test login

Both `google-wloadif-client` and `google-wfif-client` disable the OAuth 2.0 Implicit Flow (`implicit_flow_enabled = false`), Resource Owner Password Credentials grant (`direct_access_grants_enabled = false`), and plaintext `http://localhost` redirect URIs.

## Service Account — Workload Identity Federation (`client_credentials`)

```bash
curl -sS -X POST "https://$KEYCLOAK_DNS_NAME/realms/google/protocol/openid-connect/token" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$GOOGLE_WLOADIF_CLIENT_ID" \
  --data-urlencode "client_secret=$GOOGLE_WLOADIF_CLIENT_SECRET" \
  --data-urlencode "scope=$GOOGLE_WLOADIF_CLIENT_SCOPE" \
  --data-urlencode "grant_type=client_credentials"
```

## End-user — Workforce Identity Federation (Authorization Code Flow)

Interactive end-user sign-in uses the confidential OAuth 2.0 Authorization Code flow (`response_type=code`) initiated via the Google Cloud Workforce Pool Sign-in URL, redirecting solely to `https://auth.cloud.google/signin-callback/locations/global/workforcePools/<pool>/providers/<provider>`. See Section 6 ("Testing the Solution") in [../README.md](../README.md) for step-by-step browser login instructions.
