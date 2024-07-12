resource "local_file" "project_numbers_tfvars" {
  content  = <<EOT
prov_project_number_seed=${data.google_project.prov_seed_project.number}
EOT
  filename = "${path.module}/../generated/terraform.prov_project_numbers.auto.tfvars"
  file_permission = 0644
}
