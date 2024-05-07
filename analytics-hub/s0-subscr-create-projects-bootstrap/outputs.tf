output "GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT" {
  description = "GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT"
  value       = google_service_account.terraform_sa.email
}

output "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT" {
  description = "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT"
  value       = google_service_account.terraform_sa.email
}
