# 2026-03-27-gopy-export

Status: awaiting-implementation-review
assigned-to: praxis

## Summary

Implement einen reinen Engine-Export nach `.gpy`, der eine validierte GPT-2-XL-`TemplateInstance` über die bestehenden IR-Kataloge in echten, kompilierbaren gopy-Code übersetzt. Der Export muss auf aufgelösten Parametern aus der `PropagationEngine` basieren, vor der Code-Generierung Constraint- und Shape-Checks erzwingen und den erzeugten `main.gpy` gegen die lokale gopy-Toolchain kompilieren. Das liefert VISION-Meilenstein 5, während der echte Overfit-Smoke-Test bewusst ein eigener nächster Slice bleibt.

**Depends on**: 2026-03-27-ir-propagation-engine (done), 2026-03-27-shape-linter (muss zuerst landen)

## Target State

- Ein `GopyExporter` existiert in `MLXDesignerEngine` und erzeugt deterministischen `.gpy`-Quellcode für `gpt2_xl_1_5b`
- Der Export basiert auf einem aufgelösten `ParamContext` aus der `PropagationEngine`, nicht auf hartcodierten GPT-2-Konstanten
- Export guard-failed bei Constraint-Violations, Shape-Violations, fehlenden Catalog-Einträgen oder nicht unterstützten Nodes/Macros
- Der generierte Code enthält Config, Model-/Block-Builder und ein minimales Trainings-Scaffold, das mit der lokalen gopy-Toolchain kompilierbar ist
- Die aktuelle IR-Topologie aus `gpt2_decoder` und `gpt2_block` wird in gopy `nn.*`-Konstruktoren übersetzt
- Reale Compile-Verifikation mit `gpy compile` beweist, dass der Export nicht nur String-Tests besteht

## Decisions

### In Scope

- Pure Engine-Implementation in `MLXDesignerEngine`, keine UI-Buttons und kein App-Shell-Wiring
- `GopyExportError` enum für Guard-Failures: fehlende Params, ungültige Bindings, fehlende Blocks/Macros, Constraint-/Shape-Violations, unsupported node/macro, Compile-Fehler
- Deterministische Quelltext-Emission für den aktuellen GPT-2-Slice
- Unterstützung aller Primitive, die im bestehenden IR für `gpt2_decoder` und `gpt2_block` vorkommen: `input`, `embedding`, `position_embedding`, `add`, `dropout`, `layer_norm`, `mha`, `gelu_mlp`, `lm_head`, `repeat`
- Auflösung von `NodeInstance.paramBindings` gegen den propagierten globalen Param-Stand vor der eigentlichen Code-Generierung
- Macro-Expansion für `gpt2_block` und `gpt2_decoder`, inklusive `repeat(body_ref: gpt2_block, count: num_layers)`
- Reale Compile-Prüfung gegen die lokale gopy-Installation bzw. das bereits im Repo referenzierte externe Toolchain-Setup

### Out of Scope

- Ausführung des exportierten Trainings und Loss-Verifikation im Sinne des Smoke Tests
- UI-Integration, Export-Dialoge oder Dateiauswahl
- Unterstützung beliebiger weiterer Modellfamilien
- Checkpoint-Import/-Export oder Weight-Tying-Serialisierung
- Generischer IR-zu-Code-Compiler für beliebige Graphen
- Datensatz-Pipeline, Tokenisierung oder Trainingsdaten-Handling

### Rejected Alternatives

- **Hartcodierte statische GPT-2-Datei**: Verfehlt die Engine als Single Source of Truth. Der Export muss aus `TemplateInstance` und Katalogen entstehen.
- **Compile-Schritt überspringen**: Nicht akzeptabel. Dieses Slice ist nur wertvoll, wenn echter gopy-Code entsteht, der lokal kompiliert.
- **UI-eigene Exportlogik**: Verletzt die Architekturgrenze aus `AGENTS.md`. Export gehört in Ebene A.
- **Voll generischer Graph-Compiler**: Zu breit für den aktuellen Slice. GPT-2 reicht als sauberer Kalibrierungspunkt.

## Implementation Steps

1. **Validierter Export-Entrypoint**
   - `GopyExporter` mit einer klaren High-Level-API anlegen, die `.gpy`-Source zurückgibt
   - `PropagationEngine` für den aufgelösten Param-Stand nutzen
   - Template-Constraints über `ConstraintValidator` prüfen
   - `ShapeLinter` für Root-Macro und referenzierte Macro-Bodies ausführen
   - Bei jedem Guard-Fail mit strukturiertem `GopyExportError` abbrechen

