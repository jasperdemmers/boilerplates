#!/bin/bash

# Default values
ENV_FILE=".env"
PREFIX=""
OUTPUT_FILE="gcp_secrets.env"

# Function to display usage
usage() {
  echo "Usage: $0 [-f <env_file>] -p <prefix>"
  echo "  -f, --file      Specify the .env file to process (default: .env)"
  echo "  -p, --prefix    Specify the prefix for secret names (required)"
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

# Temporary files to store reports
DIFFERENT_VALUES=$(mktemp)
LOCAL_ONLY=$(mktemp)
GCP_ONLY=$(mktemp)

# Local secrets
LOCAL_SECRETS_KEYS=()
LOCAL_SECRETS_VALUES=()

# Read local secrets into arrays
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
  SECRET_NAME="${PREFIX}$(echo "$KEY" | tr '[:upper:]' '[:lower:]' | tr '_' '-')"

  LOCAL_SECRETS_KEYS+=("$SECRET_NAME")
  LOCAL_SECRETS_VALUES+=("$VALUE")
done < "$ENV_FILE"

# Fetch all GCP secrets starting with the prefix
GCP_SECRETS=$(gcloud secrets list --filter="$PREFIX" --format="value(name)")

# GCP secrets arrays
GCP_SECRETS_KEYS=()
GCP_SECRETS_VALUES=()

# Process GCP secrets
for SECRET_NAME in $GCP_SECRETS; do
  # Fetch the latest secret value
  SECRET_VALUE=$(gcloud secrets versions access latest --secret="$SECRET_NAME" 2>/dev/null)
  GCP_SECRETS_KEYS+=("$SECRET_NAME")
  GCP_SECRETS_VALUES+=("$SECRET_VALUE")
done

# Output GCP secrets to a file in .env format
echo "# GCP Secrets" > "$OUTPUT_FILE"
for i in "${!GCP_SECRETS_KEYS[@]}"; do
  SECRET_NAME="${GCP_SECRETS_KEYS[$i]}"
  SECRET_VALUE="${GCP_SECRETS_VALUES[$i]}"

  # Convert secret name to .env format
  ENV_KEY=$(echo "$SECRET_NAME" | sed "s/^$PREFIX//" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

  # Properly escape and quote the value
  ENV_VALUE=$(printf '%s' "$SECRET_VALUE" | sed 's/"/\\"/g')
  echo "${ENV_KEY}=\"${ENV_VALUE}\"" >> "$OUTPUT_FILE"
done

echo "GCP secrets have been written to $OUTPUT_FILE."

# Compare local and GCP secrets
for i in "${!LOCAL_SECRETS_KEYS[@]}"; do
  LOCAL_SECRET="${LOCAL_SECRETS_KEYS[$i]}"
  LOCAL_VALUE="${LOCAL_SECRETS_VALUES[$i]}"

  # Check if the local secret exists in GCP
  FOUND_IN_GCP=false
  for j in "${!GCP_SECRETS_KEYS[@]}"; do
    if [ "$LOCAL_SECRET" == "${GCP_SECRETS_KEYS[$j]}" ]; then
      FOUND_IN_GCP=true
      if [ "$LOCAL_VALUE" != "${GCP_SECRETS_VALUES[$j]}" ]; then
        echo "$LOCAL_SECRET" >> "$DIFFERENT_VALUES"
      fi
      break
    fi
  done

  if [ "$FOUND_IN_GCP" = false ]; then
    echo "$LOCAL_SECRET" >> "$LOCAL_ONLY"
  fi
done

# Find GCP secrets not in the local .env file
for j in "${!GCP_SECRETS_KEYS[@]}"; do
  GCP_SECRET="${GCP_SECRETS_KEYS[$j]}"
  FOUND_IN_LOCAL=false
  for i in "${!LOCAL_SECRETS_KEYS[@]}"; do
    if [ "$GCP_SECRET" == "${LOCAL_SECRETS_KEYS[$i]}" ]; then
      FOUND_IN_LOCAL=true
      break
    fi
  done

  if [ "$FOUND_IN_LOCAL" = false ]; then
    echo "$GCP_SECRET" >> "$GCP_ONLY"
  fi
done

# Generate the report
echo "Comparison Report"
echo "================="
echo
echo "Secrets with different values:"
if [ -s "$DIFFERENT_VALUES" ]; then
  cat "$DIFFERENT_VALUES"
else
  echo "None"
fi
echo
echo "Secrets that exist locally but not in GCP:"
if [ -s "$LOCAL_ONLY" ]; then
  cat "$LOCAL_ONLY"
else
  echo "None"
fi
echo
echo "Secrets that exist in GCP but not locally:"
if [ -s "$GCP_ONLY" ]; then
  cat "$GCP_ONLY"
else
  echo "None"
fi

# Cleanup temporary files
rm -f "$DIFFERENT_VALUES" "$LOCAL_ONLY" "$GCP_ONLY"