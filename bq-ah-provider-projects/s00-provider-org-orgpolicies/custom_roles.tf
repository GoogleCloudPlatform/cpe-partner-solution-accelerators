resource "google_organization_iam_custom_role" "bq-managed-project-user" {
  role_id     = "bq_managed_project_user"
  org_id      = var.prov_org_id
  title       = "bq_managed_project_user"
  description = "bq_managed_project_user"
  permissions = [
    "bigquery.datasets.get",
    "bigquery.datasets.getIamPolicy",
    "bigquery.models.export",
    "bigquery.models.getData",
    "bigquery.models.getMetadata",
    "bigquery.models.list",
    "bigquery.routines.get",
    "bigquery.routines.list",
#    "bigquery.tables.createSnapshot",
#    "bigquery.tables.export",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.getIamPolicy",
    "bigquery.tables.list",
#    "bigquery.tables.replicateData",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list",
  ]
}
