# Bug Reports

The planner files bug analyses here for bugs it can't fix itself.
The reviewer picks them up and fixes them.

## Format

Filename: `<date>-<short-description>.md` (see `templates/bug.md`)

## Workflow

1. Planner finds a bug it can't fix → writes `.workflow/bugs/<date>-<name>.md` with `assigned-to: <reviewer-label>`
2. Reviewer fixes the bug, commits, sets Status: `fixed`
3. Planner sees `fixed` on next poll and continues
