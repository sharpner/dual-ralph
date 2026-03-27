# Review: 2026-03-27-shape-linter (implementation) r1

Decision: approved ✅

## Summary

Complete, production-ready implementation. All 52 tests pass including comprehensive ShapeLinter test suite. Implementation correctly addresses both plan-r1 findings, implements all specified functionality with guard clauses and explicit error handling. No shortcuts, no workarounds, real integration with PropagationEngine and building block catalog.

## Acceptance Criteria Verification

1. **Tests Green** ✅
   - `make test` → 52/52 tests passed
   - ShapeLinterTests suite: 8 tests all passing
   - Coverage includes unit tests (resolution, compatibility), integration (GPT-2 block validation), and edge cases (missing lookups, shape mismatches)

2. **No Scope Creep** ✅
   - Implements exactly what plan specified: Shape-Matching, not Shape-Inference
   - DType and SemanticType checks correctly deferred to separate plans
   - No UI integration in this slice (correctly scoped)

3. **Visible Proof** ✅
   - E2E test: `gpt2BlockEdgesAreCompatible()` validates GPT-2 block structure
   - E2E test: `propagatedContextRelintsCleanlyAfterMasterChange()` validates after parameter changes
   - Integration test: `shapeMismatchProducesViolationWithResolvedShapes()` creates artificial mismatch and validates detection

4. **No Mocking** ✅
   - Tests use real TemplateCatalog.gpt2XL1_5B() and MacroBlockCatalog
   - Real BuildingBlockCatalog is consulted for all lookups
   - Real PropagationEngine used for parameter context

5. **Guard Clauses Only** ✅
   - All failure paths use guard statements with continue (lines 123-189 in ShapeLinter.swift)
   - No else blocks in production code
   - Proper error accumulation: violations are collected, not thrown

6. **Single Source of Truth** ✅
   - ShapeLinter reads from MacroBlock and BuildingBlockCatalog — no duplicated shape definitions
   - ParamContext is the single source for named dimension values
   - No local state or caching that could diverge from engine truth

7. **Architecture Intact** ✅
   - Pure engine code, no UI involvement
   - Fits cleanly into validation pipeline (after PropagationEngine, before export)
   - Will be consumed by TemplateSession (awaiting-plan-review) and GopyExporter (awaiting-plan-review)

8. **No New Workarounds** ✅
   - No TODOs or FIXMEs
   - Compile errors are explicit in error types (`ShapeResolutionError`, `ShapeLookupError`)
   - Missing lookups are reported clearly (lines 263-291 build helpful error messages)

9. **Documentation Current** ✅
   - Code is clear and self-documenting
   - Public API properly documented (functions have clear names and parameter types)
   - Test names clearly indicate what behavior they validate

## Plan-r1 Findings Verification

### Finding 1: Macro-Port-Lookup-Pfad (ADDRESSED ✅)
- **Status**: Properly implemented
- **Evidence**: Lines 236-239 and 257-260 in ShapeLinter.swift
- **Detail**: Both `lookupSourcePort` and `lookupTargetPort` include fallback branches:
  ```swift
  if let node = macro.nodes.first(where: { $0.alias == edge.sourceNode }) { ... }
  guard let port = macro.inputPorts.first(where: { $0.id == edge.sourcePort }) else { ... }
  ```
  This handles both NodeInstance-based ports and macro-own ports correctly.

### Finding 2: Guard-Verhalten bei Lookup-Fehler (ADDRESSED ✅)
- **Status**: Properly implemented with clear error messages
- **Evidence**: Lines 123-189 collect violations instead of throwing
- **Detail**: Each lookup failure is captured and added to violations array with descriptive message:
  - `sourceLookupMessage()` (lines 263-276): Returns specific error from `ShapeLookupError`
  - `targetLookupMessage()` (lines 278-291): Same pattern for targets
  - Example violation: `missingLookupBecomesViolationInsteadOfCrash()` test validates this (passes ✅)

## Code Quality Assessment

### Design Patterns
- **ResolvedDimension enum**: Clear two-case distinction (concrete vs symbolic), idiomatic Swift
- **ResolvedShape struct**: Simple array wrapper, no unnecessary complexity
- **ShapeLinter as enum with static methods**: Correct namespace choice per plan-r1 approval

### Error Handling
- Lookup errors properly enumerated (ShapeLookupError)
- Resolution errors properly enumerated (ShapeResolutionError)
- All failures become violations with human-readable messages
- No silent failures or ignored exceptions

### Test Coverage
- Named dimension resolution (including missing dimensions)
- Broadcast compatibility (the critical "1 vs N" case)
- GPT-2 block structure validation at production parameters
- Re-linting after parameter changes (proves integration with PropagationEngine)
- Artificial mismatches detected correctly
- Missing lookup failures converted to violations (not crashes)

## Integration Points Verified

1. **PropagationEngine Integration** ✅
   - Test `propagatedContextRelintsCleanlyAfterMasterChange()` demonstrates correct usage with resolved parameter context
   - Can be called on changed parameters immediately (no staleness)

2. **BuildingBlockCatalog Integration** ✅
   - ShapeLinter correctly looks up output/input ports from building blocks
   - Test uses real catalog with all 10 building block types

3. **MacroBlock Structure** ✅
   - Correctly handles nodes, edges, inputPorts, outputPorts
   - Test validates against real gpt2_block macro structure

## Risks Addressed

From plan's Risks section:
1. **Port-Lookup-Komplexität**: Mitigated by explicit handling of both NodeInstance and macro-own ports
2. **Macro-Input/Output-Ports als Edge-Endpunkte**: Explicitly implemented with fallback lookups

## Ready for Downstream Use

This implementation is ready for:
- TemplateSession (plan: awaiting-plan-review) → will call ShapeLinter in diagnostic aggregation
- GopyExporter (plan: awaiting-plan-review) → will call ShapeLinter to guard against export of invalid configurations

## Next Steps

1. Move plan to resolved/
2. This unblocks TemplateSession and GopyExporter implementation (both depend on ShapeLinter being complete)

## Approval

✅ **APPROVED** — Ready for production. Move to resolved/.

Signed: Theorie
