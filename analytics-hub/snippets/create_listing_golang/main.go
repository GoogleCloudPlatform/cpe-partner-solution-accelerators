// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"context"
	"encoding/base64"
	"flag"
	"fmt"
	"os"
	"time"

	analyticshub "cloud.google.com/go/bigquery/analyticshub/apiv1"
	"cloud.google.com/go/bigquery/analyticshub/apiv1/analyticshubpb"
	iampb "cloud.google.com/go/iam/apiv1/iampb"
	"google.golang.org/api/iterator"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func print_iam_policy(policy *iampb.Policy) {
	println("IAMPolicy: ")
	encodedEtag := base64.StdEncoding.EncodeToString([]byte(policy.Etag))
	println("  Etag: " + encodedEtag)
	for _, binding := range policy.Bindings {
		println(fmt.Sprintf("  Role: %s", binding.Role))
		for _, member := range binding.Members {
			println(fmt.Sprintf("    Member: %s", member))
		}
	}
}

func listing_get_iam_policy(ctx context.Context, client *analyticshub.Client, listing_id string) (*iampb.Policy, error) {
	req := &iampb.GetIamPolicyRequest{
		Resource: listing_id,
		// See https://pkg.go.dev/cloud.google.com/go/iam/apiv1/iampb#GetIamPolicyRequest.
	}
	resp, err := client.GetIamPolicy(ctx, req)
	if err != nil {
		println(err.Error())
		return nil, err
	} else {
		return resp, nil
	}
}

func create_set_iam_policy_request(ctx context.Context, client *analyticshub.Client, listing_id string, role string, member string) (*iampb.SetIamPolicyRequest, error) {
	existingPolicy, err := listing_get_iam_policy(ctx, client, listing_id)

	if err == nil {
		setIamPolicyRequest := &iampb.SetIamPolicyRequest{}
		setIamPolicyRequest.Resource = listing_id
		setIamPolicyRequest.Policy = &iampb.Policy{}
		setIamPolicyRequest.Policy.Etag = existingPolicy.Etag
		setIamPolicyRequest.Policy.Bindings = []*iampb.Binding{}
		setIamPolicyRequest.Policy.Bindings = append(
			setIamPolicyRequest.Policy.Bindings,
			existingPolicy.GetBindings()...)
		// Look for existing binding for the role
		addToBinding := &iampb.Binding{Role: role, Members: []string{member}}
		existingBindingFoundForRole := false
		for _, binding := range setIamPolicyRequest.Policy.Bindings {
			if binding.Role == role {
				addToBinding = binding
				existingBindingFoundForRole = true
			}
		}
		// If there is an existing binding, add a new member to it
		if existingBindingFoundForRole {
			addToBinding.Members = append(
				addToBinding.Members,
				member)
			// Else add a new binding with the role/member
		} else {
			setIamPolicyRequest.Policy.Bindings = append(
				setIamPolicyRequest.Policy.Bindings,
				addToBinding)
		}
		return setIamPolicyRequest, nil
	} else {
		println(err.Error())
		return nil, err
	}
}

func listing_add_iam_policy_member(ctx context.Context, client *analyticshub.Client, listing_id string, role string, member string) *iampb.Policy {
	exitLoop := false
	var newPolicy *iampb.Policy
	for !exitLoop {
		exitLoop = true
		setIamPolicyRequest, err := create_set_iam_policy_request(ctx, client, listing_id, role, member)
		if err == nil {
			resp, err := client.SetIamPolicy(ctx, setIamPolicyRequest)
			if err != nil {
				// Aborted == concurrent modification / Etag mismatch
				if status.Code(err) == codes.Aborted {
					// Add delay (should be exponential backoff instead of fixed time)
					time.Sleep(5 * time.Second)
					println("add_iam_policy_member: concurrent modification (Etag mismatch), retrying")
					exitLoop = false
					// TODO: handle UserNotFound error (e.g. the user to be added does not exist)
				} else {
					println(err.Error())
				}
			} else {
				newPolicy = resp
			}
		}
	}
	return newPolicy
}

func list_listings(ctx context.Context, client *analyticshub.Client, exchange_id string) {
	req := &analyticshubpb.ListListingsRequest{
		Parent: exchange_id,
		// TODO: Fill request struct fields.
		// See https://pkg.go.dev/cloud.google.com/go/bigquery/analyticshub/apiv1/analyticshubpb#ListListingsRequest.
	}
	it := client.ListListings(ctx, req)
	for {
		resp, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			println(err.Error())
			break
		} else {
			println(fmt.Sprintf("  ListListingsResponse: [%s] %s", resp.Name, resp.DisplayName))
			policy, err := listing_get_iam_policy(ctx, client, resp.Name)
			if err == nil {
				print_iam_policy(policy)
			}
		}
	}
}

func list_exchanges(ctx context.Context, client *analyticshub.Client, project_id string, location string) {
	req := &analyticshubpb.ListDataExchangesRequest{
		Parent: fmt.Sprintf("projects/%s/locations/%s", project_id, location),
		// See https://pkg.go.dev/cloud.google.com/go/bigquery/analyticshub/apiv1/analyticshubpb#ListDataExchangesRequest.
	}
	it := client.ListDataExchanges(ctx, req)
	for {
		resp, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			println(err.Error())
			break
		} else {
			println(fmt.Sprintf("ListDataExchangesResponse: [%s] %s", resp.Name, resp.DisplayName))
			list_listings(ctx, client, resp.Name)
		}
	}
}

