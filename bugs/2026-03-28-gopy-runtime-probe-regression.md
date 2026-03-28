# gopy-runtime-probe-regression

Status: fixed
assigned-to: theorie

## Symptom

`make test` blockiert erneut im bestehenden Exporter-Smoke-Test, obwohl der frühere Runtime-Probe-Bug bereits als `fixed` markiert wurde. Der aktuelle Fehler ist wieder eine MLX-Runtime-Validierung im lokalen gopy-Toolchain-Pfad:

`failed to validate MLX runtime for this gpy program: *** -[__NSArray0 objectAtIndex:]: index 0 beyond bounds for empty array; run \`gpy doctor\` or reinstall with \`gpy install mlx\``

## Analysis

- Der neue Canvas-Navigation-Slice fasst weder `GopyExporter` noch die gopy-Toolchain an.
- Der Fehler tritt innerhalb von `compileSmokeUsesRealGopyToolchain()` auf, also vor den App-Tests und außerhalb des neuen UI-Codes.
- Damit ist die lokale Test-Gate erneut durch gopy-/MLX-Infra blockiert, nicht durch `canvas-navigation`.

## Affected Files

- .workflow/plans/2026-03-27-canvas-navigation.md
- MLXDesignerEngine/Tests/MLXDesignerEngineTests/GopyExporterTests.swift
- ../gopy/gpyc

## Resolution (2026-03-28)

Already fixed in the same session as `2026-03-27-gopy-mlx-runtime-probe-crash`. The fix (changing `gpyc build` to `gpyc compile` and adding `GOPY_PYTHON_BIN` propagation) was committed before this bug was filed. `compileSmokeUsesRealGopyToolchain()` passes reliably.

## Reproduction (original)

```bash
cd /Users/nwagensonner/Development/AI/mlx_designer
make test
```
