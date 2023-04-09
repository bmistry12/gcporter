# GCPorter

This is a lightweight Bash script that imports existing Google Cloud Platform (GCP) resources into a Terraform state file. For some services it will also generate the Terraform code.

The script imports resources for the following GCP services:

- API Services
- Service Accounts [+ code]
- BigQuery Datasets [+ code]
- Cloud Storage Buckets

## Requirements
To use this script, the following tools must be installed and configured:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Google Cloud SDK ([gcloud](https://cloud.google.com/sdk/docs/install))

### Authenticatng the Google Provider (for Terraform)
1. Run `gcloud init`
2. (Then for Terraform) `gcloud auth application-default login`

## Usage
```
./importer.sh <project_id>
```

**Note:**

This script is intended to be used as a starting point for importing existing GCP resources into Terraform. It may need to be modified to fit your specific use case.
