resource "local_file" "project_numbers_tfvars" {
  content  = <<EOT
cust_project_number_seed=${data.google_project.cust_seed_project.number}
EOT
  filename = "${path.module}/../generated/terraform.cust_project_numbers.auto.tfvars"
  file_permission = 0644
}
