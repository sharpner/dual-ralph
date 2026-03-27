# Acceptance Criteria

Every implementation must meet these criteria before it can be marked as done.

## 1. Tests Green

Local tests (`$LOCAL_TEST_CMD`) and CI must pass. No exceptions.

## 2. No Scope Creep

Only implement what the plan specifies. No silent extensions, no "I did this while I was at it" changes.

## 3. Visible Proof

Every change must provide visible proof — test, example, demo. "It compiles" is not enough.

## 4. No New Workarounds

No TODOs, no hacks, no "we'll fix this later" comments. If something can't be done cleanly, the plan is wrong, not the code.

## 5. Documentation Current

If public APIs or behavior change, README/docs must be updated in the same commit.

## 6. Review Artifact

Every implementation ends with a review in `.workflow/reviews/`. No silent approvals.
