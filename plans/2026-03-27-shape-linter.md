# 2026-03-27-shape-linter

Status: implementing
assigned-to: praxis

## Summary

Implement einen Shape-Linter, der Tensor-Shape-Kompatibilität über Edges in Macro Blocks validiert. Wenn zwei Nodes verbunden sind, muss der Source-Port-Shape mit dem Target-Port-Shape kompatibel sein. Named Dimensions (z.B. `d_model`) werden gegen den aktuellen ParamContext aufgelöst. Broadcast-Regeln werden für Add-Nodes unterstützt. Dritter Slice Richtung GPT-2 E2E.

**Depends on**: 2026-03-27-ir-propagation-engine (done)

## Target State

- Ein `ShapeLinter` existiert, der alle Edges eines MacroBlocks gegen Shape-Kompatibilität prüft
- Named Dimensions werden gegen `ParamContext` zu konkreten Werten aufgelöst
- Broadcast-Kompatibilität wird unterstützt (z.B. `[1, T, d_model]` ↔ `[B, T, d_model]`)
- Shape-Violations werden als `ShapeViolation` mit Edge-Referenz und klarer Fehlermeldung gemeldet
- E2E-Tests beweisen: GPT-2-Block-Edges alle kompatibel, künstlicher Mismatch wird erkannt

## Decisions

### In Scope

- `ShapeLinter` enum mit statischer `lint(macro:catalog:context:)` Methode
- `ResolvedShape`: Array von konkreten Int-Werten oder symbolischen Dimensionen (batch/sequence)
- `ShapeDimension`-Resolution: `named("d_model")` → Lookup in ParamContext → konkreter Int-Wert
- `literal(n)` → direkt `n`, `batch` → symbolisch `B`, `sequence` → symbolisch `T`
- Shape-Kompatibilitäts-Check: gleiche Anzahl Dimensionen, jede Dimension entweder gleich oder broadcast-kompatibel (1 vs N)
- `ShapeViolation` struct: `edgeSource`, `edgeTarget`, `sourceShape`, `targetShape`, `message`
- Validierung aller Edges in einem MacroBlock: für jede Edge den Source-Port des Source-Nodes und den Target-Port des Target-Nodes finden, Shapes resolven, vergleichen
- Lookup von Ports über BuildingBlockCatalog (Edge.sourceNode → NodeInstance.ref → BuildingBlock → Port)

### Out of Scope

- DType-Kompatibilitäts-Check (z.B. float vs integer) — separater Plan
- SemanticType-Kompatibilitäts-Check (z.B. hidden_states → token_ids) — separater Plan
- Rekursive Validierung verschachtelter Macro Blocks (decoder → block) — dieses Slice validiert eine Ebene
- UI-Integration / Live-Anzeige von Violations
- Shape-Inferenz (Berechnung von Output-Shapes aus Input-Shapes und Parametern)

### Rejected Alternatives

- **Shape-Inferenz statt Shape-Matching**: Zu komplex für dieses Slice. Jeder Port hat bereits einen Shape-Contract — wir prüfen nur, ob verbundene Ports kompatibel sind. Inferenz (z.B. "MHA-Output hat Shape [B, T, num_heads * head_dim]") kommt in einem späteren Plan.
- **Generischer Dimension-Unifier**: YAGNI. Einfacher Check: gleiche Anzahl Dims, jede Dim gleich oder broadcast. Kein Constraint-Solver nötig.
- **Integration in ConstraintValidator**: Shape-Linting ist strukturell anders als Parameter-Constraints. Constraints prüfen Wertbeziehungen, der Shape-Linter prüft Topologie. Eigene API ist klarer.

## Implementation Steps

1. **ResolvedDimension und ResolvedShape**
   - `ResolvedDimension` enum: `.concrete(Int)`, `.symbolic(ShapeDimension)` (für batch/sequence)
   - `ResolvedShape` struct: `[ResolvedDimension]`
   - `resolve(contract: ShapeContract, context: ParamContext) -> ResolvedShape`: resolves named dims to concrete values, keeps batch/sequence symbolic

2. **Shape-Kompatibilitäts-Check**
   - `compatible(_ a: ResolvedShape, _ b: ResolvedShape) -> Bool`
   - Guard: gleiche Anzahl Dimensionen
   - Pro Dimension: gleich, oder einer ist `.concrete(1)` (broadcast), oder beide symbolisch und gleich

3. **ShapeViolation**
   - Struct: `sourceNode: String`, `sourcePort: String`, `targetNode: String`, `targetPort: String`, `sourceShape: ResolvedShape`, `targetShape: ResolvedShape`, `message: String`

4. **ShapeLinter**
   - `static func lint(macro: MacroBlock, catalog: [String: BuildingBlock], context: ParamContext) -> [ShapeViolation]`
   - Für jede Edge:
     - NodeInstance finden via alias
     - BuildingBlock finden via catalog[nodeInstance.ref]
     - Source-Port in outputPorts des Source-Blocks finden
     - Target-Port in inputPorts des Target-Blocks finden
     - Shapes resolven
     - Kompatibilität prüfen
     - Bei Inkompatibilität: ShapeViolation erzeugen

5. **Tests**
   - Unit: Shape-Resolution — `named("d_model")` → 1600
   - Unit: Kompatibilität — gleiche Shapes, broadcast-kompatible Shapes, inkompatible Shapes
   - Integration: `gpt2_block` alle Edges kompatibel mit GPT-2-XL-Parametern
   - Integration: künstlicher Mismatch (d_model auf Source ≠ Target) → Violation
   - E2E: PropagationEngine + ShapeLinter zusammen — Parameter ändern, Shapes re-linten

## Tests

- `ShapeResolutionTests` — named-dim resolution, literal, batch/sequence symbolic
- `ShapeCompatibilityTests` — matching, broadcast, mismatch, dimension count mismatch
- `ShapeLinterTests` — gpt2_block edges valid, artificial mismatch detected
- E2E: Template → PropagationEngine → ShapeLinter → keine Violations bei Defaults, Violations nach Breaking Change

## Risks

- **Port-Lookup-Komplexität**: Edge referenziert Nodes by alias, Nodes referenzieren BuildingBlocks by ref. Der Lookup-Pfad ist `edge.sourceNode → nodeInstance.alias → nodeInstance.ref → catalog[ref] → outputPorts`. Wenn ein Alias oder Ref nicht gefunden wird, muss der Linter klar melden was fehlt (nicht still ignorieren).
- **Macro-Input/Output-Ports als Edge-Endpunkte**: Edges können auch die Input/Output-Ports des Macro selbst referenzieren (z.B. `macro.hidden_in → ln_1.input`). Das muss der Linter unterstützen.

## Change Log

(initial plan)

## Approval Block

(filled by reviewer)
