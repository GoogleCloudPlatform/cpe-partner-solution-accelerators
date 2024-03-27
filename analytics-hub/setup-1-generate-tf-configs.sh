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

echo "Generating the terraform configuration based on templates ... "
for TF_CFG_TPL in "./s0-bootstrap/backend.tf.tpl" "./s0-bootstrap/terraform.auto.tfvars.tpl" "./s1-vpc-sc/backend.tf.tpl" "./s2-bigquery-analyticshub/backend.tf.tpl" "./s3-subscriber/backend.tf.tpl"
do
  echo "$TF_CFG_TPL > ${TF_CFG_TPL/\.tpl/}"
  cat $TF_CFG_TPL | sed "s/{{STATE_BUCKET}}/$STATE_BUCKET/;
  s/{{SUFFIX}}/$SUFFIX/;
  s/{{PUBLISHER_ORG_ID}}/$PUBLISHER_ORG_ID/;
  s/{{PUBLISHER_ORG_NAME}}/$PUBLISHER_ORG_NAME/;
  s/{{SUBSCRIBER_ORG_ID}}/$SUBSCRIBER_ORG_ID/;
  s/{{SUBSCRIBER_ORG_NAME}}/$SUBSCRIBER_ORG_NAME/;
  s/{{ADMIN_USER}}/$ADMIN_USER/;
  s/{{SUBSCRIBER_USER}}/$SUBSCRIBER_USER/;
  s/{{SUBSCRIBER_SA_EMAIL}}/$SUBSCRIBER_SA_EMAIL/;
  s/{{BQREADER_USER}}/$BQREADER_USER/;
  s/{{TERRAFORM_SA_EMAIL}}/$TERRAFORM_SA_EMAIL/;
  s/{{TERRAFORM_SA_USER}}/$TERRAFORM_SA_USER/;
  " > "${TF_CFG_TPL/\.tpl/}"
done
