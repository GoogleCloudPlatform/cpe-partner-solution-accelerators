# Analytics Hub / BigQuery / VPC-Service Controls end-to-end solution accelerator

This repository hosts automation that creates an end-to-end deployment of Analytics Hub / BigQuery data publishers and subscribers with enterprise grade security.

## Architectures

The following projects are used across the different architectures. The VPC SC perimeters have corresponding names.

* Projects

  | PROJECT_ID | ORG | VPC-SC | DESCRIPTION |
  |---|---|---|---|
  | ahdemo-240325-subscr | Subscriber | NO | Subscriber project without VPC-SC - hosts the linked dataset |
  | ahdemo-240325-subscr-vpcsc | Subscriber | YES | Subscriber project with VPC-SC - hosts the linked dataset |
  | ahdemo-240325-seed | Publisher | NO | Seed project hosting terraform state bucket and service account |
  | ahdemo-240325-ah-exchg | Publisher | YES | Publisher project in its own VPC-SC perimeter - hosts Analytics Hub Exchanges and Listings |
  | ahdemo-240325-nonvpcsc-ah-exch | Publisher | NO | Publisher project outside VPC-SC perimeter - hosts Analytics Hub Exchanges and Listings |
  | ahdemo-240325-bq-ah-sameproj | Publisher | YES | Publisher project in its own VPC-SC perimeter - hosts both Analytics Hub Exchanges and Listings and the BigQuery shared dataset |
  | ahdemo-240325-bq-shared-ds | Publisher | YES | Publisher project in its own VPC-SC perimeter - hosts the shared dataset |
  | ahdemo-240325-bq-src-ds | Publisher | YES | Publisher project in its own VPC-SC perimeter - hosts the source dataset. The source dataset is not shared directly, only shared through views / authorized views |

* VPC-SC perimeters
  * 1
  * 2

### Architecture #1:

## Bootstrap / prerequisites

For the sake of simplicity we are using the same user and service accounts as Administrators in this demo. In a real world scenario the two Cloud Organizations are fully disctinct.

### Prerequisites

- (Ideally) two Google Cloud organizations with Cloud Organization Admin rights (which can grant additional roles needed)
  - publisher-org-domain.org
  - subscriber-org-domain.org

- User accounts (existing Google Accounts):
  - administrator
  - subscriber
  - subscription viewer
  - BigQuery reader

- Billing account with role `Billing Account User`

- IAM roles
  - Organization: Project Creator, Organization Admin

### Stage 0 bootstrap

This stage can be skipped, if:
- You have a service account you can use directly or impersonate
- The service account has all required privileges on the organization level
  
  See `setup-0-google-cloud.sh` for the required roles.

- The required projects are created, and the service account has all required privileges on them (or is owner).
  
  See `setup-0-google-cloud.sh` for the required roles.

This stage will:

1. Create the required projects
1. Enable the APIs required for terraform on the seed project
1. Create the terraform state bucket
1. Create `terraform` and `subscriber` service accounts
1. Grant broad admin privileges to the `terraform` service account and the previously created administrator user account
1. Grant impersonation privilege on the `terraform` service account to the administrator
1. Configure terraform (create backend.tf, terraform.auto.tfvars)

Resources created:

```
$ gcloud projects list --filter 'parent.id=356954763088 AND parent.type=organization'
PROJECT_ID                  NAME                        PROJECT_NUMBER
ahdemo-240325-subscr        ahdemo-240325-subscr        1593099157
ahdemo-240325-subscr-vpcsc  ahdemo-240325-subscr-vpcsc  695555904442

$ gcloud projects list --filter 'parent.id=749200211693 AND parent.type=organization'
PROJECT_ID                      NAME                            PROJECT_NUMBER
ahdemo-240325-ah-exchg          ahdemo-240325-ah-exchg          721405761381
ahdemo-240325-bq-ah-sameproj    ahdemo-240325-bq-ah-sameproj    877945767311
ahdemo-240325-bq-shared-ds      ahdemo-240325-bq-shared-ds      423415243464
ahdemo-240325-bq-src-ds         ahdemo-240325-bq-src-ds         124968394335
ahdemo-240325-nonvpcsc-ah-exch  ahdemo-240325-nonvpcsc-ah-exch  281970723860
ahdemo-240325-seed              ahdemo-240325-seed              492564108488

$ gcloud iam service-accounts list --project ahdemo-d2403-subscr
DISPLAY NAME                            EMAIL                                                  DISABLED
Service Account for Subscriber          subscriber-d2403@ahdemo-d2403-subscr.iam.gserviceaccount.com  False

$ gcloud iam service-accounts list --project ahdemo-d2403-seed
DISPLAY NAME                            EMAIL                                                            DISABLED
Service Account for Terraform           terraform-d2403@ahdemo-d2403-seed.iam.gserviceaccount.com              False
Service Account for Jumphost            jumphost-editor-d2403@ahdemo-d2403-seed.iam.gserviceaccount.com  False
```

