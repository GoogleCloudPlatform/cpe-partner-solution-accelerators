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

. ../setup.env

for ORG_ID in $PUBLISHER_ORG_ID $SUBSCRIBER_ORG_ID
do
  for POLICY_ID in $(gcloud access-context-manager policies list --organization=$ORG_ID --format "table[no-heading](name)")
  do
    for PERIMETER in $(gcloud access-context-manager perimeters list --policy $POLICY_ID --format "table[no-heading](name)")
    do
      echo "# Delete perimeter: $PERIMETER"
      echo "gcloud access-context-manager perimeters delete --policy $POLICY_ID $PERIMETER --quiet"
    done
    for ACCESS_LEVEL in $(gcloud access-context-manager levels list --policy $POLICY_ID --format "table[no-heading](name)")
    do
      echo "# Delete access level: $ACCESS_LEVEL"
      echo "gcloud access-context-manager levels delete --policy $POLICY_ID $ACCESS_LEVEL --quiet"
    done
    echo "# Delete policy: $POLICY_ID"
    echo "gcloud access-context-manager policies delete $POLICY_ID --quiet"
  done
done
