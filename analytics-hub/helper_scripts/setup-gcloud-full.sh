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

gcloud_check_and_create_service_account () {
  P_SA_PROJECT_ID=$1
  P_SA_NAME=$2
  P_SA_EMAIL=$3
  P_SA_DESCRIPTION=$4

  echo -n "Checking / creating service account ($P_SA_EMAIL) ... "
  gcloud iam service-accounts describe $P_SA_EMAIL --project $P_SA_PROJECT_ID >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    echo "Status: FAILED"
    echo -n "Creating service account ... "
    gcloud iam service-accounts create $P_SA_NAME --project $P_SA_PROJECT_ID --display-name "$P_SA_DESCRIPTION" >> setup.sh.out 2>&1
    if [ $? -gt 0 ]; then
      echo "Status: FAILED"
    else
      echo "Status: OK"
    fi
  else
    echo "Status: OK"
  fi
}

gcloud_grant_org_privileges() {
  P_ORG_ID=$1
  P_ADMIN_USER=$2
  P_TERRAFORM_SA_EMAIL=$3
  echo "Granting broad org admin privileges in $P_ORG_ID to user:$P_ADMIN_USER and serviceAccount:$P_TERRAFORM_SA_EMAIL"
  for ADMIN_IAM_MEMBER in "user:$P_ADMIN_USER" "serviceAccount:$P_TERRAFORM_SA_EMAIL"
  do
    for ADMIN_IAM_ROLE in "${ADMIN_ROLES[@]}"
    do
      echo -n "Grant: $ADMIN_IAM_MEMBER -> $ADMIN_IAM_ROLE ... "
      gcloud organizations add-iam-policy-binding "$P_ORG_ID" --member "$ADMIN_IAM_MEMBER" --role "$ADMIN_IAM_ROLE" >> setup.sh.out 2>&1
      if [ $? -eq 0 ]; then
        echo "OK"
      else
        echo "FAILED"
      fi
      sleep 1
    done
  done
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

for GOOGLE_API_SERVICE in "cloudresourcemanager.googleapis.com" "accesscontextmanager.googleapis.com" "compute.googleapis.com" "iam.googleapis.com" "orgpolicy.googleapis.com"
do
  for PROJECT_ID_SEED in "$PUBL_PROJECT_ID_SEED" "$SUBSCR_PROJECT_ID_SEED"
  do
    echo "Enabling $GOOGLE_API_SERVICE on seed project ${PROJECT_ID_SEED} ... "
    gcloud services enable $GOOGLE_API_SERVICE --project $PROJECT_ID_SEED >> setup.sh.out 2>&1
  done
done

echo "Checking / creating publisher projects in the publisher org ($PUBLISHER_ORG_ID / $PUBLISHER_ORG_NAME)"
for PROJECT_ID in $PUBL_PROJECT_ID_BQ_SRC_DS $PUBL_PROJECT_ID_BQ_SHARED_DS $PUBL_PROJECT_ID_AH_EXCHG $PUBL_PROJECT_ID_NONVPCSC_AH_EXCHG $PUBL_PROJECT_ID_BQ_AND_AH
do
  gcloud_check_and_create_project $PUBLISHER_ORG_ID $BILLING_ACCOUNT_ID $PROJECT_ID true
done

echo "Checking / creating subscriber projects in the subscriber org ($SUBSCRIBER_ORG_ID / $SUBSCRIBER_ORG_NAME)"
for PROJECT_ID in $SUBSCR_PROJECT_ID_WITH_VPCSC $SUBSCR_PROJECT_ID_WITHOUT_VPCSC
do
  gcloud_check_and_create_project $SUBSCRIBER_ORG_ID $BILLING_ACCOUNT_ID $PROJECT_ID true
done

echo "Checking / creating terraform service accounts $PUBL_TERRAFORM_SA_EMAIL $SUBSCR_TERRAFORM_SA_EMAIL ... "
gcloud_check_and_create_service_account $PUBL_PROJECT_ID_SEED $PUBL_TERRAFORM_SA_NAME $PUBL_TERRAFORM_SA_EMAIL "Service Account for Terraform"
gcloud_check_and_create_service_account $SUBSCR_PROJECT_ID_SEED $SUBSCR_TERRAFORM_SA_NAME $SUBSCR_TERRAFORM_SA_EMAIL "Service Account for Terraform"

echo "Granting impersonation on terraform service account $PUBL_TERRAFORM_SA_EMAIL to $TERRAFORM_SA_USER"
gcloud iam service-accounts add-iam-policy-binding $PUBL_TERRAFORM_SA_EMAIL --project $PUBL_PROJECT_ID_SEED --member "user:$TERRAFORM_SA_USER" --role "roles/iam.serviceAccountUser" >> setup.sh.out 2>&1
gcloud iam service-accounts add-iam-policy-binding $PUBL_TERRAFORM_SA_EMAIL --project $PUBL_PROJECT_ID_SEED --member "user:$TERRAFORM_SA_USER" --role "roles/iam.serviceAccountTokenCreator" >> setup.sh.out 2>&1

echo "Granting impersonation on terraform service account $SUBSCR_TERRAFORM_SA_EMAIL to $TERRAFORM_SA_USER"
gcloud iam service-accounts add-iam-policy-binding $SUBSCR_TERRAFORM_SA_EMAIL --project $SUBSCR_PROJECT_ID_SEED --member "user:$TERRAFORM_SA_USER" --role "roles/iam.serviceAccountUser" >> setup.sh.out 2>&1
gcloud iam service-accounts add-iam-policy-binding $SUBSCR_TERRAFORM_SA_EMAIL --project $SUBSCR_PROJECT_ID_SEED --member "user:$TERRAFORM_SA_USER" --role "roles/iam.serviceAccountTokenCreator" >> setup.sh.out 2>&1

echo "Checking / creating subscriber service account ($SUBSCR_SUBSCRIBER_SA_EMAIL) ... "
gcloud_check_and_create_service_account $SUBSCR_PROJECT_ID_SEED $SUBSCR_SUBSCRIBER_SA_NAME $SUBSCR_SUBSCRIBER_SA_EMAIL "Service Account for Subscriber"

echo "Granting impersonation on subscriber service account $SUBSCR_SUBSCRIBER_SA_EMAIL to $SUBSCRIBER_SA_USER"
gcloud iam service-accounts add-iam-policy-binding $SUBSCR_SUBSCRIBER_SA_EMAIL --project $SUBSCR_PROJECT_ID_SEED --member "user:$SUBSCRIBER_SA_USER" --role "roles/iam.serviceAccountUser" >> setup.sh.out 2>&1
gcloud iam service-accounts add-iam-policy-binding $SUBSCR_SUBSCRIBER_SA_EMAIL --project $SUBSCR_PROJECT_ID_SEED --member "user:$SUBSCRIBER_SA_USER" --role "roles/iam.serviceAccountTokenCreator" >> setup.sh.out 2>&1

echo "Granting broad org admin privileges"
gcloud_grant_org_privileges $PUBLISHER_ORG_ID $PUBL_ADMIN_USER $PUBL_TERRAFORM_SA_EMAIL
gcloud_grant_org_privileges $SUBSCRIBER_ORG_ID $SUBSCR_ADMIN_USER $SUBSCR_TERRAFORM_SA_EMAIL

echo -n "Checking terraform state buckets ... "
gcloud_check_and_create_state_bucket $PUBL_STATE_BUCKET_URL $PUBL_PROJECT_ID_SEED $REGION
gcloud_check_and_create_state_bucket $SUBSCR_STATE_BUCKET_URL $SUBSCR_PROJECT_ID_SEED $REGION

echo "[Publisher] set the following environment variables before running terraform so it will impersonate the newly created SA:"
echo "export GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT=\"${PUBL_TERRAFORM_SA_EMAIL}\""
echo "export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=\"${PUBL_TERRAFORM_SA_EMAIL}\""

echo "[Subscriber] set the following environment variables before running terraform so it will impersonate the newly created SA:"
echo "export GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT=\"${SUBSCR_TERRAFORM_SA_EMAIL}\""
echo "export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=\"${SUBSCR_TERRAFORM_SA_EMAIL}\""

echo "Finished: $(date)" >> setup.sh.out
