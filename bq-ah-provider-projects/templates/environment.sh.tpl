#!/bin/bash

shopt -s expand_aliases

PROJECT_ID="${project_id}"
GENERATED_DIR="${generated_path}"
DB_INSTANCE="${db_instance}"
DB_IP="${db_ip}"
DB_USERNAME="${db_username}"
DNS_NAME="${dns_name}"
GATEWAY_ADDRESS_IP="${gateway_address_ip}"
GATEWAY_ADDRESS_NAME="${gateway_address_name}"
KEYCLOAK_ADMIN_USER="admin"
KEYCLOAK_ADMIN_PW="${keycloak_admin_pw}"
KEYCLOAK_DNS_NAME="keycloak.${dns_name}"
GKE_CLUSTER_NAME="${gke_cluster_name}"
GKE_CLUSTER_LOCATION="${gke_cluster_location}"
GKE_CONTEXT="gke_${project_id}_${gke_cluster_location}_${gke_cluster_name}"
