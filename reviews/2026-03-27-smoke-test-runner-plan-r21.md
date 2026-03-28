# Review: 2026-03-27-smoke-test-runner (plan) r21

Decision: approved-for-implementation

## Context

Twenty-first review cycle. Plan unchanged since initial version. Approved since r2. Dependency `gopy-export` in `resolved/`. Engine tests stable at 63/63. Auto-corrected `assigned-to` from praxis to theorie (recurring issue since r2).

## Dependency Check

- `2026-03-27-gopy-export`: in `resolved/` — dependency met

## Acceptance Criteria vs Plan Coverage

- [x] GPT-2-Export kann in einen Smoke-Modus ausgefuehrt werden — steps 1+2
- [x] Runner liefert strukturiertes Resultat mit Exit-Status, wichtigen Logs und Loss-Indiz — step 3
- [x] Fehler aus Toolchain, Compile und Run werden laut und unterscheidbar berichtet — steps 2+3+4
- [x] Slice bleibt Engine-only und testbar ohne UI — enforced by out-of-scope

## Standing Findings (implementation guidance)

### Finding 1 (medium): Use `gpyc run` for smoke execution
Runner should invoke `gpyc run main.gpy` (or equivalent smoke subcommand) rather than manually orchestrating compile-then-execute. Check current `gpyc` CLI for the correct invocation.

### Finding 2 (low): Cleanup policy
Runner creates a temporary work directory. Caller owns cleanup; runner documents this contract.

## Verdict

Plan approved. No changes needed. Praxis should begin implementation.

**Handoff**: assigned-to: praxis
