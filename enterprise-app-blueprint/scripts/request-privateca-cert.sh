#!/bin/bash

# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail
umask 077

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <project_id> <ca_location> <ca_pool_name> <fqdn> [output_dir]" >&2
  echo "Example: $0 my-project-id europe-west3 my-pool web1.entapp.mydomain.tld ./certs" >&2
  exit 1
fi

PROJECT_ID="$1"
CA_LOCATION="$2"
CA_POOL="$3"
FQDN="$4"
OUT_DIR="${5:-.}"

CERT_ID="$(echo "${FQDN}" | tr '.' '-')-$(date +%Y%m%d%H%M%S)"
mkdir -p "${OUT_DIR}"
chmod 700 "${OUT_DIR}"

KEY_FILE="${OUT_DIR}/${FQDN}.key.pem"
CERT_FILE="${OUT_DIR}/${FQDN}.crt.pem"

gcloud privateca certificates create "${CERT_ID}" \
  --project="${PROJECT_ID}" \
  --issuer-pool="${CA_POOL}" \
  --issuer-location="${CA_LOCATION}" \
  --generate-key \
  --key-output-file="${KEY_FILE}" \
  --cert-output-file="${CERT_FILE}" \
  --dns-san="${FQDN}" \
  --subject="CN=${FQDN}, O=Enterprise" \
  --validity="P365D"

chmod 600 "${KEY_FILE}"
chmod 644 "${CERT_FILE}"

echo "Generated private key (${KEY_FILE}, mode 0600) and signed certificate (${CERT_FILE})."
