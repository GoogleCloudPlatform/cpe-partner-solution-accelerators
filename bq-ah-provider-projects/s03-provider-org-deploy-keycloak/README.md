# PostgreSQL permissions

## Manual

```
postgres=> GRANT ALL PRIVILEGES ON DATABASE keycloak TO "keycloak-jm5@isv-coe-predy-00.iam";
GRANT
postgres=> \c keycloak
keycloak=> GRANT ALL ON SCHEMA public TO "keycloak-jm5@isv-coe-predy-00.iam";
GRANT
keycloak=> \q
```

## Scripted

```
. ./generated/environment.sh
. ./generated/environment_keycloak.sh

kubectl run cloudsql-keycloak-init --env PGPASSWORD="$KEYCLOAK_ADMIN_PW" --image postgres --command psql -- --host $DB_IP --port 5432 -U postgres -d keycloak -c 'GRANT ALL PRIVILEGES ON SCHEMA public TO "$DB_USERNAME";'
kubectl run cloudsql-keycloak-init --env PGPASSWORD="$KEYCLOAK_ADMIN_PW" --image postgres --command psql -- --host $DB_IP --port 5432 -U postgres -c 'GRANT ALL ON DATABASE keycloak TO "$DB_USERNAME";'
```
