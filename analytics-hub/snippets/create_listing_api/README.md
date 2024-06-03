# API sample: create_listing_api

## Data Clean Room

**Prerequisites**: view with analysis rules created and authorized for the source dataset

1. Create Analytics Hub Data Clean Room (Exchange with `sharingEnvironmentConfig.dcrExchangeConfig`)
2. Create Analytics Hub Data into the Clean Room (Listing with `restrictedExportConfig` and `bigqueryDataset.selectedResources`)

## Create DCR exchange request

Differences to a regular exchange:

* `sharingEnvironmentConfig.dcrExchangeConfig`

REST API: https://cloud.google.com/bigquery/docs/reference/analytics-hub/rest/v1/projects.locations.dataExchanges/create

```
{
  "displayName": "Example Data Clean Room - created using REST API",
  "description": "Example Data Clean Room - created using REST API",
  "documentation": "https://link.to.optional.documentation/",
  "sharingEnvironmentConfig": {
    "dcrExchangeConfig": {}
  }
}
```

## Create DCR listing request

Differences to a regular listing:

* `bigqueryDataset.selectedResources`
* `restrictedExportConfig.restrictDirectTableAccess`
* `restrictedExportConfig.enabled`

REST API: https://cloud.google.com/bigquery/docs/reference/analytics-hub/rest/v1/projects.locations.dataExchanges.listings/create

```
{
  "displayName": "view_test_api_dcr",
  "primaryContact": "primary@contact.co",
  "bigqueryDataset": {
    "dataset": "projects/isv-coe-predy-00/datasets/test",
    "selectedResources": [
      {
        "table": "projects/isv-coe-predy-00/datasets/test/tables/view_test_go_dcr"
      }
    ]
  },
  "dataProvider": {},
  "categories": [
    "CATEGORY_OTHERS"
  ],
  "restrictedExportConfig": {
    "restrictDirectTableAccess": true,
    "enabled": true
  }
}
```

## Sample run

```
export PROJECT_ID=my-project-id
export EXCHANGE_ID=ahdemo_api_exchg_dcr
export LISTING_ID=view_test_api_dcr
export DCR_SHARED_DS=projects/$PROJECT_ID/datasets/test
export DCR_SHARED_VIEW=projects/$PROJECT_ID/datasets/test/tables/view_test_go_dcr

./create_listing.sh

```
