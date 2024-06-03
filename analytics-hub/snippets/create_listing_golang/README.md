# Golang sample: create_listing_golang

## Regular Data Exchange

1. Create Analytics Hub Exchange if it does not exist
2. Create Analytics Hub Listing if it does not exist
3. Modify Analytics Hub Listing permissions

## Data Clean Room

1. Create Analytics Hub Data Clean Room (Exchange with `sharingEnvironmentConfig.Environment` set to `SharingEnvironmentConfig_DcrExchangeConfig_`)
2. Create a view with analysis policies using BigQuery DDL query job
3. Authorize the created view to query from the shared dataset
4. Create Analytics Hub Data into the Clean Room (Listing with `restrictedExportConfig` and `Source.BigqueryDataset.SelectedResources[0].Resource.Table`)

## Sample run

```
$ ./create_listing_golang \
  -project_id ahd-publ-0429c0-vpcsc-ah \
  -location us \
  -exchange_id ahdemo_golang_exchg \
  -listing_id ahdemo_golang_listing \
  -shared_ds ahdemo_0429c0_shared_ds \
  -restrict_egress false \
  -subscriber_iam_member user:user@domain.com \
  -subscription_viewer_iam_member user:user@domain.com \
  -dcr_shared_table ahdemo_0429c0_shared_table \
  -dcr_privacy_column endpoint \
  -dcr_view view_ahdemo_0429c0_shared_table_go_dcr
```
