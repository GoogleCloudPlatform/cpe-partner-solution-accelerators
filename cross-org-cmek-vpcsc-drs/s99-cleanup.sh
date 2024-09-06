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

echo -n "Deleting terraform state bucket $PROV_STATE_BUCKET_URL ... "
gcloud storage rm -r $PROV_STATE_BUCKET_URL >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo -n "Deleting terraform state bucket $CUST_STATE_BUCKET_URL ... "
gcloud storage rm -r $CUST_STATE_BUCKET_URL >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo "Deleting the seed projects"
echo -n "Deleting project ${PROV_PROJECT_ID_SEED} ... "
gcloud projects delete ${PROV_PROJECT_ID_SEED} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo -n "Deleting project ${CUST_PROJECT_ID_SEED} ... "
gcloud projects delete ${CUST_PROJECT_ID_SEED} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo "Deleting the generated terraform configuration ... "
echo "- ./generated/terraform.auto.tfvars"
echo "- ./generated/terraform.cust_project_numbers.auto.tfvars"
echo "- ./generated/terraform.prov_project_numbers.auto.tfvars"
rm "./generated/terraform.auto.tfvars"
rm "./generated/terraform.cust_project_numbers.auto.tfvars"
rm "./generated/terraform.prov_project_numbers.auto.tfvars"
for TF_CFG_TPL in "${TF_GEN_CONFIGS[@]}"
do
  SRC="$TF_CFG_TPL"
  DST="${TF_CFG_TPL/\.tpl/}"
  echo "- $DST"
  rm $DST
done

echo "Removing terraform local files ..."
for STAGE_DIR in "${STAGE_DIRS[@]}"
do
  echo "- $STAGE_DIR/{.terraform/,.terraform.lock.hcl}"
  rm -rf "$STAGE_DIR/"{.terraform/,.terraform.lock.hcl}
done
