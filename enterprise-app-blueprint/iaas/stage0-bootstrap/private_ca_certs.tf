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

# Private keys for VM and ADFS machine certificates are intentionally NOT generated
# via Terraform (tls_private_key / local_file) to prevent plaintext private key
# persistence in Terraform state and group-readable local files.
#
# Instead, authorized admin operators or the jumphost service account can request
# leaf machine certificates out-of-band (for example using
# scripts/request-privateca-cert.sh), generating private keys directly on the
# target host with restricted (0600) permissions.
resource "google_privateca_ca_pool_iam_member" "jumphost_cert_requester" {
  ca_pool = google_privateca_ca_pool.default.id
  role    = "roles/privateca.certificateRequester"
  member  = "serviceAccount:${google_service_account.jumphost_sa.email}"
}
