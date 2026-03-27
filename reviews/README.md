# Reviews

This folder contains all Theorie reviews.

Two review types exist:

- Plan review (before implementation)
- Implementation review (after implementation)

## File Names

```text
reviews/<task-id>-plan-r1.md
reviews/<task-id>-plan-r2.md
reviews/<task-id>-implementation-r1.md
reviews/<task-id>-implementation-r2.md
```

See `templates/review.md` for the template.

## Rules

- Every finding is concrete and references a file, behavior, or test gap
- `approved` without clear rationale is invalid
- `changes-requested` needs concrete points that Praxis can act on
- `changes-requested` forces a new plan revision or delta plan before the next implementation round
- New review round means new file with incremented revision number
