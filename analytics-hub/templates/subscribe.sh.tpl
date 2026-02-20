#!/bin/bash

ah_project_id="${ah_project_id}"
ah_project_number="${ah_project_number}"
scr_vpcsc_project_number="${scr_vpcsc_project_number}"
scr_nonvpcsc_project_number="${scr_nonvpcsc_project_number}"
generated_path="${generated_path}"
exchange_id="${exchange_id}"
listing_id="${listing_id}"
location="${location}"
subscriber_sa_email="${subscriber_sa_email}"

TOKEN=$(gcloud auth print-access-token --impersonate-service-account ${subscriber_sa_email})

# Linked Dataset project: ${scr_nonvpcsc_project_number} / ${scr_nonvpcsc_project_id}
curl -v --request POST \
  'https://analyticshub.googleapis.com/v1/projects/${ah_project_number}/locations/${location}/dataExchanges/${exchange_id}/listings/${listing_id}:subscribe' \
  --header "Authorization: Bearer $TOKEN" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"destinationDataset":{"datasetReference":{"datasetId":"${ah_project_number}_${listing_id}","projectId":"${scr_nonvpcsc_project_number}"},"location":"${location}"}}' \
  --compressed

# Linked Dataset project: ${scr_vpcsc_project_number} / ${scr_vpcsc_project_id}
curl -v --request POST \
  'https://analyticshub.googleapis.com/v1/projects/${ah_project_number}/locations/${location}/dataExchanges/${exchange_id}/listings/${listing_id}:subscribe' \
  --header "Authorization: Bearer $TOKEN" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"destinationDataset":{"datasetReference":{"datasetId":"${ah_project_number}_${listing_id}","projectId":"${scr_vpcsc_project_number}"},"location":"${location}"}}' \
  --compressed

curl -v --request DELETE \
  'https://bigquery.googleapis.com/bigquery/v2/projects/${scr_nonvpcsc_project_number}/datasets/${ah_project_number}_${listing_id}' \
  --header "Authorization: Bearer $TOKEN" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json'

curl -v --request DELETE \
  'https://bigquery.googleapis.com/bigquery/v2/projects/${scr_vpcsc_project_number}/datasets/${ah_project_number}_${listing_id}' \
  --header "Authorization: Bearer $TOKEN" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json'
