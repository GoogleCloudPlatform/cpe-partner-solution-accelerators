# Google Cloud Provider Managed BigQuery Projects solution accelerator

This repository hosts automation (Terraform, scripts, python, golang) that creates an end-to-end deployment of the Provider Managed BigQuery Projects solution.

## Bootstrap / prerequisites

For the sake of simplicity (and time) and making it easier to see the whole configuration at once, currently terraform is using symbolic links to share certain configuration in this repository. This may change in the future to adhere to best practices .. which is to avoid using sym
links as much as possible.

If symbolic links don't work, copy the required files into each stage.

The project structure create will look like the following:

```
cloud-partner-eng-ext.joonix.net
  bqprovpr-0819c0-root
    bqprovpr-0819c0-core
    bqprovpr-0819c0-idp
  bqprovpr-0819c0-cx
    bqprovpr-0819c0-cx-cus8216
    bqprovpr-0819c0-cx-jane
    bqprovpr-0819c0-cx-john
  bqprovpr-0819c0-data
    bqprovpr-0819c0-bqds
```

### Prerequisites

- One Google Cloud organization with Cloud Organization Admin rights (which can grant additional roles needed)
  - provider-org-domain.org

- Billing account with role `Billing Account User` to assigne newly created projects to

- A public domain name where on Cloud DNS to be used by the Identity Provider (Keycloak) will be hosted for Workforce Identity Federation
  - provider-org-domain.org

- IAM roles
  - Organization: Project Creator, Organization Admin

### Step 0 - Configure the environment

Copy `setup.env.example` to `setup.env` and modify according to your needs.

```
######################
# Mandatory settings #
######################
# 5 character long suffix - because project ids are globally unique and non-reusable, this is used between subseqent create-destroy operations
# It's also added to all other resources created: Service Account, Access Level, VPC SC Perimeter, BigQuery Dataset/Table/View, Analytics Hub Listing/Exchange
# Potential format: 2 characters month, 2 characters day, "c", 1 character incremental, e.g.: MMDDcI => 0422c0
export SUFFIX=
# Publisher org's numeric id
export PROV_ORG_ID=
# Publisher org's name
export PROV_ORG_NAME=
# Billing Account to link to projects created during stage 0 bootstrap
export BILLING_ACCOUNT_ID=
# Billing Account to link to projects created for customers
export CX_BILLING_ACCOUNT_ID=
# Google User Account that will be able to impersonate the service accounts (usually the one active in `gcloud auth list)`
export GCLOUD_USER=
# Google User Account that will be granted broad privileges on the target provider org
export PROV_ADMIN_USER=
# CloudDNS zone name
export DNS_ZONE_NAME=
# CloudDNS domain name
export DNS_DOMAIN_NAME=
```

Copy `terraform.pmprojects.auto.tfvars.example` to `terraform.pmprojects.auto.tfvars` and modify according to your needs.

```
provider_managed_projects = {
  jane = {
    customer_name = "jane"
    customer_id = "CUS1496"
    provision_managed_identity = true
    provision_service_account = true
    external_identities = [ "bqpmpjane@nonexistent-gmail.com" ]
  }
  john = {
    customer_name = "john"
    customer_id = "CUS7863"
    provision_managed_identity = true
    provision_service_account = true
    external_identities = [ "bqpmpjohn@nonexistent-gmail.com" ]
  }
}
```

Execute `s00-setup-google-cloud-seed.sh` - this will create the seed project for Terraform and initialize a Cloud Storage bucket for storing Terraform state.

Execute `s01-setup-generate-tf-configs.sh` - this will create the terraform configuration (tfvars) and backend configuration (backend.tf) based on the templates.

### Step 1 - Create provider projects and infrastructure for the Identity Provider

In each stage folder, execute `tf init` and `tf apply`.

| Step                                     | Description                                                                                                     |
|------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| s00-provider-org-orgpolicies             | Configure the org policies and execute all Organization level configuration.                                    |
| s01-provider-org-create-projects-bootstrap | Create and configure the provider projects for the Identity Provider and Data assets.                             |
| s02-provider-org-idp-infra               | Deploy the infrastructure required for running the Identity Provider (Keycloak). Create CloudSQL, GKE, CloudDNS, Load |

### Step 2 - Deploy the Identity Provider

```
cd s03-provider-org-deploy-keycloak
./deploy-and-configure-keycloak.sh
```

This step will deploy Keycloak to GKE and create an admin token that can be used by terraform in the next stage to provision provider managed user accounts.

### Step 3 - Provision users, configure Workforce Identity Federation, create the data assets (provider and per customer datasets + Analytics Hub listings)

In each stage folder, execute `tf init` and `tf apply`.

| Step                                     | Description                                                                                                     |
|------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| s04-provider-keycloak-realms-users             | Provision prover managed users                                    |
| s05-provider-wlif-wfif | Configure Workforce Identity Federation                             |
| s06-provider-bq-ds-data-sharing               | Create the source dataset and import data. Create per-user datasets and Analytics Hub listings.               |

### Step 4 - Provision the customer managed projects

```
cd s10-consumer-projects
tf init
tf apply
```

## Versioning

Initial Version August 2024

## Code of Conduct

[View](../docs/code-of-conduct.md)

## Contributing

[View](../docs/contributing.md)

## License

[View](../LICENSE)

## Disclaimer

This project is not an official Google project. It is not supported by
Google and Google specifically disclaims all warranties as to its quality,
merchantability, or fitness for a particular purpose.
