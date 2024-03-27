$ curl --request POST \
  'https://analyticshub.googleapis.com/v1/projects/cloud-partner-eng-ext-seed/locations/us/dataExchanges/predytest_ah_exchange_18e2dd1e8c1/listings/predytest_ah_public_listing_01_18e2dd3d8d2:subscribe' \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"destinationDataset":{"datasetReference":{"datasetId":"predytest_ah_public_listing_01","projectId":"isv-coe-predy-00"},"location":"us"}}' \
  --compressed
