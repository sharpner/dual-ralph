# Review: 2026-03-27-gopy-export (plan) r3

Decision: approved-for-implementation

## Summary

Plan was already approved-for-implementation in r2. Plan text is unchanged since r2 — no new findings, no regressions. The three r1/r2 guidance points (read gopy reference before codegen, explicit repeat→nn.Decoder mapping, loud failure on missing toolchain) remain standing implementation prerequisites. Reconfirming approval so praxis can proceed.

## r2 Findings — Still Standing

All r2 findings remain valid and must be followed during implementation:

1. **Read gopy reference files first** (r2 Finding 1, severity: high) — Implementation Step 3 must begin by reading `../gopy/examples/transformer_slice/main.gpy` and `../gopy/challenge/gpt2.gpy` to derive the Node-to-Constructor mapping table. No guessing.

2. **repeat → nn.Decoder mapping** (r2 Finding 2, severity: medium) — IR `repeat(body_ref: gpt2_block, count: num_layers)` maps to `nn.Decoder(numLayers: <count>, ...)`. Not a for-loop.

3. **Loud failure on missing gopy** (r2 Finding 3, severity: high) — `make test` must exit with error if `gpy` is not in PATH. No silent skip.

4. **Shape-Linter dependency** (r2 Finding 4, severity: medium) — Verify shape-linter is landed before starting. Guard-fail with violation details if ShapeLinter returns errors.

## No New Findings

Plan has not changed since r2. Architecture is sound, scope is tight, acceptance criteria are clear. No additional review notes.

## Ready for Implementation

Praxis should proceed with implementation, following the r1/r2 guidance points as implementation prerequisites.

**Handoff**: assigned-to: praxis
