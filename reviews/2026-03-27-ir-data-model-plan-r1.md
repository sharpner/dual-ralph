# Review: 2026-03-27-ir-data-model (plan) r1

Decision: changes-requested

## Summary

Starker erster Plan. Die drei Ebenen aus proposal.md sind korrekt abgebildet, die Implementation Steps sind logisch geordnet, und der E2E-Test ist der richtige Proof. Zwei Punkte brauchen Nacharbeit vor Approval: der Scope ist zu groß für einen einzelnen Plan (Auto-Propagation ist ein eigenes Feature, nicht Teil des Datenmodells), und die Expression-Evaluation für Constraints/Derived-Params wird unterschätzt.

## Findings

### Finding 1: Scope zu groß — Auto-Propagation gehört nicht in diesen Plan
- Severity: major
- Files: .workflow/plans/2026-03-27-ir-data-model.md (Steps 8-9)
- Description: Steps 8 (Auto-Propagation Engine) und 9 (Constraint Validation Engine) sind eigenständige Features mit eigener Komplexität. Die Propagation braucht einen Dependency-Graph, topologische Sortierung, Zykluserkennung. Das ist kein "Datenmodell" mehr, sondern eine Engine. Ein Plan der gleichzeitig Types definiert UND eine Evaluation-Engine baut ist zu breit — wenn die Propagation Probleme macht, blockiert sie den gesamten Plan.
- Suggestion: Diesen Plan auf die **Typdefinitionen** beschränken (Steps 1-7). Auto-Propagation und Constraint-Validation als separaten Plan `ir-propagation-engine`. Der E2E-Test (Step 10) prüft dann nur: Template instanziieren, Default-Werte korrekt, Constraints als Datenstrukturen vorhanden. Die *Evaluation* der Constraints kommt im nächsten Plan.

### Finding 2: Expression-Evaluation unterschätzt
- Severity: major
- Files: .workflow/plans/2026-03-27-ir-data-model.md (Risk section)
- Description: Der Plan sagt "Einfache arithmetische Ausdrücke (division, multiplication) reichen für GPT-2, keine generische Expression-Engine nötig." Das stimmt heute. Aber die Constraints (`d_model % num_heads == 0`) und derived params (`d_model / num_heads`) brauchen trotzdem einen Evaluator. Der Plan definiert keine Strategie dafür — weder Swift-native closures, noch ein Mini-Parser, noch fest kodierte Formeln. Ohne diese Entscheidung ist Step 8 nicht implementierbar.
- Suggestion: Explizite Entscheidung im Decisions-Block: Derived-Parameter-Expressions werden als **Swift closures** modelliert (`(ParamContext) -> ParamValue`), nicht als Strings. Strings sind für Display, Closures für Evaluation. Das ist einfacher als ein Parser und type-safe. Constraint-Expressions analog.

### Finding 3: Package-Name unklar
- Severity: minor
- Files: .workflow/plans/2026-03-27-ir-data-model.md (Step 1)
- Description: Step 1 sagt `MLXDesignerEngine`, Summary sagt nur "IR-Datenmodell". Der Package-Name sollte bewusst gewählt werden, weil er das gesamte Projekt strukturiert.
- Suggestion: `MLXDesignerEngine` ist gut. Explizit im Decisions-Block festhalten.

### Finding 4: Fehlende Edges im MacroBlock-Design
- Severity: major
- Files: .workflow/plans/2026-03-27-ir-data-model.md (Step 6)
- Description: Step 6 definiert `MacroBlock` mit `nodeRefs` und `constraints`, aber keine **Edges** (Verbindungen zwischen Nodes). proposal.md Section 2.1 zeigt explizit die Verdrahtung innerhalb eines gpt2_block (ln_1 → attn → add_1 etc.). Ohne Edges ist ein Macro nur eine Tasche voller Nodes ohne Beziehung — der Canvas kann nichts zeichnen, der Shape-Linter kann nichts prüfen.
- Suggestion: `MacroBlock` braucht ein `edges: [Edge]` Feld. `Edge` struct: `sourceNode` (alias), `sourcePort` (port_id), `targetNode` (alias), `targetPort` (port_id). Das ist die interne Verdrahtung die proposal.md impliziert aber nicht explizit als Datenstruktur zeigt.

### Finding 5: UX Gate — kein UI-Impact, bestanden
- Severity: info
- Files: n/a
- Description: Reiner Engine-Layer, kein UI-Impact. UX Gate ist nicht relevant für diesen Plan.

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — **Finding 1: Scope zu groß, muss reduziert werden**
- [x] Visible proof of work — E2E-Test definiert
- [x] No new workarounds — keine
- [ ] Documentation updated — nach Implementation
