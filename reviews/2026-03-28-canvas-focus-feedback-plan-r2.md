# Review: 2026-03-28-canvas-focus-feedback (plan) r2

Decision: approved-for-implementation

## r1 Finding Resolution

### Finding 1 (medium): Define concrete family scheme for GPT-2 — OPEN
The plan still says families are derived from "Node-Typen, Param-Bindings und Container-Kontexten" without defining a concrete initial scheme. Standing recommendation from r1:

- Embedding family: `token_embedding`, `pos_embedding`, `embed_add`, `embed_dropout`
- Attention family (per block): `ln_1`, `attn`, `add_1`
- Feedforward family (per block): `ln_2`, `mlp`, `add_2`
- Output family: `final_ln`, `lm_head`

Derivation should use macro containment + edge connectivity, not hardcoded node lists. Praxis should clarify this during implementation — the derivation rule and how repeated blocks get per-instance vs shared family identity.

### Finding 2 (low): Readout content underspecified — OPEN
Standing recommendation: start minimal with alias + semantic role from building block catalog. Do not build a full inspector readout; that is the parameter-inspector's job.

## Dependency Check

- `canvas-navigation`: now `resolved/` — dependency met
- `parameter-inspector`: currently `implementing` by praxis — this plan should wait until parameter-inspector lands before starting implementation. The plan correctly notes this dependency.

## Architecture Assessment

- **Pure-Swift focus model**: `CanvasFocusState` + resolver pattern matches the Viewport pattern from canvas-navigation. Correct approach.
- **AppKit hit-testing**: `NodeCanvasView` already knows frame rects from `GraphLayout`. Correct foundation.
- **Engine-derived families**: No hardcoded node lists. Correct.
- **UX-Gate**: Dimming must preserve readability. Plan's risk section acknowledges this.
- **Guard Clauses**: Expected in the focus resolver and hit-testing code.
- **No Mocking**: Tests must use real `GraphLayout` from GPT-2 template.

## Verdict

Plan is approved for implementation. Both r1 findings are implementation guidance, not plan blockers. Praxis should wait for parameter-inspector to land before starting this slice.

**Handoff**: assigned-to: praxis
