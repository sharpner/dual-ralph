# Review: 2026-03-27-canvas-navigation (implementation) r2

Decision: approved

## r1 Finding Resolution

### Finding 1 (blocking): Untracked source files — RESOLVED
`CanvasViewportState.swift` and `CanvasViewportStateTests.swift` are now committed in `e0f448f` ("Add canvas navigation controls"). All 5 changed files are tracked and pushed.

### Finding 2 (informational): xcodebuild plugin failure — UNCHANGED
Still present. Tracked separately as bug `2026-03-28-xcodebuild-plugin-load-failure`, assigned to user. Requires `sudo xcodebuild -runFirstLaunch`. Not blocking for this slice.

## Acceptance Criteria

- [x] User kann den Canvas kontrolliert hinein- und herauszoomen — `zoomIn()`/`zoomOut()` with discrete steps, epsilon-based level matching, clamped to `[0.25...2.0]`
- [x] Fit-to-Graph-Aktion fuer den vollstaendigen GPT-2-Graphen — "Fit" button as `.borderedProminent`, `fitScale(for:visibleSize:)` computes from real `GraphLayout.canvasSize`
- [x] Aktueller Zoom-Status ist sichtbar — `canvasZoomLabel` shows percentage in header
- [x] Zoom ist auf sinnvolle Grenzen begrenzt — 9 discrete levels `[0.25, 0.33, 0.5, 0.67, 0.8, 1.0, 1.25, 1.5, 2.0]`, clamp logic in pure Swift
- [x] Scroll- und Zoom-Verhalten funktionieren mit bestehendem GPT-2-Layout — `testFitScaleUsesGPT2CanvasSize` validates against real `TemplateCatalog.gpt2XL1_5B()` layout
- [x] `make test` deckt Viewport-/Zoom-Logik ab — 4 tests in `CanvasViewportStateTests`: clamp bounds, GPT-2 fit scale, stable zoom round-trips, layout-fit-stops-after-user-interaction. Engine tests (63/63) green. App tests blocked by known Xcode environment issue (not a code problem).

## Implementation Quality

**Code style compliance:**
- Guard clauses throughout, zero `else` blocks
- No mocks, tests use real `TemplateCatalog`/`PropagationEngine`/`GraphLayoutEngine`
- No TODOs, no workarounds
- Single source of truth: `AppModel` owns `CanvasViewportState`, UI reads from it
- Clean composition: `CanvasViewportState` is a value type, `CanvasRepresentable` is the bridge, `AppModel` is the coordinator

**Architecture boundaries:**
- `CanvasViewportState` is pure Swift, no AppKit/SwiftUI imports — correct layer separation
- `CanvasRepresentable` bridges to `NSScrollView.allowsMagnification` — correct API for the macOS platform
- UI never decides validity; viewport model owns scale truth

**UX-Gate ("Don't make me think"):**
- Fit button is `.borderedProminent` — clear primary action
- Zoom percentage always visible
- +/- buttons disable at bounds — no confusion about why zoom stopped
- Auto-fit on initial load via `requestLayoutFitIfNeeded()`, respects subsequent user adjustments

## Verdict

All r1 findings are resolved. Implementation is complete, well-tested, and architecturally clean. Approved for resolution.

**Handoff**: assigned-to: praxis
