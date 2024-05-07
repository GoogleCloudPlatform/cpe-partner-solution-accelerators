#!/bin/bash

. ../setup.env

TOKEN=$(gcloud auth print-access-token --impersonate-service-account $SUBSCR_SUBSCRIBER_SA_EMAIL)

for SUBSCR_PROJECT in "${SUBSCR_PROJECT_ID_WITH_VPCSC}" "${SUBSCR_PROJECT_ID_WITHOUT_VPCSC}"
do
  curl -H "Authorization: Bearer $TOKEN" "https://bigquery.googleapis.com/bigquery/v2/projects/${SUBSCR_PROJECT}/datasets?all=true"
done
