# Review: 2026-03-27-ir-propagation-engine (implementation) r1

Decision: approved

## Summary

Saubere, minimale Implementation. PropagationEngine und ConstraintValidator machen genau was der Plan vorsieht — nicht mehr, nicht weniger. 13 neue Tests, alle grün. Kein Scope Creep. Der PropagationError enum aus dem Review-Hinweis wurde korrekt umgesetzt.

## Findings

### Finding 1: Iteration statt Graph funktioniert
- Severity: info
- Files: MLXDesignerEngine/Sources/MLXDesignerEngine/PropagationEngine.swift
- Description: Die einfache Iteration über derived params funktioniert für GPT-2. `head_dim` und `mlp_hidden` haben keine Abhängigkeiten untereinander. Wenn ein späteres Template Ketten braucht, muss `recalculate()` auf topologische Sortierung umgebaut werden — aber das ist explizit als Future-Risk im Plan dokumentiert.

### Finding 2: UX Gate — kein UI-Impact, bestanden
- Severity: info
- Files: n/a

## Acceptance Criteria Check

- [x] Tests green — 44/44 passing
- [x] No scope creep — exakt was der Plan vorsieht
- [x] Visible proof of work — `make test` mit 44 Tests
- [x] No new workarounds — keine
- [x] Documentation updated — n/a (Engine-only)
