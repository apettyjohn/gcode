# ===========================================================================
# Gcode - Lightweight Coding Agent
# ===========================================================================
# Runs as a non-root user (gcode) with filesystem access restricted to:
#   /workspace  - persistent volume for cloned repos, worktrees, projects
#   /app        - read-only application code (writable only in dev via bind mount)
# ===========================================================================

FROM agnohq/python:3.12

# ---------------------------------------------------------------------------
# System dependencies
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Git configuration (safe defaults for agent use)
# ---------------------------------------------------------------------------
RUN git config --system init.defaultBranch main \
    && git config --system user.name "Gcode" \
    && git config --system user.email "gcode@agno.com" \
    && git config --system advice.detachedHead false

# ---------------------------------------------------------------------------
# Create non-root user
# ---------------------------------------------------------------------------
RUN groupadd -r gcode && useradd -r -g gcode -m -s /bin/bash gcode

# ---------------------------------------------------------------------------
# Application code
# ---------------------------------------------------------------------------
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV PYTHONPATH=/app

# ---------------------------------------------------------------------------
# Directory setup & permissions
# ---------------------------------------------------------------------------
# /workspace - agent's persistent coding workspace (Docker volume)
RUN mkdir -p /workspace \
    && chown -R gcode:gcode /workspace \
    && chmod 755 /app

# Ensure the gcode user CANNOT write outside /workspace
# /app is readable but not writable (agent can read its own code, not modify it)
# Everything else is owned by root and not writable by gcode

# ---------------------------------------------------------------------------
# GitHub token configuration
# ---------------------------------------------------------------------------
# The GITHUB_TOKEN env var is used for cloning private repos.
# Git credential helper stores it in memory (never written to disk).
# Set via: docker compose env or .env file
# ---------------------------------------------------------------------------
RUN git config --system credential.helper 'store --file=/dev/null' \
    && printf '%s\n' \
        '#!/bin/bash' \
        'if [ -n "$GITHUB_TOKEN" ]; then' \
        '    echo "protocol=https"' \
        '    echo "host=github.com"' \
        '    echo "username=x-access-token"' \
        '    echo "password=$GITHUB_TOKEN"' \
        'fi' \
        > /usr/local/bin/git-credential-gcode \
    && chmod +x /usr/local/bin/git-credential-gcode \
    && git config --system credential.helper '/usr/local/bin/git-credential-gcode'

# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------
RUN chmod +x /app/scripts/entrypoint.sh
ENTRYPOINT ["/app/scripts/entrypoint.sh"]

# ---------------------------------------------------------------------------
# Switch to non-root user
# ---------------------------------------------------------------------------
USER gcode
WORKDIR /app

# ---------------------------------------------------------------------------
# Default command (overridden by compose)
# ---------------------------------------------------------------------------
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
