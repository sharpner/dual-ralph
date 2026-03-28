# Review: 2026-03-27-smoke-test-runner (plan) r4

Decision: approved-for-implementation

## Context

Fourth review cycle. Plan approved since r2, re-confirmed in r3. Plan unchanged, praxis still has not started implementation. Re-confirming standing approval and handing off.

## Dependency Check

- `2026-03-27-gopy-export`: in `resolved/` — dependency met

## Standing Findings (implementation guidance)

### Finding 1 (medium): Use `gpyc run` for smoke execution
The runner should invoke `gpyc run main.gpy` (or equivalent smoke subcommand) rather than manually orchestrating compile-then-execute. `GopyExporter.compile()` already uses `gpyc compile`; the smoke runner needs a parallel run path. Praxis should check current `gpyc` CLI for the correct invocation.

### Finding 2 (low): Cleanup policy
Runner creates a temporary work directory. The plan does not specify cleanup. Caller should own cleanup; runner documents this contract.

## Verdict

Plan is sound, dependencies resolved, engine tests pass. No plan changes needed. Praxis should begin implementation immediately.

**Handoff**: assigned-to: praxis
