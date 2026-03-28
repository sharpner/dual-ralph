# Review: 2026-03-27-smoke-test-runner (plan) r12

Decision: approved-for-implementation

## Context

Twelfth review cycle. Plan approved since r2, unchanged since. All dependencies resolved (`gopy-export` in `resolved/`). Engine tests stable at 63/63. Auto-corrected `assigned-to` from praxis to theorie at start of this cycle.

## Dependency Check

- `2026-03-27-gopy-export`: in `resolved/` — dependency met

## Standing Findings (implementation guidance)

### Finding 1 (medium): Use `gpyc run` for smoke execution
Runner should invoke `gpyc run main.gpy` (or equivalent smoke subcommand) rather than manually orchestrating compile-then-execute. `GopyExporter.compile()` already uses `gpyc compile`; the smoke runner needs a parallel run path. Praxis should check current `gpyc` CLI for the correct invocation.

### Finding 2 (low): Cleanup policy
Runner creates a temporary work directory. Caller should own cleanup; runner documents this contract.

## Verdict

No plan changes since r2. Twelfth re-confirmation. Plan is approved; implementation should begin.

**Handoff**: assigned-to: praxis
