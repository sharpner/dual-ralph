# Review: 2026-03-27-canvas-navigation (plan) r1

Decision: approved

## Summary

Solid, pragmatic plan for making the GPT-2 canvas genuinely navigable. The decision to extend the existing NSScrollView (not build a custom camera stack) is correct and aligns with YAGNI. Scope is appropriately tight: Zoom, Fit-to-Graph, and status visibility. No feature creep into selection or editing. Four concrete clarifications needed before implementation, but no structural flaws.

## Findings

### Finding 1: Viewport-Modell API nicht spezifiziert
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Implementation Steps Step 1 fordert "CanvasViewportState oder CanvasViewportController einführen" aber nicht die öffentliche API. Welche öffentliche Methoden hat dieser Typ? Was ist der öffentliche Zustand, was ist privat? Beispiel: ist `zoomScale: CGFloat` public oder nur lesbar? Können zoomIn/zoomOut auf Lock-Fehler schlagen oder nicht?
- Suggestion: Plan sollte mindestens skizzieren:
  ```swift
  struct CanvasViewportState {
    var zoomScale: CGFloat { get }
    mutating func zoomIn()
    mutating func zoomOut()
    mutating func resetZoom()
    static func fitScale(graphSize: CGSize, visibleSize: CGSize) -> CGFloat
  }
  ```
  Oder ähnliche Clear API.

### Finding 2: ScrollView-Magnification Mechanik nicht klar
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Step 2 sagt "NSScrollView Magnification korrekt unterstützen", aber nicht ob das durch `scrollView.magnification`, einen custom `NSView.drawsBackground` oder einen Transform-Stack läuft. Der Typ `magnificationFactor` in NSScrollView ist schreibbar, aber ohne Erklärung unklar, wie die Größe des gezeichneten Inhalts (Canvas-Dokumentgröße) sich verhält. Kann es passieren, dass Zoom die `NodeCanvasView.frame` ändert oder bleibt die Größe fix?
- Suggestion: Plan sollte klarstellen:
  - "NodeCanvasView.frame bleibt auf `GraphLayout.canvasSize` fixiert"
  - "`NSScrollView.magnification` wird direkt gesetzt (keine Transform)"
  - "Zoom-Aktion berechnet neue `magnificationFactor` über `CanvasViewportState.zoomScale`"
  - "ScrollView-View-Hierarchy: NSScrollView → NSClipView → NodeCanvasView"

### Finding 3: Fit-to-Graph Semantik für Layout-Änderungen nicht definiert
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Step 4 warnt korrekt "spätere User-Zooms dürfen nicht still überschrieben werden", aber es fehlt: Was ist das Szenario? Beispiel: User zoomed auf 200%, dann werden neue Daten laden — sollte das Auto-Fit auf 100% zurückfallen oder nicht? Der Slice hat als Abhängigkeit nur `swiftui-app-shell`, keine TemplateSession oder Daten-Änderungen. Also konkrete Frage: Wann wird Auto-Fit getriggert? Nur beim Launch oder auch wenn der Benutzer Template wechselt?
- Suggestion: Plan sollte klarstellen:
  - "Auto-Fit on App Launch: Beim ersten Laden des GPT-2-Templates wird fitScale() berechnet und gesetzt"
  - "User-Zoom-Persistenz: Nach manuellem Zoom-In/Out wird der neue Zoom behalten, bis explizit Reset oder Fit aufgerufen wird"
  - "Kein Auto-Fit bei Daten-Änderungen" (weil dieser Slice noch keine Daten-Variabilität hat)

### Finding 4: Clamp-Grenzen nicht spezifiziert
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Implementation Steps Step 1 sagt "Zoom-Stufe auf feste Grenzen begrenzt" aber nicht auf welche. Min 10%? 50%? Max 500%? 1000%? Für GPT-2 mit 30k+ pixels Canvas-Höhe ist das nicht trivial: zu grosser Min-Zoom macht das Entire-Canvas-View unmöglich, zu klein Max-Zoom macht Detailsicht sinnlos.
- Suggestion: Plan sollte festlegen:
  - `minimumZoomScale: 0.1` (10% — kleiner wird zu unlesbar)
  - `maximumZoomScale: 3.0` (300% — größer ist zu nah)
  - Oder ähnliche sinnvolle Grenzen mit Begründung für GPT-2-Canvas

### Finding 5: UX Gate — Don't Make Me Think
- Severity: info
- Files: n/a
- Description: Zoom-Controls in Header/Toolbar sind Standard und sofort verständlich. Zoom-Wert sichtbar macht den aktuellen Status klar. Fit-to-Graph als Primary Action reduziert Frust bei "wo bin ich?". UX Gate: bestanden.

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — Zoom + Fit + Status, keine Selektion/Editing
- [x] Visible proof of work — Tests für fitScale-Berechnung + manueller Smoke-Test
- [x] No mocking — gegen echten GPT-2-Canvas und NSScrollView
- [x] Guard clauses — Plan fordert explicitly für leere/ungültige Größen
- [x] Single source of truth — Viewport-State kommt nicht dupliziert vor
- [x] Architecture intact — UI-Shell (SwiftUI) koordiniert AppKit-Canvas (NSScrollView/NodeCanvasView)
- [x] No new workarounds — keine
- [x] Dependency clear — muss nach swiftui-app-shell landen

## Critical Dependencies

**Blocker**: Dieser Plan hängt von `2026-03-27-swiftui-app-shell` ab. AppShell muss implementiert und getestet sein, bevor dieser Slice startet (was jetzt der Fall ist: SwiftUI-AppShell ist gerade in resolved/ angekommen).

## Ready for Implementation

Plan ist strukturell robust. Die vier Findings sind Implementation-Klärungs-Punkte, keine Architektur-Fehler. Praxis sollte vor der Implementierung die vier Punkte adressieren (API skizzieren, ScrollView-Magnification-Pfad definieren, Fit-Semantik klarstellen, Clamp-Grenzen wählen) und diese im Code dokumentieren.

Suggested approach:
1. Definiere CanvasViewportState struct mit öffentlicher API (Finding 1)
2. Definiere ScrollView-Magnification-Mechanik in CanvasRepresentable (Finding 2)
3. Dokumentiere Fit-Trigger-Semanti in code comment (Finding 3)
4. Definiere min/max Zoom Scale als LayoutMetrics konstanten (Finding 4)
5. Schreibe tests für fitScale mit konkreten GPT-2-Dimensionen
6. Implementiere Zoom-Controls in App Header

**Handoff**: assigned-to: praxis
