#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/config.sh"

CI_CHECK=""
if [ "$CI_SYSTEM" = "github-actions" ]; then
  CI_CHECK="check GitHub Actions CI status: gh run list --branch \$(git branch --show-current) --limit 1"
fi


ralph \
  --agent "$THEORIE_AGENT" \
  --allow-all \
  --no-commit \
  "Check ALL plans in .workflow/plans/, all bugs in .workflow/bugs/, and feedback in .workflow/feedback/.

  Read $AGENTS_FILE and $THEORIE_FILE before every action.

  ## IMPORTANT: assigned-to auto-correction

  $PRAXIS_LABEL often forgets to set assigned-to: $THEORIE_LABEL. Therefore:
  - If a plan has Status: awaiting-plan-review or awaiting-implementation-review
    but assigned-to: $PRAXIS_LABEL (or no assigned-to at all),
    correct assigned-to: $THEORIE_LABEL, commit and push IMMEDIATELY.
  - Then handle the plan normally (see below).

  ## Plans (.workflow/plans/)

  1. Status: awaiting-plan-review (regardless of assigned-to) → Plan review:
     - read .workflow/user-input/<task-id>.md, the plan, $ACCEPTANCE_CRITERIA and previous reviews
     - write .workflow/reviews/<task-id>-plan-rN.md (N = next number)
     - list concrete findings with severity and affected files
     - set assigned-to: $PRAXIS_LABEL in the plan (do NOT change the status)

  2. Status: awaiting-implementation-review (regardless of assigned-to) → Implementation review:
     - read the plan, all previous reviews, $ACCEPTANCE_CRITERIA and the relevant code changes (git log, git diff)
     - $CI_CHECK
     - check all acceptance criteria explicitly
     - write .workflow/reviews/<task-id>-implementation-rN.md
     - if Decision: approved → move plan to .workflow/plans/resolved/
     - set assigned-to: $PRAXIS_LABEL in the plan (do NOT change the status)

  3. Status: ci-blocked + assigned-to: $THEORIE_LABEL → Resolve CI blocker:
     - $CI_CHECK
     - if CI is already GREEN: the blocker is already resolved
       → set Status: awaiting-implementation-review, assigned-to stays $THEORIE_LABEL
       → commit and push
       → immediately perform implementation review (see point 2)
     - if CI is RED: diagnose and fix the problem
       → commit fix and push
       → wait for CI
       → if green: set Status: awaiting-implementation-review, perform review

  ## Bugs (.workflow/bugs/)

  4. Status: open + assigned-to: $THEORIE_LABEL → Fix bug:
     - read the error analysis
     - diagnose and fix the bug
     - set Status: fixed
     - commit and push

  ## Feedback (.workflow/feedback/)

  5. Check for files that don't have a ## Theorie Assessment yet → Process feedback:
     - read the feedback and affected areas
     - assess relevance (high/medium/low) and write your assessment in ## Theorie Assessment
     - if relevant: incorporate points into next $PRAXIS_LABEL review or create a bug report
     - commit and push

  ## Idle

  6. Nothing assigned and no new feedback → wait 5 minutes (sleep 300), then check again.

  You do NOT implement features. You may commit bug fixes and infra fixes.
  You write review files, assess feedback, and move completed plans to resolved/."
