resource "google_billing_budget" "customer_project_budget" {
  for_each = google_project.cx_projects

  billing_account = var.cx_billing_account_id
  display_name    = "Budget for ${each.value.name}"

  budget_filter {
    projects = ["projects/${each.value.number}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "100"
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.9
  }
  threshold_rules {
    threshold_percent = 1.0
  }

  depends_on = [google_project.cx_projects]
}