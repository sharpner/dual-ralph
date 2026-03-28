# Review: 2026-03-27-smoke-test-runner (plan) r1

Decision: approved-with-findings

## Summary

The plan is architecturally sound: Engine-only `GopySmokeRunner` reuses `GopyExporter`, compiles and runs via the local gopy toolchain, and returns structured results. Scope is tight, no UI. The dependency chain is clear. Three findings require attention before implementation starts.

## Findings

### 1. Blocked dependency — gopy-export is ci-blocked (severity: high)

**Affected**: entire plan

The plan depends on `2026-03-27-gopy-export`, which is currently `Status: ci-blocked` due to a gopy toolchain issue (was MLX runtime probe crash, now numpy missing for datasets import). Implementation of smoke-test-runner cannot start until the gopy-export blocker is resolved and that plan reaches `resolved/`. The plan acknowledges this ("muss zuerst als Feature oder Infra-Blocker geklärt sein") — correct. No action needed in the plan text, but praxis must not start this slice prematurely.

### 2. Specify the run command explicitly (severity: medium)

**Affected**: Implementation Step 2 (Compile- und Run-Pipeline)

The plan says "das kompilierte Programm im gopy-Smoke-Modus starten" but does not specify the concrete toolchain command. The local `gpyc` supports:

- `gpyc build <file.gpy>` — compile only
- `gpyc run <file.gpy> [args...]` — compile and run

The runner should use `gpyc run main.gpy` (default mode is already `"smoke"` in the generated code) or `gpyc run main.gpy smoke` for explicitness. Implementation Step 2 should reference `gpyc run`, not invent a separate compile-then-execute flow. The `GopyExporter.compile()` already uses `gpyc build` — the runner needs a parallel `run` path that collects stdout/stderr and exit code.

**Recommendation**: Add a note to Step 2 that the run command is `gpyc run <file.gpy> [args...]` and that the generated code defaults to smoke mode.

### 3. Cleanup policy for work directories (severity: low)

**Affected**: Implementation Step 1 (Runner-API definieren), Risks (Artefakt-Müll)

The plan mentions "Arbeitsverzeichnis und Artefaktpfade deterministisch kapseln" and the risk section warns about artifact pollution. Good. But the plan does not specify the cleanup policy:
- Always clean up, even on failure? (Loses debug artifacts)
- Keep on failure, clean on success? (Accumulates on repeated failures)
- Caller-controlled?

**Recommendation**: Keep it simple — the runner creates the directory but does not delete it. The caller (or test harness) owns cleanup. This avoids losing debug info on failures and keeps the runner's responsibility narrow.

## Architecture Assessment

- **Single Source of Truth**: Correct — runner reuses `GopyExporter`, no parallel export logic.
- **Architektur-Grenzen**: Correct — Engine-only, no UI dependencies.
- **UX-Gate**: Not applicable (no UI in this slice).
- **Guard Clauses**: Plan describes structured error types for toolchain/compile/runtime — correct approach.
- **No Mocking**: Plan requires real gopy toolchain execution — correct.

## Verdict

Plan is approved with the caveat that findings 1 and 2 must be addressed. Finding 1 is a sequencing constraint (wait for gopy-export to land). Finding 2 is an implementation detail that praxis should incorporate into Step 2 before starting work.

**Handoff**: assigned-to: praxis
