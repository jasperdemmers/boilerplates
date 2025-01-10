# Migrate Secrets Script

This Bash script simplifies the migration of secrets from a `.env` file to Google Cloud Secret Manager. It supports custom file paths, prefixes, and a dry-run mode for testing.

---

## Features

- **Custom `.env` File**: Specify a custom `.env` file to process using the `-f` or `--file` option.
- **Custom Prefix**: Define a custom prefix for secret names using the `-p` or `--prefix` option.
- **Dry-Run Mode**: Simulate the process without making changes using the `--dry-run` option.
- **Automatic Handling**: Skips creating secrets if they already exist and adds new values as versions.
- **Error Handling**: Validates `.env` file existence and handles invalid lines gracefully.

---

## Usage

### Syntax
```bash
./migrate-secrets.sh [-f <env_file>] -p <prefix> [--dry-run]
```

### Options
| Option         | Description                                                          | Default Value          |
|----------------|----------------------------------------------------------------------|------------------------|
| `-f`, `--file` | Specify the `.env` file to process.                                 | `.env`                 |
| `-p`, `--prefix` | Specify the prefix for secret names.                              | Required               |
| `--dry-run`    | Simulate the operations without making changes.                     | N/A                    |
| `-h`, `--help` | Display usage information.                                          | N/A                    |

---

## Examples

### Default Usage
If no custom `.env` file is specified, the script processes the default `.env` file with a provided prefix:
```bash
./migrate-secrets.sh -p "prd-simplepark-"
```

### Custom `.env` File
To use a specific `.env` file:
```bash
./migrate-secrets.sh -f custom.env -p "dev-app-"
```

### Dry-Run Mode
To preview the operations without making changes:
```bash
./migrate-secrets.sh -f custom.env -p "dev-app-" --dry-run
```

---

## How It Works

1. **File Validation**: Checks for the existence of the `.env` file.
2. **Process `.env` File**:
   - Reads the file line by line, skipping comments and invalid lines.
   - Extracts `KEY=VALUE` pairs from valid lines.
3. **Key Formatting**:
   - Converts keys to lowercase.
   - Replaces underscores (`_`) with hyphens (`-`).
   - Prepends the custom prefix to form the secret name.
4. **Secret Management**:
   - Checks if the secret exists in Google Cloud Secret Manager.
   - Creates the secret if it does not exist.
   - Adds the value as a new version of the secret.
5. **Dry-Run**: If enabled, simulates the operations without making changes.
6. **Logging**: Outputs the status of each operation to the terminal.

---

## Prerequisites

1. **Google Cloud SDK**: Ensure the `gcloud` CLI is installed and authenticated.
   - [Install Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. **Secret Manager API**: Enable the Secret Manager API in your Google Cloud project.
   ```bash
   gcloud services enable secretmanager.googleapis.com
   ```
3. **Permissions**: Ensure your Google Cloud account has permissions to create and manage secrets.

---

## Notes

- The script assumes that the `.env` file uses the standard format: `KEY=VALUE`.
- Use the `--dry-run` option to preview the operations before applying changes.

---

# Bulk Delete Secrets Script

This Bash script allows you to bulk delete secrets in Google Cloud Secret Manager based on a specified prefix. It provides options for a dry run to preview the secrets to be deleted and requires confirmation before performing the deletion.

---

## Features

- **Prefix-Based Deletion**: Deletes all secrets that match a specified prefix.
- **Dry-Run Mode**: Preview the secrets that would be deleted without actually deleting them.
- **Confirmation Prompt**: Asks for user confirmation before proceeding with deletion.
- **Error Handling**: Ensures that the prefix is provided and handles cases where no secrets match the prefix.

---

## Usage

### Script Syntax
```bash
./bulk-delete-secrets.sh -p <prefix> [--dry-run]
```

### Options
| Option         | Description                                                          | Required |
|----------------|----------------------------------------------------------------------|----------|
| `-p`, `--prefix` | Specify the prefix for secrets to delete.                           | Yes      |
| `--dry-run`      | Log the secrets to be deleted without actually deleting them.       | No       |
| `-h`, `--help`   | Display usage information.                                          | No       |

---

## Examples

### Delete Secrets with a Prefix
To delete all secrets with the prefix `prd-simplepark-`:
```bash
./bulk-delete-secrets.sh -p prd-simplepark-
```

### Dry Run
To preview the secrets that would be deleted without actually deleting them:
```bash
./bulk-delete-secrets.sh -p prd-simplepark- --dry-run
```

---

## How It Works

1. **Prefix Validation**: Ensures that a prefix is provided as an argument.
2. **List Matching Secrets**: Uses the `gcloud secrets list` command to find secrets that match the specified prefix.
3. **Dry Run**:
   - If the `--dry-run` option is specified, the script lists the matching secrets without deleting them.
4. **Confirmation Prompt**:
   - If not in dry-run mode, the script prompts the user to confirm the deletion.
5. **Delete Secrets**:
   - Deletes each secret using the `gcloud secrets delete` command.
6. **Logging**: Outputs the status of each operation to the terminal.

---

## Notes

- Ensure that you have the proper permissions to delete secrets in your Google Cloud project.
- Use the `--dry-run` option to preview the secrets before deletion to avoid accidental data loss.

---

## Prerequisites

1. **Google Cloud SDK**: Ensure the `gcloud` CLI is installed and authenticated.
   - [Install Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. **Permissions**: Ensure your Google Cloud account has the necessary permissions to delete secrets.