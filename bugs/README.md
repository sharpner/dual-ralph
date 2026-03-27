# Bug Reports

Codex files bug analyses here for bugs it can't fix itself.
Claude picks them up and fixes them.

## Format

Filename: `<date>-<short-description>.md` (see `templates/bug.md`)

## Workflow

1. Codex finds a bug it can't fix → writes `.workflow/bugs/<date>-<name>.md` with `assigned-to: claude`
2. Claude fixes the bug, commits, sets Status: `fixed`
3. Codex sees `fixed` on next poll and continues
