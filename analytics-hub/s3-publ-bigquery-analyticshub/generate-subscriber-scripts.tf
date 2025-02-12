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
  gen_scripts = {
    priv_bqah = {
      dst = "../generated/subscribe_priv_bqah.sh",
      vars = {
        ah_project_id = data.google_project.publ_bq_and_ah.project_id,
        ah_project_number = data.google_project.publ_bq_and_ah.number,
        scr_vpcsc_project_id = var.subscr_project_id_subscr_with_vpcsc,
        scr_vpcsc_project_number = var.subscr_project_number_subscr_with_vpcsc,
        scr_nonvpcsc_project_id = var.subscr_project_id_subscr_without_vpcsc,
        scr_nonvpcsc_project_number = var.subscr_project_number_subscr_without_vpcsc,
        generated_path = "${abspath(path.module)}/../generated",
        exchange_id = google_bigquery_analytics_hub_data_exchange.bqah_exchange.data_exchange_id,
        listing_id = google_bigquery_analytics_hub_listing.bqah_listing.listing_id,
        location = lower(google_bigquery_analytics_hub_data_exchange.bqah_exchange.location),
        subscriber_sa_email = var.subscr_subscriber_sa_email,
      }
    }
    priv_ah_dedicated = {
      dst = "../generated/subscribe_priv_ah_dedicated.sh",
      vars = {
        ah_project_id = data.google_project.publ_ah_exchg.project_id,
        ah_project_number = data.google_project.publ_ah_exchg.number,
        scr_vpcsc_project_id = var.subscr_project_id_subscr_with_vpcsc,
        scr_vpcsc_project_number = var.subscr_project_number_subscr_with_vpcsc,
        scr_nonvpcsc_project_id = var.subscr_project_id_subscr_without_vpcsc,
        scr_nonvpcsc_project_number = var.subscr_project_number_subscr_without_vpcsc,
        generated_path = "${abspath(path.module)}/../generated",
        exchange_id = google_bigquery_analytics_hub_data_exchange.exchange.data_exchange_id,
        listing_id = google_bigquery_analytics_hub_listing.listing.listing_id,
        location = lower(google_bigquery_analytics_hub_data_exchange.exchange.location),
        subscriber_sa_email = var.subscr_subscriber_sa_email,
      }
    }
    priv_nonvpcsc_ah_dedicated = {
      dst = "../generated/subscribe_priv_nonvpcsc_ah_dedicated.sh"
      vars = {
        ah_project_id = data.google_project.publ_nonvpcsc_ah_exchg.project_id,
        ah_project_number = data.google_project.publ_nonvpcsc_ah_exchg.number,
        scr_vpcsc_project_id = var.subscr_project_id_subscr_with_vpcsc,
        scr_vpcsc_project_number = var.subscr_project_number_subscr_with_vpcsc,
        scr_nonvpcsc_project_id = var.subscr_project_id_subscr_without_vpcsc,
        scr_nonvpcsc_project_number = var.subscr_project_number_subscr_without_vpcsc,
        generated_path = "${abspath(path.module)}/../generated",
        exchange_id = google_bigquery_analytics_hub_data_exchange.nonvpcsc_exchange.data_exchange_id,
        listing_id = google_bigquery_analytics_hub_listing.nonvpcsc_listing.listing_id,
        location = lower(google_bigquery_analytics_hub_data_exchange.nonvpcsc_exchange.location),
        subscriber_sa_email = var.subscr_subscriber_sa_email,
      }
    }
    publ_bqah = {
      dst = "../generated/subscribe_publ_bqah.sh"
      vars = {
        ah_project_id = data.google_project.publ_bq_and_ah.project_id,
        ah_project_number = data.google_project.publ_bq_and_ah.number,
        scr_vpcsc_project_id = var.subscr_project_id_subscr_with_vpcsc,
        scr_vpcsc_project_number = var.subscr_project_number_subscr_with_vpcsc,
        scr_nonvpcsc_project_id = var.subscr_project_id_subscr_without_vpcsc,
        scr_nonvpcsc_project_number = var.subscr_project_number_subscr_without_vpcsc,
        generated_path = "${abspath(path.module)}/../generated",
        exchange_id = google_bigquery_analytics_hub_data_exchange.bqah_public_exchange.data_exchange_id,
        listing_id = google_bigquery_analytics_hub_listing.bqah_public_listing.listing_id,
        location = lower(google_bigquery_analytics_hub_data_exchange.bqah_public_exchange.location),
        subscriber_sa_email = var.subscr_subscriber_sa_email,
      }
    }
    publ_ah_dedicated = {
      dst = "../generated/subscribe_publ_ah_dedicated.sh"
      vars = {
        ah_project_id = data.google_project.publ_ah_exchg.project_id,
        ah_project_number = data.google_project.publ_ah_exchg.number,
        scr_vpcsc_project_id = var.subscr_project_id_subscr_with_vpcsc,
        scr_vpcsc_project_number = var.subscr_project_number_subscr_with_vpcsc,
        scr_nonvpcsc_project_id = var.subscr_project_id_subscr_without_vpcsc,
        scr_nonvpcsc_project_number = var.subscr_project_number_subscr_without_vpcsc,
        generated_path = "${abspath(path.module)}/../generated",
        exchange_id = google_bigquery_analytics_hub_data_exchange.public_exchange.data_exchange_id,
        listing_id = google_bigquery_analytics_hub_listing.public_listing.listing_id,
        location = lower(google_bigquery_analytics_hub_data_exchange.public_exchange.location),
        subscriber_sa_email = var.subscr_subscriber_sa_email,
      }
    }
    publ_nonvpcsc_ah_dedicated = {
      dst = "../generated/subscribe_publ_nonvpcsc_ah_dedicated.sh"
      vars = {
        ah_project_id = data.google_project.publ_nonvpcsc_ah_exchg.project_id,
        ah_project_number = data.google_project.publ_nonvpcsc_ah_exchg.number,
        scr_vpcsc_project_id = var.subscr_project_id_subscr_with_vpcsc,
        scr_vpcsc_project_number = var.subscr_project_number_subscr_with_vpcsc,
        scr_nonvpcsc_project_id = var.subscr_project_id_subscr_without_vpcsc,
        scr_nonvpcsc_project_number = var.subscr_project_number_subscr_without_vpcsc,
        generated_path = "${abspath(path.module)}/../generated",
        exchange_id = google_bigquery_analytics_hub_data_exchange.nonvpcsc_public_exchange.data_exchange_id,
        listing_id = google_bigquery_analytics_hub_listing.nonvpcsc_public_listing.listing_id,
        location = lower(google_bigquery_analytics_hub_data_exchange.nonvpcsc_public_exchange.location),
        subscriber_sa_email = var.subscr_subscriber_sa_email,
      }
    }
  }
}

resource "local_file" "generated_bqah" {
  for_each = local.gen_scripts

  content  = templatefile("${path.module}/../templates/subscribe.sh.tpl", each.value.vars)
  filename = "${path.module}/${each.value.dst}"
  file_permission = 0644
}

resource "local_file" "subscribe_tfvars" {
  content  = <<EOT
ah_project_id="${data.google_project.publ_bq_and_ah.project_id}"
ah_project_number="${data.google_project.publ_bq_and_ah.number}"
ah_exchange_id="${google_bigquery_analytics_hub_data_exchange.bqah_exchange.id}"
ah_listing_id="${google_bigquery_analytics_hub_listing.bqah_listing.id}"
ah_exchange_name="${google_bigquery_analytics_hub_data_exchange.bqah_exchange.data_exchange_id}"
ah_listing_name="${google_bigquery_analytics_hub_listing.bqah_listing.listing_id}"
ah_location="${lower(google_bigquery_analytics_hub_data_exchange.bqah_exchange.location)}"
EOT
  filename = "${path.module}/../s5-subscr-subscribe/terraform.publ_ahlistings.auto.tfvars"
  file_permission = 0644
}
