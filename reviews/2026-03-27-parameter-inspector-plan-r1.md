# Review: 2026-03-27-parameter-inspector (plan) r1

Decision: approved

## Summary

Erster echter UI-Slice mit echtem User-Wert. Die Entscheidung, sich auf globale Template-Parameter statt auf freies Node-Editing zu konzentrieren, ist pragmatisch und verhindert Scope-Creep. Die TemplateSession-Abhängigkeit ist richtig — ohne echte Session-API wäre die UI-Logik dupliziert. Vier konkrete Lücken zur Klärung vor Implementation.

## Findings

### Finding 1: Fehlerbehandlung für ungültige Input nicht spezifiziert
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Implementation Steps Step 3 beschreiben "ungültige Eingaben führen zu verständlichen Fehlzuständen". Aber was sind "verständliche Fehlzustände"? Beispiele: Eingabe "abc" in Int-Feld → lokale Markierung im Input-Textfeld? Toast-Notification? Inline-Error-Text? Der Plan sagt nicht, wie der Error-Flow UI-seitig aussieht. Das ist wichtig, weil CLAUDE.md fordert: "Fehlerbehandlung ist Pflicht, aber nicht durch Logs verstecken".
- Suggestion: Der Plan sollte explizit zwei Fehlerklassen unterscheiden: (1) **Parsing-Fehler** (z.B. "abc" im Int-Feld) → lokale UI-Markierung, kein Session-Aufruf. (2) **Validation-Fehler** (z.B. Override-Wert verletzt Constraint) → Session liefert Diagnose → inline im Inspector anzeigen. Die Flows müssen im Acceptance Test sichtbar sein.

### Finding 2: Canvas-Refresh-Trigger nicht spezifiziert
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Implementation Steps Step 4 sagen: "Graph-Datenaufbereitung an den Session-Kontext hängen, damit Node-Labels und Parameterwerte live aktualisieren". Das ist zu abstrakt. Wie wird diese Aufbereitung getriggert?
  - Option A: ViewModel hält GraphLayout als computed Property, die bei Session-Änderung sofort neu berechnet wird?
  - Option B: Inspector-Change → Session-Update → expliziter Refresh-Call an GraphLayoutEngine?
  - Option C: SwiftUI-State-Binding, das den Canvas neu zeichnet?
  Der Plan sagt nicht, welches Pattern. Das könnte zu Performance-Problemen (zu häufiges Neuzeichnen) oder zu fehlenden Updates führen.
- Suggestion: Der Plan sollte klarstellen: "Nach jeder bestätigten Parameter-Änderung ruft das ViewModel `GraphLayoutEngine.layout(template:catalog:)` erneut mit dem aktualisierten Session-Kontext auf und updated die `@Published var graphLayout`-Property. SwiftUI beobachtet diese Änderung und re-rendert den Canvas."

### Finding 3: Lock/Unlock-Steuerung UI-Pattern nicht definiert
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Der Plan nennt "Lock/Unlock-/Reset-Steuerung" aber nicht das UI-Pattern. Ist das ein Button neben dem Eingabefeld? Eine Toggle-Checkbox? Ein Kontextmenü? Der Plan sagt "klare Lock-/Override-/Reset-Status" muss sichtbar sein, aber nicht wie. Das könnte zu unnötiger Komplexität oder zu unerwarteter UX führen.
- Suggestion: Der Plan sollte mindestens skizzieren: "Der `derived_overridable`-Parameter wird mit drei Buttons angezeigt: [🔓 Unlock] (wenn locked), [Override: <Wert>] + [🔒 Reset] (wenn unlocked). Der aktuelle Zustand ist farblich unterschieden (z.B. grauer Button = locked, blauer Button = unlocked)."

### Finding 4: App-State-Management Pattern nicht spezifiziert
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Implementation Steps Step 1 sagen "App-State oder ViewModel einführen", aber nicht ob das eine `@StateObject`, ein Singleton, oder ein separates Struct ist. Das beeinflusst Lifecycle, Testing und Speichermanagement. In SwiftUI ist die Wahl hier wichtig.
- Suggestion: Der Plan sollte festlegen: "TemplateSession wird in einem `@StateObject` von `ContentView` gehalten. Das ViewModel-Pattern wird nicht benötigt — Session selbst ist das State-Model. Parameter-Änderungen werden direkt durch Sessions-Methoden ausgelöst (z.B. `session.setMaster(paramName:value:)`)."

### Finding 5: UX Gate — Don't make me think
- Severity: info
- Files: n/a
- Description: Klare Struktur: Inspector mit Parameterinputs, Diagnosebereich, Lock-Buttons. Der erste Parameter-Change ist direkt verständlich. Keine Mehrdeutigkeit. UX Gate: bestanden.

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — nur globale Parameter + Diagnose, kein Node-Editing
- [x] Visible proof of work — Integration Tests für Param-Change → Canvas-Refresh, Override-Diagnose
- [x] No mocking — gegen echte TemplateSession
- [x] Guard clauses — Plan fordert explizite Fehlerzustände
- [x] Single source of truth — TemplateSession ist Baseline, UI visualisiert nur
- [x] Architecture intact — UI liest nur über Session-API
- [x] No new workarounds — keine, aber Error-Flows müssen sauber definiert sein

## Critical Dependencies

**Blocker**: Dieser Plan hängt von `2026-03-27-swiftui-app-shell` und `2026-03-27-template-session` ab. Beide müssen implementiert und getestet sein, bevor dieser Slice startet.
