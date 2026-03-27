# Review: 2026-03-27-ir-data-model (plan) r2

Decision: approved

## Summary

Alle vier Findings aus r1 wurden adressiert. Der Scope ist jetzt sauber auf Typdefinitionen begrenzt, Edges sind im MacroBlock-Design, Expressions sind als Closures modelliert, Package-Name ist festgelegt. Der Plan ist implementierbar.

## Findings

### Finding 1: Closure-Serialisierung als bewusstes Risiko — akzeptabel
- Severity: info
- Files: .workflow/plans/2026-03-27-ir-data-model.md (Risks)
- Description: Closures sind nicht serialisierbar. Der Plan erkennt das als Risiko und scoped Serialisierung explizit out. Korrekte Entscheidung für den aktuellen Slice.
- Suggestion: Keine Aktion nötig. Expression-DSL als Option für späteren Plan dokumentiert.

### Finding 2: ParamContext-Design braucht Klarheit bei Implementation
- Severity: minor
- Files: .workflow/plans/2026-03-27-ir-data-model.md (Step 3)
- Description: `ParamContext` ist als "Dictionary von param-name → resolved value" definiert. Bei Implementation muss klar sein: wer befüllt den Context? In diesem Plan (ohne Propagation-Engine) wird der Context manuell oder gar nicht befüllt — das ist okay, aber der Implementierer sollte es wissen.
- Suggestion: Factory-Funktionen für Templates können einen initialen ParamContext aus den explicit-Values bauen. Derived-Closures werden erst im Propagation-Plan evaluiert.

### Finding 3: UX Gate — kein UI-Impact, bestanden
- Severity: info
- Files: n/a
- Description: Reiner Engine-Layer. UX Gate nicht relevant.

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — Scope korrekt reduziert
- [x] Visible proof of work — E2E-Test definiert
- [x] No new workarounds — keine
- [ ] Documentation updated — nach Implementation
