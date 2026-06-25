# odoo-custom

Extends the [official Odoo Docker image](https://hub.docker.com/_/odoo) with
additional pip packages.  Built automatically via GitHub Actions whenever:

- you push changes to this repo (new packages, config tweaks), **or**
- Odoo publishes a new date-tagged image on Docker Hub (daily scheduled check).

Your custom images are stored in **GitHub Container Registry (GHCR)** at:

```
ghcr.io/redleader36/odoo-custom
```

---

## Quick start

### 1. Create the repo on GitHub

Create a new repository at `github.com/redleader36/odoo-custom` (leave it empty
— no README, no licence).

### 2. Clone and push

```bash
git clone git@github.com:redleader36/odoo-custom.git
cd odoo-custom
# Copy the files from this repo into it, or create them fresh:

# ── File: .github/workflows/build.yml ──────────────────────────────────
# ── File: Dockerfile
# ── File: requirements.txt
# ── File: scripts/check-upstream.sh
# ── File: README.md

git add -A && git commit -m "Initial: Odoo custom image with packaging + easypost"
git push origin main
```

The push triggers the **Build Odoo Custom Image** workflow. After ~3 minutes
your custom image is live at `ghcr.io/redleader36/odoo-custom:18.0`.

### 3. Verify the first build

**GitHub → Actions** → watch the workflow run. Once green, check the image:

```bash
docker pull ghcr.io/redleader36/odoo-custom:18.0
docker inspect ghcr.io/redleader36/odoo-custom:18.0 \
  --format '{{index .Config.Labels "com.odoo-custom.base-version"}}'
```

### 4. Configure Unraid

**Docker → Registry → Add:**
| Field        | Value                         |
|--------------|-------------------------------|
| Name         | `GitHub Container Registry`   |
| Server URL   | `ghcr.io`                     |
| Username     | *(your GitHub username)*       |
| Password     | *(GitHub classic PAT with `read:packages` scope)* |

Then edit your Odoo container template → change **Repository** from
`odoo:18.0` to `ghcr.io/redleader36/odoo-custom:18.0`. Apply — Unraid pulls
your custom image.

---

## Auto-update mechanism

```
                    ┌──────────────────┐
                    │  Docker Hub API  │
                    │  /v2/odoo/tags   │
                    └───┬──────────────┘
                        │  daily at 06:00 UTC
                    ┌───▼──────────────┐
                    │  GitHub Actions  │
                    │  (scheduled run) │
                    └───┬──────────────┘
                        ▼
                 "18.0-20260619"
                        │
               ┌────────┴────────┐
               ▼                 ▼
         Already in GHCR?    NEW release
               │                 │
            skip     docker build --build-arg ODOO_VERSION=18.0-20260619
                        docker tag → :18.0-20260619  (pinned)
                        docker tag → :18.0           (rolling)
                        docker push both
```

Your Unraid container uses the **rolling** `:18.0` tag, so it automatically
gets the latest Odoo base with your pip packages. If something breaks, you
can pin to `:18.0-20260619` for rollback.

### Tag strategy

| Tag pattern | Example | Purpose |
|---|---|---|
| `18.0` | `ghcr.io/.../odoo-custom:18.0` | Rolling — use in Unraid |
| `18.0-20260619` | `ghcr.io/.../odoo-custom:18.0-20260619` | Pinned to a specific Odoo release |
| `latest` | `ghcr.io/.../odoo-custom:latest` | Same as `18.0` (convenience) |
| `18` | `ghcr.io/.../odoo-custom:18` | Short-form alias |

---

## Changing the Odoo version

Edit the `ODOO_VERSION` variable at the top of `.github/workflows/build.yml`:

```yaml
env:
  ODOO_VERSION: "17.0"   # or "19.0", etc.
```

## Adding more pip packages

Edit `requirements.txt` — one package per line. Push to `main` → the workflow
rebuilds and the `:18.0` tag updates automatically on GHCR.

## Manual trigger

Go to **GitHub → Actions → Build Odoo Custom Image → Run workflow** to
trigger a build any time.
