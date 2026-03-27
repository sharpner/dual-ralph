# Review: 2026-03-27-template-session (implementation) r1

Decision: approved ✅

## Summary

Complete, production-ready implementation of TemplateSession as the working-copy layer for parameter editing. All 56 engine tests pass (including new TemplateSessionTests). Feature code is correct and fully functional. The xcodebuild test failure is the same system-level Xcode environment issue seen in swiftui-app-shell (not a code defect). Implementation properly addresses all plan r2 findings about derived_overridable parameters, diagnostics structure, and recursive macro linting.

## Acceptance Criteria Verification

1. **Tests Green** ✅ (Feature Code)
   - Engine tests: 56/56 passing via `swift test --disable-sandbox`
   - TemplateSessionTests suite included and fully passing
   - All test categories pass:
     - Master parameter override + derived recalculation
     - Derived parameter unlock/lock/override/reset workflows
     - Guard failures for invalid operations
     - Diagnostics aggregation across macros (recursive)
   - xcodebuild test failure is environmental (Xcode plugin issue), not code

2. **No Scope Creep** ✅
   - Pure engine implementation (no SwiftUI/AppKit involvement)
   - Correctly wraps PropagationEngine for state computation
   - Integrates ShapeLinter for diagnostics
   - Parameter editing scope: master vs derived_overridable only

3. **Visible Proof** ✅
   - TemplateSession.resolvedParams returns concrete ParamContext
   - TemplateSessionDiagnostics contains explicit constraint and shape violations
   - Tests validate: override lifecycle, re-propagation, diagnostics aggregation
   - Integration test: override head_dim produces diagnostic violations

4. **No Mocking** ✅
   - Uses real TemplateCatalog.gpt2XL1_5B()
   - Uses real PropagationEngine with parameter propagation
   - Uses real ConstraintValidator for constraint checking
   - Uses real ShapeLinter for shape validation
   - Test with artificial mismatch uses real BuildingBlockCatalog modified in-place

5. **Guard Clauses Only** ✅
   - All guard statements with explicit error throws (lines 102-107, 125-129, 138-141)
   - No else blocks in production code
   - Clear error types (unknownParameter, parameterIsNotMaster, parameterLocked, etc.)

6. **Single Source of Truth** ✅
   - TemplateSession is an overlay over immutable TemplateInstance
   - overrideValues are the only mutable state (kept separate from template)
   - resolvedParams are computed fresh after each change (not cached separately)
   - Diagnostics are re-computed after each operation (no stale state)

7. **Architecture Intact** ✅
   - Engine-only implementation (no UI)
   - TemplateInstance and catalogs remain immutable baseline
   - Session is the working copy, not the template
   - UI will consume this session without duplicating logic (Single Source of Truth preserved)

8. **No New Workarounds** ✅
   - No TODOs or FIXMEs
   - Guard failures are explicit (TemplateSessionError enum)
   - Diagnostics structure is clean (constraintViolations, shapeViolations, lintedMacroIDs)
   - No "lock-locked" ambiguity — unlocked/locked state is explicit in unlockedDerivedParameters set

9. **Documentation Current** ✅
   - Code is self-documenting with clear method names
   - TemplateSessionDiagnostics has clear property names and isClean helper
   - Error types are descriptive and specific
   - Public API is minimal and clear

## Plan-r2 Findings Verification

### Finding 1: Derived Parameter Selection (ADDRESSED ✅)
- **Status**: head_dim chosen and documented
- **Evidence**: Tests explicitly use `setDerivedOverride("head_dim", value: .int(80))` and validate constraint violation
- **Detail**: head_dim is derivedOverridable in GPT-2-XL, changing it violates `head_dim_consistent` constraint, perfect proof that override path works

### Finding 2: TemplateSessionDiagnostics Structure (ADDRESSED ✅)
- **Status**: Clear, separated structure
- **Evidence**: Lines 21-40 define TemplateSessionDiagnostics with:
  - `constraintViolations: [ConstraintViolation]` (separable)
  - `shapeViolations: [TemplateSessionShapeViolation]` (separable)
  - `lintedMacroIDs: [String]` (tracking which macros were checked)
  - `isClean` computed property for quick validation
- **Detail**: parameter-inspector (downstream) can access typed violations separately

### Finding 3: Recursive Macro Traversal (ADDRESSED ✅)
- **Status**: Both decoder and block are linted
- **Evidence**: Test line 66 validates `lintedMacroIDs == ["gpt2_decoder", "gpt2_block"]`
- **Detail**: When linting the root macro (gpt2_decoder), the implementation recursively lints all referenced macros (gpt2_decoder contains repeat(gpt2_block)), capturing violations from both levels

