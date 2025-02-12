#!/bin/bash

. ../setup.env

TOKEN=$(gcloud auth print-access-token --impersonate-service-account $SUBSCR_SUBSCRIBER_SA_EMAIL)

for SUBSCR_PROJECT in "${SUBSCR_PROJECT_ID_WITH_VPCSC}" "${SUBSCR_PROJECT_ID_WITHOUT_VPCSC}"
do
  for SUBSCRIPTION_ID in $(curl -H "Authorization: Bearer $TOKEN" "https://analyticshub.googleapis.com/v1/projects/${SUBSCR_PROJECT}/locations/${REGION}/subscriptions" 2>/dev/null | jq -r '.subscriptions[]? | (.name)')
  do
    curl -X DELETE -H "Authorization: Bearer $TOKEN" "https://analyticshub.googleapis.com/v1/$SUBSCRIPTION_ID"
  done
done
