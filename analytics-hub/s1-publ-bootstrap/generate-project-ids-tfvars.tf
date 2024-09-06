resource "local_file" "project_numbers_tfvars" {
  content  = <<EOT
publ_project_number_seed=${data.google_project.publ_seed_project.number}
publ_project_number_bq_src_ds=${data.google_project.publ_bq_src_ds.number}
publ_project_number_bq_shared_ds=${data.google_project.publ_bq_shared_ds.number}
publ_project_number_ah_exchg=${data.google_project.publ_ah_exchg.number}
publ_project_number_nonvpcsc_ah_exchg=${data.google_project.publ_nonvpcsc_ah_exchg.number}
publ_project_number_bq_and_ah=${data.google_project.publ_bq_and_ah.number}
publ_root_folder_id=${data.google_project.publ_bq_src_ds.folder_id}
EOT
  filename = "${path.module}/../generated/terraform.publ_project_numbers.auto.tfvars"
  file_permission = 0644
}