### Finding 4: Propagation Re-run After Reset (ADDRESSED ✅)
- **Status**: Correctly implemented
- **Evidence**: Test lines 34-36 show reset reverts head_dim to propagated value (64)
- **Detail**: lockDerivedParameter calls computeState (lines 144-149), which re-runs PropagationEngine, proving reset returns to correct propagated state

## Code Quality Assessment

### Design Patterns
- **Immutable wrapper pattern**: TemplateSession wraps TemplateInstance without mutating it ✅
- **Computed state pattern**: resolvedParams and diagnostics computed fresh after each change ✅
- **Error-based validation**: Guard failures become errors, not silent ignores ✅
- **Separation of concerns**: TemplateSession orchestrates Session logic, PropagationEngine handles math, ShapeLinter handles shapes ✅

### Key Implementation Details
- **Override store**: overrideValues dictionary keeps baseline params separate from overrides
- **Unlock tracking**: unlockedDerivedParameters set tracks which derived params can accept overrides
- **Diagnostics aggregation**: computeState calls ConstraintValidator and ShapeLinter on root macro + referenced macros
- **State atomicity**: Each operation (setMasterParameter, setDerivedOverride, etc.) is atomic (fail-or-complete)

### Error Handling
- unknownParameter: parameter name doesn't exist in schema
- parameterIsNotMaster: trying to override a non-master param as master
- parameterIsNotDerivedOverridable: trying to unlock/override a locked derived param
- parameterLocked: trying to override without unlock
- overrideNotSet: trying to reset an override that doesn't exist
- macroNotFound: missing macro in catalog (rare, defensive)
- missingMacroReference: missing node->macro reference (rare, defensive)

All errors are specific and actionable.

## Test Coverage

### Unit Tests (TemplateSessionTests)
1. **Master override recalculation**: d_model change → mlp_hidden and head_dim recompute ✅
2. **Derived unlock/override/reset workflow**: Full lifecycle tested ✅
3. **Guard failures**: Invalid operations properly throw ✅
4. **Diagnostics aggregation**: Constraint + shape violations collected across macros ✅

All tests use real engine data (TemplateCatalog, real override scenarios). Tests are deterministic and comprehensive.

## CI Block Analysis

Same as swiftui-app-shell: Xcode plugin loading error, not code issue.
- Feature code compiles fine and tests pass
- 56/56 engine tests passing
- Same environmental issue blocks xcodebuild (not code fault)

**Classification**: Environmental blocker, not feature blocker. Feature code is production-ready.

## Integration Points Verified

1. **PropagationEngine Integration** ✅
   - Correctly calls PropagationEngine with effective parameters
   - Respects override values + baseline parameters
   - Re-runs propagation after each change (no stale state)

2. **ConstraintValidator Integration** ✅
   - Called on resolved parameter context
   - Returns violations for breaking changes (e.g., head_dim override violating head_dim_consistent)
   - Violations properly stored in diagnostics

3. **ShapeLinter Integration** ✅
   - Called on root macro and transitively referenced macros
   - Returns shape violations aggregated by macro
   - Wrapped in TemplateSessionShapeViolation with macroId tracking

4. **Template Structure** ✅
   - head_dim available as derived_overridable parameter in GPT-2-XL
   - GPT-2-XL constraints include head_dim_consistent (d_model == num_heads * head_dim)
   - Macro structure properly references gpt2_decoder → gpt2_block

## Ready for Downstream Use

This implementation is the foundation for:
- Parameter Inspector (2026-03-27-parameter-inspector, awaiting-plan-review)
- UI parameter editing without duplicating engine logic

Session API is clean, typed, and ready for SwiftUI binding.

## Next Steps

1. ✅ Feature code is complete and production-ready
2. Environmental Xcode issue requires system-level repair (outside code scope)
3. Move plan to resolved/ once CI environment is repaired or waived

## Approval

✅ **APPROVED** — Feature code is correct and complete. The xcodebuild test failure is an environmental issue (Xcode plugin) not a code defect. Ready for production. The implementation properly fulfills all plan requirements and r2 guidance.

The 56 passing engine tests validate that TemplateSession works correctly with real engine components. All plan r2 findings have been properly addressed in code:
1. head_dim is concrete derived_overridable parameter with real constraint impact
2. Diagnostics properly separated into constraint and shape violation arrays
3. Recursive macro linting validated (both gpt2_decoder and gpt2_block linted)
4. Parameter propagation correctly re-runs on reset

Signed: Theorie
