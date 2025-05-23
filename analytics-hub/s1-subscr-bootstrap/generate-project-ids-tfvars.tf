resource "local_file" "project_numbers_tfvars" {
  content  = <<EOT
subscr_project_number_seed=${data.google_project.subscr_seed_project.number}
subscr_project_number_subscr_with_vpcsc=${data.google_project.subscr_subscr_with_vpcsc.number}
subscr_project_number_subscr_without_vpcsc=${data.google_project.subscr_subscr_without_vpcsc.number}
subscr_project_number_subscr_xpn=${data.google_project.subscr_subscr_xpn.number}
subscr_project_number_subscr_vm=${data.google_project.subscr_subscr_vm.number}
subscr_root_folder_id=${data.google_project.subscr_subscr_without_vpcsc.folder_id}
EOT
  filename = "${path.module}/../generated/terraform.subscr_project_numbers.auto.tfvars"
  file_permission = 0644
}
