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
. ./generated/terraform.publ_project_numbers.auto.tfvars
. ./generated/terraform.subscr_project_numbers.auto.tfvars

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

echo "Deleting publisher projects"
PUBL_PROJECTS=("$PUBL_PROJECT_ID_BQ_FED_DS" "$PUBL_PROJECT_ID_BQ_SRC_DS" "$PUBL_PROJECT_ID_BQ_SHARED_DS" "$PUBL_PROJECT_ID_AH_EXCHG" "$PUBL_PROJECT_ID_NONVPCSC_AH_EXCHG" "$PUBL_PROJECT_ID_BQ_AND_AH")
for PROJECT in "${PUBL_PROJECTS[@]}"
do
  echo -n "Deleting project ${PROJECT} ... "
  gcloud projects delete ${PROJECT} --quiet >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    echo "Status: FAILED"
  else
    echo "Status: OK"
  fi
done

echo -n "Deleting publisher root folder ${publ_root_folder_id} ... "
gcloud resource-manager folders delete ${publ_root_folder_id} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo "Deleting subscriber projects"
for LIEN in $(gcloud alpha resource-manager liens list --project $SUBSCR_PROJECT_ID_XPN --format 'table[no-heading](name)' --filter "origin=xpn.googleapis.com" )
do
  echo -n "Deleting XPN lien on project ${SUBSCR_PROJECT_ID_XPN} - $LIEN ... "
  gcloud alpha resource-manager liens delete --project $SUBSCR_PROJECT_ID_XPN $LIEN --quiet >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    echo "Status: FAILED"
  else
    echo "Status: OK"
  fi
done

SUBSCR_PROJECTS=("$SUBSCR_PROJECT_ID_WITH_VPCSC" "$SUBSCR_PROJECT_ID_WITHOUT_VPCSC" "$SUBSCR_PROJECT_ID_XPN" "$SUBSCR_PROJECT_ID_VM")
for PROJECT in "${SUBSCR_PROJECTS[@]}"
do
  echo -n "Deleting project ${PROJECT} ... "
  gcloud projects delete ${PROJECT} --quiet >> setup.sh.out 2>&1
  if [ $? -gt 0 ]; then
    echo "Status: FAILED"
  else
    echo "Status: OK"
  fi
done

echo -n "Deleting subscriber root folder ${subscr_root_folder_id} ... "
gcloud resource-manager folders delete ${subscr_root_folder_id} --quiet >> setup.sh.out 2>&1
if [ $? -gt 0 ]; then
  echo "Status: FAILED"
else
  echo "Status: OK"
fi

echo "Deleting the generated terraform configuration ... "
echo "- ./generated/terraform.auto.tfvars"
rm "./generated/terraform.auto.tfvars"
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