2. **Resolved Export Model**
   - Kleine exportseitige Strukturen für bereits aufgelöste Node-Bindings und Macro-Expansion einführen
   - `paramBindings` genau einmal gegen den globalen Kontext resolven, damit Codegen nur noch typisierte Werte verarbeitet
   - Int/Float/Bool/String deterministisch in `.gpy`-Literale serialisieren
   - Keine doppelte Wahrheit: Export liest IR-Kataloge und Template, nicht parallel gepflegte GPT-2-Konstanten

3. **GPT-2 Macro Mapping**
   - Einen expliziten GPT-2-Block-Builder aus `gpt2_block` erzeugen
   - Den Decoder aus `gpt2_decoder` gemäß IR-Topologie erzeugen:
     token embedding + positional embedding -> add -> dropout -> repeated blocks -> final layer norm -> lm head
   - Die beteiligten Primitives auf die lokalen gopy-`nn.*`-Bausteine mappen; die exakten Signaturen werden durch den realen Compile-Check abgesichert
   - `repeat` nicht als opaque Text behandeln, sondern als echte Macro-Expansion aus `body_ref` und `count`

4. **Programm-Scaffold**
   - Einen kompilierbaren `main.gpy` generieren mit:
     - Config-Struktur aus den aufgelösten Template-Parametern
     - Block- und Model-Buildern
     - minimalem Trainings-Entrypoint bzw. Train-Step-Scaffold
   - Das Scaffold bewusst knapp halten; der eigentliche Overfit-Smoke-Test bleibt ein Folgeslice

5. **Compile-Backed Verifikation**
   - Export-Tests für Erfolgsfall und Fehlerfälle hinzufügen
   - Einen Compile-Smoke-Test bzw. ein angebundenes Repo-Skript anlegen, das den Export unter `claude-files/` schreibt und `gpy compile` ausführt
   - Die reale Compile-Prüfung in den Verifikationspfad dieses Slices aufnehmen, nicht als manuellen Nachtrag

## Tests

- `make test` besteht
- `GopyExporterTests` prüfen, dass GPT-2-XL-Export die aufgelösten Werte (`d_model`, `num_heads`, `mlp_hidden`, `vocab_size`) korrekt ausgibt
- `GopyExporterTests` prüfen Guard-Failures für fehlende Macros, fehlende Param-Bindings und unsupported nodes
- `GopyExporterTests` prüfen, dass Constraint- oder Shape-Violations den Export blockieren
- Compile-Smoke: der exportierte GPT-2-XL-`main.gpy` wird mit der realen lokalen gopy-Toolchain erfolgreich kompiliert
- Schmale Source-Assertions auf Block-/Decoder-Sektionen, damit Tests deterministisch bleiben ohne brittle Full-File-Snapshots

## Risks

- **Lokale gopy-API kann driften**: Exakte Konstruktor-Signaturen dürfen nicht geraten werden. Der Compile-Smoke ist deshalb Pflichtbestandteil des Slices.
- **Abhängigkeit vom Shape-Linter**: Der Export darf nicht still ohne Shape-Validierung laufen. Wenn sich der Upstream-Plan ändert, muss die Implementation hier sauber nachziehen.
- **Nested Macro Expansion**: `repeat` plus `gpt2_block` ist die erste echte Übersetzung von IR-Struktur in Code. Scope bleibt deshalb strikt auf GPT-2.
- **Lange Compile-Läufe**: Toolchain-Install und Compile können langsamer sein als reine Unit-Tests. Der Verifikationspfad muss laut und lesbar scheitern, nicht still skippen.

## Change Log

- 2026-03-27 Praxis: `GopyExporter` in `MLXDesignerEngine` implementiert. Der Export validiert Template-Constraints, resolved node bindings gegen den propagierten `ParamContext`, guard-failed bei fehlenden Bindings/unsupported node configuration und rendert deterministischen GPT-2-gopy-Code mit Config-, Block-, Model- und Trainings-Scaffold.
- 2026-03-27 Praxis: Neue `GopyExporterTests` decken Erfolgsfall, fehlende Macros, fehlende Bindings, strukturell unerwartete Nodes, Constraint-Blocker und Shape-Blocker ab.
- 2026-03-27 Praxis: Engine-Tests fachlich grün bis auf den verpflichtenden realen Compile-Smoke. `swift test --disable-sandbox`, `make test`, `gpyc doctor` und ein direkter Compile des bestehenden `../gopy/examples/transformer_slice/main.gpy` scheitern reproduzierbar außerhalb des Feature-Codes an der lokalen gopy-MLX-Runtime:
  `failed to validate MLX runtime for this gpy program: mlx runtime probe failed: *** -[__NSArray0 objectAtIndex:]: index 0 beyond bounds for empty array`
  `gopy doctor found issues`
  Auch mit explizitem `GOPY_MLX_PYTHON_BIN=../gopy/.venv-mlx-bench/bin/python` bleibt der Fehler unverändert.

## Approval Block

(filled by reviewer)
