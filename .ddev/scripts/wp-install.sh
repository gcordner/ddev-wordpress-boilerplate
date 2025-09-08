#!/usr/bin/env bash
# Bootstraps WordPress (latest or pinned) INSIDE the DDEV web container.

set -euo pipefail

# Load .env if present (mounted into container)
if [[ -f ".env" ]]; then
  set -o allexport
  source .env
  set +o allexport
fi

DOCROOT="${DOCROOT:-public}"

# DDEV provides these inside the container:
#   DDEV_SITENAME, DDEV_PRIMARY_URL
PROJECT_NAME="${DDEV_SITENAME:-$(basename "$(pwd)")}"
PRIMARY_URL="${DDEV_PRIMARY_URL:-https://${PROJECT_NAME}.ddev.site}"

# Defaults (overridable via .env)
WP_URL="${WP_URL:-${PRIMARY_URL}}"
WP_TITLE="${WP_TITLE:-${PROJECT_NAME}}"
WP_ADMIN_USER="${WP_ADMIN_USER:-${PROJECT_NAME}-admin}"
WP_ADMIN_PASS="${WP_ADMIN_PASS:-admin}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-${PROJECT_NAME}@example.com}"

WP_VERSION_OPT=""
if [[ -n "${WP_VERSION:-}" ]]; then
  WP_VERSION_OPT="--version=${WP_VERSION}"
fi

mkdir -p "${DOCROOT}"
cd "${DOCROOT}"

echo "→ Ensuring WordPress core files..."
if [[ ! -f "wp-load.php" ]]; then
  wp core download ${WP_VERSION_OPT}
fi

echo "→ Creating wp-config.php (if missing)..."
if [[ ! -f "wp-config.php" ]]; then
  wp config create \
    --dbname=db \
    --dbuser=db \
    --dbpass=db \
    --dbhost=db \
    --force
fi

echo "→ Installing WordPress (if not already installed)..."
if ! wp core is-installed >/dev/null 2>&1; then
  wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}"
  wp config shuffle-salts || true
fi

echo "✓ WordPress is ready."
echo "🌍 URL: ${WP_URL}"
echo "👤 Admin: ${WP_ADMIN_USER}  (${WP_ADMIN_EMAIL})"
