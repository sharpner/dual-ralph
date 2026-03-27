#!/usr/bin/env bash
# Project configuration for the Dual-Ralph workflow.
# Copy this file and adapt it to your project.

# --- Agent configuration ---
# Which ralph agents to use for planner and reviewer roles.
# Defaults: codex plans+implements, claude-code reviews.
# Override to run both as the same agent (e.g. REVIEWER_AGENT=codex).
export PLANNER_AGENT="${PLANNER_AGENT:-codex}"
export REVIEWER_AGENT="${REVIEWER_AGENT:-claude-code}"

# Labels used for assigned-to routing in plan files.
# Auto-derived from agent name (strips "-code" suffix), override if needed.
export PLANNER_LABEL="${PLANNER_LABEL:-${PLANNER_AGENT%-code}}"
export REVIEWER_LABEL="${REVIEWER_LABEL:-${REVIEWER_AGENT%-code}}"

# Vision/goals document — planner reads this to plan the next feature slice
export VISION_FILE="${VISION_FILE:-./VISION.md}"

# Agent role descriptions (in repo root)
export AGENTS_FILE="${AGENTS_FILE:-./AGENTS.md}"
export CLAUDE_FILE="${CLAUDE_FILE:-./CLAUDE.md}"

# Local quick test (must run without network — planner has none)
export LOCAL_TEST_CMD="${LOCAL_TEST_CMD:-go test ./...}"

# Acceptance criteria
export ACCEPTANCE_CRITERIA="${ACCEPTANCE_CRITERIA:-./.workflow/acceptance-criteria.md}"

# CI system: github-actions | none
# With github-actions, reviewer checks CI status via gh CLI
export CI_SYSTEM="${CI_SYSTEM:-github-actions}"
