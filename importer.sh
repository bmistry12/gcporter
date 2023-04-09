#!/usr/bin/env bash

PROJECT=${1:-default-project}

function sleep_for_seconds() {
  local seconds=${1:-2}
  sleep "$seconds"
}

# API Services
gcloud services list --enabled | awk '{if(NR>1)print $1}' | while read service; do
    service_clean=$(echo "$service" | sed 's/\.googleapis\.com//g')
    command="terraform import 'module.${PROJECT}.module.terraform_gcp.google_PROJECT_service.service_api[\"${service_clean}\"]' ${PROJECT}/${service}"
    echo $command | bash -
    sleep_for_seconds
done

sleep_for_seconds 5

# Service Accounts
gcloud iam service-accounts list | sed -nE 's/^[^ ]+ +([^ ]+@[a-z0-9.-]+)\s+.*/\1/p' | while read account; do
    resource=$(echo $account | awk -F'@' '{ print $1 }')  # Extract the resource name from the email address
    ## TF Config
    cat <<EOF > iam.tf
resource "google_service_account" "${resource}-service_account" {
    account_id="${resource}"
    display_name = "${resource}"
}
EOF
    sleep_for_seconds
    ## Import
    echo "terraform import module.${PROJECT}.google_service_account.${resource}-service_account PROJECTs/${PROJECT}/serviceAccounts/${account}" | bash -
    sleep_for_seconds
done

sleep_for_seconds 5

# BigQuery Datasets
gcloud alpha bq datasets list | awk '{ print $1 }' | awk -F ":" '{ print $2 }' | while read dataset; do
    ## TF Config
cat <<EOF >> bigquery.tf
module bigquery-${dataset} {
    source       = "../../../../../terraform/bigquery"
    dataset_id   = "${dataset}"
}
EOF
    sleep_for_seconds
    ## Import
    echo "terraform import module.${PROJECT}.module.bigquery-${dataset}.google_bigquery_dataset.dataset ${PROJECT}/${dataset}" | bash -
    sleep_for_seconds
done

sleep_for_seconds 5

# Cloud Storage Buckets
gcloud storage ls | sed 's/gs:\/\///; s/\/$//' | while read bucket; do
    underscore_bucket=${bucket//-/_}
    echo "terraform import module.${PROJECT}.module.${underscore_bucket}_storage_bucket.google_storage_bucket.bucket ${PROJECT}/${bucket}" | bash -
    sleep_for_seconds
done
