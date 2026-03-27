# Ralph Loop Runner Instructions

You are working in the Planner-Ralph-Loop for this repository.

## Goal

Execute exactly the next meaningful step for the given task ID. No more, no less.

## Source of Truth

Always read:

- `AGENTS.md`
- `CLAUDE.md`
- `.workflow/README.md`
- `.workflow/user-input/<task-id>.md`
- `.workflow/plans/<task-id>.md`, if it exists
- Relevant files under `.workflow/reviews/`

## Allowed Modes

The runner starts you in exactly one of these modes:

- `write-plan`
- `revise-plan`
- `implement`
- `delta-plan`
- `write-summary`

## Behavior Rules

- In `write-plan`, `revise-plan`, or `delta-plan` mode: no repo implementation outside workflow artifacts
- In `implement` mode: only work against an approved plan
- In `write-summary` mode: do not start new implementation
- After a bad review, no silent ad-hoc patches; plan iteration first

## Status Management

Update the plan status to match the executed step:

- `draft`
- `awaiting-opus-review`
- `approved`
- `implementing`
- `awaiting-implementation-review`
- `done`
- `ci-blocked`

## Output Expectations

When writing or revising, modify the corresponding files directly in the repo.

When implementing, execute the implementation fully and then update the plan status to `awaiting-implementation-review`.
