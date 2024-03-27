# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  templates_bqah = {
    "../s3-subscriber/generated/subscribe_bqah.sh" = "../s3-subscriber/templates/subscribe.sh.tpl",
  }
  templates_ah_dedicated = {
    "../s3-subscriber/generated/subscribe_ah_dedicated.sh" = "../s3-subscriber/templates/subscribe.sh.tpl",
  }
  templates_nonvpcsc_ah_dedicated = {
    "../s3-subscriber/generated/subscribe_nonvpcsc_ah_dedicated.sh" = "../s3-subscriber/templates/subscribe.sh.tpl",
  }
}

resource "local_file" "generated_bqah" {
  for_each = local.templates_bqah

  content  = templatefile("${path.module}/${each.value}",
    {
      ah_project_id = data.google_project.bq_and_ah.project_id,
      ah_project_number = data.google_project.bq_and_ah.number,
      scr_vpcsc_project_id = data.google_project.subscr_with_vpcsc.project_id,
      scr_vpcsc_project_number = data.google_project.subscr_with_vpcsc.number,
      scr_project_id = data.google_project.subscr_without_vpcsc.project_id,
      scr_project_number = data.google_project.subscr_without_vpcsc.number,
      generated_path = "${abspath(path.module)}/../s3-subscriber/generated",
      exchange_id = google_bigquery_analytics_hub_data_exchange.bqah_exchange.data_exchange_id,
      listing_id = google_bigquery_analytics_hub_listing.bqah_listing.listing_id,
      location = lower(google_bigquery_analytics_hub_data_exchange.bqah_exchange.location),
      subscriber_sa_email = var.subscriber_sa_email,
    }
  )
  filename = "${path.module}/${each.key}"
  file_permission = 0644
}

resource "local_file" "generated_ah_dedicated" {
  for_each = local.templates_ah_dedicated

  content  = templatefile("${path.module}/${each.value}",
    {
      ah_project_id = data.google_project.ah_exchg.project_id,
      ah_project_number = data.google_project.ah_exchg.number,
      scr_vpcsc_project_id = data.google_project.subscr_with_vpcsc.project_id,
      scr_vpcsc_project_number = data.google_project.subscr_with_vpcsc.number,
      scr_project_id = data.google_project.subscr_without_vpcsc.project_id,
      scr_project_number = data.google_project.subscr_without_vpcsc.number,
      generated_path = "${abspath(path.module)}/../s3-subscriber/generated",
      exchange_id = google_bigquery_analytics_hub_data_exchange.exchange.data_exchange_id,
      listing_id = google_bigquery_analytics_hub_listing.listing.listing_id,
      location = lower(google_bigquery_analytics_hub_data_exchange.exchange.location),
      subscriber_sa_email = var.subscriber_sa_email,
    }
  )
  filename = "${path.module}/${each.key}"
  file_permission = 0644
}

resource "local_file" "generated_nonvpcsc_ah_dedicated" {
  for_each = local.templates_nonvpcsc_ah_dedicated

  content  = templatefile("${path.module}/${each.value}",
    {
      ah_project_id = data.google_project.nonvpcsc_ah_exchg.project_id,
      ah_project_number = data.google_project.nonvpcsc_ah_exchg.number,
      scr_vpcsc_project_id = data.google_project.subscr_with_vpcsc.project_id,
      scr_vpcsc_project_number = data.google_project.subscr_with_vpcsc.number,
      scr_project_id = data.google_project.subscr_without_vpcsc.project_id,
      scr_project_number = data.google_project.subscr_without_vpcsc.number,
      generated_path = "${abspath(path.module)}/../s3-subscriber/generated",
      exchange_id = google_bigquery_analytics_hub_data_exchange.nonvpcsc_exchange.data_exchange_id,
      listing_id = google_bigquery_analytics_hub_listing.nonvpcsc_listing.listing_id,
      location = lower(google_bigquery_analytics_hub_data_exchange.nonvpcsc_exchange.location),
      subscriber_sa_email = var.subscriber_sa_email,
    }
  )
  filename = "${path.module}/${each.key}"
  file_permission = 0644
}
