#!/usr/bin/env bash
# Bootstraps WordPress (latest or pinned) inside DDEV.
# Reads optional .env for:
#   WP_VERSION, WP_URL, WP_TITLE, WP_ADMIN_USER, WP_ADMIN_PASS, WP_ADMIN_EMAIL
# Defaults (if not set) are derived from the project folder name.

set -euo pipefail

# Load .env if present
if [[ -f ".env" ]]; then
  set -o allexport
  source .env
  set +o allexport
fi

DOCROOT="${DOCROOT:-public}"

# Derive project name from the current repo folder (no jq dependency)
REPO_ROOT="$(pwd)"
PROJECT_NAME="$(basename "$REPO_ROOT")"

# Derive primary URL from `ddev describe` if WP_URL not provided
PRIMARY_URL="$(ddev describe 2>/dev/null | awk '/https:/{print $1; exit}')"

# Defaults that can be overridden via .env
WP_URL="${WP_URL:-${PRIMARY_URL}}"
WP_TITLE="${WP_TITLE:-${PROJECT_NAME}}"
WP_ADMIN_USER="${WP_ADMIN_USER:-${PROJECT_NAME}-admin}"
WP_ADMIN_PASS="${WP_ADMIN_PASS:-admin}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-${PROJECT_NAME}@example.com}"

# Optional pin: WP_VERSION (empty = latest)
WP_VERSION_OPT=""
if [[ -n "${WP_VERSION:-}" ]]; then
  WP_VERSION_OPT="--version=${WP_VERSION}"
fi

mkdir -p "${DOCROOT}"
cd "${DOCROOT}"

echo "→ Ensuring WordPress core files..."
if [[ ! -f "wp-load.php" ]]; then
  ddev wp core download ${WP_VERSION_OPT}
fi

echo "→ Creating wp-config.php (if missing)..."
if [[ ! -f "wp-config.php" ]]; then
  # DDEV's default DB creds are db/db/db@db
  ddev wp config create \
    --dbname=db \
    --dbuser=db \
    --dbpass=db \
    --dbhost=db \
    --force
fi

echo "→ Installing WordPress (if not already installed)..."
if ! ddev wp core is-installed >/dev/null 2>&1; then
  ddev wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}"
  # Add fresh salts after install (idempotent/safe)
  ddev wp config shuffle-salts || true
fi

echo "✓ WordPress is ready."
echo "🌍 URL: ${WP_URL}"
echo "👤 Admin: ${WP_ADMIN_USER}  (${WP_ADMIN_EMAIL})"
