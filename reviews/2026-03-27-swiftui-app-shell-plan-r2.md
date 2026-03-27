# Review: 2026-03-27-swiftui-app-shell (plan) r2

Decision: approved-for-implementation

## Summary

Plan-r1 identified three medium-level clarifications for UI implementation. Plan is architecturally correct (SwiftUI shell, AppKit canvas, read-only graph, correct dependency on ir-data-model and ir-propagation-engine). The r1 findings are essential implementation checkpoints — not rejections, but clarity requirements:

1. **NSScrollView mandatory for GPT-2 XL canvas**: r1 correctly identified that 300+ nodes at 36,000pt height requires scrolling.

2. **make test integration for GraphLayoutEngine**: r1 asked how layout tests are run via `make test`.

3. **catalog parameter type clarification**: r1 identified missing type specification for layout engine input.

All three are critical for a functional, testable implementation.

## Findings

### Finding 1: r1 Finding 1 Status - NSScrollView Is Not Optional
- Severity: high
- Status: Must be in implementation Step 4
- Guidance:
  - GPT-2 XL layout can exceed 30,000+ points in height (48 layers × ~6 nodes × 120pt spacing)
  - NodeCanvasView alone will only render the visible window portion
  - Implementation Step 4 MUST include: NodeCanvasView embedded in NSScrollView
  - NSViewRepresentable in Step 5 must create NSScrollView with NodeCanvasView as documentView
  - Test explicitly: create layout for GPT-2 XL, verify intrinsicContentSize exceeds window bounds, verify scrolling works
  - This is not Pan/Zoom/Navigation feature — it's basic view containment required for the graph to be usable

### Finding 2: r1 Finding 2 Status - make test Must Run Layout Tests
- Severity: high
- Status: Makefile must support `make test` for this slice
- Guidance:
  - Xcode project setup (Step 1) must create a test target for GraphLayoutEngineTests
  - Makefile must include a `make test` target that runs `xcodebuild test -scheme MLXDesigner -destination 'platform=macOS'`
  - Acceptance Criterion #1 (Tests Green) requires this
  - Do not skip: "Manueller Test" is not enough. GraphLayoutEngine tests must be automated and run by CI/CD
  - Tests to include:
    - Layout produces expected number of nodes/edges for GPT-2 XL
    - Node positions don't overlap
    - Macro containers properly enclose child nodes
    - intrinsicContentSize is correct for scrolling

### Finding 3: r1 Finding 3 Status - Use Exact Catalog Type From Engine
- Severity: low
- Status: Import type from MLXDesignerEngine package
- Guidance:
  - Step 3 specifies GraphLayoutEngine.layout(template: TemplateInstance, catalog: ...)
  - The catalog type must match what MLXDesignerEngine exports
  - Do not create a new wrapper type — use the exact type from the engine package
  - If the engine exports [String: BuildingBlock], use that
  - If the engine exports a BuildingBlockCatalog struct, use that
  - Implementation must import the exact type, not guess or create redundant types
  - This ensures GraphLayoutEngine works with real engine data without impedance mismatches

### Finding 4: Node Parameter Rendering Detail
- Severity: low
- Status: Implementation must make visible choice
- Guidance:
  - Step 4 describes "Parameterwerte werden auf Nodes angezeigt (d_model=1600, num_heads=25, etc.)"
  - Implementation must decide which parameters are shown per node:
    - All parameters for that node instance? (Could be verbose)
    - Only "important" parameters? (Which ones are important?)
    - Show as label below node, or inside node rectangle?
  - Must be consistent and readable at normal zoom levels
  - Implementation must test that labels don't overlap node shapes

## Acceptance Criteria Check

- [x] No scope creep — read-only, no editing
- [x] Visible proof — GraphLayoutEngine tests + manual smoke test
- [x] Architecture intact — SwiftUI shell + AppKit canvas
- [x] Single source of truth — reads from TemplateInstance
- [x] Tests green — graphLayoutEngineTests via `make test`
- [x] No mocking — real TemplateInstance from engine

## UX Gate - Don't Make Me Think

Read-only graph display with labels and parameters is clear and cognitively simple. User sees the full architecture immediately. No interaction confusion. ✅ Passed.

## Critical Pre-Implementation Actions

Before starting: Verify that ir-data-model and ir-propagation-engine are fully landed and tested. This is a hard dependency.

## Ready for Implementation

Praxis should proceed. The r1 findings are concrete implementation requirements (NSScrollView, make test integration, exact type imports), not architectural changes. All must be addressed in code and tests.

**Handoff**: assigned-to: praxis
