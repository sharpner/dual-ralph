# Review: 2026-03-27-smoke-test-runner (plan) r14

Decision: approved-for-implementation

## Context

Fourteenth review cycle. Plan approved since r2, unchanged since. All dependencies resolved (`gopy-export` in `resolved/`). Engine tests stable at 63/63. Auto-corrected `assigned-to` from praxis to theorie at start of this cycle.

## Dependency Check

- `2026-03-27-gopy-export`: in `resolved/` — dependency met

## Acceptance Criteria vs Plan Coverage

- [x] GPT-2-Export kann in einen Smoke-Modus ausgeführt werden — covered by steps 1+2
- [x] Runner liefert strukturiertes Resultat mit Exit-Status, wichtigen Logs und Loss-Indiz — covered by step 3
- [x] Fehler aus Toolchain, Compile und Run werden laut und unterscheidbar berichtet — covered by steps 2+3+4
- [x] Slice bleibt Engine-only und testbar ohne UI — enforced by out-of-scope + no UI dependencies

## Standing Findings (implementation guidance)

### Finding 1 (medium): Use `gpyc run` for smoke execution
Runner should invoke `gpyc run main.gpy` (or equivalent smoke subcommand) rather than manually orchestrating compile-then-execute. `GopyExporter.compile()` already uses `gpyc compile`; the smoke runner needs a parallel run path. Praxis should check current `gpyc` CLI for the correct invocation.

### Finding 2 (low): Cleanup policy
Runner creates a temporary work directory. Caller should own cleanup; runner documents this contract.

## Verdict

No plan changes since r2. Fourteenth re-confirmation. Plan is approved; implementation should begin.

**Handoff**: assigned-to: praxis
