# 2026-03-27-canvas-navigation

Status: awaiting-implementation-review
assigned-to: praxis

## Summary

Erweitert die macOS-App-Shell um echte Canvas-Navigation für den bereits gerenderten GPT-2-Graphen. Der Slice liefert Zoom, Fit-to-Graph und klar sichtbaren Viewport-Status auf Basis des bestehenden `NSScrollView`-Canvas, damit der sehr große Decoder-Graph ohne Suchfrust erkundbar wird. Das schließt die offensichtliche Lücke zwischen „Graph wird dargestellt“ und VISION-Meilenstein 2 „navigierbar“.

**Depends on**: 2026-03-27-swiftui-app-shell (muss zuerst landen)

## Target State

- Der App-Canvas unterstützt kontrollierte Vergrößerung und Verkleinerung des gesamten Graphen
- Eine Fit-to-Graph-Aktion setzt den Viewport auf einen sinnvollen Überblick über den vollständigen GPT-2-Graphen
- Der aktuelle Zoom-Level ist in der UI sichtbar
- Zoom ist auf feste Grenzen begrenzt und bleibt bei wiederholten Aktionen stabil
- Die eigentliche Zoom-/Fit-Berechnung ist als testbare Pure-Swift-Logik gekapselt

## Decisions

### In Scope

- Erweiterung des bestehenden `NSScrollView`-Canvas um Magnification-Unterstützung
- Kleine, testbare Viewport-/Zoom-Modellschicht für:
  - minimale und maximale Zoom-Stufe
  - Zoom-In/Zoom-Out/Reset
  - Fit-to-Graph-Berechnung auf Basis von Graphgröße und sichtbarer Viewport-Größe
- SwiftUI-Controls im bestehenden App-Header oder Toolbar-Bereich:
  - Zoom-Out
  - Zoom-In
  - 100%-Reset
  - Fit-to-Graph
  - sichtbarer Zoom-Wert
- Coordinator-/Bridge-Wiring zwischen SwiftUI-State und `NSScrollView`
- Reale Verifikation gegen den bestehenden GPT-2-Graphen

### Out of Scope

- Node-Selektion, Hit-Testing oder Fokus auf einzelne Nodes
- Mini-Map oder Bird’s-Eye-Overview
- Frei verschiebbare Kamera unabhängig vom ScrollView
- Gesten-Erkennung jenseits der Standard-ScrollView-/Trackpad-Unterstützung
- Editing, Hover-Farbfamilien oder Diagnose-Overlay
- Bezier-Kabel oder Layout-Neuberechnung

### Rejected Alternatives

- **Eigenen Kamera-Stack außerhalb von `NSScrollView` bauen**: Unnötig komplex. Der bestehende ScrollView soll gezielt erweitert werden statt doppelte Viewport-Logik einzuführen.
- **Nur Keyboard-Shortcuts ohne sichtbare Controls**: Verstößt gegen „Don’t make me think“. Der aktuelle Zoom-Zustand und die Hauptaktionen müssen sichtbar sein.
- **Mini-Map als erster Navigationsschritt**: Zu viel UI-Fläche und Komplexität für den ersten Navigations-Slice. Fit + Zoom lösen das Kernproblem direkter.
- **Viewport-Logik direkt im Representable verstreuen**: Schwer testbar und unnötig fragil. Die Berechnung gehört in eine kleine Pure-Swift-Schicht.

## Implementation Steps

1. **Viewport-Modell**
   - Einen kleinen Typ wie `CanvasViewportState` oder `CanvasViewportController` einführen
   - Zoom-Stufe, Min/Max-Grenzen und Aktionen `zoomIn`, `zoomOut`, `resetZoom`, `fitScale(for:visibleSize:)` kapseln
   - Guard-Failures für leere oder ungültige Größen explizit behandeln

