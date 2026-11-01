#!/usr/bin/env bash
# Creates the Azure Storage backend used for Terraform state. Run once per environment.
# Usage: ./scripts/bootstrap-state.sh <subscription_id> <location> <resource_group> <storage_account> [container]
set -euo pipefail

SUBSCRIPTION_ID="${1:?subscription id}"
LOCATION="${2:?location, e.g. uksouth}"
RG="${3:?state resource group}"
SA="${4:?state storage account (globally unique, lowercase, 3-24 chars)}"
CONTAINER="${5:-tfstate}"

az account set --subscription "$SUBSCRIPTION_ID"

az group create --name "$RG" --location "$LOCATION" --output none

az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_GRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --allow-shared-key-access false \
  --output none

# Soft delete + versioning so a bad apply can be recovered.
az storage account blob-service-properties update \
  --account-name "$SA" \
  --resource-group "$RG" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 14 \
  --output none

SA_ID=$(az storage account show --name "$SA" --resource-group "$RG" --query id -o tsv)
ME=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --assignee-object-id "$ME" \
  --assignee-principal-type User \
  --role "Storage Blob Data Contributor" \
  --scope "$SA_ID" \
  --output none || true

# Role assignments can take a minute to propagate.
sleep 30

az storage container create \
  --name "$CONTAINER" \
  --account-name "$SA" \
  --auth-mode login \
  --output none

echo "State backend ready: $SA/$CONTAINER (rg: $RG)"
echo "Grant the same 'Storage Blob Data Contributor' role to any CI service principal."
