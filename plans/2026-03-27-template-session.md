# 2026-03-27-template-session

Status: awaiting-plan-review
assigned-to: praxis

## Summary

Implement eine editierbare `TemplateSession` in `MLXDesignerEngine`, die aus einer unveränderlichen `TemplateInstance` eine echte Working Copy für User-Interaktion macht. Die Session hält Parameter-Overrides getrennt vom Katalog, führt Propagation neu aus, aggregiert Constraint- und Shape-Diagnosen über die GPT-2-Macro-Hierarchie und liefert damit die produktive Engine-Basis für spätere UI-Parameterbearbeitung. Ohne diesen Slice müsste die UI eigene Zustands- und Validierungslogik duplizieren, was direkt gegen `AGENTS.md` verstößt.

**Depends on**: 2026-03-27-ir-propagation-engine (done), 2026-03-27-shape-linter (muss zuerst landen)

## Target State

- Ein `TemplateSession`-Typ existiert im Engine-Package und kapselt die editierbare Working Copy eines Templates
- Die Session trennt Baseline-Template, aktive Overrides und den aktuell propagierten `ParamContext`
- GPT-2 hat mindestens einen echten `derived_overridable`-Parameter, damit der Unlock-/Override-Pfad nicht theoretisch bleibt
- Ein Diagnose-Snapshot liefert Constraint-Violations plus Shape-Violations für Root-Macro und referenzierte Macro-Bodies
- Overrides können gesetzt und zurückgesetzt werden, ohne die Kataloge oder die `TemplateInstance` selbst zu mutieren
- Inkonsistente Overrides werden nicht geblockt, aber sofort sauber diagnostiziert

## Decisions

### In Scope

- Neuer Engine-Typ `TemplateSession` mit klarer API für:
  - Lesen des aktuellen `ParamContext`
  - Setzen von Master-Parametern
  - Entsperren/Übersteuern von `derived_overridable`
  - Reset einzelner Overrides
  - Lesen eines aggregierten Diagnose-Snapshots
- Session-State lebt als Overlay über einer unveränderlichen `TemplateInstance`; Kataloge bleiben Baseline
- Ergänzung des GPT-2-Templates, damit mindestens ein realer Derived-Parameter den Status `derived_overridable` trägt
- Ergänzung der nötigen GPT-2-Constraints, damit ein Derived-Override fachlich überprüfbar bleibt, insbesondere die Beziehung `d_model == num_heads * head_dim`
- Template-weite Diagnose-Aggregation:
  - `ConstraintValidator` gegen den aktuellen Kontext
  - `ShapeLinter` für Root-Macro und jede referenzierte Macro-Definition, die das Template benutzt
- Strukturierte Error-/Result-Typen für Guard-Failures wie unbekannter Parameter, Override auf nicht editierbarem Parameter oder Reset auf nicht gesetztem Override

### Out of Scope

- SwiftUI-/AppKit-Bindings oder jede direkte UI
- Undo/Redo, Change-History oder Persistence
- Batch-Edits mehrerer Parameter in einer Operation
- Unterstützung beliebiger weiterer Modellfamilien außer dem bestehenden GPT-2-Slice
- Autonomes Reparieren ungültiger Overrides; die Session diagnostiziert, sie "heilt" nicht

### Rejected Alternatives

- **Direkte Mutation von `TemplateInstance.globalParams`**: Verliert die unveränderliche Baseline und macht Session-Lifecycle schwer beherrschbar.
- **UI-eigene Override- und Diagnose-Logik**: Verstößt gegen die Architekturgrenze. Ebene B darf nicht selbst über Gültigkeit entscheiden.
- **Overrides nur als loses Dictionary im ViewModel**: Führt zu doppelter Wahrheit zwischen Engine und UI und macht Tests unnötig fragil.
- **Derived-Override im GPT-2-Template nicht konkret nutzbar machen**: Nicht akzeptabel. Der Unlock-Pfad muss an echtem Produktverhalten beweisbar sein.

## Implementation Steps

1. **Session-Modell**
   - `TemplateSession` einführen mit Baseline-`TemplateInstance`, Override-Storage und aktuellem Diagnose-Snapshot
   - Kleine begleitende Typen definieren, z. B. `TemplateSessionError`, `TemplateSessionDiagnostics`, `ParameterOverride`
   - Guard-Failures explizit modellieren statt still zu ignorieren

2. **Overlay-basierte Param-Auflösung**
   - Effektive Param-Schemas aus Baseline plus Overrides ableiten, ohne die Template-Definition zu mutieren
   - Propagation über den effektiven Satz ausführen, sodass Master-Änderungen und nicht übersteuerte Derived-Werte sauber neu berechnet werden
   - Für übersteuerte `derived_overridable`-Parameter den Override-Wert gegenüber der Derived-Closure bevorzugen

3. **GPT-2-Editierbarkeit konkret machen**
   - Einen sinnvollen Derived-Parameter im GPT-2-Template als `derived_overridable` freigeben
   - Fehlende Constraint-Abdeckung ergänzen, damit dieser Override diagnostisch sichtbar brechen kann
   - Die Entscheidung im Plan bewusst eng halten: nur das, was für echte GPT-2-Interaktion nötig ist

4. **Diagnose-Aggregation**
   - `ConstraintValidator` gegen den aktuellen Session-Kontext laufen lassen
   - `ShapeLinter` für Root-Macro und genutzte referenzierte Macro-Bodies aufrufen
   - Ergebnisse in einem Snapshot bündeln, den UI und Tests direkt konsumieren können

5. **Tests**
   - Unit: Master-Änderung aktualisiert propagierte Werte in der Session
   - Unit: `derived_overridable` kann übersteuert und wieder zurückgesetzt werden
   - Unit: Override auf `derived_locked` guard-failed
   - Integration: GPT-2-Override auf `head_dim` erzeugt eine Diagnose, wenn die globale Beziehung zu `d_model` bricht
   - Integration: Diagnose-Snapshot enthält Constraint- und Shape-Ergebnisse für die GPT-2-Macro-Hierarchie

## Tests

- `TemplateSessionTests` — Override-Lifecycle, Guard-Failures, Reset
- `TemplateSessionDiagnosticsTests` — Constraint-/Shape-Aggregation
- GPT-2-Integrationstest über Session + Propagation + Linting
