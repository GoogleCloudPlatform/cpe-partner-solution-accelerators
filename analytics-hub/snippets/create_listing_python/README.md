# GolaPythonng sample: create_listing_python

## Regular Data Exchange

1. Create Analytics Hub Exchange if it does not exist
2. Create Analytics Hub Listing if it does not exist
3. Modify Analytics Hub Listing permissions

## Data Clean Room

1. Create Analytics Hub Data Clean Room (Exchange with `shared_environment_config.dcr_exchange_config` set to `bigquery_analyticshub_v1.SharingEnvironmentConfig.DcrExchangeConfig()`)
2. Create a view with analysis policies using BigQuery DDL query job
3. Authorize the created view to query from the shared dataset
4. Create Analytics Hub Data into the Clean Room (Listing with `restrictedExportConfig` and `listing.bigquery_dataset.selected_resources[0].table`)

## Sample run

```
$ python3 ./main.py \
  --project_id ahd-publ-0429c0-vpcsc-ah \
  --location us \
  --exchange_id ahdemo_python_exchg \
  --listing_id ahdemo_python_listing \
  --shared_ds ahdemo_0429c0_shared_ds \
  --restrict_egress \
  --subscriber_iam_member user:user@domain.com \
  --subscription_viewer_iam_member user:user@domain.com \
  --dcr_shared_table ahdemo_0429c0_shared_table \
  --dcr_privacy_column endpoint \
  --dcr_view view_ahdemo_0429c0_shared_table_python_dcr
```
