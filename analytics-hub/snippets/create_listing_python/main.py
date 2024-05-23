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

from string import Template
from google.cloud import bigquery_analyticshub_v1
from google.cloud import bigquery
from google.iam.v1 import iam_policy_pb2
from http import HTTPStatus
from google.protobuf.json_format import MessageToDict
import base64 
import time   
import argparse


def get_or_create_exchange(client: bigquery_analyticshub_v1.AnalyticsHubServiceClient, project_id: str, location: str, exchange_id: str, is_dcr: bool):
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
            # DataCleanRoom
            shared_environment_config = bigquery_analyticshub_v1.SharingEnvironmentConfig()
            if is_dcr:
                shared_environment_config.dcr_exchange_config = bigquery_analyticshub_v1.SharingEnvironmentConfig.DcrExchangeConfig()
                exTitleTag = "Data Clean Room"
            else:
                shared_environment_config.default_exchange_config = bigquery_analyticshub_v1.SharingEnvironmentConfig.DefaultExchangeConfig()
                exTitleTag = "Data Exchange"
            # Initialize request argument(s)
            data_exchange = bigquery_analyticshub_v1.DataExchange()
            data_exchange.display_name = f"Example {exTitleTag} - created using python API"
            data_exchange.description = f"Example {exTitleTag} - created using python API"
            data_exchange.primary_contact = ""
            data_exchange.documentation = "https://link.to.optional.documentation/"
            data_exchange.sharing_environment_config = shared_environment_config

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

def get_or_create_listing(client: bigquery_analyticshub_v1.AnalyticsHubServiceClient, project_id: str, location: str, exchange_id: str, listing_id: str, restrict_egress: bool, shared_ds: str):
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
            listing.bigquery_dataset.dataset = f"projects/{project_id}/datasets/{shared_ds}"

            listing.restricted_export_config = bigquery_analyticshub_v1.Listing.RestrictedExportConfig()

            if restrict_egress:
                listing.restricted_export_config.enabled = True
                listing.restricted_export_config.restrict_direct_table_access = True
                listing.restricted_export_config.restrict_query_result = True
            else:
                listing.restricted_export_config.enabled = False
                listing.restricted_export_config.restrict_direct_table_access = False
                listing.restricted_export_config.restrict_query_result = False

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

def get_or_create_dcr_listing(client: bigquery_analyticshub_v1.AnalyticsHubServiceClient, project_id: str, location: str, exchange_id: str, listing_id: str, shared_ds: str, source_view: str):
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
            listing.display_name = source_view
            listing.primary_contact = "primary@contact.co"

            listing.bigquery_dataset = bigquery_analyticshub_v1.Listing.BigQueryDatasetSource()
            listing.bigquery_dataset.dataset = f"projects/{project_id}/datasets/{shared_ds}"
            
            listing_ds_selected_resource = bigquery_analyticshub_v1.Listing.BigQueryDatasetSource.SelectedResource()
            listing_ds_selected_resource.table = f"projects/{project_id}/datasets/{shared_ds}/tables/{source_view}"

            listing.bigquery_dataset.selected_resources = [ listing_ds_selected_resource ]

            listing.restricted_export_config = bigquery_analyticshub_v1.Listing.RestrictedExportConfig()
            listing.restricted_export_config.enabled = True
            listing.restricted_export_config.restrict_direct_table_access = True
            listing.restricted_export_config.restrict_query_result = False

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

def create_set_iam_policy_request(client: bigquery_analyticshub_v1.AnalyticsHubServiceClient, listing_id: str, role: str, member: str):
    existingPolicy = listing_get_iam_policy(client, listing_id)
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

def listing_add_iam_policy_member(client: bigquery_analyticshub_v1.AnalyticsHubServiceClient, listing_id: str, role: str, member: str):
    newPolicy = False
    exitLoop = False
    while not exitLoop:
        exitLoop = True
        try:
            # Make the request
            request = create_set_iam_policy_request(client, listing_id, role, member)
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

def listing_get_iam_policy(client: bigquery_analyticshub_v1.AnalyticsHubServiceClient, listing_id: str):
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

def bq_view_prep_ddl(project_id: str, dataset_id: str, source_table_id: str, dst_table_id: str, privacy_unit_column: str):
    """Generates the BigQuery DDL statement for creating a view with privacy policy."""
    create_view_ddl_template = Template(
        """CREATE OR REPLACE VIEW $project_id.$dataset_id.$dst_table_id
        OPTIONS(
          privacy_policy= '{"aggregation_threshold_policy": {"threshold": 3, "privacy_unit_column": "$privacy_unit_column"}}'
        )
        AS ( SELECT * FROM $project_id.$dataset_id.$source_table_id );"""
    )

    ddl_statement = create_view_ddl_template.substitute(
        project_id=project_id,
        dataset_id=dataset_id,
        source_table_id=source_table_id,
        dst_table_id=dst_table_id,
        privacy_unit_column=privacy_unit_column,
    )

    return ddl_statement

