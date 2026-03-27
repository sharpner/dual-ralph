# Review: 2026-03-27-template-session (plan) r1

Decision: approved

## Summary

Solider Plan für die fehlende Editierbarkeits-Schicht. Die Architektur-Entscheidung, Session-State als Overlay über unveränderliche TemplateInstance zu halten, ist richtig — Single Source of Truth bleibt bei Engine und Katalogen, nicht bei UI-Dictionary. Die Abhängigkeit auf Shape-Linter vor diesem Slice ist sauber. Drei konkrete Lücken, die vor der Implementierung geklärt werden müssen.

## Findings

### Finding 1: Welcher GPT-2-Derived-Parameter wird `derived_overridable`?
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Der Plan fordert "Mindestens ein echter Derived-Parameter im GPT-2-Template als `derived_overridable`" und nennt als Beispiel `head_dim`, aber commits nicht zu einer konkreten Wahl. Implementation Steps sagen "Einen sinnvollen Derived-Parameter freigeben" ohne Spezifikation. Das führt zu Uncertainty in der Implementation: Praxis muss die Wahl selbst treffen und das könnte zu falscher Wahl führen (z.B. ein Parameter, der nicht wirklich overridable sein sollte). Der Test-Plan hängt von dieser Wahl ab.
- Suggestion: Der Plan sollte explizit benennen: "In GPT-2-Template: `head_dim` als `derived_overridable` freigeben, mit Constraint-Check auf `d_model == num_heads * head_dim`." Das macht die Wahl fachlich begründet und verhindert abseits Implementierungs-Rätselraten.

### Finding 2: Struktur von `TemplateSessionDiagnostics` nicht spezifiziert
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Implementation Steps Step 4 beschreiben: "Ergebnisse in einem Snapshot bündeln, den UI und Tests direkt konsumieren können". Aber der Plan definiert nicht, wie dieser Snapshot strukturiert ist. Hat `TemplateSessionDiagnostics` separate Arrays für Constraint-Violations und Shape-Violations? Oder ein einziges `violations: [Violation]`-Array? Gibt es auch Warnungen oder nur Fehler? Das ist wichtig für die UI-Integration (parameter-inspector Plan), die diesen Snapshot konsumiert.
- Suggestion: Der Plan sollte die Struktur von `TemplateSessionDiagnostics` skizzieren: z.B. `struct TemplateSessionDiagnostics { constraintViolations: [ConstraintViolation], shapeViolations: [ShapeViolation] }`. Nicht ins Detail gehen, aber die Silos klarmachen.

### Finding 3: Session-Initialisierungs-Semantik für Shape-Linter nicht klar
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Step 4 fordert, `ShapeLinter` für "Root-Macro und genutzte referenzierte Macro-Bodies" aufzurufen. Aber was bedeutet "genutzt"? Wenn ein Template `gpt2_decoder` referenziert und `gpt2_decoder` intern `gpt2_block` referenziert: werden beide gelintet? Oder nur der Top-Level `gpt2_decoder`? Das beeinflusst die Diagnose-Vollständigkeit und könnte zu überraschenden Hidden-Violations führen, wenn nicht explizit durchdacht.
- Suggestion: Der Plan sollte klarstellen: "Aggregierte Shape-Linting: ShapeLinter wird für die Root-Macro des Templates und für jede Macro-Definition, die transitiv vom Template referenziert wird, ausgeführt. Beispiel: gpt2_decoder enthält repeat(gpt2_block) — beide werden gelintet."

### Finding 4: UX Gate — keine UI-Beteiligung, bestanden
- Severity: info
- Files: n/a
- Description: Reine Engine-Logik, keine direkten UI-Auswirkungen in diesem Slice. parameter-inspector wird das Interface sein.

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — Fokus auf Session-API und Overlay-Param-Verwaltung
- [x] Visible proof of work — Tests für Override-Lifecycle, Diagnose-Aggregation, GPT-2-Integration
- [x] No mocking — gegen echte PropagationEngine, ConstraintValidator, ShapeLinter
- [x] Guard clauses — Plan fordert Guard-Failures explizit zu modellieren
- [x] Single source of truth — Session ist Overlay über TemplateInstance, nicht neue Baseline
- [x] Architecture intact — Engine-only, kein UI-Entscheidungscode
- [x] No new workarounds — keine
