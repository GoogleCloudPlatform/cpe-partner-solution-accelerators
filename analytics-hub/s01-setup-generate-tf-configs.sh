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

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

generate_config () {
  P_SRC=$1
  P_DST=$2
  ALLOWLISTED_IPV4_S=$(echo -n '"'; echo -n ${ALLOWLISTED_IPV4_A[@]} | sed s/' '/'","'/g; echo -n '"';)
  ALLOWLISTED_IPV6_S=$(echo -n '"'; echo -n ${ALLOWLISTED_IPV6_A[@]} | sed s/' '/'","'/g; echo -n '"';)

  echo "$P_SRC > $P_DST"

  cat $P_SRC | sed "s/{{SUFFIX}}/$SUFFIX/;
  s/{{TERRAFORM_SA_USER}}/$TERRAFORM_SA_USER/;
  s/{{SUBSCRIBER_SA_USER}}/$SUBSCRIBER_SA_USER/;
  s/{{PUBL_PROJECT_ID_PREFIX}}/$PUBL_PROJECT_ID_PREFIX/;
  s/{{PUBL_PROJECT_ID_SEED}}/$PUBL_PROJECT_ID_SEED/;
  s/{{PUBL_PROJECT_ID_BQ_SRC_DS}}/$PUBL_PROJECT_ID_BQ_SRC_DS/;
  s/{{PUBL_PROJECT_ID_BQ_SHARED_DS}}/$PUBL_PROJECT_ID_BQ_SHARED_DS/;
  s/{{PUBL_PROJECT_ID_AH_EXCHG}}/$PUBL_PROJECT_ID_AH_EXCHG/;
  s/{{PUBL_PROJECT_ID_NONVPCSC_AH_EXCHG}}/$PUBL_PROJECT_ID_NONVPCSC_AH_EXCHG/;
  s/{{PUBL_PROJECT_ID_BQ_AND_AH}}/$PUBL_PROJECT_ID_BQ_AND_AH/;
  s/{{PUBL_ADMIN_USER}}/$PUBL_ADMIN_USER/;
  s/{{PUBL_TERRAFORM_SA_NAME}}/$PUBL_TERRAFORM_SA_NAME/;
  s/{{PUBL_TERRAFORM_SA_EMAIL}}/$PUBL_TERRAFORM_SA_EMAIL/;
  s/{{PUBL_TERRAFORM_SA_USER}}/$PUBL_TERRAFORM_SA_USER/;
  s/{{PUBL_STATE_BUCKET}}/$PUBL_STATE_BUCKET/;
  s/{{PUBLISHER_ORG_ID}}/$PUBLISHER_ORG_ID/;
  s/{{PUBLISHER_ORG_NAME}}/$PUBLISHER_ORG_NAME/;
  s/{{SUBSCR_PROJECT_ID_PREFIX}}/$SUBSCR_PROJECT_ID_PREFIX/;
  s/{{SUBSCR_PROJECT_ID_SEED}}/$SUBSCR_PROJECT_ID_SEED/;
  s/{{SUBSCR_PROJECT_ID_WITH_VPCSC}}/$SUBSCR_PROJECT_ID_WITH_VPCSC/;
  s/{{SUBSCR_PROJECT_ID_WITHOUT_VPCSC}}/$SUBSCR_PROJECT_ID_WITHOUT_VPCSC/;
  s/{{SUBSCR_ADMIN_USER}}/$SUBSCR_ADMIN_USER/;
  s/{{SUBSCR_TERRAFORM_SA_NAME}}/$SUBSCR_TERRAFORM_SA_NAME/;
  s/{{SUBSCR_TERRAFORM_SA_EMAIL}}/$SUBSCR_TERRAFORM_SA_EMAIL/;
  s/{{SUBSCR_TERRAFORM_SA_USER}}/$SUBSCR_TERRAFORM_SA_USER/;
  s/{{SUBSCR_SUBSCRIBER_SA_NAME}}/$SUBSCR_SUBSCRIBER_SA_NAME/;
  s/{{SUBSCR_SUBSCRIBER_SA_EMAIL}}/$SUBSCR_SUBSCRIBER_SA_EMAIL/;
  s/{{SUBSCR_SUBSCRIBER_SA_USER}}/$SUBSCR_SUBSCRIBER_SA_USER/;
  s/{{SUBSCR_STATE_BUCKET}}/$SUBSCR_STATE_BUCKET/;
  s/{{SUBSCRIBER_ORG_ID}}/$SUBSCRIBER_ORG_ID/;
  s/{{SUBSCRIBER_ORG_NAME}}/$SUBSCRIBER_ORG_NAME/;
  s/{{SUBSCRIBER_USER}}/$SUBSCRIBER_USER/;
  s/{{SUBSCRIPTION_VIEWER_USER}}/$SUBSCRIPTION_VIEWER_USER/;
  s/{{BQREADER_USER}}/$BQREADER_USER/;
  s/{{REQUEST_ACCESS_EMAIL_OR_URL}}/$REQUEST_ACCESS_EMAIL_OR_URL/;
  s/{{GCLOUD_USER}}/$GCLOUD_USER/;
  s/{{BILLING_ACCOUNT_ID}}/$BILLING_ACCOUNT_ID/;
  s!{{ALLOWLISTED_IPV4_S}}!$ALLOWLISTED_IPV4_S!;
  s!{{ALLOWLISTED_IPV6_S}}!$ALLOWLISTED_IPV6_S!;
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
