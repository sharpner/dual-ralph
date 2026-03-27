# Bug Reports

Praxis files bug analyses here for bugs it can't fix itself.
Theorie picks them up and fixes them.

## Format

Filename: `<date>-<short-description>.md` (see `templates/bug.md`)

## Workflow

1. Praxis finds a bug it can't fix → writes `.workflow/bugs/<date>-<name>.md` with `assigned-to: <theorie-label>`
2. Theorie fixes the bug, commits, sets Status: `fixed`
3. Praxis sees `fixed` on next poll and continues
