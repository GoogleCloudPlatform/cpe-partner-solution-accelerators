#!/bin/bash

# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TOKEN=$(gcloud auth print-access-token)
PROJECT_ID="${PROJECT_ID:=my-test-project-b929dee7}"
EXCHANGE_ID="${EXCHANGE_ID:=ahdemo_api_exchg_dcr}"
LISTING_ID="${LISTING_ID:=view_test_api_dcr}"
DCR_SHARED_DS="${DCR_SHARED_DS:=projects/$PROJECT_ID/datasets/test}"
DCR_SHARED_VIEW="${DCR_SHARED_VIEW:=projects/$PROJECT_ID/datasets/test/tables/view_test_go_dcr}"

EXCHG_REQ='{
  "displayName": "Example Data Clean Room - created using REST API",
  "description": "Example Data Clean Room - created using REST API",
  "documentation": "https://link.to.optional.documentation/",
  "sharingEnvironmentConfig": {
    "dcrExchangeConfig": {}
  }
}'

echo "$EXCHG_REQ" | jq .

curl -v \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-type: application/json" \
 -H "x-goog-user-project: $PROJECT_ID" \
 -X POST \
 -d "$EXCHG_REQ" \
 "https://analyticshub.googleapis.com/v1/projects/$PROJECT_ID/locations/us/dataExchanges?dataExchangeId=$EXCHANGE_ID"


LISTING_REQ='{
      "displayName": "'$LISTING_ID'",
      "primaryContact": "primary@contact.co",
      "bigqueryDataset": {
        "dataset": "'$DCR_SHARED_DS'",
        "selectedResources": [
          {
            "table": "'$DCR_SHARED_VIEW'"
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
    }'

echo "$LISTING_REQ" | jq .

curl -v \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-type: application/json" \
 -H "x-goog-user-project: $PROJECT_ID" \
 -X POST \
 -d "$LISTING_REQ" \
 "https://analyticshub.googleapis.com/v1/projects/$PROJECT_ID/locations/us/dataExchanges/$EXCHANGE_ID/listings?listingId=$LISTING_ID"
