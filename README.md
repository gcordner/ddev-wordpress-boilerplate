# WordPress + DDEV Boilerplate

Spin up a fresh WordPress site (latest or pinned) with:
- DDEV (per-project containers, HTTPS, fast file I/O)
- One-shot init script (`ddev init`)
- Adminer add-on (DB UI)
- PHPCS/WPCS (coding standards)
- PHPStan + WordPress extension + stubs (static analysis)

> **Project name & URL:** If you don’t set a `name:` in `.ddev/config.yaml`, DDEV uses the **folder name** as the project name.  
> URL becomes `https://<folder-name>.ddev.site`.

---

## Prerequisites

- Docker Desktop (or equivalent)
- DDEV installed (`ddev version` should work)
- `git` installed

---

## Quick Start (first time)

```bash
# 1) Clone your repo
git clone <YOUR_GIT_URL> my-great-site
cd my-great-site

# 2) (Optional) Override defaults
cp .env.example .env
# Edit .env to pin a WP version or set admin/email, else defaults are used:
# - Title: <folder-name>
# - Admin user: <folder-name>-admin
# - Admin pass: admin
# - Admin email: <folder-name>@example.com

# 3) Start containers
ddev start

# 4) Initialize the project (Composer tools + WordPress install + Adminer)
ddev init
```

When `ddev init` finishes, it prints your primary URL, e.g.:

```
https://my-great-site.ddev.site
```

Log into WP Admin with:
- **User:** `<folder-name>-admin` (or whatever you set in `.env`)
- **Pass:** `admin` (change it after login)

Open **Adminer**:
```bash
ddev adminer
```
Login:
- System: **MySQL**
- Server: **db**
- Username: **db**
- Password: **db**
- Database: **db**

---

## Everyday Commands (cheat sheet)

### DDEV lifecycle
```bash
ddev start        # start this project
ddev stop         # stop this project (containers down, volumes intact)
ddev poweroff     # stop ALL ddev projects globally
ddev list         # list all projects + their URLs/status
ddev describe     # show current project's URL + routed services
ddev ssh          # shell into the web container
ddev launch       # open the site in your browser
```

### Project init / setup
```bash
ddev init         # runs .ddev/commands/web/init (Composer + WP + Adminer)
```

### Adminer (DB UI)
```bash
ddev adminer      # open Adminer URL for this project
```

### WordPress CLI & Composer
```bash
ddev wp <cmd>                 # WP-CLI (e.g., ddev wp plugin list)
ddev composer install         # install dev tools (PHPCS, PHPStan, etc.)
ddev composer update          # update dev tools
```

### Code quality
If you added the **Composer script aliases**:
```bash
ddev composer lint            # PHPCS (uses phpcs.xml.dist if present)
ddev composer fix             # PHPCBF (auto-fix style issues)
ddev composer stan            # PHPStan analysis (uses phpstan.neon.dist)
```

If you added the **Makefile** targets:
```bash
make lint
make fix
make stan
```

### Snapshots (nice to have)
```bash
ddev snapshot                     # save DB snapshot
ddev snapshot --list              # list snapshots
ddev snapshot restore <name>      # restore a snapshot
```

---

## Files in this boilerplate

```
.ddev/
  config.yaml                     # DDEV project config (no 'name:' → uses folder name)
  commands/web/init               # custom init command (Composer + WP + Adminer)
  scripts/wp-install.sh           # installs WP (latest or pinned), creates config, installs site
.env.example                      # copy to .env to override title/user/email/version
.gitignore                        # keep repo clean (vendor, uploads, cache)
composer.json                     # dev tools: PHPCS/WPCS, PHPStan, WP extension
phpcs.xml.dist                    # PHPCS defaults: WordPress ruleset, paths, excludes
phpstan.neon.dist                 # PHPStan defaults: level, WordPress extension + stubs
```

**Defaults if `.env` is not set:**
- **Site Title:** `<folder-name>`
- **Admin User:** `<folder-name>-admin`
- **Admin Email:** `<folder-name>@example.com`
- **Admin Pass:** `admin`
- **WP Version:** latest

---

## Pinning WordPress version

Set `WP_VERSION` in `.env` before `ddev init`, e.g.:

```
WP_VERSION=6.6.2
```

Leave it blank for latest.

---

## Linting & Static Analysis

**PHPCS (WordPress Coding Standards):**
```bash
ddev composer lint
# or
ddev exec vendor/bin/phpcs
```

**PHPCBF (auto-fix what can be fixed):**
```bash
ddev composer fix
# or
ddev exec vendor/bin/phpcbf
```

**PHPStan (with WordPress awareness):**
```bash
ddev composer stan
# or
ddev exec vendor/bin/phpstan analyse
```

Configuration files (`phpcs.xml.dist` and `phpstan.neon.dist`) define:
- paths to scan (`public/wp-content/themes/my-theme`, etc.),
- excludes (`vendor`, `node_modules`, `dist`),
- WP rules/extension/stubs,
- initial PHPStan strictness (`level: 5`).

Raise PHPStan’s `level` gradually as you clean up findings.

---

## Adminer notes

- Installed automatically by `ddev init` (first run) via the DDEV add-on.
- To remove later:
  ```bash
  ddev add-on remove ddev/ddev-adminer
  ddev restart
  ```

---

## Troubleshooting

- **URL didn’t print?**  
  Run `ddev describe` to see the primary URL and routed services.

- **Re-run init safely**  
  `ddev init` is idempotent: it’ll skip steps that are already done.

- **WP didn’t install?**  
  Ensure containers are started (`ddev start`), then run `ddev init` again.

- **Change admin creds after install**  
  Use WP Admin or WP-CLI:
  ```bash
  ddev wp user update <user> --user_pass=<newpass>
  ```

---

## Cleaning up (this project only)

Stops and removes containers/volumes for **this** project (keeps code):
```bash
ddev delete -Oy
```

Recreate:
```bash
ddev start
ddev init
```