// createOrGetDataExchange creates an example data exchange, or returns information about the exchange already bearing
// the example identifier.
func create_or_get_exchange(ctx context.Context, client *analyticshub.Client, projectID, location, exchangeID string) (*analyticshubpb.DataExchange, error) {
	req := &analyticshubpb.GetDataExchangeRequest{
		Name: fmt.Sprintf("projects/%s/locations/%s/dataExchanges/%s", projectID, location, exchangeID),
	}
	resp, err := client.GetDataExchange(ctx, req)
	if err != nil {
		println(err.Error())
		req := &analyticshubpb.CreateDataExchangeRequest{
			Parent:         fmt.Sprintf("projects/%s/locations/%s", projectID, location),
			DataExchangeId: exchangeID,
			DataExchange: &analyticshubpb.DataExchange{
				DisplayName:    "Example Data Exchange - created using golang API",
				Description:    "Example Data Exchange - created using golang API",
				PrimaryContact: "",
				Documentation:  "https://link.to.optional.documentation/",
			},
		}
		resp, err := client.CreateDataExchange(ctx, req)
		if err != nil {
			println(err.Error())
			return nil, err
		} else {
			return resp, nil
		}
	} else {
		return resp, nil
	}
}

// createListing creates an example listing within the specified exchange using the provided source dataset.
func create_or_get_listing(ctx context.Context, client *analyticshub.Client, projectID, location, exchangeID, listingID, sourceDataset string) (*analyticshubpb.Listing, error) {
	getReq := &analyticshubpb.GetListingRequest{
		Name: fmt.Sprintf("projects/%s/locations/%s/dataExchanges/%s/listings/%s", projectID, location, exchangeID, listingID),
	}
	resp, err := client.GetListing(ctx, getReq)
	if err != nil {
		println(err.Error())
		req := &analyticshubpb.CreateListingRequest{
			Parent:    fmt.Sprintf("projects/%s/locations/%s/dataExchanges/%s", projectID, location, exchangeID),
			ListingId: listingID,
			Listing: &analyticshubpb.Listing{
				DisplayName: "Example Exchange Listing - created using golang API",
				Description: "Example Exchange Listing - created using golang API",
				Categories: []analyticshubpb.Listing_Category{
					analyticshubpb.Listing_CATEGORY_OTHERS,
				},
				Source: &analyticshubpb.Listing_BigqueryDataset{
					BigqueryDataset: &analyticshubpb.Listing_BigQueryDatasetSource{
						Dataset: sourceDataset,
					},
				},
				RestrictedExportConfig: &analyticshubpb.Listing_RestrictedExportConfig{
					Enabled:                   true,
					RestrictDirectTableAccess: true,
					RestrictQueryResult:       true,
				},
			},
		}
		resp, err := client.CreateListing(ctx, req)
		if err != nil {
			println(err.Error())
			return nil, err
		}
		return resp, nil
	} else {
		return resp, nil
	}
}

func parse_args() (string, string, string, string, string, string) {
	// Define command-line flags
	projectID := flag.String("project_id", "", "Google Cloud project ID (required)")
	location := flag.String("location", "", "Location for the BigQuery dataset (required)")
	exchangeID := flag.String("exchange_id", "", "Exchange ID (required)")
	listingID := flag.String("listing_id", "", "Listing ID (required)")
	sharedDS := flag.String("shared_ds", "", "Shared dataset ID (required)")
	subscriptionViewerIAMMember := flag.String("subscription_viewer_iam_member", "", "IAM member for subscription viewer (optional) - requires either user: or serviceAccount: prefix")

	// Parse the command-line flags
	flag.Parse()

	// Check if required flags are provided
	if *projectID == "" || *location == "" || *exchangeID == "" || *listingID == "" || *sharedDS == "" || *subscriptionViewerIAMMember == "" {
		flag.Usage()
		os.Exit(1)
	}

	// Use the parsed values
	fmt.Println("Parsed arguments:")
	fmt.Println("project_id:", *projectID)
	fmt.Println("location:", *location)
	fmt.Println("exchange_id:", *exchangeID)
	fmt.Println("listing_id:", *listingID)
	fmt.Println("shared_ds:", *sharedDS)
	fmt.Println("subscription_viewer_iam_member:", *subscriptionViewerIAMMember)

	return *projectID, *location, *exchangeID, *listingID, *sharedDS, *subscriptionViewerIAMMember
}

func main() {
	ctx := context.Background()
	client, err := analyticshub.NewClient(ctx)
	if err != nil {
		println(err)
	}
	defer client.Close()

	project_id, location, exchange_id, listing_id, source_ds, subscription_viewer_iam_member := parse_args()
	list_exchanges(ctx, client, project_id, location)
	exchg, err := create_or_get_exchange(ctx, client, project_id, location, exchange_id)
	if err == nil {
		listing, err := create_or_get_listing(ctx, client, project_id, location, exchange_id, listing_id, source_ds)
		if err == nil {
			println(fmt.Sprintf("Exchange: [%s] %s", exchg.Name, exchg.DisplayName))
			println(fmt.Sprintf("Listing: [%s] %s", listing.Name, listing.DisplayName))
			println("GetIamPolicy before setIamPolicy")
			policy, err := listing_get_iam_policy(ctx, client, listing.Name)
			if err == nil {
				print_iam_policy(policy)
				listing_add_iam_policy_member(ctx, client, listing.Name, "roles/analyticshub.viewer", subscription_viewer_iam_member)
				println("GetIamPolicy after setIamPolicy")
				policy, err := listing_get_iam_policy(ctx, client, listing.Name)
				if err == nil {
					print_iam_policy(policy)
				}
			}
		}
	}
}
