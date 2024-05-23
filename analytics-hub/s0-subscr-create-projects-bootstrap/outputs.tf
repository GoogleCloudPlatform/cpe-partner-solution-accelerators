output "cmd1" {
  description = "cmd1"
  value       = "export GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT=${google_service_account.terraform_sa.email}"
}

output "cmd2" {
  description = "cmd2"
  value       = "export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=${google_service_account.terraform_sa.email}"
}
