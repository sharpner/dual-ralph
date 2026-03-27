# 2026-03-27-swiftui-app-shell

Status: awaiting-plan-review
assigned-to: theorie

## Summary

Erstellt die macOS SwiftUI-App mit AppKit-basiertem Node-Canvas, der eine GPT-2-Template-Instanz als read-only Graph rendert. Erster visueller Meilenstein: User öffnet die App und sieht den vollständigen GPT-2-XL-Graphen mit Nodes, Edges und Parameterwerten. Navigation (Pan/Zoom) und Editing kommen in späteren Slices.

**Depends on**: 2026-03-27-ir-data-model (done), 2026-03-27-ir-propagation-engine (done)

## Target State

- Eine macOS-App startet und zeigt ein Fenster mit Sidebar + Canvas-Bereich
- Der Canvas (AppKit NSView) rendert den GPT-2-XL-Graphen: Nodes als beschriftete Rechtecke, Edges als Linien
- Macro-Block-Hierarchie ist sichtbar: Decoder enthält Repeat, Repeat enthält Block
- Parameterwerte werden auf Nodes angezeigt (d_model=1600, num_heads=25, etc.)
- Engine ist Single Source of Truth — UI liest nur aus dem IR-Modell

## Decisions

### In Scope

- Xcode-Projekt (macOS App, Swift 5.9+, macOS 14+)
- SwiftUI `App` + `WindowGroup` mit `NavigationSplitView` (Sidebar + Detail)
- Sidebar: Template-Auswahl (erstmal nur GPT-2 XL, hardcoded)
- Detail: `CanvasView` (NSViewRepresentable → AppKit `NodeCanvasView`)
- `NodeCanvasView` (NSView subclass): zeichnet Nodes und Edges via Core Graphics
- Layout-Engine: einfaches vertikales Pipeline-Layout (Nodes von oben nach unten, Edges vertikal)
- Node-Rendering: Rechteck mit nodeType-Label, Alias, und sichtbaren Parametern
- Edge-Rendering: gerade Linien zwischen Output-Port-Position und Input-Port-Position
- Macro-Block-Rendering: umschließendes Rechteck mit Label für gpt2_block, gpt2_decoder
- Integration von MLXDesignerEngine als Package-Dependency
- `make app` Target im Makefile für `xcodebuild`

### Out of Scope

- Pan/Zoom/Scroll — eigener Plan
- Parameter-Editing im Canvas — eigener Plan
- Drag-and-Drop / Node-Verschieben — eigener Plan
- Bezier-Kabel (erstmal gerade Linien, Bezier-Upgrade in späterem Plan)
- Port-Visualisierung (farbige Punkte für Ports) — eigener Plan
- Hit-Testing / Selektion — eigener Plan
- Shape-Linter-Integration in UI — eigener Plan
- Farbfamilien für Parameter-Propagation — eigener Plan
- Responsive Layout / Window-Resizing — grundlegende NSView-Autorezising reicht

### Rejected Alternatives

- **Reines SwiftUI Canvas**: SwiftUI Canvas hat Limitierungen bei Hit-Testing und Custom Drawing. AGENTS.md spezifiziert AppKit NSView für den Node-Canvas. SwiftUI nur als Shell.
- **SceneKit / SpriteKit**: Overkill für 2D-Node-Graphen. Core Graphics reicht für Rechtecke und Linien.
- **Automatisches Graph-Layout (z.B. Graphviz)**: YAGNI für GPT-2. Die Pipeline-Struktur ist linear (decoder → repeat → block), ein einfaches vertikales Layout ist ausreichend und vorhersagbar.
- **SwiftUI-only ohne AppKit**: Kein ausreichendes Custom Drawing für Canvas-Interaktion in späteren Slices.

## Implementation Steps

1. **Xcode-Projekt Setup**
   - macOS App Target, Swift 5.9+, macOS 14+ Deployment Target
   - MLXDesignerEngine als lokale Package-Dependency
   - Makefile Target `make app` (xcodebuild)
   - .gitignore für Xcode-Artefakte