Usage:

1. Copy `setup.env.exampe` -> `setup.env`
1. Edit `setup.env`
1. Run `setup-0-google-cloud.sh`
1. Run `setup-1-generate-tf-configs.sh`

In `setup.env`, modify at least the following lines:

```
export SUFFIX=
export PUBLISHER_ORG_ID=
export PUBLISHER_ORG_NAME=
export SUBSCRIBER_ORG_ID=
export SUBSCRIBER_ORG_NAME=
export BILLING_ACCOUNT_ID=
export TERRAFORM_SA_USER="gclouduser@nonexisting-domain.com"
export ADMIN_USER="ahdemo-admin@nonexisting-domain.com"
export SUBSCRIBER_USER="ahdemo-subscriber@nonexisting-domain.com"
export SUBSCRIPCTION_VIEWER_USER="ahdemo-subscription-viewer@nonexisting-domain.com"
export BQREADER_USER=ahdemo-bq-reader@nonexisting-domain.com"
```

```
user@workstation:~/git/ahdemo ./setup-0-google-cloud.sh
Checking seed project ahdemo-240325-seed ... 
Checking project ahdemo-240325-seed ... Status: FAILED
Creating project ahdemo-240325-seed ... Status: OK
Linking billing account ... Status: OK
Enabling cloudresourcemanager.googleapis.com on seed project ahdemo-240325-seed ... 
Enabling accesscontextmanager.googleapis.com on seed project ahdemo-240325-seed ... 
Enabling compute.googleapis.com on seed project ahdemo-240325-seed ... 
Enabling iam.googleapis.com on seed project ahdemo-240325-seed ... 
Enabling orgpolicy.googleapis.com on seed project ahdemo-240325-seed ... 
Checking / creating publisher projects in the publisher org (749200211693 / latchkey1-ephemeral-generic-ahdemo-publisher-749200211693)
Checking project ahdemo-240325-bq-src-ds ... Status: FAILED
Creating project ahdemo-240325-bq-src-ds ... Status: OK
Linking billing account ... Status: OK
Checking project ahdemo-240325-bq-shared-ds ... Status: FAILED
Creating project ahdemo-240325-bq-shared-ds ... Status: OK
Linking billing account ... Status: OK
Checking project ahdemo-240325-ah-exchg ... Status: FAILED
Creating project ahdemo-240325-ah-exchg ... Status: OK
Linking billing account ... Status: OK
Checking project ahdemo-240325-nonvpcsc-ah-exch ... Status: FAILED
Creating project ahdemo-240325-nonvpcsc-ah-exch ... Status: OK
Linking billing account ... Status: OK
Checking project ahdemo-240325-bq-ah-sameproj ... Status: FAILED
Creating project ahdemo-240325-bq-ah-sameproj ... Status: OK
Linking billing account ... Status: OK
Checking / creating subscriber projects in the subscriber org (356954763088 / latchkey1-ephemeral-generic-ahdemo-subscriber-356954763088)
Checking project ahdemo-240325-subscr-vpcsc ... Status: FAILED
Creating project ahdemo-240325-subscr-vpcsc ... Status: OK
Linking billing account ... Status: OK
Checking project ahdemo-240325-subscr ... Status: FAILED
Creating project ahdemo-240325-subscr ... Status: OK
Linking billing account ... Status: OK
Checking / creating terraform service account (terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com) ... 
Checking / creating service account (terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com) ... Status: FAILED
Creating service account ... Checking / creating subscriber service account (subscriber-240325@ahdemo-240325-subscr.iam.gserviceaccount.com) ... 
Checking / creating service account (subscriber-240325@ahdemo-240325-subscr.iam.gserviceaccount.com) ... Status: FAILED
Creating service account ... Granting impersonation on terraform service account terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com to gcloud-user@domain.com
Granting broad org admin privileges
Granting broad org admin privileges in 356954763088 to user:ahdemo-admin@cloud-partner-eng-ext.joonix.net and serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/owner ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.projectIamAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/browser ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/accesscontextmanager.policyAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.folderAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.organizationAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.tagAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/orgpolicy.policyAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/owner ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.projectIamAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/browser ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/accesscontextmanager.policyAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.folderAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.organizationAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.tagAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/orgpolicy.policyAdmin ... OK
Granting broad org admin privileges in 749200211693 to user:ahdemo-admin@cloud-partner-eng-ext.joonix.net and serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/owner ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.projectIamAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/browser ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/accesscontextmanager.policyAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.folderAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.organizationAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.tagAdmin ... OK
Grant: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/orgpolicy.policyAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/owner ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.projectIamAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/browser ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/accesscontextmanager.policyAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.folderAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.organizationAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.tagAdmin ... OK
Grant: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/orgpolicy.policyAdmin ... OK
Checking terraform state bucket ... Status: CREATED
Set the following environment variables before running terraform so it will impersonate the newly created SA:
export GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT="terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com"
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com"
```

