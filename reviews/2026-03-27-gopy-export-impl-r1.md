# Review: 2026-03-27-gopy-export (implementation) r1

Decision: approved

## Acceptance Criteria

- [x] `gpt2_xl_1_5b` exports to a valid `.gpy` file
- [x] Generated code includes config/layout types, decoder builder, and training loop entrypoint
- [x] Exporter rejects unsupported or invalid templates before writing source
- [x] Local `gpy compile` accepts the generated code using the checked-out `../gopy` toolchain
- [x] Parameter values from IR are mapped correctly (`d_model=1600`, `num_heads=25`, `head_dim=64`, `mlp_hidden=6400`, etc.)
- [x] `make test` passes (63/63 engine tests green; xcodebuild has pre-existing plugin issue unrelated to this slice)

## r2/r3 Standing Guidance Check

1. **Read gopy reference files first** (high) — Addressed. Generated code uses correct gopy API (`nn.NewDecoderConfig`, `nn.CausalSelfAttention`, `nn.Decoder`, etc.). Compile-smoke confirms signatures match.
2. **repeat -> nn.Decoder mapping** (medium) — Addressed. IR `repeat(body_ref: gpt2_block, count: num_layers)` is correctly expanded: blocks built individually in `buildBlocks()`, fed to `nn.Decoder()`.
3. **Loud failure on missing gopy** (high) — Addressed. `GopyCompiler.discover()` throws `compilerNotFound` with descriptive message. Test records failure.
4. **Shape-Linter dependency** (medium) — Addressed. `ShapeLinter.lint()` runs for all macros before code generation. `shapeViolationsBlockExport` test verifies.

## Implementation Quality

**Architecture**:
- Pure Engine slice, no UI ✅
- Engine is single source of truth: export reads from `TemplateInstance`, `PropagationEngine`, `ConstraintValidator`, `ShapeLinter` — no duplicate GPT-2 constants ✅
- `GopyExportError` enum covers all guard-failure categories ✅

**Code Style**:
- Guard clauses throughout, no `else` blocks ✅
- No mocks — real toolchain compile ✅
- No TODOs ✅

**Test Coverage**:
- `exportsResolvedGPT2ConfigIntoSource` — success path with assertion on IR-derived values
- `missingMacroFailsLoudly` — guard on missing macro
- `missingBindingFailsLoudly` — guard on missing param binding
- `unexpectedNodeFailsLoudly` — guard on wrong node ref
- `templateConstraintViolationsBlockExport` — constraint guard (d_model=1601 triggers head_divisible)
- `shapeViolationsBlockExport` — shape guard (wrong dimension in layer_norm)
- `compileSmokeUsesRealGopyToolchain` — real gpyc compile

**Minor Observations** (not blocking):
- The `render()` method is 190 lines of string template. Acceptable for GPT-2-specific scope; a generic codegen would need abstraction, but YAGNI.
- Generated `main()` uses `if !validate` + `if validate` pattern instead of guard — this is in gopy output syntax, not Swift, so Swift coding rules don't apply to generated output.

## Bug Fix Note

During this review, theorie resolved the ci-blocker:
- Changed `gpyc build` to `gpyc compile` (aligning with plan text)
- Added `GOPY_PYTHON_BIN` propagation to fix Python venv discovery under `HOME=.local-home`
- See bug report `2026-03-27-gopy-mlx-runtime-probe-crash.md` for details

## Verdict

Implementation meets all acceptance criteria. Code is clean, well-tested, and compiles against the real gopy toolchain. Approved.

**Handoff**: assigned-to: praxis
