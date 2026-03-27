# Review: 2026-03-27-gopy-export (plan) r2

Decision: approved-for-implementation

## Summary

Plan-r1 identified three critical implementation guidance points and one tooling requirement. Plan structure is architecturally sound (Engine-only, real Compile verification, no hardcoded constants). The r1 findings are not scope creep but essential clarifications:

1. **Derive gopy API signatures from source, not guesswork**: r1 correctly identified that Step 3 must start by reading actual gopy reference files.

2. **Explicit repeat-to-nn.Decoder mapping**: r1 asked to map IR repeat construct to gopy's concrete nn.Decoder constructor.

3. **Loud failure if gopy toolchain missing**: r1 correctly identified that silent skip of Compile-Smoke violates Acceptance Criteria.

All three are implementation prerequisites, not plan rewrites.

## Findings

### Finding 1: r1 Finding 1 Status - API Reference Reading Is Mandatory First Step
- Severity: high
- Status: Must happen before codegen implementation
- Guidance: Implementation Step 3 MUST begin by reading these reference files:
  - `../gopy/examples/transformer_slice/main.gpy` → learn nn.* constructors
  - `../gopy/challenge/gpt2.gpy` → learn actual GPT-2 model structure
  - Build a Node-to-Constructor table: `input → nn.Input`, `embedding → nn.Embedding`, `mha → nn.CausalSelfAttention`, etc.
  - Document this table in code comments or a small mapping struct
  - Only after this should codegen logic be written
  - This prevents compile-fail loops and ensures signatures match reality

### Finding 2: r1 Finding 2 Status - repeat Macro Maps to nn.Decoder
- Severity: medium
- Status: Must be explicit in codegen
- Guidance: IR `repeat(body_ref: gpt2_block, count: num_layers)` must map to gopy `nn.Decoder(numLayers: <count>, ...)`:
  - IR repeat is a list repetition primitive
  - gopy nn.Decoder is the gpt2-specific repeated block container
  - Codegen must look up the repeat's body_ref (gpt2_block), find it in catalog, extract its gopy codegen, and wrap in nn.Decoder(numLayers: ...)
  - Do not emit repeat as a for-loop or manual block array — use nn.Decoder constructor directly

### Finding 3: r1 Finding 3 Status - Compile Failure Must Be Loud and Clear
- Severity: high
- Status: Acceptance Criterion #1 depends on this
- Guidance: If gopy toolchain is not installed locally:
  - `make test` must EXIT WITH ERROR, not skip the Compile-Smoke test
  - Error message must clearly state: "error: gpy not found in PATH. Please install gopy from https://github.com/sharpner/gopy"
  - Do not continue with other tests if gopy is missing — Compile-Smoke is non-negotiable for this slice
  - If gopy is installed but compilation fails, also exit with error (include compiler output in test failure message)
  - This ensures Acceptance Criterion #3 (Visible Proof) is met: export must compile to be considered done

### Finding 4: Shape-Linter Dependency Must Be Satisfied
- Severity: medium
- Status: Verify before starting
- Guidance: Implementation assumes ShapeLinter is available and tested:
  - Before calling `ShapeLinter.lint()`, verify shape-linter is landed and tests pass
  - If shape-linter plan changes scope or output format, GopyExporter must adapt
  - Guard-fail clearly if ShapeLinter returns violations: include violation details in GopyExportError

## Acceptance Criteria Check

- [x] Tests green — Compile-Smoke is part of `make test`
- [x] No scope creep — GPT-2-only, single model family
- [x] Visible proof — Real gopy compilation is the proof
- [x] No mocking — Real gopy toolchain, real compile
- [x] Guard clauses — GopyExportError enum covers all failures
- [x] Single source of truth — exports from TemplateInstance + ParamContext
- [x] Architecture intact — Engine-only, no UI
- [x] No new workarounds — Compile failure is loud and clear

## Risks Revisited

- **Compile loops**: Mitigated by mandatory gopy reference reading in Step 3
- **Toolchain drift**: Real Compile-Smoke catches signature changes immediately
- **Missing dependencies**: If shape-linter changes, implementation must adapt (not silent ignore)
- **Missing blocks/macros**: Guard-fail clearly with helpful error messages

## Ready for Implementation

Praxis should proceed. The r1 findings are essential pre-flight checks (read gopy reference) and implementation checkpoints (Compile-Smoke loudness, nn.Decoder mapping). No plan rewrite needed.

**Dependencies**: Must land after shape-linter is done and passing tests.

**Handoff**: assigned-to: praxis
