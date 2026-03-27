# Review: 2026-03-27-canvas-navigation (plan) r2

Decision: approved-for-implementation

## Summary

Plan-r1 identified four implementation-level clarifications (Viewport API shape, ScrollView magnification mechanics, Fit-trigger semantics, Clamp bounds). The plan structure is architecturally sound — NSScrollView extension over custom camera stack, pure-Swift viewport logic, visible controls in toolbar. None of the r1 findings require a plan rewrite; all are concrete decisions that praxis resolves during implementation.

## Findings

### Finding 1: r1 Finding 1 Status — Viewport API Shape
- Severity: medium
- Status: Must be resolved in implementation
- Guidance: Implementation Step 1 MUST produce a concrete `CanvasViewportState` struct with:
  - `zoomScale: CGFloat` (read-only externally)
  - `mutating func zoomIn()`, `zoomOut()`, `resetZoom()`
  - `static func fitScale(graphSize: CGSize, visibleSize: CGSize) -> CGFloat`
  - Guard clauses for zero/negative sizes returning a sensible default (1.0)
  - This is the testable core — all zoom logic lives here, not in AppKit wiring

### Finding 2: r1 Finding 2 Status — ScrollView Magnification Path
- Severity: medium
- Status: Must be explicit in implementation
- Guidance: Implementation Step 2 MUST use `NSScrollView.magnification` directly:
  - `NodeCanvasView.frame` stays fixed at `GraphLayout.canvasSize`
  - Zoom changes only `scrollView.magnification`, no frame/transform mutation
  - View hierarchy: `NSScrollView` → `NSClipView` → `NodeCanvasView`
  - `CanvasRepresentable.Coordinator` syncs `CanvasViewportState.zoomScale` → `scrollView.magnification`
  - This avoids double-viewport-logic and keeps the scroll-position stable

### Finding 3: r1 Finding 3 Status — Fit-Trigger Semantics
- Severity: low
- Status: Praxis decides, must be documented in code
- Guidance:
  - Auto-Fit on App Launch: `fitScale()` is called once when GPT-2 template loads
  - After manual zoom: user's zoom is preserved until explicit Reset or Fit action
  - No auto-fit on data changes (this slice has no runtime data variability)
  - Implementation must not silently override user zoom state

### Finding 4: r1 Finding 4 Status — Clamp Bounds
- Severity: low
- Status: Praxis chooses values, must be constants
- Guidance:
  - Define min/max zoom as named constants (e.g., `CanvasViewportState.minimumZoom`, `.maximumZoom`)
  - Suggested range: `0.1` (10%) to `3.0` (300%) — reasonable for GPT-2 XL canvas dimensions (~30k px height)
  - Tests must verify clamp behavior at boundaries
  - If GPT-2 XL fitScale() lands below 0.1, the minimum must be adjusted — test with real canvas dimensions

## Acceptance Criteria Check

- [x] No scope creep — Zoom + Fit + Status visibility only
- [x] Visible proof — pure-Swift tests for fitScale + clamp + manual smoke test
- [x] No mocking — real NSScrollView, real GPT-2 canvas dimensions
- [x] Guard clauses — required for zero/negative sizes in viewport calculations
- [x] Single source of truth — CanvasViewportState owns zoom, UI reads it
- [x] Architecture intact — SwiftUI toolbar controls → Coordinator → NSScrollView.magnification
- [x] No new workarounds — none
- [x] Dependency satisfied — swiftui-app-shell is in resolved/

## Ready for Implementation

Plan is approved. The r1 findings are all concrete implementation decisions, not architectural gaps. Praxis should:
1. Define `CanvasViewportState` with the API from Finding 1
2. Wire `NSScrollView.magnification` per Finding 2
3. Set auto-fit on launch, preserve user zoom per Finding 3
4. Choose clamp bounds and test with GPT-2 XL dimensions per Finding 4

**Handoff**: assigned-to: praxis
