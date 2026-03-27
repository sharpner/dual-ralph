# Review: 2026-03-27-ir-data-model (implementation) r1

Decision: approved

## Summary

Saubere Implementation. Alle 10 Building Blocks, beide Macros, GPT-2 XL Template — alles da, alles getestet. 31 Tests, alle grün. Kein Scope Creep, keine TODOs, keine Mocks. Die Typen bilden proposal.md korrekt ab. Zwei kleinere Hinweise für Nachfolge-Pläne.

## Findings

### Finding 1: ParamValue Equatable fehlt
- Severity: minor
- Files: MLXDesignerEngine/Sources/MLXDesignerEngine/ParamSchema.swift
- Description: `ParamValue` und `ParamSchema` sind nicht `Equatable`, weil `ParamValue.expression` eine Closure enthält. Das ist korrekt für jetzt (Closures sind nicht vergleichbar), aber wird für die Propagation-Engine relevant wenn man Parameter-Änderungen tracken will.
- Suggestion: Kein Fix nötig in diesem Plan. Im Propagation-Engine-Plan adressieren — eventuell ParamValue.expression in einen eigenen Typ wrappen der Equatable über den String-Teil implementiert.

### Finding 2: Edge-Konvention `_input`/`_output`
- Severity: minor
- Files: MLXDesignerEngine/Sources/MLXDesignerEngine/MacroBlockCatalog.swift
- Description: Die Konvention `_input` und `_output` als pseudo-Node-Namen für Macro-Ein-/Ausgänge ist implizit. Funktioniert, aber sollte dokumentiert/als Konstante definiert werden wenn die Edge-Validation kommt.
- Suggestion: Für jetzt akzeptabel. Im nächsten Plan als Konstanten extrahieren.

### Finding 3: Keine `else` Branches — korrekt
- Severity: info
- Files: Alle
- Description: Guard clauses überall, keine else-Branches. Coding-Regeln eingehalten.

### Finding 4: UX Gate — kein UI-Impact, bestanden
- Severity: info
- Files: n/a
- Description: Reiner Engine-Layer.

## Acceptance Criteria Check

- [x] Tests green — 31/31 passing
- [x] No scope creep — exakt was der Plan vorsieht
- [x] Visible proof of work — `make test` mit 31 Tests
- [x] No new workarounds — keine
- [ ] Documentation updated — AGENTS.md könnte Build-Befehle aktualisieren (minor, nicht blockierend)
