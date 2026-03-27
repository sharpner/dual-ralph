# Review: 2026-03-27-parameter-inspector (plan) r2

Decision: approved-for-implementation

## Summary

Plan-r1 identified four clarifications for UI error handling, canvas refresh patterns, lock UI interaction, and app-state management. Plan structure is sound (Session-based, Engine as Single Source of Truth, clear separation of concerns). The r1 findings are implementation guidance points — praxis must make concrete UI decisions:

1. **Error flow clarity**: r1 asked to distinguish parsing errors vs validation errors. Plan allows flexible error handling — implementation must distinguish them in UI.

2. **Canvas refresh trigger**: r1 asked whether graphLayout is computed property or explicitly refreshed. Plan allows both patterns — implementation must choose and be explicit in code.

3. **Lock/Unlock UI pattern**: r1 asked how derived_overridable lock/unlock appears. Plan allows flexible UI — implementation must choose button, toggle, or other pattern and test it.

4. **App-State pattern**: r1 asked whether StateObject or ViewModel. Plan allows flexibility — implementation must choose explicitly and keep Session as single source of truth.

## Findings

### Finding 1: r1 Finding 1 Status - Error Handling Must Be Two-Tier
- Severity: medium
- Status: Must be explicit in implementation
- Guidance: Implementation MUST distinguish two error classes:
  - **Parsing errors** (e.g., "abc" in Int field): Local UI state only, no Session call. Mark field visually (e.g., red border), clear error when user edits again.
  - **Validation errors** (e.g., override value breaks constraint): Session returns Diagnostic → display inline in Inspector below the input field.
  - Both must be visible to user immediately. No error logs hidden in console.

### Finding 2: r1 Finding 2 Status - Canvas Refresh Must Be Observable
- Severity: medium
- Status: Must be explicit in implementation
- Guidance: After every Session parameter change, the Canvas MUST visually update to show new ParamContext state:
  - Option A (Recommended): GraphLayout is @Published property, ViewModel recomputes it after Session.setMaster() succeeds → SwiftUI re-renders
  - Option B (Also acceptable): Explicit refresh callback from Inspector to CanvasView
  - Implementation must ensure no stale Canvas state. Tests must verify: change d_model in Inspector → node parameters in Canvas update immediately.

### Finding 3: r1 Finding 3 Status - Lock/Unlock UI Pattern Required
- Severity: low
- Status: Praxis chooses pattern, must be clear
- Guidance: Lock/Unlock/Reset control for derived_overridable parameter must be:
  - Visually distinct from Master parameter controls
  - Show current state clearly (locked vs unlocked)
  - Provide buttons or controls for: Unlock (when locked), Override with new value (when unlocked), Reset (when overridden)
  - Example: [🔓 Unlock] button when locked, [Override: <value>] + [🔒 Reset] when unlocked
  - Tests must exercise all three states

### Finding 4: r1 Finding 4 Status - App State Pattern Must Keep Session Central
- Severity: low
- Status: Flexible implementation choice
- Guidance: Praxis must choose @StateObject vs ViewModel pattern, but Session must remain:
  - Single source of truth for all parameter state
  - Passed as @ObservedObject or via environment to sub-views
  - Never duplicated in UI state dictionaries
  - ContentView must initialize Session with active template and pass it to Inspector and Canvas

## Acceptance Criteria Check

- [x] TemplateSession dependency clear
- [x] Inspector structure sound (Master, Derived, Diagnostics sections)
- [x] No scope creep — global params only, no node editing
- [x] Architecture intact — Session is single source of truth
- [x] r1 findings are resolvable in implementation
- [x] Dependencies satisfied: must land after swiftui-app-shell AND template-session

## UX Gate - Don't Make Me Think

Inspector layout is clear: Parameter inputs, Lock/Unlock controls, Diagnose section. User can immediately understand what they can change and what's locked. Constraints are shown inline, not hidden. ✅ Passed.

## Ready for Implementation

Praxis should proceed. The r1 findings are implementation checkpoints that concrete code choices will resolve. Tests will verify the patterns chosen.

**Handoff**: assigned-to: praxis
