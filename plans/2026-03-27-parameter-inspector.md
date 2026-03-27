# 2026-03-27-parameter-inspector

Status: awaiting-plan-review
assigned-to: praxis

## Summary

Erweitert die geplante macOS-App-Shell um einen echten Parameter-Inspector, der auf `TemplateSession` aufsetzt. Der User kann globale GPT-2-Parameter ändern, einen `derived_overridable`-Parameter entsperren/übersteuern und Diagnosen inline sehen, während Canvas und Parameteranzeigen sofort den neuen Engine-Zustand spiegeln. Das ist der erste UI-Slice, der das Produkt von "Graph anschauen" zu "Architektur verstehen und testen" verschiebt.

**Depends on**: 2026-03-27-swiftui-app-shell (muss zuerst landen), 2026-03-27-template-session (muss zuerst landen)

## Target State

- Die App zeigt neben Sidebar und Canvas einen Inspector für die globale Template-Konfiguration
- Der Inspector liest seinen Zustand aus einer `TemplateSession`, nicht aus separaten UI-Dictionaries
- Master-Parameter lassen sich editieren; Propagation läuft sofort und sichtbare Werte aktualisieren sich ohne manuellen Refresh
- Ein `derived_overridable`-Parameter zeigt klaren Lock-/Override-/Reset-Status
- Constraint- und Shape-Verstöße werden inline erklärt und nicht in Logs versteckt
- Canvas-Node-Labels und Parameter-Readouts spiegeln den aktuellen Session-Zustand

## Decisions

### In Scope

- App-State-/ViewModel-Schicht, die eine `TemplateSession` für das aktive Template hält
- Inspector-UI für globale Parameter:
  - Int-/Float-Eingaben für Master-Parameter
  - Lock/Unlock-/Reset-Steuerung für `derived_overridable`
  - Sichtbarer Status für `derived_locked`, `derived_overridable`, `master`
- Inline-Diagnosebereich mit Constraint- und Shape-Meldungen aus dem Session-Snapshot
- Aktualisierung des gerenderten Graphen bzw. der Node-Parameterrendering-Daten aus der Session statt aus statischen Template-Werten
- Kleine, testbare Formatierungs- und Input-Parsing-Schicht, damit ungültige Eingaben als UI-Fehlerzustand erscheinen statt sofort die Session zu beschädigen

### Out of Scope

- Freies Node-Editing auf dem Canvas
- Pan/Zoom, Hit-Testing, Multi-Selection oder Drag-and-Drop
- Hover-Farbfamilien und Propagation-Animationslogik
- Datei-Persistenz für User-Änderungen
- Export-Buttons oder Smoke-Test-Steuerung

### Rejected Alternatives

- **Parameter nur in der Sidebar als rohe Textliste anzeigen**: Zu schwach. Der Slice muss echte Bearbeitung plus Diagnose leisten.
- **Direkte Canvas-Inplace-Editoren**: Zu früh. Ein klarer Inspector reduziert kognitive Last und hält die erste Interaktion verständlich.
- **SwiftUI hält eigene Parameterkopien**: Verboten. Engine-Session bleibt die Wahrheit.
- **Diagnosen nur als generisches Status-Badge**: Nicht akzeptabel. `AGENTS.md` fordert Inline-Erklärung statt versteckter Logs.

## Implementation Steps

1. **Session-gebundener App-State**
   - App-State oder ViewModel einführen, das das aktive Template lädt und eine `TemplateSession` hält
   - Änderungen aus dem Inspector ausschließlich über Session-Methoden routen
   - Guard-Failures in explizite UI-Fehlerzustände übersetzen

2. **Inspector-Struktur**
   - Rechten Inspector- oder Split-Panel-Bereich im bestehenden App-Shell-Layout ergänzen
   - Parametergruppen klar gliedern: Master, Derived, Diagnostics
   - Default-Zustand sinnvoll halten; keine leeren Panels ohne Erklärung

3. **Editierlogik**
   - Typed Input für Int-/Float-Parameter mit Commit-Verhalten, das ungültige Eingaben lokal markiert
   - Lock/Unlock-/Reset-Flow für `derived_overridable`
   - Session-Neuberechnung nach jeder bestätigten Änderung auslösen

4. **Canvas-Refresh**
   - Graph-Datenaufbereitung an den Session-Kontext hängen, damit Node-Labels und Parameterwerte live aktualisieren
   - Diagnostisch relevante Werte sichtbar machen, ohne die Canvas-Darstellung zu überladen

5. **Tests**
   - Unit: ViewModel lädt Session und spiegelt Änderungen korrekt
   - Unit: Ungültige Eingabe bleibt lokaler Fehlerzustand und schreibt nicht in die Session
   - Integration: Änderung von `d_model` aktualisiert Inspector-Werte und Canvas-Datenmodell
   - Integration: Override eines `derived_overridable`-Parameters zeigt Diagnose inline

## Tests

- App-State-/ViewModel-Tests für Editierfluss und Fehlerzustände
- Integrationstests für Session-Bindung und Canvas-Datenrefresh
- `make test` deckt Engine- plus App-Tests ab
