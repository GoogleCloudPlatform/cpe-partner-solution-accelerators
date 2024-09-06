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

generate_config () {
  P_SRC=$1
  P_DST=$2

  echo "$P_SRC > $P_DST"

  cat $P_SRC | sed "s/{{SUFFIX}}/$SUFFIX/;
  s/{{DNS_ZONE_NAME}}/$DNS_ZONE_NAME/;
  s/{{DNS_DOMAIN_NAME}}/$DNS_DOMAIN_NAME/;
  s/{{PROV_PROJECT_ID_SEED}}/$PROV_PROJECT_ID_SEED/;
  s/{{PROV_ADMIN_USER}}/$PROV_ADMIN_USER/;
  s/{{PROV_STATE_BUCKET}}/$PROV_STATE_BUCKET/;
  s/{{PROV_ORG_ID}}/$PROV_ORG_ID/;
  s/{{PROV_ORG_NAME}}/$PROV_ORG_NAME/;
  s/{{GCLOUD_USER}}/$GCLOUD_USER/;
  s/{{BILLING_ACCOUNT_ID}}/$BILLING_ACCOUNT_ID/;
  s/{{CX_BILLING_ACCOUNT_ID}}/$CX_BILLING_ACCOUNT_ID/;
  s/{{PROV_PROJECT_ID_PREFIX}}/$PROV_PROJECT_ID_PREFIX/;
  " > "$P_DST"
}

echo "Generating the terraform configuration based on templates ... "
generate_config "./templates/terraform.auto.tfvars.tpl" "./generated/terraform.auto.tfvars"
for TF_CFG_TPL in "${TF_GEN_CONFIGS[@]}"
do
  SRC="$TF_CFG_TPL"
  DST="${TF_CFG_TPL/\.tpl/}"
  generate_config $SRC $DST
done
