#!/usr/bin/env bash
# Project configuration for the Dual-Ralph workflow.
# Copy this file and adapt it to your project.

# --- Agent configuration ---
# Which ralph agents to use for Praxis and Theorie.
# Set these in config.sh or via environment variables before starting the loops.
export PRAXIS_AGENT="${PRAXIS_AGENT:-}"
export THEORIE_AGENT="${THEORIE_AGENT:-}"

if [ -z "$PRAXIS_AGENT" ]; then
  echo "PRAXIS_AGENT is not set. Configure .workflow/config.sh or export PRAXIS_AGENT." >&2
  exit 1
fi

if [ -z "$THEORIE_AGENT" ]; then
  echo "THEORIE_AGENT is not set. Configure .workflow/config.sh or export THEORIE_AGENT." >&2
  exit 1
fi

# Labels used for assigned-to routing in plan files.
# Defaults stay role-based so both loops are addressed consistently.
export PRAXIS_LABEL="${PRAXIS_LABEL:-praxis}"
export THEORIE_LABEL="${THEORIE_LABEL:-theorie}"

# Vision/goals document — Praxis reads this to plan the next feature slice
export VISION_FILE="${VISION_FILE:-./VISION.md}"

# Shared and Theorie-specific role descriptions (in repo root)
export AGENTS_FILE="${AGENTS_FILE:-./AGENTS.md}"
export THEORIE_FILE="${THEORIE_FILE:-./THEORIE.md}"

# Local quick test (must run without network — Praxis has none)
export LOCAL_TEST_CMD="${LOCAL_TEST_CMD:-go test ./...}"

# Acceptance criteria
export ACCEPTANCE_CRITERIA="${ACCEPTANCE_CRITERIA:-./.workflow/acceptance-criteria.md}"

# CI system: github-actions | none
# With github-actions, Theorie checks CI status via gh CLI
export CI_SYSTEM="${CI_SYSTEM:-github-actions}"
