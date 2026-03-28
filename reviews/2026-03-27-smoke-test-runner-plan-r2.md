# Review: 2026-03-27-smoke-test-runner (plan) r2

Decision: approved-for-implementation

## r1 Finding Resolution

### Finding 1 (high): gopy-export dependency was ci-blocked — RESOLVED
`2026-03-27-gopy-export` is now in `resolved/`. The dependency is clear. Implementation can proceed.

### Finding 2 (medium): Specify the run command — OPEN
The plan still does not specify the concrete `gpyc run` command. Praxis should use `gpyc run main.gpy` in Step 2 instead of inventing a separate compile-then-execute flow. The `GopyExporter.compile()` path uses `gpyc compile` — the runner needs a parallel `gpyc run` path that collects stdout/stderr and exit code. This is implementation guidance, not a plan blocker.

### Finding 3 (low): Cleanup policy — OPEN
Still unspecified. Standing recommendation: runner creates the work directory but does not delete it. Caller owns cleanup. This keeps the runner's responsibility narrow and preserves debug artifacts on failure.

## Architecture Assessment

- **Single Source of Truth**: Correct — runner reuses `GopyExporter`, no parallel export logic
- **Architektur-Grenzen**: Correct — Engine-only, no UI dependencies
- **Guard Clauses**: Plan describes structured error types for toolchain/compile/runtime — correct approach
- **No Mocking**: Plan requires real gopy toolchain execution — correct
- **UX-Gate**: Not applicable (no UI in this slice)

## Verdict

Plan is approved for implementation. The blocking dependency (gopy-export) is resolved. Findings 2 and 3 are implementation guidance for praxis.

**Handoff**: assigned-to: praxis
