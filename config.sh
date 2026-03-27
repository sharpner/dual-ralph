#!/usr/bin/env bash
# Project configuration for the Dual-Ralph workflow.
# Copy this file and adapt it to your project.

# Vision/goals document — Codex reads this to plan the next feature slice
export VISION_FILE="${VISION_FILE:-./VISION.md}"

# Agent role descriptions (in repo root)
export AGENTS_FILE="${AGENTS_FILE:-./AGENTS.md}"
export CLAUDE_FILE="${CLAUDE_FILE:-./CLAUDE.md}"

# Local quick test (must run without network — Codex has none)
export LOCAL_TEST_CMD="${LOCAL_TEST_CMD:-go test ./...}"

# Acceptance criteria
export ACCEPTANCE_CRITERIA="${ACCEPTANCE_CRITERIA:-./.workflow/acceptance-criteria.md}"

# CI system: github-actions | none
# With github-actions, Claude checks CI status via gh CLI
export CI_SYSTEM="${CI_SYSTEM:-github-actions}"
