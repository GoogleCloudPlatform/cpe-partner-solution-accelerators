#!/bin/bash

. ../setup.env

TOKEN=$(gcloud auth print-access-token --impersonate-service-account $SUBSCR_SUBSCRIBER_SA_EMAIL)

for SUBSCR_PROJECT in "${SUBSCR_PROJECT_ID_WITH_VPCSC}" "${SUBSCR_PROJECT_ID_WITHOUT_VPCSC}"
do
  for DATASET_ID in $(curl -H "Authorization: Bearer $TOKEN" "https://bigquery.googleapis.com/bigquery/v2/projects/${SUBSCR_PROJECT}/datasets?all=true" | jq -r '.datasets[]? | ("projects/" + .datasetReference.projectId + "/datasets/" + .datasetReference.datasetId)')
  do
    echo "Deleting: $DATASET_ID"
    curl -X DELETE -H "Authorization: Bearer $TOKEN" "https://bigquery.googleapis.com/bigquery/v2/$DATASET_ID"
  done
done
