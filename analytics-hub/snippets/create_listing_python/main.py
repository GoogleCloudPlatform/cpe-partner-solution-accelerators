# -*- coding: utf-8 -*-
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from google.cloud import bigquery_analyticshub_v1
from google.iam.v1 import iam_policy_pb2
from http import HTTPStatus
from google.protobuf.json_format import MessageToDict
import base64 
import time   


def get_or_create_exchange(project_id: str, location: str, exchange_id: str):
    # Create a client
    client = bigquery_analyticshub_v1.AnalyticsHubServiceClient()

    # Initialize request argument(s)
    request = bigquery_analyticshub_v1.GetDataExchangeRequest(
        name=f"projects/{project_id}/locations/{location}/dataExchanges/{exchange_id}",
    )

    # Make the request
    try:
        response = client.get_data_exchange(request=request)
        # Handle the response
        print(response)
        return response
    except Exception as ex:
        if ex.code == HTTPStatus.NOT_FOUND:
            print("Not found, creating")
            # Initialize request argument(s)
            data_exchange = bigquery_analyticshub_v1.DataExchange()
            data_exchange.display_name = "Example Data Exchange - created using python API"
            data_exchange.description = "Example Data Exchange - created using python API"
            data_exchange.primary_contact = ""
            data_exchange.documentation = "https://link.to.optional.documentation/"

            request = bigquery_analyticshub_v1.CreateDataExchangeRequest(
                parent=f"projects/{project_id}/locations/{location}",
                data_exchange_id=exchange_id,
                data_exchange=data_exchange,
            )

            try:
                # Make the request
                response = client.create_data_exchange(request=request)
                # Handle the response
                print(response)
                return response
            except Exception as ex:
                print(ex)
        else:
            print(ex)
    return False

def get_or_create_listing(project_id: str, location: str, exchange_id: str, listing_id: str, shared_ds: str):
    # Create a client
    client = bigquery_analyticshub_v1.AnalyticsHubServiceClient()

    # Initialize request argument(s)
    request = bigquery_analyticshub_v1.GetListingRequest(
        name=f"projects/{project_id}/locations/{location}/dataExchanges/{exchange_id}/listings/{listing_id}",
    )

    # Make the request
    try:
        response = client.get_listing(request=request)
        # Handle the response
        print(response)
        return response
    except Exception as ex:
        if ex.code == HTTPStatus.NOT_FOUND:
            print("Not found, creating")
            # Initialize request argument(s)
            listing = bigquery_analyticshub_v1.Listing()
            listing.display_name = "Example Exchange Listing - created using python API"
            listing.description = "Example Exchange Listing - created using python API"

            listing.data_provider = bigquery_analyticshub_v1.DataProvider()
            listing.data_provider.name = "Example Exchange Listing - created using python API"
            listing.data_provider.primary_contact = "primary@contact.co"

            listing.bigquery_dataset = bigquery_analyticshub_v1.Listing.BigQueryDatasetSource()
            listing.bigquery_dataset.dataset = shared_ds

            listing.restricted_export_config = bigquery_analyticshub_v1.Listing.RestrictedExportConfig()
            listing.restricted_export_config.enabled = True
            listing.restricted_export_config.restrict_direct_table_access = True
            listing.restricted_export_config.restrict_query_result = True

            request = bigquery_analyticshub_v1.CreateListingRequest(
                parent=f"projects/{project_id}/locations/{location}/dataExchanges/{exchange_id}",
                listing_id=listing_id,
                listing=listing,
            )

            try:
                # Make the request
                response = client.create_listing(request=request)
                # Handle the response
                print(response)
                return response
            except Exception as ex:
                print(ex)
        else:
            print(ex)
    return False

def create_set_iam_policy_request(listing_id: str, role: str, member: str):
    existingPolicy = listing_get_iam_policy(listing_id)
    existingPolicyDict = MessageToDict(existingPolicy)
    if existingPolicyDict:
        policy = {
            "etag": base64.b64decode(existingPolicyDict['etag']),
            "bindings": []
        }
        bindingForRoleFound = False
        if 'bindings' in existingPolicyDict:
            policy['bindings'] = existingPolicyDict['bindings'].copy()
            for binding in policy['bindings']:
                if binding['role'] == role:
                    binding['members'].append(member)
                    bindingForRoleFound = True
        if not bindingForRoleFound:
            policy['bindings'].append({
                "role": role,
                "members": [ member ]
            })
        request = iam_policy_pb2.SetIamPolicyRequest(
            resource=listing_id,
            policy=policy
        )
        return request
    return False

def listing_add_iam_policy_member(listing_id: str, role: str, member: str):
    # Create a client
    client = bigquery_analyticshub_v1.AnalyticsHubServiceClient()
    newPolicy = False
    exitLoop = False
    while not exitLoop:
        exitLoop = True
        try:
            # Make the request
            request = create_set_iam_policy_request(listing_id, role, member)
            if request:
                # Make the request
                response = client.set_iam_policy(request=request)
                # Handle the response
                newPolicy = response
        except Exception as ex:
            # CONFLICT == concurrent modification / Etag mismatch
            if ex.code == HTTPStatus.CONFLICT:
                print("listing_add_iam_policy_member: concurrent modification (Etag mismatch), retrying")
                time.sleep(60)
                exitLoop = False
			# TODO: handle UserNotFound error (e.g. the user to be added does not exist)
            else:
                print(ex)
    
    return newPolicy

def listing_get_iam_policy(listing_id: str):
    # Create a client
    client = bigquery_analyticshub_v1.AnalyticsHubServiceClient()
    request = iam_policy_pb2.GetIamPolicyRequest(
        resource=listing_id,
    )
    try:
        # Make the request
        response = client.get_iam_policy(request=request)
        # Handle the response
        return response
    except Exception as ex:
        print(ex)
    return False

import argparse

def parse_commandline_args():
    """Parses command-line arguments and returns them as a dictionary."""

    parser = argparse.ArgumentParser(description="Command-line parameter parser")

    # Required arguments
    parser.add_argument("project_id", help="Google Cloud project ID")
    parser.add_argument("location", help="Location for the BigQuery dataset")
    parser.add_argument("exchange_id", help="Exchange ID")
    parser.add_argument("listing_id", help="Listing ID")
    parser.add_argument("shared_ds", help="Shared dataset ID")
    parser.add_argument("subscription_view_iam_member", help="IAM member for subscription view")

    args = parser.parse_args()

    # Convert parsed arguments to a dictionary
    return vars(args)


if __name__ == "__main__":
    arguments = parse_commandline_args()
    print(f"Parsed arguments: {arguments}")  # For demonstration

    exchg = get_or_create_exchange(arguments["project_id"], arguments["location"], arguments["exchange_id"])
    if exchg:
        print(exchg)
        listing = get_or_create_listing(arguments["project_id"], arguments["location"], arguments["exchange_id"], arguments["listing_id"], arguments["shared_ds"])
        if listing:
            print(listing)
            policy = listing_get_iam_policy(listing.name)
            print("IAMPolicy.before")
            print(policy)
            policy = listing_add_iam_policy_member(listing.name, "roles/analyticshub.subscriber", arguments["subscription_view_iam_member"])
            print("IAMPolicy.returned")
            print(policy)
            print("IAMPolicy.after")
            policy = listing_get_iam_policy(listing.name)
            print(policy)
