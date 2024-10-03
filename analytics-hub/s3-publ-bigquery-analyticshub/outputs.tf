output "bq_load_commands" {
  description = "bq_load_commands"
  value       = <<EOT

bq --project_id ${data.google_project.publ_bq_shared_ds.project_id} load --source_format NEWLINE_DELIMITED_JSON ${google_bigquery_dataset.private_dataset.dataset_id}.${google_bigquery_table.private_src_table.table_id} gs://${var.publ_tf_state_bucket}/${google_storage_bucket_object.src_table_data_jsonl.name}
bq --project_id ${data.google_project.publ_bq_shared_ds.project_id} load --source_format NEWLINE_DELIMITED_JSON ${google_bigquery_dataset.shared_dataset.dataset_id}.${google_bigquery_table.shared_table.table_id} gs://${var.publ_tf_state_bucket}/${google_storage_bucket_object.shared_table_data_jsonl.name}
bq --project_id ${data.google_project.publ_bq_src_ds.project_id} load --source_format NEWLINE_DELIMITED_JSON ${google_bigquery_dataset.src_dataset.dataset_id}.${google_bigquery_table.src_table.table_id} gs://${var.publ_tf_state_bucket}/${google_storage_bucket_object.src_table_data_jsonl.name}
bq --project_id ${data.google_project.publ_bq_src_ds.project_id} load --source_format NEWLINE_DELIMITED_JSON ${google_bigquery_dataset.src_dataset_authz.dataset_id}.${google_bigquery_table.src_table_authz.table_id} gs://${var.publ_tf_state_bucket}/${google_storage_bucket_object.src_table_data_jsonl.name}
bq --project_id ${data.google_project.publ_bq_and_ah.project_id} load --source_format NEWLINE_DELIMITED_JSON ${google_bigquery_dataset.bqah_shared_dataset.dataset_id}.${google_bigquery_table.bqah_shared_table.table_id} gs://${var.publ_tf_state_bucket}/${google_storage_bucket_object.shared_table_data_jsonl.name}

EOT
}
