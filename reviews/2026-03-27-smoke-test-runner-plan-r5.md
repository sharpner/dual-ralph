# Review: 2026-03-27-smoke-test-runner (plan) r5

Decision: approved-for-implementation

## Context

Fifth review cycle. Plan approved since r2 and re-confirmed in r3, r4. Plan unchanged. Status was stuck at `awaiting-plan-review` with `assigned-to: praxis` again — auto-corrected to theorie per routing rules. Re-confirming standing approval.

## Dependency Check

- `2026-03-27-gopy-export`: in `resolved/` — dependency met

## Standing Findings (implementation guidance)

### Finding 1 (medium): Use `gpyc run` for smoke execution
Runner should invoke `gpyc run main.gpy` (or equivalent smoke subcommand) rather than manually orchestrating compile-then-execute. `GopyExporter.compile()` already uses `gpyc compile`; the smoke runner needs a parallel run path. Praxis should check current `gpyc` CLI for the correct invocation.

### Finding 2 (low): Cleanup policy
Runner creates a temporary work directory. Caller should own cleanup; runner documents this contract.

## Verdict

No plan changes since r2. All dependencies resolved. Engine tests pass. Approval stands — this is the fifth re-confirmation. Praxis should begin implementation immediately.

**Handoff**: assigned-to: praxis
