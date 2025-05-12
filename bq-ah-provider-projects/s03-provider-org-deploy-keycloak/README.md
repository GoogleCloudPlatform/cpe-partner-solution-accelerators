# PostgreSQL permissions

## Manual

We are using IAM authentication for CloudSQL, the username format is `<service_account_name>@<project_id>.iam`.

```
postgres=> GRANT ALL PRIVILEGES ON DATABASE keycloak TO "keycloak-jm5@bqprovpr-idp.iam";
GRANT
postgres=> \c keycloak
keycloak=> GRANT ALL ON SCHEMA public TO "keycloak-jm5@bqprovpr-idp.iam";
GRANT
keycloak=> \q
```

## Scripted

```
. ../generated/environment.sh
. ../generated/environment_keycloak.sh

echo "Granting access to $DB_USERNAME"
kubectl run cloudsql-keycloak-init --env PGPASSWORD="$KEYCLOAK_ADMIN_PW"  --env DB_USERNAME="$DB_USERNAME" --env DB_IP="$DB_IP" --image postgres --command=true -- /bin/sh -c 'export SQL="GRANT ALL PRIVILEGES ON SCHEMA public TO \"$DB_USERNAME\";" && echo "$SQL" && psql -h $DB_IP -p 5432 -U postgres -d keycloak -c "$SQL"'
kubectl delete pod cloudsql-keycloak-init
kubectl run cloudsql-keycloak-init --env PGPASSWORD="$KEYCLOAK_ADMIN_PW"  --env DB_USERNAME="$DB_USERNAME" --env DB_IP="$DB_IP" --image postgres --command=true -- /bin/sh -c 'export SQL="GRANT ALL ON DATABASE keycloak TO \"$DB_USERNAME\";" && echo "$SQL" && psql -h $DB_IP -p 5432 -U postgres -d keycloak -c "$SQL"'
kubectl delete pod cloudsql-keycloak-init
```