2. **ScrollView-Magnification**
   - `CanvasRepresentable` und/oder `NodeCanvasView` so erweitern, dass der bestehende `NSScrollView` Magnification korrekt unterstützt
   - Bestehendes Scrolling erhalten, kein neuer Pan-Stack
   - Sicherstellen, dass Graphgröße und Dokumentansicht sauber mit Zoom zusammenspielen

3. **Visible Controls**
   - Im bestehenden SwiftUI-Header oder Toolbar-Bereich die Zoom-Aktionen ergänzen
   - Den aktuellen Zoom-Wert sichtbar darstellen
   - Fit-to-Graph als klare Primäraktion anbieten, nicht im Kontextmenü verstecken

4. **Fit-to-Graph Wiring**
   - Beim Fit die aktuelle `GraphLayout.canvasSize` mit der sichtbaren ScrollView-Fläche verrechnen
   - Bei Layout-Änderungen einen sinnvollen Default-Zoom ableiten, ohne User-Aktionen überraschend zu überschreiben

5. **Tests**
   - Pure-Swift-Tests für Clamp-Logik und Fit-Skalen-Berechnung
   - App-seitige Tests für stabile Zoom-Aktionen auf GPT-2-Canvas-Dimensionen
   - Manueller Smoke-Test: Fit, Zoom-In, Zoom-Out, Reset an GPT-2 XL

## Tests

- `CanvasViewportStateTests` — Zoom clamp auf definierte Min/Max-Grenzen
- `CanvasViewportStateTests` — `fitScale(for:visibleSize:)` berechnet für GPT-2-Canvas einen sinnvollen Überblick
- `CanvasViewportStateTests` — wiederholte Zoom-In/Out-Aktionen bleiben stabil und driften nicht
- `make test` besteht inklusive App-Tests
- Manueller Smoke-Test gegen den vollständigen GPT-2-Graphen im App-Canvas

## Risks

- **ScrollView-Magnification auf sehr großem Canvas**: Dokumentgröße, Zoom und Scrollposition müssen zusammenspielen, sonst springt der Viewport unkontrolliert.
- **UI-Überfrachtung**: Zu viele Controls würden den Header unnötig aufblasen. Deshalb nur die Kernaktionen Fit, Reset und Zoom.
- **Automatische Fit-Logik kann bevormundend wirken**: Einmaliger Default-Fit ist sinnvoll, aber spätere User-Zooms dürfen nicht still überschrieben werden.
- **Testbarkeit von AppKit-Wiring**: Deshalb Fokus der Automation auf die Pure-Swift-Viewport-Berechnung; AppKit selbst bleibt zusätzlich im manuellen Smoke abgesichert.

## Change Log

- initial plan
- 2026-03-28: Canvas-Navigation vollständig implementiert:
  - `CanvasViewportState` als Pure-Swift-Viewport-Modell mit stabilen Zoom-Stufen, Clamp-Grenzen, Reset und Fit-Berechnung ergänzt
  - `CanvasRepresentable` um echte `NSScrollView`-Magnification, Fit-Wiring und Sync des sichtbaren Zoom-Levels erweitert
  - SwiftUI-Header um `Fit`, `100%`, Zoom-In, Zoom-Out und sichtbaren Prozentwert ergänzt
  - App-Tests `CanvasViewportStateTests` für Clamp, GPT-2-Fit und stabile Zoom-Schritte ergänzt
- 2026-03-28: Lokale Verifikation blockiert durch zwei fremde Infrastrukturfehler:
  - `make test` scheitert weiterhin in `compileSmokeUsesRealGopyToolchain()` mit `failed to validate MLX runtime for this gpy program: *** -[__NSArray0 objectAtIndex:]: index 0 beyond bounds for empty array`
  - Direkter App-Testlauf via `xcodebuild ... -only-testing:MLXDesignerTests` scheitert vor dem Build mit `A required plugin failed to load` / `xcodebuild -runFirstLaunch`

## Approval Block

(filled by reviewer)
