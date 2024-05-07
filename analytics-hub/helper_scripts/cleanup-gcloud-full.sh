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

echo "Deleting publisher projects"
for PROJECT_ID in $PUBL_PROJECT_ID_BQ_SRC_DS $PUBL_PROJECT_ID_BQ_SHARED_DS $PUBL_PROJECT_ID_AH_EXCHG $PUBL_PROJECT_ID_NONVPCSC_AH_EXCHG $PUBL_PROJECT_ID_BQ_AND_AH
do
  echo -n "Deleting project ${PROJECT_ID} ... "
  gcloud projects delete ${PROJECT_ID} --quiet >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    echo "Status: FAILED"
  else
    echo "Status: OK"
  fi
done

echo "Deleting subscriber projects"
for PROJECT_ID in $SUBSCR_PROJECT_ID_WITH_VPCSC $SUBSCR_PROJECT_ID_WITHOUT_VPCSC
do
  echo -n "Deleting project ${PROJECT_ID} ... "
  gcloud projects delete ${PROJECT_ID} --quiet >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    echo "Status: FAILED"
  else
    echo "Status: OK"
  fi
done

echo "Revoking broad org admin privileges from the publisher org"
echo "Revoking broad org admin privileges in $PUBLISHER_ORG_ID from user:$PUBL_ADMIN_USER and serviceAccount:$PUBL_TERRAFORM_SA_EMAIL"
for ADMIN_IAM_MEMBER in "user:$PUBL_ADMIN_USER" "serviceAccount:$PUBL_TERRAFORM_SA_EMAIL"
do
  for ADMIN_IAM_ROLE in "${ADMIN_ROLES[@]}"
  do
    echo -n "Revoke: $ADMIN_IAM_MEMBER -> $ADMIN_IAM_ROLE ... "
    gcloud organizations remove-iam-policy-binding "$PUBLISHER_ORG_ID" --member "$ADMIN_IAM_MEMBER" --role "$ADMIN_IAM_ROLE" >> setup.sh.out 2>&1
    if [ $? -eq 0 ]; then
      echo "OK"
    else
      echo "FAILED"
    fi
  done
done

echo "Revoking broad org admin privileges from the subscriber org"
echo "Revoking broad org admin privileges in $SUBSCRIBER_ORG_ID from user:$SUBSCR_ADMIN_USER and serviceAccount:$SUBSCR_TERRAFORM_SA_EMAIL"
for ADMIN_IAM_MEMBER in "user:$SUBSCR_ADMIN_USER" "serviceAccount:$SUBSCR_TERRAFORM_SA_EMAIL"
do
  for ADMIN_IAM_ROLE in "${ADMIN_ROLES[@]}"
  do
    echo -n "Revoke: $ADMIN_IAM_MEMBER -> $ADMIN_IAM_ROLE ... "
    gcloud organizations remove-iam-policy-binding "$SUBSCRIBER_ORG_ID" --member "$ADMIN_IAM_MEMBER" --role "$ADMIN_IAM_ROLE" >> setup.sh.out 2>&1
    if [ $? -eq 0 ]; then
      echo "OK"
    else
      echo "FAILED"
    fi
  done
done

echo -n "Deleting the terraform service account ($PUBL_TERRAFORM_SA_EMAIL) ... "
gcloud iam service-accounts delete $PUBL_TERRAFORM_SA_EMAIL --project ${PUBL_PROJECT_ID_SEED} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo -n "Deleting the terraform service account ($SUBSCR_TERRAFORM_SA_EMAIL) ... "
gcloud iam service-accounts delete $SUBSCR_TERRAFORM_SA_EMAIL --project ${SUBSCR_PROJECT_ID_SEED} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo -n "Deleting terraform state bucket $PUBL_STATE_BUCKET_URL ... "
gcloud storage rm -r $PUBL_STATE_BUCKET_URL >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo -n "Deleting terraform state bucket $SUBSCR_STATE_BUCKET_URL ... "
gcloud storage rm -r $SUBSCR_STATE_BUCKET_URL >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo "Deleting the seed projects"
echo -n "Deleting project ${PUBL_PROJECT_ID_SEED} ... "
gcloud projects delete ${PUBL_PROJECT_ID_SEED} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo -n "Deleting project ${SUBSCR_PROJECT_ID_SEED} ... "
gcloud projects delete ${SUBSCR_PROJECT_ID_SEED} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo "Deleting the generated terraform configuration ... "
for TF_CFG in "./s0-publ-bootstrap/backend.tf" "./s0-subscr-bootstrap/backend.tf" "./generated/terraform.auto.tfvars" "./s1-publ-vpc-sc/backend.tf" "./s2-publ-bigquery-analyticshub/backend.tf" "./s3-subscr-subscriber-projects/backend.tf"
do
  echo "- $TF_CFG"
  rm $TF_CFG
done

echo "Removing terraform local files ..."
for TF_LOCAL_FILE in "./s0-bootstrap/.terraform" "./s0-bootstrap/.terraform.lock.hcl" "./s1-vpc-sc/.terraform" "./s1-vpc-sc/.terraform.lock.hcl" "./s2-bigquery-analyticshub/.terraform" "./s2-bigquery-analyticshub/.terraform.lock.hcl" "./s3-subscriber/.terraform" "./s3-subscriber/.terraform.lock.hcl"
do
  echo "- $TF_LOCAL_FILE"
  rm -rf $TF_LOCAL_FILE
done
