# 2026-03-28-canvas-focus-feedback

Status: awaiting-plan-review
assigned-to: theorie

## Summary

Erweitert den nativen macOS-Canvas um fokussiertes Verständnis-Feedback für den GPT-2-Graphen: Node-Hover bzw. Fokus hebt Nachbarschaft und zusammengehörige Parameterfamilien farblich hervor, während irrelevante Bereiche zurücktreten. Der Slice schließt damit die Vision-Lücke zwischen „Graph ist sichtbar/editierbar“ und „der User versteht sofort die Auswirkungen einer Änderung“.

**Depends on**: 2026-03-27-canvas-navigation (muss zuerst landen), 2026-03-27-parameter-inspector (muss zuerst landen)

## Target State

- Der Canvas kennt einen expliziten Fokuszustand für „kein Fokus“ oder „Node im Fokus“
- Ein fokussierter Node hebt direkte Nachbarschaft und zugehörige Verbindungen sichtbar hervor
- Der Canvas zeigt konsistente Farbfamilien für semantisch zusammengehörige Nodes bzw. Ports, statt nur Tiefe zu kolorieren
- Ein kleiner Readout in der nativen Shell beschreibt den aktuellen Fokus verständlich
- Highlight- und Dimming-Regeln sind als testbare Pure-Swift-Logik modelliert
- Die Daten für Fokus und Familien werden aus Layout-/Session-Daten abgeleitet, nicht aus ad-hoc UI-Sonderlisten

## Decisions

### In Scope

- Erweiterung des nativen `GraphLayout` um die minimalen Metadaten, die für Fokus und Familienfarben nötig sind:
  - gerichtete Nachbarschaft/Verbindungs-Referenzen pro Node
  - stabile Familienkennung pro Node bzw. Port-Gruppe
  - optionaler Readout-Text oder dafür nötige Basisteile
- Kleine Pure-Swift-Modellschicht für Fokusregeln, z. B. ein `CanvasFocusState` und ein Resolver für:
  - aktiver Node
  - hervorgehobene Nodes/Edges
  - gedimmte Nodes/Edges
  - Farbfamilie für Fokus oder Hover
- AppKit-Hit-Testing im bestehenden `NodeCanvasView`, damit der User per Mausbewegung oder Klick einen Node fokussieren kann
- SwiftUI-/Bridge-Wiring, damit Header oder Statusbereich einen kompakten Fokus-Readout zeigt
- Visuelle Darstellung im nativen Canvas:
  - hervorgehobene Nodes/Edges mit klarer Priorität
  - gedimmte Umgebung ohne komplettes Ausblenden
  - familienbasierte Farbgebung, die auf hellem Hintergrund lesbar bleibt
- Automatisierte Tests für Familienzuordnung, Fokusauflösung und Dimming-Regeln

### Out of Scope

- Drag-and-Drop, freie Node-Positionierung oder strukturelles Graph-Editing
- Mehrfachselektion, Lasso oder Frame-/Group-Selektion
- Vollwertiger Detail-Inspector für den selektierten Node
- Parameter-Hover-Animationen oder zeitbasierte Propagation-Effekte
- Export-/Smoke-Test-Buttons oder Runtime-Ausführung
- Beliebige weitere Templates außer GPT-2 XL

### Rejected Alternatives

- **Nur kosmetisches Hover im `NSView`**: Reicht nicht. Ohne modellierten Fokuszustand ist das Verhalten nicht testbar und driftet von der Engine-/Session-Wahrheit weg.
- **Komplette Selection-Architektur wie im HTML-Prototyp sofort portieren**: Zu breit für diesen Slice. Für jetzt reicht ein klarer Einzel-Fokus mit Nachbarschaft und Farbfamilien.
- **Farben ausschließlich nach Container-Tiefe**: Verfehlt die Vision. Der User soll Auswirkungen und Zusammenhänge verstehen, nicht nur Ebenen unterscheiden.

## Implementation Steps

1. **Layout-Metadaten erweitern**
   - `GraphLayout`, `LayoutNode` und `LayoutEdge` um die minimalen Identitäten erweitern, die für Hit-Testing, Nachbarschaft und Familien gebraucht werden
   - Familienzuordnung aus vorhandenen Node-Typen, Param-Bindings und Container-Kontexten deterministisch ableiten
   - GraphLayoutEngine so anpassen, dass diese Metadaten beim Rendern des GPT-2-Templates mitgeführt werden

2. **Fokusmodell als Pure Swift**
   - `CanvasFocusState` für „none“ oder „node(id)“
   - Resolver einführen, der aus `GraphLayout` + Fokuszustand eine renderbare Fokus-Sicht ableitet
   - Regeln für Highlight, Dimming und Fokus-Readout explizit modellieren und clampen, damit der Canvas nie in einen unlesbaren Voll-Dim-Zustand kippt

3. **AppKit-Hit-Testing und Bridge**
   - Im `NodeCanvasView` Node-Hit-Testing auf Basis der vorhandenen Frames ergänzen
   - Hover und optional Klick in einen fokussierten Node übersetzen
   - `CanvasRepresentable` und `AppModel` so verdrahten, dass Fokuszustand und aktueller Readout observable bleiben

4. **Visuelles Rendering**
   - Bestehende Tiefenfarben auf ein System aus Basisfarben plus Fokus-/Familien-Overrides umstellen
   - Knoten, Container und Kanten so zeichnen, dass Fokuspfad und Familienbezug auf hellem Hintergrund sofort sichtbar sind
   - Status-/Header-Readout ergänzen, z. B. „Familie hidden_size · Nachbarschaft von attn“

5. **Tests und reale Verifikation**
   - Unit-Tests für Familienzuordnung im GPT-2-Layout
   - Unit-Tests für Fokusresolver: none, einzelner Node, Highlight/Dim-Mengen, Readout
   - App-seitiger Test für Hit-Testing oder wenigstens deterministische Fokusverdrahtung
   - Manueller Lauf in der macOS-App: GPT-2 laden, Node überfahren, visuelles Fokusverhalten prüfen

## Change Log

- Initialer Plan für nativen Canvas-Fokus mit Familienfarben und Hover-Propagation

## Tests

- `GraphLayoutEngineTests` — Layout enthält stabile Familien- und Nachbarschaftsmetadaten
- Neuer Testtyp wie `CanvasFocusResolverTests` — Fokuszustände, Highlight-/Dim-Mengen, Readout
- App-seitiger Test für Fokusverdrahtung zwischen `NodeCanvasView`, Bridge und `AppModel`
- `make test`

## Risks

- **Familienzuordnung ist fachlich unscharf**: Wenn die Ableitung nur auf Node-Typen basiert, wirkt das Highlight beliebig. Die Zuordnung muss deshalb Param-Bindings und Kontextpfade mit einbeziehen.
- **Zu aggressives Dimming schadet Lesbarkeit**: Der Fokus darf Orientierung geben, aber den Rest des Graphen nicht auslöschen. Die Farbwerte müssen bewusst abgestimmt und manuell geprüft werden.
- **Hover-only ist auf macOS fragil**: Wenn Maus-Tracking unzuverlässig ist, braucht der Slice eine saubere Klick-Fallback-Interaktion statt flackernder Zustände.

## Approval Block

(filled by reviewer)
