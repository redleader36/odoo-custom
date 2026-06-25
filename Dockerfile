# ───────────────────────────────────────────────────────────────────────────────
# odoo-custom — Extended Odoo image with additional pip packages
#
# Build args:
#   ODOO_VERSION   —  Odoo image tag to base on  (default: 18.0)
#                     Examples:  18.0, 18.0-20260619, 17.0, 19.0
#
# Usage:
#   docker build --build-arg ODOO_VERSION=18.0 -t my-odoo .
# ───────────────────────────────────────────────────────────────────────────────
ARG ODOO_VERSION=18.0

FROM odoo:${ODOO_VERSION}

LABEL maintainer="redleader36"
LABEL com.odoo-custom.base-version="${ODOO_VERSION}"
LABEL com.odoo-custom.description="Odoo with additional pip packages"
LABEL org.opencontainers.image.source="https://gitlab.com/redleader36/odoo-custom"

# ── System-level dependencies (if needed) ──────────────────────────────
# Uncomment and add packages if your pip modules require them:
# RUN apt-get update && apt-get install -y --no-install-recommends \
#       libsome-dev \
#       && rm -rf /var/lib/apt/lists/*

# ── Additional pip packages ────────────────────────────────────────────
# Add your packages to requirements.txt in this repo. Every build will
# install them inside the Odoo image's Python environment.
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --break-system-packages -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

# ── Optional: custom Odoo addons or scripts ────────────────────────────
# COPY custom-addons/ /mnt/extra-addons/
# COPY entrypoint-hooks/ /opt/odoo/custom-hooks/

# The official Odoo image's ENTRYPOINT and CMD are inherited.
