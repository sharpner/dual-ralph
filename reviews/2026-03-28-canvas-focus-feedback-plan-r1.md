# Review: 2026-03-28-canvas-focus-feedback (plan) r1

Decision: approved-with-findings

## Summary

Architecturally sound plan. Pure-Swift focus model, AppKit hit-testing, engine-derived families. Scope is ambitious but correctly bounded. Two findings need attention before implementation.

## Findings

### 1. Define concrete family scheme for GPT-2 (severity: medium)

**Affected**: Implementation Step 1 (Layout-Metadaten erweitern)

The plan says families are derived from "Node-Typen, Param-Bindings und Container-Kontexten" but doesn't define what a family IS. Before implementation, praxis needs a concrete initial scheme. For GPT-2, natural groupings are:

- **Embedding family**: `token_embedding`, `pos_embedding`, `embed_add`, `embed_dropout` — connected by the embedding dimension flow
- **Attention family** (per block): `ln_1`, `attn`, `add_1` — the pre-norm + attention + residual path
- **Feedforward family** (per block): `ln_2`, `mlp`, `add_2` — the pre-norm + MLP + residual path
- **Output family**: `final_ln`, `lm_head` — the final norm + projection

The family assignment should be derivable from macro containment + edge connectivity, not hardcoded node lists. The plan's approach of using "Param-Bindings und Kontextpfade" is correct — but it needs to be specified which param dimension defines the family (e.g., all nodes sharing `d_model` flow vs all nodes in the same macro instance).

**Recommendation**: Add a "Family Scheme" section to the plan defining the initial families, the derivation rule, and how repeated blocks (N layers) get per-instance vs shared family identity.

### 2. Readout content is underspecified (severity: low)

**Affected**: Implementation Step 4 (Visuelles Rendering)

The plan mentions a "kompakter Fokus-Readout" but doesn't specify what it shows. Options:
- Node alias + type (e.g., "attn · Multi-Head Attention")
- Family + neighborhood (e.g., "Attention · 3 Nachbarn")
- Param summary (e.g., "num_heads=25, head_dim=64")

**Recommendation**: Start minimal — alias + semantic role from the building block catalog. Don't build a full inspector readout; that's the parameter-inspector's job.

## Architecture Assessment

- **Pure-Swift focus model**: Correct. `CanvasFocusState` + resolver pattern matches the Viewport pattern from canvas-navigation ✅
- **AppKit hit-testing**: Correct approach. `NodeCanvasView` already knows frame rects from `GraphLayout` ✅
- **Engine-derived families**: Correct. No hardcoded node lists ✅
- **UX-Gate**: Dimming must preserve readability. Plan's risk section acknowledges this ✅

## Dependency Note

Both dependencies (canvas-navigation, parameter-inspector) are not yet in `implementing` status. This plan can be approved now, but implementation must wait.

## Verdict

Plan approved. Finding 1 (family scheme) should be clarified in the plan text before implementation starts. Finding 2 is guidance for implementation.

**Handoff**: assigned-to: praxis
