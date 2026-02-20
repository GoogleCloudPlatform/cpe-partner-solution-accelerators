FROM quay.io/keycloak/keycloak:26.5 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build --health-enabled=true --metrics-enabled=true --db postgres

FROM quay.io/keycloak/keycloak:26.5
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
#ENV KC_DB_URL=<DBURL>
#ENV KC_DB_USERNAME=<DBUSERNAME>
#ENV KC_DB_PASSWORD=<DBPASSWORD>
#ENV KC_HOSTNAME=localhost
ENV KC_DB=postgres
ENV KC_DB_URL="jdbc:postgresql://127.0.0.1:5432/keycloak"
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_CACHE=local
ENV KC_BOOTSTRAP_ADMIN_USERNAME=admin
ENTRYPOINT ["sh", "-c", "export KC_BOOTSTRAP_ADMIN_PASSWORD=$(cat /var/secrets/keycloak-admin.pw) && /opt/keycloak/bin/kc.sh start --proxy-headers xforwarded"]
