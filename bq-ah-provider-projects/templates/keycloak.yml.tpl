apiVersion: v1
kind: Namespace
metadata:
  name: keycloak
  labels:
    shared-gateway-access: "true"
---
kind: Gateway
apiVersion: gateway.networking.k8s.io/v1beta1
metadata:
  name: predy-gw
  namespace: default
  annotations:
    networking.gke.io/certmap: managed-zone-crt-map
spec:
  gatewayClassName: gke-l7-global-external-managed
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels:
            shared-gateway-access: "true"
  addresses:
  - type: NamedAddress
    value: ${gateway_address_name}
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: keycloak-httproute
  namespace: keycloak
spec:
  hostnames:
  - "keycloak.${dns_name}"
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: predy-gw
    namespace: default
  rules:
  - backendRefs:
    - group: ""
      kind: Service
      name: keycloak
      port: 8443
      weight: 1
    matches:
    - path:
        type: PathPrefix
        value: /
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  ports:
    - name: https
      port: 8443
      targetPort: 8443
      appProtocol: HTTPS
  selector:
    app: keycloak
  type: ClusterIP
---
apiVersion: networking.gke.io/v1
kind: HealthCheckPolicy
metadata:
  name: keycloak-healthcheck
  namespace: keycloak
spec:
  default:
    checkIntervalSec: 15
    timeoutSec: 5
    healthyThreshold: 2
    unhealthyThreshold: 2
    logConfig:
      enabled: true
    config:
      type: "HTTPS"
      httpsHealthCheck:
        port: 8443
        requestPath: /health/live
  targetRef:
    group: ""
    kind: Service
    name: keycloak
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    iam.gke.io/gcp-service-account: ${keycloak_google_sa}
  name: keycloak
  namespace: keycloak
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      serviceAccountName: keycloak
      containers:
        - name: keycloak
          image: ${keycloak_image_name}
          args:
            - "start"
            - "--proxy-headers"
            - "xforwarded"
#            - "--log-level"
#            - "DEBUG"
          env:
            - name: KEYCLOAK_ADMIN
              value: "admin"
            - name: KEYCLOAK_ADMIN_PASSWORD
              value: "${keycloak_admin_pw}"
            - name: KC_CACHE
              value: "local"
            - name: KC_DB_URL
              value: "jdbc:postgresql://127.0.0.1:5432/keycloak"
            - name: KC_DB
              value: "postgres"
            - name: KC_DB_USERNAME
              value: "${db_username}"
            - name: KC_DB_PASSWORD
              value: "password"
            - name: KC_HOSTNAME
              value: "keycloak.${dns_name}"
          ports:
            - name: https
              containerPort: 8443
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8443
              scheme: HTTPS
          livenessProbe:
            httpGet:
              path: /health/live
              port: 8443
              scheme: HTTPS
        - name: cloud-sql-proxy
          image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2-alpine
          args:
            - "--private-ip"
            - "--structured-logs"
            - "--auto-iam-authn"
            - "--debug-logs"
            - "--impersonate-service-account"
            - "${db_username}.gserviceaccount.com"
            - "${db_instance}"
          securityContext:
            runAsNonRoot: true
          resources:
            requests:
              memory: "256Mi"
              cpu:    "200m"
