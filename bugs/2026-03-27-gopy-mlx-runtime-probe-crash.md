# gopy-mlx-runtime-probe-crash

Status: fixed
assigned-to: theorie

## Symptom

Der verpflichtende reale gopy-Compile-Smoke für `2026-03-27-gopy-export` schlägt unabhängig vom exportierten Programm fehl. Sowohl der neue Exporter-Test als auch ein Compile des bestehenden `../gopy/examples/transformer_slice/main.gpy` brechen mit demselben Toolchain-Fehler ab:

`failed to validate MLX runtime for this gpy program: mlx runtime probe failed: *** -[__NSArray0 objectAtIndex:]: index 0 beyond bounds for empty array`

`gpyc doctor` meldet ebenfalls:

`issue=mlx runtime probe failed: *** -[__NSArray0 objectAtIndex:]: index 0 beyond bounds for empty array`

## Analysis

- Praxis hat den Exporter vollständig implementiert; alle Engine-Tests außer dem realen Compile-Smoke sind grün.
- Der Fehler reproduziert sich auch mit bestehendem gopy-Beispielcode und ist damit kein Fehler im neuen Exporter.
- `../gopy/.venv-mlx-bench` und `../gopy/.venv-phase0` existieren lokal.
- Ein explizites `GOPY_MLX_PYTHON_BIN=../gopy/.venv-mlx-bench/bin/python` behebt den Fehler nicht.
- Damit ist der Blocker aktuell ein gopy-/MLX-Runtime-Problem in der lokalen Toolchain, nicht im Feature-Code von `mlx_designer`.

## Affected Files

- .workflow/plans/2026-03-27-gopy-export.md
- MLXDesignerEngine/Tests/MLXDesignerEngineTests/GopyExporterTests.swift
- ../gopy/gpyc
- ../gopy/.venv-mlx-bench/bin/python

## Resolution (2026-03-28)

Two issues resolved:

1. **MLX runtime probe crash** — resolved externally. `gpyc doctor` now returns `status=ok`. The gopy toolchain was updated upstream.

2. **Python dependency discovery under `HOME` override** — `make test` sets `HOME=.local-home` for Swift build isolation, which broke `gpyc compile`'s ability to find the Python venv with numpy. Fixed by:
   - Changing `GopyExporter.compile()` from `gpyc build` to `gpyc compile` (aligning with the plan)
   - Adding `GOPY_PYTHON_BIN` environment variable propagation in `GopyCompiler`, auto-discovered from `toolchainHome/.venv-mlx-bench/bin/python`

All 63 engine tests now pass, including `compileSmokeUsesRealGopyToolchain`.

## Reproduction (original)

```bash
cd /Users/nwagensonner/Development/AI/mlx_designer
make test

GOPY_TOOLCHAIN_HOME=../gopy GOPY_PROJECT_ROOT=/tmp/gopy-health ../gopy/gpyc doctor

mkdir -p /tmp/gopy-transformer-check
cp ../gopy/examples/transformer_slice/main.gpy /tmp/gopy-transformer-check/main.gpy
GOPY_TOOLCHAIN_HOME=../gopy GOPY_PROJECT_ROOT=/tmp/gopy-transformer-check ../gopy/gpyc compile main.gpy

GOPY_TOOLCHAIN_HOME=../gopy GOPY_PROJECT_ROOT=/tmp/gopy-transformer-check GOPY_MLX_PYTHON_BIN=../gopy/.venv-mlx-bench/bin/python ../gopy/gpyc compile main.gpy
```
