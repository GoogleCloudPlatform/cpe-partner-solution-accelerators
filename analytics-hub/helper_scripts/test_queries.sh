#!/bin/bash

. ../setup.env

TOKEN=$(gcloud auth print-access-token --impersonate-service-account $SUBSCR_SUBSCRIBER_SA_EMAIL)

query_bq() {
  PROJECT_ID="$1"
  QUERY="$2"
  curl "https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/queries" \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -d "{\"query\":\"$QUERY\", \"maxResults\":3, \"useLegacySql\": false}" \
    --compressed 2>/dev/null
}

get_datasets_from_subscriptions() {
  PROJECT_ID=$1

  curl -H "Authorization: Bearer $TOKEN" "https://analyticshub.googleapis.com/v1/projects/${PROJECT_ID}/locations/us/subscriptions" 2>/dev/null \
    | jq -r 'try .subscriptions[]? | 
select(.state == "STATE_ACTIVE") | 
[
  ((.linkedDatasetMap | to_entries[0].value.linkedDataset | scan("projects/[0-9]+/datasets/(.*)")[0]))
] | @tsv'
}

get_tables_from_datasets() {
  PROJECT_ID=$1
  DATASET=$2

  curl -H "Authorization: Bearer $TOKEN" "https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/${DATASET}/tables" 2>/dev/null \
    | jq -r 'try .tables[]? | 
[
  .tableReference.tableId
] | @tsv'
}

for SUBSCR_PROJECT_ID in "${SUBSCR_PROJECT_ID_WITH_VPCSC}" "${SUBSCR_PROJECT_ID_WITHOUT_VPCSC}"
do
  for BQ_DATASET in $(get_datasets_from_subscriptions "$SUBSCR_PROJECT_ID")
  do
    echo "$SUBSCR_PROJECT_ID.$BQ_DATASET"
    for BQ_TABLE in $(get_tables_from_datasets "$SUBSCR_PROJECT_ID" "$BQ_DATASET")
    do
      echo -n "$SUBSCR_PROJECT_ID.$BQ_DATASET.$BQ_TABLE        "
      QUERY="SELECT * FROM \`$SUBSCR_PROJECT_ID.$BQ_DATASET.$BQ_TABLE\` LIMIT 3"
      query_bq "$SUBSCR_PROJECT_ID" "$QUERY" | jq 'if has("error") then "ERROR/" + (.error.code | tostring) + "/" +  .error.message else "OK/totalRows/" + .totalRows end'
    done
    echo ""
  done
done