def create_bq_view_with_analysis_rules(client: bigquery.Client, project_id: str, dataset_id: str, source_table_id: str, dst_table_id: str):
    """Creates a BigQuery view using the generated DDL statement."""
    ddl_statement = bq_view_prep_ddl(project_id, dataset_id, source_table_id, dst_table_id, "test")

    query_job = client.query(ddl_statement)

    # Wait for the query job to complete and check for errors.
    query_job.result() 
    if query_job.error_result:
        print(query_job.error_result)
        return False

    return True

def get_bq_table_metadata(client: bigquery.Client, dataset_id: str, table_id: str):
    """Retrieves metadata for a BigQuery table."""
    table_ref = client.dataset(dataset_id).table(table_id)

    try:
        table_metadata = client.get_table(table_ref)
        return table_metadata, None  # No error
    except Exception as e:  
        return None, e            # Return error 

def parse_commandline_args():
    """Parses command-line arguments and returns them as a dictionary."""

    parser = argparse.ArgumentParser(description="Command-line parameter parser")

    # Required arguments
    parser.add_argument("--project_id", help="Google Cloud project ID", required=True)
    parser.add_argument("--location", help="Location for the BigQuery dataset", required=True)
    parser.add_argument("--exchange_id", help="Exchange ID", required=True)
    parser.add_argument("--listing_id", help="Listing ID", required=True)
    parser.add_argument("--restrict_egress", help="Restrict egress", action='store_true', required=True)
    parser.add_argument("--shared_ds", help="Shared dataset ID", required=True)
    parser.add_argument("--dcr_shared_table", help="Table to share in Data Clean Room", required=True)
    parser.add_argument("--dcr_privacy_column", help="Privacy column for Data Clean Room", required=True)
    parser.add_argument("--dcr_view", help="View with analysis rules to create for Data Clean Room", required=True)
    parser.add_argument("--subscriber_iam_member", help="IAM member who can subscribe - requires either user: or serviceAccount: prefix", required=True)
    parser.add_argument("--subscription_viewer_iam_member", help="IAM member who can see subscription and request access - requires either user: or serviceAccount: prefix", required=True)

    args = parser.parse_args()

    # Convert parsed arguments to a dictionary
    return vars(args)


if __name__ == "__main__":
    arguments = parse_commandline_args()
    arguments['dcr_exchange_id'] = f"{arguments['exchange_id']}_dcr"
    arguments['dcr_listing_id'] = f"{arguments['listing_id']}_dcr"
    print(f"Parsed arguments: {arguments}")  # For demonstration
    clientAH = bigquery_analyticshub_v1.AnalyticsHubServiceClient()
    clientBQ = bigquery.Client()
    print("Creating Data Exchange")
    exchg = get_or_create_exchange(clientAH, arguments["project_id"], arguments["location"], arguments["exchange_id"], False)
    if exchg:
        print(exchg)
        listing = get_or_create_listing(clientAH, arguments["project_id"], arguments["location"], arguments["exchange_id"], arguments["listing_id"], arguments["restrict_egress"], arguments["shared_ds"])
        if listing:
            print(listing)
            policy = listing_get_iam_policy(clientAH, listing.name)
            print("IAMPolicy.before")
            print(policy)
            policy = listing_add_iam_policy_member(clientAH, listing.name, "roles/analyticshub.subscriber", arguments["subscriber_iam_member"])
            print("IAMPolicy.returned")
            print(policy)
            policy = listing_add_iam_policy_member(clientAH, listing.name, "roles/analyticshub.viewer", arguments["subscription_viewer_iam_member"])
            print("IAMPolicy.returned")
            print(policy)
            print("IAMPolicy.after")
            policy = listing_get_iam_policy(clientAH, listing.name)
            print(policy)

    print("\nCreating Data Clean Room")
    exchgId = f'{arguments["exchange_id"]}_dcr'
    listingId = f'{arguments["listing_id"]}_dcr'
    exchg = get_or_create_exchange(clientAH, arguments["project_id"], arguments["location"], exchgId, True)
    if exchg:
        print(exchg)
        if create_bq_view_with_analysis_rules(clientBQ, arguments["project_id"], arguments["shared_ds"], arguments["dcr_shared_table"], arguments["dcr_view"]):
            (tmd, err) = get_bq_table_metadata(clientBQ, arguments["shared_ds"], arguments["dcr_view"])
            print(tmd)
            if tmd is not None:
                listing = get_or_create_dcr_listing(clientAH, arguments["project_id"], arguments["location"], exchgId, listingId, arguments["shared_ds"], arguments["dcr_view"])
                if listing:
                    print(listing)
