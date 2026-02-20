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
	"bytes"
	"context"
	"encoding/base64"
	"flag"
	"fmt"
	"os"
	"text/template"
	"time"

	"cloud.google.com/go/bigquery"
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
func create_or_get_exchange(ctx context.Context, client *analyticshub.Client, projectID, location, exchangeID string, isDCR bool) (*analyticshubpb.DataExchange, error) {
	req := &analyticshubpb.GetDataExchangeRequest{
		Name: fmt.Sprintf("projects/%s/locations/%s/dataExchanges/%s", projectID, location, exchangeID),
	}
	resp, err := client.GetDataExchange(ctx, req)
	if err != nil {
		println(err.Error())
		// Default: create regular Data Exchange / DefaultExchangeConfig
		sharingEnvironmentConfig := &analyticshubpb.SharingEnvironmentConfig{
			Environment: &analyticshubpb.SharingEnvironmentConfig_DefaultExchangeConfig_{},
		}
		exTitleTag := "Data Exchange"
		// if DataCleanRoom: create a Data Clean Room Data Exchange / DcrExchangeConfig
		if isDCR {
			sharingEnvironmentConfig = &analyticshubpb.SharingEnvironmentConfig{
				Environment: &analyticshubpb.SharingEnvironmentConfig_DcrExchangeConfig_{},
			}
			exTitleTag = "Data Clean Room"
		}
		req := &analyticshubpb.CreateDataExchangeRequest{
			Parent:         fmt.Sprintf("projects/%s/locations/%s", projectID, location),
			DataExchangeId: exchangeID,
			DataExchange: &analyticshubpb.DataExchange{
				DisplayName:              fmt.Sprintf("Example %s - created using golang API", exTitleTag),
				Description:              fmt.Sprintf("Example %s - created using golang API", exTitleTag),
				PrimaryContact:           "",
				Documentation:            "https://link.to.optional.documentation/",
				SharingEnvironmentConfig: sharingEnvironmentConfig,
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

// create_or_get_dcr_listing creates an example listing within the specified exchange using the authorized view with analysis rules to represent DCR
func create_or_get_dcr_listing(ctx context.Context, client *analyticshub.Client, projectID, location, exchangeID, listingID string, sharedDataset string, sourceView string) (*analyticshubpb.Listing, error) {
	getReq := &analyticshubpb.GetListingRequest{
		Name: fmt.Sprintf("projects/%s/locations/%s/dataExchanges/%s/listings/%s", projectID, location, exchangeID, listingID),
	}
	resp, err := client.GetListing(ctx, getReq)
	if err != nil {
		println(err.Error())
		restrictedExportConfig := &analyticshubpb.Listing_RestrictedExportConfig{}
		restrictedExportConfig.Enabled = true
		restrictedExportConfig.RestrictDirectTableAccess = true
		restrictedExportConfig.RestrictQueryResult = false
		req := &analyticshubpb.CreateListingRequest{
			Parent:    fmt.Sprintf("projects/%s/locations/%s/dataExchanges/%s", projectID, location, exchangeID),
			ListingId: listingID,
			Listing: &analyticshubpb.Listing{
				DisplayName: sourceView,
				Categories: []analyticshubpb.Listing_Category{
					analyticshubpb.Listing_CATEGORY_OTHERS,
				},
				PrimaryContact: "primary@contact.co",
				Source: &analyticshubpb.Listing_BigqueryDataset{
					BigqueryDataset: &analyticshubpb.Listing_BigQueryDatasetSource{
						Dataset: fmt.Sprintf("projects/%s/datasets/%s", projectID, sharedDataset),
						SelectedResources: []*analyticshubpb.Listing_BigQueryDatasetSource_SelectedResource{
							{
								Resource: &analyticshubpb.Listing_BigQueryDatasetSource_SelectedResource_Table{
									Table: fmt.Sprintf("projects/%s/datasets/%s/tables/%s", projectID, sharedDataset, sourceView),
								},
							},
						},
					},
				},
				RestrictedExportConfig: restrictedExportConfig,
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

// create_or_get_listing creates an example listing within the specified exchange using the provided source dataset.
func create_or_get_listing(ctx context.Context, client *analyticshub.Client, projectID, sharedDSprojectID, location, exchangeID, listingID string, restrictEgress bool, sharedDataset string) (*analyticshubpb.Listing, error) {
	getReq := &analyticshubpb.GetListingRequest{
		Name: fmt.Sprintf("projects/%s/locations/%s/dataExchanges/%s/listings/%s", projectID, location, exchangeID, listingID),
	}
	resp, err := client.GetListing(ctx, getReq)
	if err != nil {
		println(err.Error())
		restrictedExportConfig := &analyticshubpb.Listing_RestrictedExportConfig{}
		if restrictEgress {
			restrictedExportConfig.Enabled = true
			restrictedExportConfig.RestrictDirectTableAccess = true
			restrictedExportConfig.RestrictQueryResult = true
		} else {
			restrictedExportConfig.Enabled = false
			restrictedExportConfig.RestrictDirectTableAccess = false
			restrictedExportConfig.RestrictQueryResult = false
		}
		println(fmt.Sprintf("Creating listing: projects/%s/locations/%s/dataExchanges/%s", projectID, location, exchangeID))
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
						Dataset: fmt.Sprintf("projects/%s/datasets/%s", sharedDSprojectID, sharedDataset),
					},
				},
				RestrictedExportConfig: restrictedExportConfig,
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

type Flags struct {
	project_id                     string
	location                       string
	exchange_id                    string
	listing_id                     string
	restrict_egress                bool
	shared_ds                      string
	shared_ds_project_id           string
	subscriber_iam_member          string
	subscription_viewer_iam_member string
	dcr_exchange_id                string
	dcr_listing_id                 string
	dcr_view                       string
	dcr_shared_table               string
	dcr_privacy_column             string
}

func parse_args() Flags {
	// Define command-line flags
	flags := Flags{}

	project_id := flag.String("project_id", "", "Google Cloud project ID (required)")
	location := flag.String("location", "", "Location for the BigQuery dataset (required)")
	exchange_id := flag.String("exchange_id", "", "Exchange ID (required)")
	listing_id := flag.String("listing_id", "", "Listing ID (required)")
	restrict_egress := flag.Bool("restrict_egress", false, "Egress controls enabled")
	shared_ds_project_id := flag.String("shared_ds_project_id", "", "Shared dataset project ID (required)")
	shared_ds := flag.String("shared_ds", "", "Shared dataset ID (required)")
	subscriber_iam_member := flag.String("subscriber_iam_member", "", "IAM member who can subscribe - requires either user: or serviceAccount: prefix")
	subscription_viewer_iam_member := flag.String("subscription_viewer_iam_member", "", "IAM member who can see subscription and request access - requires either user: or serviceAccount: prefix")
	dcr_exchange_id := flag.String("dcr_exchange_id", "", "Exchange ID for Data Clean Room")
	dcr_listing_id := flag.String("dcr_listing_id", "", "Listing ID  for Data Clean Room")
	dcr_view := flag.String("dcr_view", "", "View with analysis rules to create for Data Clean Room")
	dcr_shared_table := flag.String("dcr_shared_table", "", "Table to share in Data Clean Room")
	dcr_privacy_column := flag.String("dcr_privacy_column", "", "Privacy column for Data Clean Room")

	// Parse the command-line flags
	flag.Parse()

	// Use the parsed values
	flags.project_id = *project_id
	flags.location = *location
	flags.exchange_id = *exchange_id
	flags.listing_id = *listing_id
	flags.restrict_egress = *restrict_egress
	flags.shared_ds_project_id = *shared_ds_project_id
	flags.shared_ds = *shared_ds
	flags.subscriber_iam_member = *subscriber_iam_member
	flags.subscription_viewer_iam_member = *subscription_viewer_iam_member
	flags.dcr_exchange_id = *dcr_exchange_id
	flags.dcr_listing_id = *dcr_listing_id
	flags.dcr_view = *dcr_view
	flags.dcr_shared_table = *dcr_shared_table
	flags.dcr_privacy_column = *dcr_privacy_column
	fmt.Print(flags)

	// Check if required flags are provided
	if *project_id == "" || *location == "" || *exchange_id == "" || *listing_id == "" || *shared_ds_project_id == "" || *shared_ds == "" || *subscriber_iam_member == "" || *subscription_viewer_iam_member == "" || *dcr_shared_table == "" || *dcr_privacy_column == "" {
		flag.Usage()
		os.Exit(1)
	}

	return flags
}

func bq_view_prep_ddl(projectID string, datasetID string, sourceTableID string, dstTableID string, privacyUnitColumn string) string {
	createViewDDLTemplate := `CREATE OR REPLACE VIEW {{.projectID}}.{{.datasetID}}.{{.dstTableID}}
	OPTIONS(
	  privacy_policy= '{"aggregation_threshold_policy": {"threshold": 3, "privacy_unit_column": "{{.privacyUnitColumn}}"}}'
	)
	AS ( SELECT * FROM {{.projectID}}.{{.datasetID}}.{{.sourceTableID}} );`
	t := template.Must(template.New("createViewDDL").Parse(createViewDDLTemplate))
	buf := &bytes.Buffer{}
	data := map[string]interface{}{
		"projectID":         projectID,
		"datasetID":         datasetID,
		"sourceTableID":     sourceTableID,
		"dstTableID":        dstTableID,
		"privacyUnitColumn": privacyUnitColumn,
	}
	if err := t.Execute(buf, data); err != nil {
		panic(err)
	}
	s := buf.String()
	return s
}

func create_bq_view_with_analysis_rules(ctx context.Context, client *bigquery.Client, projectID string, datasetID string, sourceTableID string, dstTableID string, privacyUnitColumn string) error {
	q := client.Query(bq_view_prep_ddl(projectID, datasetID, sourceTableID, dstTableID, privacyUnitColumn))
	it, err := q.Read(ctx)
	_ = it
	if err != nil {
		println(err)
		// TODO: Handle error.
		return err
	}
	return nil
}

func bq_dataset_add_authorization(ctx context.Context, client *bigquery.Client, projectID string, datasetID string, tableID string) error {
	ds := client.DatasetInProject(projectID, datasetID)
	dsMetadata, err := ds.Metadata(ctx)
	if err == nil {
		dsMetadataToUpdate := &bigquery.DatasetMetadataToUpdate{}
		dsMetadataToUpdate.Access = append(dsMetadataToUpdate.Access, dsMetadata.Access...)
		needsUpdate := true
		for _, bqAccess := range dsMetadataToUpdate.Access {
			if bqAccess.EntityType == bigquery.ViewEntity &&
				bqAccess.View.ProjectID == projectID &&
				bqAccess.View.DatasetID == datasetID &&
				bqAccess.View.TableID == tableID {
				needsUpdate = false
			}
		}
		if needsUpdate {
			dsMetadataToUpdate.Access = append(dsMetadataToUpdate.Access,
				&bigquery.AccessEntry{
					EntityType: bigquery.ViewEntity,
					View: &bigquery.Table{
						ProjectID: projectID,
						DatasetID: datasetID,
						TableID:   tableID,
					},
				})
			_, err := ds.Update(ctx, *dsMetadataToUpdate, dsMetadata.ETag)
			if err != nil {
				println(err)
				return err
			}
		}
		return nil
	} else {
		return err
	}
}

func get_bq_table_metadata(ctx context.Context, client *bigquery.Client, datasetID string, tableID string) (*bigquery.TableMetadata, error) {
	table := client.Dataset(datasetID).Table(tableID)
	tableMetadata, err := table.Metadata(ctx, bigquery.WithMetadataView(bigquery.FullMetadataView))
	return tableMetadata, err
}

func main() {
	flags := parse_args()

	ctx := context.Background()
	client, err := analyticshub.NewClient(ctx)
	if err != nil {
		println(err)
	}
	defer client.Close()
	bqClient, err := bigquery.NewClient(ctx, flags.project_id)
	if err != nil {
		println(fmt.Errorf("bigquery.NewClient: %v", err))
	}
	defer bqClient.Close()

	println("Creating Data Exchange")
	list_exchanges(ctx, client, flags.project_id, flags.location)
	exchg, err := create_or_get_exchange(ctx, client, flags.project_id, flags.location, flags.exchange_id, false)
	if err == nil {
		println(fmt.Sprintf("Exchange: [%s] %s", exchg.Name, exchg.DisplayName))
		listing, err := create_or_get_listing(ctx, client, flags.project_id, flags.shared_ds_project_id, flags.location, flags.exchange_id, flags.listing_id, flags.restrict_egress, flags.shared_ds)
		if err == nil {
			println(fmt.Sprintf("Listing: [%s] %s", listing.Name, listing.DisplayName))
			println("GetIamPolicy before setIamPolicy")
			policy, err := listing_get_iam_policy(ctx, client, listing.Name)
			if err == nil {
				print_iam_policy(policy)
				listing_add_iam_policy_member(ctx, client, listing.Name, "roles/analyticshub.subscriber", flags.subscriber_iam_member)
				listing_add_iam_policy_member(ctx, client, listing.Name, "roles/analyticshub.viewer", flags.subscription_viewer_iam_member)
				println("GetIamPolicy after setIamPolicy")
				policy, err := listing_get_iam_policy(ctx, client, listing.Name)
				if err == nil {
					print_iam_policy(policy)
				}
			}
		}
	}

	println("\nCreating Data Clean Room")
	exchgDCR, err := create_or_get_exchange(ctx, client, flags.project_id, flags.location, flags.dcr_exchange_id, true)
	if err == nil {
		println(fmt.Sprintf("Exchange(DCR): [%s] %s", exchgDCR.Name, exchgDCR.DisplayName))
		println("Creating BigQuery view with analysis rules")
		create_bq_view_with_analysis_rules(ctx, bqClient, flags.project_id, flags.shared_ds, flags.dcr_shared_table, flags.dcr_view, flags.dcr_privacy_column)
		tableMetadata, err := get_bq_table_metadata(ctx, bqClient, flags.shared_ds, flags.dcr_view)
		if err == nil {
			print(tableMetadata)
			bq_dataset_add_authorization(ctx, bqClient, flags.project_id, flags.shared_ds, flags.dcr_view)
			listingDCR, err := create_or_get_dcr_listing(
				ctx,
				client,
				flags.project_id,
				flags.location,
				flags.dcr_exchange_id,
				flags.dcr_listing_id,
				flags.shared_ds,
				flags.dcr_view,
			)
			if err == nil {
				println(fmt.Sprintf("Listing(DCR): [%s] %s", listingDCR.Name, listingDCR.DisplayName))
			}
		}
	}
}
