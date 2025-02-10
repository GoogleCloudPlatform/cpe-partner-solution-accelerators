resource "google_service_account" "regfunc-sa" {
  account_id   = "regfunc-sa"
  display_name = "Service Account for the regfunc Cloud Run deployment"
}

resource "google_project_iam_member" "project_regfunc_sa" {
  count = length(var.regfunc_sa_roles)

  project = data.google_project.project.project_id
  role    = var.regfunc_sa_roles[count.index]
  member  = "serviceAccount:${google_service_account.regfunc-sa.email}"
}

data "google_iam_policy" "regfunc_auth_policy" {
  binding {
    role = "roles/run.invoker"
    members = [
       "allUsers",
#      "serviceAccount:${data.google_service_account.vm_sa.email}",
#      "serviceAccount:${data.google_service_account.vm_sa_adsrv.email}",
#      "serviceAccount:${data.google_service_account.jumphost_sa.email}",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "regfunc_auth_policy" {
  location = google_cloud_run_v2_service.regfunc.location
  name = google_cloud_run_v2_service.regfunc.name

  policy_data = data.google_iam_policy.regfunc_auth_policy.policy_data
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = "vpc-connector"

  subnet {
    name = data.google_compute_subnetwork.vpc_connector["fra"].name
  }
  machine_type = "e2-micro"
  min_instances = 2
  max_instances = 3
}

resource "google_cloud_run_v2_service" "regfunc" {
  name     = "regfunc"
  location = var.sites["fra"].region
  ingress = "INGRESS_TRAFFIC_ALL"

  scaling {
    min_instance_count = 1
  }

  template {
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"

    containers {
      name       = "regfunc-1"
      image      = var.ad_register_image

      env {
        name = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name = "PROJECTS_DN"
        value = var.ad_register_projects_dn
      }
      env {
        name = "AD_DOMAIN"
        value = trimsuffix(var.ad_dns_domain, ".")
      }
      env {
        name = "AD_USERNAME"
        value = var.ad_register_username
      }
#      env {
#        name = "AD_PASSWORD"
#        value = var.ad_register_password
#      }
#      env {
#        name = "AD_DOMAINCONTROLLER"
#        value = var.project_id
#      }
      env {
        name = "SM_PROJECT"
        value = var.project_id
      }
      env {
        name = "SM_NAME_ADPASSWORD"
        value = data.google_secret_manager_secret.secret-register-computer.secret_id
      }
      env {
        name = "SM_VERSION_ADPASSWORD"
        value = "latest"
      }
      env {
        name = "FUNCTION_IDENTITY"
        value = google_service_account.regfunc-sa.email
      }
    }
    vpc_access{
      connector = google_vpc_access_connector.vpc_connector.id
      egress = "ALL_TRAFFIC"
    }
    service_account = google_service_account.regfunc-sa.email
  }

  traffic {
    percent         = 100
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  lifecycle {
    ignore_changes = [
        labels,
        annotations,
        client,
        client_version,
        template[0].labels,
        template[0].revision,
        template[0].annotations,
        template[0].containers[0].image,
        template[0].containers[0].image,
      ]
  }

  deletion_protection = false
}
