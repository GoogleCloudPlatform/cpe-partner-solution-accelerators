output "compute_service_sa" {
  description = "compute.googleapis.com service agent SA"
  value       = "serviceAccount:service-${data.google_project.prov_seed_project.number}@compute-system.iam.gserviceaccount.com"
}
