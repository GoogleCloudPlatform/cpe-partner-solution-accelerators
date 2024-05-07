#!/bin/bash

. ../setup.env

TOKEN=$(gcloud auth print-access-token --impersonate-service-account $SUBSCR_SUBSCRIBER_SA_EMAIL)

for SUBSCR_PROJECT_ID in "${SUBSCR_PROJECT_ID_WITH_VPCSC}" "${SUBSCR_PROJECT_ID_WITHOUT_VPCSC}"
do
#  curl -H "Authorization: Bearer $TOKEN" "https://analyticshub.googleapis.com/v1/projects/${SUBSCR_PROJECT_ID}/locations/us/subscriptions"
  curl -H "Authorization: Bearer $TOKEN" "https://analyticshub.googleapis.com/v1/projects/${SUBSCR_PROJECT_ID}/locations/us/subscriptions" 2>/dev/null | jq -r 'if . | has("subscriptions") then .subscriptions | sort_by(.creationTime)[] | [.creationTime,.name,.listing,(.linkedDatasetMap | to_entries[0].value.linkedDataset),.state ] end'
done