```
user@workstation:~/git/ahdemo ./setup-1-generate-tf-configs.sh
Generating the terraform configuration based on templates ... 
./s0-bootstrap/backend.tf.tpl > ./s0-bootstrap/backend.tf
./s0-bootstrap/terraform.auto.tfvars.tpl > ./s0-bootstrap/terraform.auto.tfvars
./s1-vpc-sc/backend.tf.tpl > ./s1-vpc-sc/backend.tf
./s2-bigquery-analyticshub/backend.tf.tpl > ./s2-bigquery-analyticshub/backend.tf
./s3-subscriber/backend.tf.tpl > ./s3-subscriber/backend.tf
```

### Stage 1 - Terraform

Configure [ADC](https://cloud.google.com/docs/authentication/provide-credentials-adc) and test authentication / impersonation

```
user@workstation:~$ gcloud auth login
user@workstation:~$ gcloud auth application-default login
user@workstation:~$ export GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT=terraform-d2403@ahdemo-d2403-seed.iam.gserviceaccount.com
user@workstation:~$ export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=terraform-d2403@ahdemo-d2403-seed.iam.gserviceaccount.com
user@workstation:~$ gcloud auth print-access-token --impersonate-service-account $GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
user@workstation:~$ gcloud auth print-access-token --impersonate-service-account $GOOGLE_IMPERSONATE_SERVICE_ACCOUNT >/dev/null 2>&1 && echo "Service Account impersonation working"

```

#### Stage 1.1 - Bootstrap

Configures all projects:
- Enable all required Google Cloud APIs
- Disable DRS on the Analytics Hub Public Exchange projects

Configures the seed project:
- Networking
  - VPC
  - Firewall
  - Private Google Access (PGA)
  - Private Service Access / Networking (PSA)
  - Cloud NAT
  - Cloud DNS for PGA
- Create a jumphost

```
user@workstation:~/git/ahdemo/s0-bootstrap$ tf init
user@workstation:~/git/ahdemo/s0-bootstrap$ tf apply
user@workstation:~/git/ahdemo/s0-bootstrap$ 
```

#### Stage 1.1 - Create VPC-SC resources: (singleton) Global Access Policy, Access Levels, Perimeters

```
user@workstation:~/git/ahdemo/s1-vpc-sc$ tf init
user@workstation:~/git/ahdemo/s1-vpc-sc$ tf apply
user@workstation:~/git/ahdemo/s1-vpc-sc$ 
```

##### DRY-RUN

```
user@workstation:~/git/ahdemo/s1-vpc-sc$ tf destroy
user@workstation:~/git/ahdemo/s1-vpc-sc$ <edit terraform.auto.tfvars and set vpc_sc_dry_run to true>
user@workstation:~/git/ahdemo/s1-vpc-sc$ tf apply
```

##### Troubleshooting

If you are using an already existing organization, you may need to import the global access policy if it already exists. 
The global access policy is a singleton object, only one global access policy is allowed to exist.

Error message:

```
╷
│ Error: Error creating AccessPolicy: googleapi: Error 409: Policy already exists with parent organizations/749200211693
│ 
│   with module.access_context_manager_policy.google_access_context_manager_access_policy.access_policy,
│   on .terraform/modules/access_context_manager_policy/main.tf line 17, in resource "google_access_context_manager_access_policy" "access_policy":
│   17: resource "google_access_context_manager_access_policy" "access_policy" {
│ 
╵
```

Solution:

```
$ gcloud access-context-manager policies list --organization 749200211693 --impersonate-service-account $GOOGLE_IMPERSONATE_SERVICE_ACCOUNT 
WARNING: This command is using service account impersonation. All API calls will be executed as [terraform@ahdemo-240322-seed.iam.gserviceaccount.com].
WARNING: This command is using service account impersonation. All API calls will be executed as [terraform@ahdemo-240322-seed.iam.gserviceaccount.com].
NAME          ORGANIZATION  SCOPES  TITLE          ETAG
588164632170  749200211693          ahdemo-policy  2b9a132235b32dc8

$ tf import module.access_context_manager_policy.google_access_context_manager_access_policy.access_policy 588164632170
```

#### Stage 1.2 - BigQuery, Analytics Hub resources: datasets, views, exchanges, listings

```
user@workstation:~/git/ahdemo/s2-bigquery-analyticshub$ tf init
user@workstation:~/git/ahdemo/s2-bigquery-analyticshub$ tf apply
user@workstation:~/git/ahdemo/s2-bigquery-analyticshub$ 
```

#### Stage 1.3 - Subscriber project, subscribe API call scripts

```
user@workstation:~/git/ahdemo/s3-subscriber$ tf init
user@workstation:~/git/ahdemo/s3-subscriber$ tf apply
user@workstation:~/git/ahdemo/s3-subscriber$ 
```

#### Stage 2 - Testing

The following scripts are generated to help with testing subscription:

- subscribe_ah_dedicated.sh
- subscribe_bqah.sh
- subscribe_nonvpcsc_ah_dedicated.sh

There are API calls for subscribing to the listings and also for deleting the linked datasets that are created as a result of a successful subscription.

#### Stage 3 - Cleanup

1. Delete the resources provisioned by terraform

   ```
   user@workstation:~/git/ahdemo/s3-subscriber$ tf destroy
   user@workstation:~/git/ahdemo/s2-bigquery-analyticshub$ tf destroy
   user@workstation:~/git/ahdemo/s1-vpc-sc$ tf destroy
   user@workstation:~/git/ahdemo/s0-bootstrap$ tf destroy
   ```

2. Delete the resources provisioned by the bootstrap `setup-0-google-cloud.sh` script

   ```
   user@workstation:~/git/ahdemo$ ./cleanup.sh
   Deleting publisher projects
   Deleting project ahdemo-240325-bq-src-ds ... Status: OK
   Deleting project ahdemo-240325-bq-shared-ds ... Status: OK
   Deleting project ahdemo-240325-ah-exchg ... Status: OK
   Deleting project ahdemo-240325-nonvpcsc-ah-exch ... Status: OK
   Deleting project ahdemo-240325-bq-ah-sameproj ... Status: OK
   Deleting subscriber projects
   Deleting project ahdemo-240325-subscr-vpcsc ... Status: OK
   Deleting project ahdemo-240325-subscr ... Status: OK
   Revoking broad org admin privileges
   Revoking broad org admin privileges in 356954763088 from user:ahdemo-admin@cloud-partner-eng-ext.joonix.net and serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/owner ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.projectIamAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/browser ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/accesscontextmanager.policyAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.folderAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.organizationAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.tagAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/orgpolicy.policyAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/owner ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.projectIamAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/browser ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/accesscontextmanager.policyAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.folderAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.organizationAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.tagAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/orgpolicy.policyAdmin ... OK
   Revoking broad org admin privileges in 749200211693 from user:ahdemo-admin@cloud-partner-eng-ext.joonix.net and serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/owner ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.projectIamAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/browser ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/accesscontextmanager.policyAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.folderAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.organizationAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/resourcemanager.tagAdmin ... OK
   Revoke: user:ahdemo-admin@cloud-partner-eng-ext.joonix.net -> roles/orgpolicy.policyAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/owner ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.projectIamAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/browser ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/accesscontextmanager.policyAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.folderAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.organizationAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/resourcemanager.tagAdmin ... OK
   Revoke: serviceAccount:terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com -> roles/orgpolicy.policyAdmin ... OK
   Deleting the terraform service account (terraform-240325@ahdemo-240325-seed.iam.gserviceaccount.com) ... Status: OK
   Deleting terraform state bucket ... Status: OK
   Deleting the seed project
   Deleting project ahdemo-240325-seed ... Status: OK
   Deleting the generated terraform configuration ... 
   - ./s0-bootstrap/backend.tf
   - ./s0-bootstrap/terraform.auto.tfvars
   - ./s1-vpc-sc/backend.tf
   - ./s2-bigquery-analyticshub/backend.tf
   - ./s3-subscriber/backend.tf
   Removing terraform local files ...
   - ./s0-bootstrap/.terraform
   - ./s0-bootstrap/.terraform.lock.hcl
   - ./s1-vpc-sc/.terraform
   - ./s1-vpc-sc/.terraform.lock.hcl
   - ./s2-bigquery-analyticshub/.terraform
   - ./s2-bigquery-analyticshub/.terraform.lock.hcl
   - ./s3-subscriber/.terraform
   - ./s3-subscriber/.terraform.lock.hcl
   ```

## Versioning

Initial Version March 2024

## Code of Conduct

[View](./docs/code-of-conduct.md)

## Contributing

[View](./docs/contributing.md)

## License

[View](./LICENSE)