2. **SwiftUI App Shell**
   - `MLXDesignerApp`: SwiftUI App mit WindowGroup
   - `ContentView`: NavigationSplitView mit Sidebar + Detail
   - Sidebar: Liste mit Template-Namen (erstmal nur "GPT-2 XL 1.5B")
   - Detail: `CanvasContainerView` (enthält NSViewRepresentable)

3. **Graph-Datenaufbereitung**
   - `GraphLayout` struct: flacht MacroBlock-Hierarchie in positionierte Nodes und Edges ab
   - `LayoutNode` struct: `id`, `label`, `params: [(String, String)]`, `position: CGPoint`, `size: CGSize`, `depth: Int` (Macro-Nesting-Tiefe)
   - `LayoutEdge` struct: `from: CGPoint`, `to: CGPoint`
   - `GraphLayoutEngine.layout(template: TemplateInstance, catalog: ...)` → `GraphLayout`
   - Vertikales Pipeline-Layout: Y-Position = Index * Spacing, X = zentriert

4. **AppKit Node Canvas**
   - `NodeCanvasView: NSView` subclass
   - `var graphLayout: GraphLayout`
   - `override func draw(_ dirtyRect: NSRect)` — zeichnet:
     - Macro-Container-Rechtecke (äußere Rahmen mit Label)
     - Node-Rechtecke (gefüllter Hintergrund, nodeType + alias + Params als Text)
     - Edge-Linien (von Source-Node-Bottom-Center zu Target-Node-Top-Center)
   - Core Graphics: `NSBezierPath`, `NSColor`, `NSFont`

5. **NSViewRepresentable Bridge**
   - `CanvasRepresentable: NSViewRepresentable`
   - Erstellt `NodeCanvasView`
   - Updatet `graphLayout` wenn sich Template ändert

6. **Integration**
   - `ContentView` erstellt `PropagationEngine` mit GPT-2-XL-Template
   - Übergibt resolved Params an `GraphLayoutEngine`
   - `CanvasRepresentable` rendert das Ergebnis

7. **Tests**
   - Unit: `GraphLayoutEngine` — korrekte Anzahl Nodes/Edges für GPT-2 XL
   - Unit: `LayoutNode`-Positionen — keine Überlappungen
   - Manueller Test: App starten, Graph sichtbar

## Tests

- `GraphLayoutEngineTests` — GPT-2 XL Template → korrekte Anzahl LayoutNodes und LayoutEdges
- `GraphLayoutEngineTests` — Node-Positionen haben keine Überlappungen
- `GraphLayoutEngineTests` — Macro-Container umschließen ihre Child-Nodes
- Manueller Smoke Test: App starten, GPT-2-Graph visuell korrekt

## Risks

- **Xcode-Projekt im Git**: `.xcodeproj` kann Merge-Konflikte erzeugen. Minimieren durch saubere Projekt-Struktur und wenige manuelle Xcode-Einstellungen.
- **AppKit-Zeichnung Performance**: Bei GPT-2 XL mit 48 Layers × 6 Nodes = ~300 Nodes. Core Graphics sollte das problemlos schaffen, aber falls nicht → Layer-backed Views oder Canvas-Clipping.
- **Layout-Komplexität**: GPT-2-Decoder hat verschachtelte Macros (decoder → repeat → block). Das flache Pipeline-Layout muss die Nesting-Hierarchie sinnvoll darstellen. Risiko: visuelle Unübersichtlichkeit. Mitigation: Macro-Container als farblich abgesetzte Rahmen.
- **Kein `make test` für UI**: AppKit-Rendering ist schwer automatisiert testbar. Tests fokussieren auf die Layout-Engine (pure Swift). Visueller Test manuell.

## Change Log

(initial plan)

## Approval Block

(filled by reviewer)
