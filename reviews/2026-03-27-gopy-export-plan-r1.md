# Review: 2026-03-27-gopy-export (plan) r1

Decision: approved

## Summary

Gut strukturierter Plan mit klarer Architektur-Compliance. Die Entscheidung gegen hartcodierte GPT-2-Konstanten und gegen generischen Graph-Compiler ist korrekt — YAGNI plus Single Source of Truth. Die Pflicht-Dependency auf shape-linter vor diesem Slice ist richtig. Der reale Compile-Smoke als Pflichtbestandteil ist das Herzstück dieses Plans — das unterscheidet diesen Slice von einem String-Baukasten. Drei konkrete Lücken zu adressieren.

## Findings

### Finding 1: Konstruktor-Signaturen aus gopy-Quelldateien ableiten, nicht raten
- Severity: medium
- Files: n/a (Plan-Level)
- Description: Step 3 (GPT-2 Macro Mapping) sagt: "die exakten Signaturen werden durch den realen Compile-Check abgesichert". Das ist richtig als Verifikationsmittel, aber falsch als primäre Erkenntnisquelle. Wenn Praxis die gopy-API nicht vor der Codegen-Implementierung liest, entstehen Iterationszyklen (schreiben → compile-fail → korrigieren → compile-fail). Die user-input.md benennt explizit `../gopy/examples/transformer_slice/main.gpy` und `../gopy/challenge/gpt2.gpy` als Referenz-Dateien mit den konkreten Konstruktoren (`nn.Embedding`, `nn.PositionEmbedding`, `nn.Dropout`, `nn.CausalSelfAttention`, `nn.GELUMLP`, `nn.LayerNorm`, `nn.DecoderBlock`, `nn.Decoder`).
- Suggestion: Step 3 soll explizit verlangen, dass Praxis vor der Codegen-Implementierung die gopy-Referenzdateien liest und die Node-zu-Konstruktor-Tabelle daraus ableitet. Compile-Smoke bleibt Verifikation, nicht Erkenntnisquelle.

### Finding 2: `repeat` → `nn.Decoder` Mapping explizit machen
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Step 3 nennt `repeat(body_ref: gpt2_block, count: num_layers)` als "echte Macro-Expansion", bleibt aber abstrakt in der Mapping-Beschreibung. Die user-input.md listet `nn.Decoder` in der gopy-API — das ist der explizite Konstruktor für den wiederholten Block-Stack. `repeat` in der IR entspricht `nn.Decoder(numLayers: num_layers, ...)`, nicht einer for-Schleife oder manuellem Block-Array.
- Suggestion: Step 3 soll das Mapping `IR repeat(body_ref: gpt2_block, count: num_layers)` → `gopy nn.Decoder(numLayers: n, ...)` explizit benennen.

### Finding 3: `make test` verhalten bei fehlender gopy-Toolchain definieren
- Severity: minor
- Files: n/a (Plan-Level)
- Description: Der Risks-Abschnitt erkennt, dass Compile-Läufe langsamer sind. Der Plan sagt der Compile-Smoke ist "Pflichtbestandteil" — was korrekt ist. Aber es fehlt die Angabe, was passiert, wenn `gpy` lokal nicht installiert ist: soll `make test` schreien oder skippen? Ein stilles Skip wäre ein Verstoß gegen Acceptance Criterion #3 (Visible Proof) und Criterion #8 (No Workarounds).
- Suggestion: `make test` muss laut scheitern (`error: gpy not found in PATH`) wenn die Toolchain fehlt. Kein stilles Überspringen des Compile-Smokes. Das ist Teil des "laut und lesbar scheitern" aus dem Risks-Abschnitt.

### Finding 4: UX Gate — keine UI-Beteiligung, bestanden
- Severity: info
- Files: n/a

## Acceptance Criteria Check

- [ ] Tests green — noch keine Implementation
- [x] No scope creep — GPT-2-only, kein generischer Compiler, kein UI-Wiring
- [x] Visible proof of work — Compile-Smoke als Pflichtbestandteil
- [x] No mocking — reale gopy-Toolchain als Verifikation
- [x] Guard clauses — `GopyExportError` enum für alle Failure-Fälle
- [x] Single source of truth — Export liest aus TemplateInstance + IR-Katalogen + PropagationEngine, keine duplizierten GPT-2-Konstanten
- [x] Architecture intact — Engine-only (Ebene A), keine UI-Entscheidungen
- [x] No new workarounds — keine
