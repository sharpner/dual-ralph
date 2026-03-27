# Review: 2026-03-27-template-session (plan) r2

Decision: approved-for-implementation

## Summary

Plan-r1 identified three clarifications needed before implementation. Plan remains structurally sound (Single Source of Truth, overlay-based sessions, no UI involvement). The r1 findings are design decision points that praxis must resolve during implementation — not plan rewrites, but concrete choices in code:

1. **GPT-2 derived_overridable parameter selection**: r1 suggested naming `head_dim` explicitly. Plan allows praxis to choose any sensible derived parameter. Implementation must document the choice in code.

2. **TemplateSessionDiagnostics structure**: r1 asked for structure sketch. Plan allows flexible internal design. Implementation must ensure both ConstraintViolations and ShapeViolations are separable for downstream consumers (parameter-inspector will need them).

3. **Transitive macro linting scope**: r1 asked to clarify "genutzte referenzierte Macro-Bodies". Plan says ShapeLinter runs on "Root-Macro and referenced Macro-Bodies" — praxis must ensure recursive traversal of the entire macro hierarchy (decoder → repeat → block).

## Findings

### Finding 1: r1 Finding 1 Status - GPT-2 Choice Not Critical Path
- Severity: low
- Status: Acceptable as implementation decision
- Guidance: Praxis must choose one concrete derived_overridable parameter in GPT-2 template and document the choice with a code comment explaining why it's editability-relevant. `head_dim` from r1 suggestion is sensible (impacts output shape), but praxis can choose differently if justified.

### Finding 2: r1 Finding 2 Status - Diagnostics Structure Will Emerge
- Severity: low
- Status: Acceptable if implementation ensures clarity
- Guidance: TemplateSessionDiagnostics doesn't need detailed sketch in plan, but implementation MUST provide clear API:
  - ConstraintViolations and ShapeViolations MUST be separable (not mixed in single array)
  - parameter-inspector will consume this snapshot and needs typed access
  - Write clear property names in the struct definition

### Finding 3: r1 Finding 3 Status - Recursive Macro Traversal Required
- Severity: medium
- Status: Must be explicit in implementation
- Guidance: ShapeLinter call in Step 4 must recursively lint all macro bodies transitively referenced from the template root:
  - gpt2_decoder contains repeat(gpt2_block, num_layers)
  - Both gpt2_decoder AND gpt2_block must be linted
  - All Shape violations from both levels must appear in the snapshot
  - Implementation must iterate over macro.referencedMacros or equivalent, not just top-level

### Finding 4: Propagation Re-run After Override Reset
- Severity: low
- Status: Plan implies correctly, implementation must verify
- Guidance: When reset() is called on an override, the Session must re-run PropagationEngine to recalculate the derived value. Tests must verify: override a derived_overridable param, reset it, confirm the derived value returns to its propagated value (not stale).

## Acceptance Criteria Check

- [x] Plan structure sound (Overlay, immutable baseline, aggregated diagnostics)
- [x] No scope creep — pure engine, no UI
- [x] Architecture intact — Single Source of Truth preserved
- [x] Dependencies clear (must land after shape-linter)
- [x] r1 findings are resolvable without plan rewrite

## Ready for Implementation

Praxis should proceed with implementation. The plan is sufficiently detailed for a skilled implementation. The r1 findings are design checkpoints that implementation will resolve through code decisions and test verification.

**Handoff**: assigned-to: praxis
