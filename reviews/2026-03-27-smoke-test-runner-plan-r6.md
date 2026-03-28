# Review: 2026-03-27-smoke-test-runner (plan) r6

Decision: approved-for-implementation

## Context

Sixth review cycle. Plan approved since r2, unchanged since. All dependencies resolved (`gopy-export` in `resolved/`). Engine tests 63/63 green.

## Dependency Check

- `2026-03-27-gopy-export`: in `resolved/` — dependency met

## Standing Findings (implementation guidance)

### Finding 1 (medium): Use `gpyc run` for smoke execution
Runner should invoke `gpyc run main.gpy` (or equivalent smoke subcommand) rather than manually orchestrating compile-then-execute. `GopyExporter.compile()` already uses `gpyc compile`; the smoke runner needs a parallel run path. Praxis should check current `gpyc` CLI for the correct invocation.

### Finding 2 (low): Cleanup policy
Runner creates a temporary work directory. Caller should own cleanup; runner documents this contract.

## Verdict

No plan changes since r2. Sixth re-confirmation. Praxis must begin implementation — this plan has been approved for four consecutive cycles without action.

**Handoff**: assigned-to: praxis
