# Plans

This folder contains the implementation plan per task, written by the planner agent.

The plan is the approval artifact for the plan gate. No implementation without an approved plan.

## File

```text
plans/<task-id>.md
```

See `templates/plan.md` for the template.

## Rules

- The plan must be concrete enough for the reviewer to review real risks
- Decisions must be clearly locked
- Tests must be named before implementation
- When the reviewer requests changes, the same plan is updated with a new revision instead of silently moving on
- Every post-review plan change needs a brief change log entry
- After a bad implementation review, a new plan revision or delta plan is required before the next implementation round
