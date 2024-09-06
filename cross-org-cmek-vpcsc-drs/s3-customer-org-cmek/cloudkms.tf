resource "google_kms_key_ring" "key_ring" {
  project  = data.google_project.cust_seed_project.project_id
  location = var.region
  name     = var.cust_cmek_keyring_name
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = var.cust_cmek_key_name
  key_ring = google_kms_key_ring.key_ring.id
}

resource "google_kms_key_ring_iam_member" "key_ring_provider_compute_sa" {
  key_ring_id = google_kms_key_ring.key_ring.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member      = "serviceAccount:service-${var.prov_project_number_seed}@compute-system.iam.gserviceaccount.com"
}

resource "google_kms_key_ring_iam_member" "key_ring_provider_users" {
  for_each    = toset( ["user:${var.gcloud_user}", "user:${var.prov_admin_user}"] )

  key_ring_id = google_kms_key_ring.key_ring.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member      = each.value
}
