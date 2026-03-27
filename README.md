# Dual-Ralph: AI Pairing Workflow

A self-sustaining development loop between two Ralph loops: Praxis plans+implements, Theorie reviews+fixes.

Copy this repo as `.workflow/` into your project and start both loops.

## Quick Start

```bash
# In your project repo:
git clone git@github.com:sharpner/dual-ralph.git .workflow && rm -rf .workflow/.git
```

Then tell your AI agent:

> Read `.workflow/agent-setup.md` and help me set up the workflow.

The agent will investigate your repo, ask a few questions, and create all needed files (`VISION.md`, `AGENTS.md`, `THEORIE.md`, config). After setup:

```bash
# Start the Praxis loop (implements, plans, escalates):
.workflow/praxis.sh

# Start the Theorie loop (reviews, fixes blockers, evaluates feedback):
.workflow/theorie.sh

# Optional: override agents via env
PRAXIS_AGENT=my-agent THEORIE_AGENT=my-agent .workflow/praxis.sh
```

## Architecture

```
┌───────────┐  Plan    ┌─────────┐  Review  ┌────────────┐
│  PRAXIS   │─────────▶│  Plans  │─────────▶│  THEORIE   │
│  (Impl)   │◀─────────│         │◀─────────│  (Review)  │
└─────┬─────┘  Code    └─────────┘ Approved  └─────┬──────┘
      │                                            │
      │ Bug report ──▶ .workflow/bugs/ ──▶ Theorie fixes
      │ Escalation ──▶ ci-blocked ──▶ Theorie fixes infra
      │                                            │
      └──── Feedback ◀── .workflow/feedback/ ◀─────┘
```

Configure the runtime agents via `PRAXIS_AGENT` / `THEORIE_AGENT`.

## Directory Structure

```
.workflow/
├── config.sh                 # Project configuration (customize!)
├── acceptance-criteria.md    # Acceptance criteria (customize!)
├── praxis.sh                # Praxis loop entry point
├── theorie.sh               # Theorie loop entry point
├── agent-setup.md            # Interactive setup guide
├── templates/                # Copy-paste templates for all artifacts
├── plans/                    # Active feature plans
│   └── resolved/             # Completed plans
├── reviews/                  # Review artifacts
├── user-input/               # User input per feature
├── bugs/                     # Bug reports (Praxis → Theorie)
├── feedback/                 # External feedback (Gemini etc.)
├── summaries/                # Completion summaries
└── ralph-loop/               # Ralph runner docs
```

## Prerequisites

- **[open-ralph-wiggum](https://github.com/Th0rgal/open-ralph-wiggum)** — The `ralph` CLI that runs the agent loops. Install via `npm install -g @th0rgal/ralph-wiggum`.
- **At least one ralph-compatible agent** installed for each loop (or one shared agent you run in both loops).
- **Git** — Both loops commit and push via git.

## Plan Lifecycle

```
Praxis writes plan
  → awaiting-plan-review (assigned-to: theorie)
  → Theorie reviews
    → approved → Praxis implements
    → changes-requested → Praxis revises plan
  → awaiting-implementation-review (assigned-to: theorie)
  → Theorie reviews
    → approved → plans/resolved/ ✓
    → changes-requested → Praxis iterates
```

## Escalation

Praxis has **no network access**. When local tests fail 3x and the problem is not in feature code:

1. Praxis sets `Status: ci-blocked`, `assigned-to: <theorie>`
2. Theorie checks CI, diagnoses, fixes infra
3. Theorie sets back to `awaiting-implementation-review` and performs review

**Important:** Theorie must commit and push after every fix. Local changes that aren't pushed are invisible to Praxis.

## Bug Reports

Praxis finds bug → `.workflow/bugs/<date>-<name>.md` with `assigned-to: <theorie>` → Theorie fixes → `Status: fixed`

## Feedback

External feedback (Gemini, manual reviews) → `.workflow/feedback/<date>-<source>-<topic>.md` → Theorie evaluates and incorporates into the next review.

## Configuration

Edit `config.sh` for your project:

| Variable | Default | Description |
|---|---|---|
| `PRAXIS_AGENT` | required | Ralph agent for the Praxis loop (`--agent` flag) |
| `THEORIE_AGENT` | required | Ralph agent for the Theorie loop (`--agent` flag) |
| `PRAXIS_LABEL` | `praxis` | Routing label in plan files (`assigned-to:`) |
| `THEORIE_LABEL` | `theorie` | Routing label in plan files (`assigned-to:`) |
| `VISION_FILE` | `./VISION.md` | Praxis reads this for feature planning |
| `AGENTS_FILE` | `./AGENTS.md` | Architecture boundaries, paths, rules |
| `THEORIE_FILE` | `./THEORIE.md` | Theorie-specific routing rules |
| `LOCAL_TEST_CMD` | `go test ./...` | Local test command (no network needed) |
| `ACCEPTANCE_CRITERIA` | `./.workflow/acceptance-criteria.md` | Review criteria |
| `CI_SYSTEM` | `github-actions` | CI provider (`none` to disable) |

### Agent Configuration Examples

```bash
# Distinct agents for each loop
PRAXIS_AGENT=my-planning-agent THEORIE_AGENT=my-review-agent

# Same agent for both loops
PRAXIS_AGENT=my-agent THEORIE_AGENT=my-agent

# Custom agent names:
PRAXIS_AGENT=team-alpha THEORIE_AGENT=team-beta
```

## Target Repo Requirements

1. **`VISION.md`** — What should the project achieve? Praxis plans features from this.
2. **`AGENTS.md`** — Architecture boundaries, relevant paths, change rules.
3. **`THEORIE.md`** — Theorie routing (reviews, bug fixes, feedback evaluation).
4. **Local tests** that run without network access.
5. **CI pipeline** (optional) — GitHub Actions, GitLab CI, etc.

## Roles

### Praxis
- Plans features based on vision document
- Implements against approved plans
- Always commits and pushes
- Escalates infra problems to Theorie
- Writes bug reports for problems it can't solve

### Theorie
- Reviews plans and implementations
- Fixes CI blockers and infra problems
- Evaluates external feedback
- Only commits bug fixes and infra fixes
- Moves completed plans to resolved/

### User
- Describes goals in vision document
- Decides on goal conflicts
- Can override reviews

---

## Learnings

### What Works

- **Enforced reviews catch real bugs.** Forward-declaration errors, CI blockers, refcount bugs — all caught in the review loop, not in production code.
- **Escalation path is critical.** Without `ci-blocked → Theorie fixes`, Praxis spins endlessly documenting the error instead of solving it.
- **Plan in parallel while blocked.** Praxis should plan new features while waiting on CI/review. Otherwise the entire workflow stalls.
- **Theorie must commit and push.** If Theorie only changes files locally, Praxis never sees the changes.
- **External feedback (Gemini) is valuable.** Theorie evaluates and incorporates relevant points into reviews. No special status needed — just check if the assessment section is missing.
- **The workflow improves itself.** Early reviews were unstructured, later ones followed clear format. Quality increases with each cycle.
