#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/config.sh"

ralph \
  --agent "$PLANNER_AGENT" \
  --allow-all \
  --no-commit \
  --completion-promise "VISION COMPLETE" \
  "We are in auto-mode. Check if a plan in .workflow/plans/ is assigned to you (assigned-to: $PLANNER_LABEL).

  IMPORTANT: Read $AGENTS_FILE before every action.

  ## Plan Header Template

  Every plan MUST have this exact header. Copy it and fill in the values:

  \`\`\`
  # YYYY-MM-DD-short-slug

  Status: <draft|awaiting-plan-review|approved|implementing|awaiting-implementation-review|ci-blocked|done>
  assigned-to: <$PLANNER_LABEL|$REVIEWER_LABEL>
  \`\`\`

  When to use which value:
  - You create a plan → Status: awaiting-plan-review, assigned-to: $REVIEWER_LABEL
  - You finish implementing → Status: awaiting-implementation-review, assigned-to: $REVIEWER_LABEL
  - You revise a plan → Status: awaiting-plan-review, assigned-to: $REVIEWER_LABEL
  - CI fails (not your code) → Status: ci-blocked, assigned-to: $REVIEWER_LABEL
  - $REVIEWER_LABEL gives you work back → Status: approved or implementing, assigned-to: $PLANNER_LABEL

  ## CI Gate

  You have NO network access. No gh, no curl, no web searches. Everything local.
  1. Run $LOCAL_TEST_CMD as local test
  2. Commit and push: git push origin HEAD
  3. $REVIEWER_LABEL checks CI status for you and reports errors via reviews
  4. When local tests are green, you may hand off to $REVIEWER_LABEL

  ## Routing

  Check ALL plans with assigned-to: $PLANNER_LABEL and handle the highest priority one:

  Priority 1 — Complete implementation:
  If a plan has Status approved or implementing + no open changes-requested review:
     - read the plan and all reviews
     - implement fully against the plan, no silent scope changes
     - run $LOCAL_TEST_CMD
     - commit all changes INCLUDING review files that $REVIEWER_LABEL wrote
     - push with git push origin HEAD
     - set in plan: Status: awaiting-implementation-review, assigned-to: $REVIEWER_LABEL

  Priority 2 — Address review feedback:
  If latest review has Decision: changes-requested (implementation review):
     - address all findings from the review
     - run $LOCAL_TEST_CMD
     - commit and push
     - set in plan: Status: awaiting-implementation-review, assigned-to: $REVIEWER_LABEL

  Priority 3 — Revise plan:
  If latest review has Decision: changes-requested (plan review):
     - address all findings explicitly in ## Change Log
     - set in plan: Status: awaiting-plan-review, assigned-to: $REVIEWER_LABEL

  Priority 4 — Write next feature plan:
  If ALL plans with assigned-to: $PLANNER_LABEL have already been handed to $REVIEWER_LABEL
  OR if you are waiting on CI/review and have nothing else to do:
     - read $VISION_FILE and $AGENTS_FILE
     - choose the next meaningful slice according to the vision
     - write .workflow/user-input/<task-id>.md and .workflow/plans/<task-id>.md
     - set in plan: Status: awaiting-plan-review, assigned-to: $REVIEWER_LABEL
     - You may prepare multiple plans in parallel!

  BUG REPORTS: If you find a bug you cannot fix:
     - write .workflow/bugs/<date>-<short-description>.md with assigned-to: $REVIEWER_LABEL
     - describe symptom, analysis, affected files, reproduction

  ESCALATION: If local tests fail after 3 attempts and the problem is NOT in your feature code:
     - set in plan: Status: ci-blocked, assigned-to: $REVIEWER_LABEL
     - write the error output in ## Change Log
     - commit and push
     - Switch to Priority 4 and plan the next feature slice!

  Only implement against approved plans. No scope creep.
  $PLANNER_LABEL ALWAYS commits — $REVIEWER_LABEL NEVER commits (except bug fixes and infra fixes).
  Completed plans (Status: done) are moved to .workflow/plans/resolved/.

  When all goals from $VISION_FILE are fully achieved and tests are green,
  output exactly: <promise>VISION COMPLETE</promise>"
