output "cmd1" {
  description = "cmd1"
  value       = <<EOT

export GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT="${google_service_account.terraform_sa.email}"
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="${google_service_account.terraform_sa.email}"

EOT
}
