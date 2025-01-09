#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -p <prefix> [--dry-run]"
  echo "  -p, --prefix    Specify the prefix for secrets to delete (required)"
  echo "  --dry-run       Log the secrets to be deleted without actually deleting them"
  echo "  -h, --help      Display this help message"
  exit 1
}

# Parse command-line arguments
PREFIX=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prefix)
      PREFIX="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Ensure the prefix is provided
if [ -z "$PREFIX" ]; then
  echo "Error: --prefix is required."
  usage
fi

# Get the list of secrets with the specified prefix
SECRETS=$(gcloud secrets list --format="value(name)" | grep "^$PREFIX")

# Check if any secrets match the prefix
if [ -z "$SECRETS" ]; then
  echo "No secrets found with the prefix: $PREFIX"
  exit 0
fi

# Display the secrets to be deleted
echo "The following secrets match the prefix '$PREFIX':"
echo "$SECRETS"

# Handle dry-run mode
if $DRY_RUN; then
  echo "Dry-run mode enabled. No secrets will be deleted."
  exit 0
fi

# Confirm deletion
read -p "Are you sure you want to delete these secrets? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborting deletion."
  exit 0
fi

# Delete the secrets
for SECRET in $SECRETS; do
  echo "Deleting secret: $SECRET"
  gcloud secrets delete "$SECRET" --quiet
done

echo "Secrets with prefix '$PREFIX' have been deleted."