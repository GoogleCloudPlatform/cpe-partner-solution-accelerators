#!/bin/bash

. ./generate-letsencrypt-key-cert.env

docker run -it --rm --name certbot \
  -v "${PWD}/../work/letsencrypt/etc:/etc/letsencrypt" \
  -v "${PWD}/../work/letsencrypt/varlib:/var/lib/letsencrypt" \
  -v "${PWD}/../work/letsencrypt/varlog:/var/log/letsencrypt" \
  certbot/dns-google \
  certonly --dns-google --dns-google-project "$DNS_PROJECT_ID" -d "$CERTBOT_DOMAIN" -m "$CERTBOT_EMAIL" --agree-tos -n
