resource "google_artifact_registry_repository" "apprepo" {
  location      = var.sites["fra"].region
  repository_id = "app-repo"
  description   = "Application repository"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "member1" {
  repository = google_artifact_registry_repository.apprepo.name
  role = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.jumphost_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "member2" {
  repository = google_artifact_registry_repository.apprepo.name
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.vm_sa.email}"
}
