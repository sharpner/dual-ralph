# Review: 2026-03-27-swiftui-app-shell (plan) r1

Decision: approved

## Summary

Klarer erster UI-Slice mit korrekter Architektur-Compliance. SwiftUI als Shell, AppKit NSView für den Canvas — exakt wie AGENTS.md es vorschreibt. Read-only ist die richtige Scope-Entscheidung für diesen Meilenstein. Die vertikale Pipeline-Layout-Entscheidung ist pragmatisch und für GPT-2 ausreichend. Zwei mittelschwere Lücken in den Implementation Steps die behoben werden müssen, bevor der Canvas real benutzbar ist.

## Findings

### Finding 1: NSScrollView fehlt in Implementation Steps
- Severity: medium
- Files: n/a (Plan-Level)
- Description: GPT-2 XL hat 48 Layer × ~6 Nodes/Layer plus Decoder-Level = ~300+ LayoutNodes im vertikalen Pipeline-Layout. Bei einem realistischen Node-Spacing (z.B. 120pt) ergibt das eine Canvas-Höhe von ~36.000pt. Ohne `NSScrollView` ist nur der sichtbare Fenster-Ausschnitt erreichbar. Step 4 beschreibt `NodeCanvasView: NSView` — aber ohne `NSScrollView`-Einbettung ist der Graph für GPT-2 XL faktisch unnutzbar.
- Suggestion: Step 4 muss explizit vorsehen: `NodeCanvasView` hat `intrinsicContentSize` basierend auf dem Layout-Extent. Step 5 (`CanvasRepresentable`) bettet `NodeCanvasView` in ein `NSScrollView` ein, das als `documentView` gesetzt wird. Das ist Standard-AppKit-Pattern und erzeugt kein Scope-Creep — ohne das ist der Acceptance Criterion "App launches and shows the graph" für GPT-2 XL nicht erfüllbar.

### Finding 2: `make test` Integration für Layout Engine nicht spezifiziert
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Der Plan sagt "Kein `make test` für UI" und erklärt korrekt, dass AppKit-Rendering schwer automatisiert testbar ist. Aber die `GraphLayoutEngineTests` sind reine Swift-Logic — kein AppKit, kein Rendering. Diese Tests müssen über `make test` ausführbar sein. Das Makefile-Target `make app` für `xcodebuild` ist definiert, aber es bleibt offen ob die XCTest-Targets (z.B. mit `xcodebuild test`) in `make test` aufgenommen werden.
- Suggestion: Step 1 (Xcode-Projekt Setup) soll explizit ein `make test` Target für `xcodebuild test -scheme ... -destination 'platform=macOS'` spezifizieren, das die Layout-Engine-Tests ausführt. Das Makefile muss `make test` unterstützen — Acceptance Criteria #1 (Tests Green) setzt das voraus.

### Finding 3: `catalog`-Parameter in `GraphLayoutEngine.layout(...)` Typ nicht spezifiziert
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Step 3 nennt `GraphLayoutEngine.layout(template: TemplateInstance, catalog: ...)` mit `...` als Typ-Platzhalter. Der korrekte Typ sollte der im IR verwendete Katalog-Typ sein (wahrscheinlich `[String: BuildingBlock]` oder ein `BuildingBlockCatalog`-Wrapper). Unspezifiert lässt das Spielraum für inkonsistente Typen.
- Suggestion: Praxis soll den Katalog-Parameter mit dem exakten Typ aus dem bestehenden `MLXDesignerEngine`-Package verwenden — kein neuer Wrapper-Typ.

### Finding 4: UX Gate — Don't make me think
- Severity: info
- Files: n/a
- Description: Read-only Graph mit Labels, Params und Macro-Hierarchy ist kognitiv klar. Kein Handlungsbedarf vom User in diesem Slice. UX Gate: bestanden. Folge-Slices (Navigation, Editing) müssen separat geprüft werden.

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — Read-only, kein Pan/Zoom/Edit
- [x] Visible proof of work — `GraphLayoutEngineTests` + Manueller Smoke Test
- [x] No mocking — gegen echte TemplateInstance aus MLXDesignerEngine
- [x] Guard clauses — Plan fordert guard clauses, no else
- [x] Single source of truth — UI liest ausschließlich aus Engine-IR
- [x] Architecture intact — SwiftUI Shell + AppKit Canvas, Engine ist Single Source of Truth
- [x] No new workarounds — keine
