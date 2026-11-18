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

resource "google_privateca_ca_pool" "default" {
  name     = "my-pool"
  location = var.sites["fra"].region
  tier     = "ENTERPRISE"

  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }

  issuance_policy {
    identity_constraints {
      allow_subject_passthrough           = true
      allow_subject_alt_names_passthrough = true
    }

    baseline_values {
      ca_options {
        is_ca = false
      }
      key_usage {
        base_key_usage {
          digital_signature  = true
          content_commitment = true
          key_encipherment   = true
          data_encipherment  = true
          key_agreement      = true
          cert_sign          = false
          crl_sign           = false
          decipher_only      = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = true
          email_protection = true
          code_signing     = true
          time_stamping    = true
        }
      }
    }
  }
}

resource "google_privateca_certificate_authority" "default" {
  certificate_authority_id = "my-ca"
  location                 = var.sites["fra"].region
  pool                     = google_privateca_ca_pool.default.name
  config {
    subject_config {
      subject {
        country_code        = "us"
        organization        = "acme"
        organizational_unit = "enterprise"
        locality            = "locality"
        province            = "province"
        street_address      = "street address"
        postal_code         = "12345"
        common_name         = "ca.${trimsuffix(var.dns_custom_domain, ".")}"
      }
    }
    x509_config {
      ca_options {
        is_ca = true
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign  = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
      name_constraints {
        critical            = true
        permitted_dns_names = ["*.${trimsuffix(var.dns_custom_domain, ".")}", "*.${trimsuffix(var.ad_dns_domain, ".")}"]
        permitted_ip_ranges = ["10.0.0.0/8"]
        permitted_uris      = [".${trimsuffix(var.dns_custom_domain, ".")}", ".${trimsuffix(var.ad_dns_domain, ".")}"]
      }
    }
  }
  type = "SELF_SIGNED"
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }

  // Disable CA deletion related safe checks for easier cleanup.
  deletion_protection                    = false
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true
}
