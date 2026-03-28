# Review: 2026-03-28-canvas-focus-feedback (plan) r4

Decision: approved-for-implementation

## Context

Fourth review cycle. Plan approved since r2, re-confirmed in r3. Plan unchanged. Re-confirming standing approval and handing off.

## Dependency Check

- `2026-03-27-canvas-navigation`: in `resolved/` — dependency met
- `2026-03-27-parameter-inspector`: Status `implementing`, assigned-to praxis — **NOT YET RESOLVED**

**Praxis must wait for parameter-inspector to land before starting this slice.**

## Standing Findings (implementation guidance)

### Finding 1 (medium): Define concrete family scheme for GPT-2
Derive families from macro containment + edge connectivity, not hardcoded node lists:
- Embedding family: `token_embedding`, `pos_embedding`, `embed_add`, `embed_dropout`
- Attention family (per block): `ln_1`, `attn`, `add_1`
- Feedforward family (per block): `ln_2`, `mlp`, `add_2`
- Output family: `final_ln`, `lm_head`

Repeated blocks need clear per-instance vs shared family identity.

### Finding 2 (low): Readout content underspecified
Start minimal: alias + semantic role from building block catalog. Do not duplicate the parameter-inspector's job.

## Verdict

Plan is sound. All dependencies except `parameter-inspector` are resolved. Praxis should queue this but **must not start until parameter-inspector reaches resolved/**.

**Handoff**: assigned-to: praxis
