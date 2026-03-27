# Review: 2026-03-27-shape-linter (plan) r1

Decision: approved

## Summary

Solider, präziser Plan. Scope ist sauber auf Shape-Matching begrenzt — keine Inferenz, keine DType-Prüfung, kein rekursives Nesting. Die Trennung von ConstraintValidator und ShapeLinter ist architektonisch richtig. Die `enum`-Namespacing-Entscheidung für `ShapeLinter` ist idiomatisches Swift. Zwei konkrete Lücken in den Implementation Steps müssen bei der Umsetzung adressiert werden.

## Findings

### Finding 1: Macro-Port-Lookup-Pfad fehlt in Implementation Steps
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Der Risks-Abschnitt nennt das Problem korrekt — Edges können die Input/Output-Ports des Macro selbst referenzieren (z.B. `macro.hidden_in → ln_1.input`). Aber die Implementation Steps (Step 4) beschreiben ausschließlich den Lookup-Pfad über NodeInstance-Alias → BuildingBlock-Ref → Port. Für Macro-eigene Ports gibt es keinen NodeInstance-Eintrag — der Lookup wird scheitern oder abstürzen, wenn Praxis nicht explizit einen Sonderfall einbaut.
- Suggestion: Step 4 muss einen Branch für Macro-eigene Port-Referenzen enthalten: wenn `edge.sourceNode` keiner NodeInstance-Alias entspricht, dann direkt in `macro.inputPorts` bzw. `macro.outputPorts` nachschlagen. Shape des Macro-Ports direkt resolven. Keine NodeInstance nötig.

### Finding 2: Guard-Verhalten bei fehlgeschlagenem Lookup nicht spezifiziert
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Step 4 beschreibt den Happy-Path-Lookup (`alias → NodeInstance → ref → BuildingBlock → Port`), sagt aber nicht was passiert wenn ein Schritt fehlschlägt. Stilles Überspringen würde Violations verschleiern und gegen Acceptance Criterion #3 (Visible Proof) und #8 (No Workarounds) verstoßen.
- Suggestion: Bei fehlgeschlagenem Alias-, Ref- oder Port-Lookup soll der Linter eine `ShapeViolation` mit einem klaren `message`-String erzeugen (z.B. `"unresolvable source port: <alias>.<portName>"`). Nicht ignorieren, nicht crashen.

### Finding 3: UX Gate — keine UI-Beteiligung, bestanden
- Severity: info
- Files: n/a
- Description: Reine Engine-Logik, keine UI-Auswirkungen.

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — Scope korrekt abgegrenzt
- [x] Visible proof of work — E2E-Tests definiert (GPT-2-Block valid + künstlicher Mismatch)
- [x] No mocking — gegen echte IR-Strukturen
- [x] Guard clauses — Plan fordert explizit guard clauses, no else
- [x] Single source of truth — ShapeLinter liest aus BuildingBlockCatalog und ParamContext
- [x] Architecture intact — Engine-only, keine UI-Entscheidungen
- [x] No new workarounds — keine
