# Dual-Ralph: Codex+Claude Pairing Workflow

A self-sustaining development loop between Codex (implementation) and Claude (review + infra fixes).

Clone this repo as `.workflow/` into your project and start both loops.

## Quick Start

```bash
# In your project repo:
git clone git@github.com:sharpner/dual-ralph.git .workflow
```

Then tell your AI agent:

> Read `.workflow/agent-setup.md` and help me set up the workflow.

The agent will investigate your repo, ask a few questions, and create all needed files (`VISION.md`, `AGENTS.md`, `CLAUDE.md`, config). After setup:

```bash
# Start the Codex loop (implements, plans, escalates):
.workflow/codex-plan-work.sh

# Start the Claude loop (reviews, fixes blockers, evaluates feedback):
.workflow/claude-review.sh
```

## Architecture

```
┌─────────┐  Plan    ┌─────────┐  Review  ┌──────────┐
│  CODEX  │─────────▶│  Plans  │─────────▶│  CLAUDE  │
│  (Impl) │◀─────────│         │◀─────────│ (Review) │
└────┬────┘  Code    └─────────┘ Approved  └────┬─────┘
     │                                          │
     │ Bug report ──▶ .workflow/bugs/ ──▶ Claude fixes
     │ Escalation ──▶ ci-blocked ──▶ Claude fixes infra
     │                                          │
     └──── Feedback ◀── .workflow/feedback/ ◀───┘
```

## Directory Structure

```
.workflow/
├── config.sh                 # Project configuration (customize!)
├── acceptance-criteria.md    # Acceptance criteria (customize!)
├── codex-plan-work.sh        # Codex loop entry point
├── claude-review.sh          # Claude loop entry point
├── agent-setup.md            # Interactive setup guide
├── templates/                # Copy-paste templates for all artifacts
├── plans/                    # Active feature plans
│   └── resolved/             # Completed plans
├── reviews/                  # Review artifacts
├── user-input/               # User input per feature
├── bugs/                     # Bug reports (Codex → Claude)
├── feedback/                 # External feedback (Gemini etc.)
├── summaries/                # Completion summaries
└── ralph-loop/               # Ralph runner docs
```

## Prerequisites

- **[open-ralph-wiggum](https://github.com/Th0rgal/open-ralph-wiggum)** — The `ralph` CLI that runs the agent loops. Install via `npm install -g @th0rgal/ralph-wiggum`.
- **[Codex CLI](https://github.com/openai/codex)** — Used as the implementation agent (`--agent codex`).
- **[Claude Code CLI](https://claude.ai/claude-code)** — Used as the review agent (`--agent claude-code`).
- **Git** — Both loops commit and push via git.

## Plan Lifecycle

```
Codex writes plan
  → awaiting-opus-review (assigned-to: claude)
  → Claude reviews
    → approved → Codex implements
    → changes-requested → Codex revises plan
  → awaiting-implementation-review (assigned-to: claude)
  → Claude reviews
    → approved → plans/resolved/ ✓
    → changes-requested → Codex iterates
```

## Escalation

Codex has **no network access**. When local tests fail 3x and the problem is not in feature code:

1. Codex sets `Status: ci-blocked`, `assigned-to: claude`
2. Claude checks CI, diagnoses, fixes infra
3. Claude sets back to `awaiting-implementation-review` and performs review

**Important:** Claude must commit and push after every fix. Local changes that aren't pushed are invisible to Codex.

## Bug Reports

Codex finds bug → `.workflow/bugs/<date>-<name>.md` with `assigned-to: claude` → Claude fixes → `Status: fixed`

## Feedback

External feedback (Gemini, manual reviews) → `.workflow/feedback/<date>-<source>-<topic>.md` → Claude evaluates and incorporates into next review.

## Configuration

Edit `config.sh` for your project:

| Variable | Default | Description |
|---|---|---|
| `VISION_FILE` | `./VISION.md` | Codex reads this for feature planning |
| `AGENTS_FILE` | `./AGENTS.md` | Architecture boundaries, paths, rules |
| `CLAUDE_FILE` | `./CLAUDE.md` | Claude-specific routing rules |
| `LOCAL_TEST_CMD` | `go test ./...` | Local test command (no network needed) |
| `ACCEPTANCE_CRITERIA` | `./.workflow/acceptance-criteria.md` | Review criteria |
| `CI_SYSTEM` | `github-actions` | CI provider (`none` to disable) |

## Target Repo Requirements

1. **`VISION.md`** — What should the project achieve? Codex plans features from this.
2. **`AGENTS.md`** — Architecture boundaries, relevant paths, change rules.
3. **`CLAUDE.md`** — Claude routing (reviewer, bug-fixer, feedback evaluator).
4. **Local tests** that run without network access.
5. **CI pipeline** (optional) — GitHub Actions, GitLab CI, etc.

## Roles

### Codex
- Plans features based on vision document
- Implements against approved plans
- Always commits and pushes
- Escalates infra problems to Claude
- Writes bug reports for problems it can't solve

### Claude
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
- **Escalation path is critical.** Without `ci-blocked → Claude fixes`, Codex spins endlessly documenting the error instead of solving it.
- **Plan in parallel while blocked.** Codex should plan new features while waiting on CI/review. Otherwise the entire workflow stalls.
- **Claude must commit and push.** If Claude only changes files locally, Codex never sees the changes.
- **External feedback (Gemini) is valuable.** Claude evaluates and incorporates relevant points into reviews. No special status needed — just check if `## Claude Assessment` is missing.
- **The workflow improves itself.** Early reviews were unstructured, later ones followed clear format. Quality increases with each cycle.

### What Does NOT Work

- **Heavy local tests in Codex sandbox.** MLX, Docker, Metal — none of these run in Codex's sandbox. Local tests must be lightweight, CI runs remotely.
- **`gh` CLI in Codex.** No network = no `gh`. Codex pushes blind, Claude checks CI.
- **Web searches for CI status.** Codex tries to crawl google/github.com when `gh` fails. Explicitly forbid this.
- **Status without exit path.** Never introduce a status that has no way out. Always define a clear path back.
- **Manual intervention from monitoring session.** The loop must be self-sustaining. Otherwise changes sit locally and the loop never sees them.

### Typical Throughput

~1 feature per hour after workflow stabilization. The first hour goes to setup.
