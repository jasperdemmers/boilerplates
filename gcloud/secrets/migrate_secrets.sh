#!/bin/bash

# Default values
ENV_FILE=".env"
PREFIX=""
DRY_RUN=false

# Function to display usage
usage() {
  echo "Usage: $0 [-f <env_file>] -p <prefix> [--dry-run]"
  echo "  -f, --file      Specify the .env file to process (default: .env)"
  echo "  -p, --prefix    Specify the prefix for secret names (required)"
  echo "  --dry-run       Simulate the operations without making any changes"
  echo "  -h, --help      Display this help message"
  exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--file)
      ENV_FILE="$2"
      shift 2
      ;;
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

# Check if the .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found at $ENV_FILE"
  exit 1
fi

# Read the .env file line by line
while IFS= read -r line || [ -n "$line" ]; do
  # Remove comments and skip empty lines
  line=$(echo "$line" | sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//')
  if [ -z "$line" ]; then
    continue
  fi

  # Split the line into key and value
  if [[ "$line" != *=* ]]; then
    echo "Skipping invalid line (no '=' found): $line"
    continue
  fi

  KEY=$(echo "$line" | cut -d '=' -f 1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  VALUE=$(echo "$line" | awk -F= '{print substr($0, index($0, $2))}' | sed 's/^"//; s/"$//') # Handle values with spaces

  # Skip lines with empty keys
  if [ -z "$KEY" ]; then
    echo "Skipping invalid line (empty key): $line"
    continue
  fi

  # Convert the key to lowercase and replace underscores with hyphens
  SECRET_NAME="${PREFIX}$(echo "$KEY" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | sed 's/[^a-z0-9-]//g' | cut -c1-63)"

  if $DRY_RUN; then
    echo "[DRY-RUN] Would check if secret exists: $SECRET_NAME"
    echo "[DRY-RUN] Would create secret: $SECRET_NAME"
    echo "[DRY-RUN] Would add value to secret: $SECRET_NAME"
    echo "[DRY-RUN] Secret value: $VALUE"
  else
    # Check if the secret already exists
    if gcloud secrets describe "$SECRET_NAME" >/dev/null 2>&1; then
      echo "Secret $SECRET_NAME already exists. Skipping creation."
    else
      # Create the secret
      if ! gcloud secrets create "$SECRET_NAME" --replication-policy="automatic"; then
        echo "Error: Failed to create secret $SECRET_NAME"
        exit 1
      fi
      echo "Created secret: $SECRET_NAME"
    fi

    # Add the secret value as a new version
    if ! echo -n "$VALUE" | gcloud secrets versions add "$SECRET_NAME" --data-file=-; then
      echo "Error: Failed to add value to secret $SECRET_NAME"
      exit 1
    fi
    echo "Added value to secret: $SECRET_NAME"
  fi

done < "$ENV_FILE"