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

if [ ! -f setup.env ]; then
  echo "Copy setup.env.example to setup.env and edit, before running this script"
  exit
fi

. ./setup.env

gcloud_check_and_create_project () {
  P_ORG_ID=$1
  P_BILLING_ACCOUNT_ID=$2
  P_PROJECT_ID=$3
  P_EXIT_ON_FAIL=$4

  echo -n "Checking project ${P_PROJECT_ID} ... "
  gcloud projects describe ${P_PROJECT_ID} >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    echo "Status: FAILED"
    echo -n "Creating project ${P_PROJECT_ID} ... "
    gcloud projects create ${P_PROJECT_ID} --organization=$P_ORG_ID >> setup.sh.out 2>&1
    if [ $? -gt 0 ]; then
      echo "Status: FAILED"
      if [ $P_EXIT_ON_FAIL = true ]; then
        exit
      fi
    else
      sleep 1
      echo "Status: OK"
      echo -n "Linking billing account ... "
      gcloud billing projects link $P_PROJECT_ID --billing-account $P_BILLING_ACCOUNT_ID >> setup.sh.out 2>&1
      if [ $? -gt 0 ]; then
        echo "Status: FAILED"
        exit
      else
        echo "Status: OK"
      fi
    fi
  else
    echo "Status: OK"
  fi
}

gcloud_check_and_create_state_bucket() {
  P_STATE_BUCKET_URL=$1
  P_PROJECT_ID=$2
  P_REGION=$3

  gcloud storage buckets describe $P_STATE_BUCKET_URL >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    gcloud storage buckets create --project $P_PROJECT_ID --location $P_REGION $P_STATE_BUCKET_URL >> setup.sh.out 2>&1
    if [ $? -gt 0 ]; then
      echo "Status: FAILED. Reason: Failed to create bucket"
    else
      echo "Status: CREATED"
    fi
  else
    echo "Status: OK"
  fi
}

echo "Started: $(date)" > setup.sh.out

echo "Checking seed projects ${PUBL_PROJECT_ID_SEED} ${SUBSCR_PROJECT_ID_SEED} ... "
gcloud_check_and_create_project $PUBLISHER_ORG_ID $BILLING_ACCOUNT_ID $PUBL_PROJECT_ID_SEED true
gcloud_check_and_create_project $SUBSCRIBER_ORG_ID $BILLING_ACCOUNT_ID $SUBSCR_PROJECT_ID_SEED true

for GOOGLE_API_SERVICE in "cloudresourcemanager.googleapis.com" "accesscontextmanager.googleapis.com" "iam.googleapis.com" "cloudbilling.googleapis.com" "orgpolicy.googleapis.com"
do
  for PROJECT_ID_SEED in "$PUBL_PROJECT_ID_SEED" "$SUBSCR_PROJECT_ID_SEED"
  do
    echo "Enabling $GOOGLE_API_SERVICE on seed project ${PROJECT_ID_SEED} ... "
    gcloud services enable $GOOGLE_API_SERVICE --project $PROJECT_ID_SEED >> setup.sh.out 2>&1
  done
done

echo -n "Checking terraform state bucket $PUBL_STATE_BUCKET_URL ... "
gcloud_check_and_create_state_bucket $PUBL_STATE_BUCKET_URL $PUBL_PROJECT_ID_SEED $REGION
echo -n "Checking terraform state bucket $SUBSCR_STATE_BUCKET_URL ... "
gcloud_check_and_create_state_bucket $SUBSCR_STATE_BUCKET_URL $SUBSCR_PROJECT_ID_SEED $REGION

echo "Finished: $(date)" >> setup.sh.out
