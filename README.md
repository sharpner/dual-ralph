# Dual-Ralph: AI Pairing Workflow

A self-sustaining development loop between two AI agents — one plans+implements, the other reviews+fixes. Defaults to Codex+Claude, configurable via environment variables.

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
# Start the planner loop (implements, plans, escalates):
.workflow/praxis.sh

# Start the reviewer loop (reviews, fixes blockers, evaluates feedback):
.workflow/theorie.sh

# Optional: override agents via env
PLANNER_AGENT=claude-code REVIEWER_AGENT=claude-code .workflow/praxis.sh
```

## Architecture

```
┌───────────┐  Plan    ┌─────────┐  Review  ┌────────────┐
│  PLANNER  │─────────▶│  Plans  │─────────▶│  REVIEWER  │
│  (Impl)   │◀─────────│         │◀─────────│  (Review)  │
└─────┬─────┘  Code    └─────────┘ Approved  └─────┬──────┘
      │                                            │
      │ Bug report ──▶ .workflow/bugs/ ──▶ Reviewer fixes
      │ Escalation ──▶ ci-blocked ──▶ Reviewer fixes infra
      │                                            │
      └──── Feedback ◀── .workflow/feedback/ ◀─────┘
```

Default: Planner=Codex, Reviewer=Claude. Override via `PLANNER_AGENT` / `REVIEWER_AGENT`.

## Directory Structure

```
.workflow/
├── config.sh                 # Project configuration (customize!)
├── acceptance-criteria.md    # Acceptance criteria (customize!)
├── praxis.sh                # Planner loop entry point
├── theorie.sh               # Reviewer loop entry point
├── agent-setup.md            # Interactive setup guide
├── templates/                # Copy-paste templates for all artifacts
├── plans/                    # Active feature plans
│   └── resolved/             # Completed plans
├── reviews/                  # Review artifacts
├── user-input/               # User input per feature
├── bugs/                     # Bug reports (planner → reviewer)
├── feedback/                 # External feedback (Gemini etc.)
├── summaries/                # Completion summaries
└── ralph-loop/               # Ralph runner docs
```

## Prerequisites

- **[open-ralph-wiggum](https://github.com/Th0rgal/open-ralph-wiggum)** — The `ralph` CLI that runs the agent loops. Install via `npm install -g @th0rgal/ralph-wiggum`.
- **At least one ralph-compatible agent** installed (Codex, Claude Code, or any other `ralph --agent` target).
- **Git** — Both loops commit and push via git.

## Plan Lifecycle

```
Planner writes plan
  → awaiting-plan-review (assigned-to: reviewer)
  → Reviewer reviews
    → approved → Planner implements
    → changes-requested → Planner revises plan
  → awaiting-implementation-review (assigned-to: reviewer)
  → Reviewer reviews
    → approved → plans/resolved/ ✓
    → changes-requested → Planner iterates
```

## Escalation

The planner has **no network access**. When local tests fail 3x and the problem is not in feature code:

1. Planner sets `Status: ci-blocked`, `assigned-to: <reviewer>`
2. Reviewer checks CI, diagnoses, fixes infra
3. Reviewer sets back to `awaiting-implementation-review` and performs review

**Important:** Reviewer must commit and push after every fix. Local changes that aren't pushed are invisible to the planner.

## Bug Reports

Planner finds bug → `.workflow/bugs/<date>-<name>.md` with `assigned-to: <reviewer>` → Reviewer fixes → `Status: fixed`

## Feedback

External feedback (Gemini, manual reviews) → `.workflow/feedback/<date>-<source>-<topic>.md` → Reviewer evaluates and incorporates into next review.

## Configuration

Edit `config.sh` for your project:

| Variable | Default | Description |
|---|---|---|
| `PLANNER_AGENT` | `codex` | Ralph agent for planner role (`--agent` flag) |
| `REVIEWER_AGENT` | `claude-code` | Ralph agent for reviewer role (`--agent` flag) |
| `PLANNER_LABEL` | auto from agent | Routing label in plan files (`assigned-to:`) |
| `REVIEWER_LABEL` | auto from agent | Routing label in plan files (`assigned-to:`) |
| `VISION_FILE` | `./VISION.md` | Planner reads this for feature planning |
| `AGENTS_FILE` | `./AGENTS.md` | Architecture boundaries, paths, rules |
| `CLAUDE_FILE` | `./CLAUDE.md` | Reviewer-specific routing rules |
| `LOCAL_TEST_CMD` | `go test ./...` | Local test command (no network needed) |
| `ACCEPTANCE_CRITERIA` | `./.workflow/acceptance-criteria.md` | Review criteria |
| `CI_SYSTEM` | `github-actions` | CI provider (`none` to disable) |

### Agent Configuration Examples

```bash
# Default: Codex plans, Claude reviews
PLANNER_AGENT=codex REVIEWER_AGENT=claude-code

# Only have Claude? Both roles run as Claude:
PLANNER_AGENT=claude-code REVIEWER_AGENT=claude-code

# Only have Codex? Both roles run as Codex:
PLANNER_AGENT=codex REVIEWER_AGENT=codex

# Custom agent names:
PLANNER_AGENT=my-agent REVIEWER_AGENT=my-other-agent
```

## Target Repo Requirements

1. **`VISION.md`** — What should the project achieve? The planner plans features from this.
2. **`AGENTS.md`** — Architecture boundaries, relevant paths, change rules.
3. **`CLAUDE.md`** — Reviewer routing (reviewer, bug-fixer, feedback evaluator).
4. **Local tests** that run without network access.
5. **CI pipeline** (optional) — GitHub Actions, GitLab CI, etc.

## Roles

### Planner (default: Codex)
- Plans features based on vision document
- Implements against approved plans
- Always commits and pushes
- Escalates infra problems to reviewer
- Writes bug reports for problems it can't solve

### Reviewer (default: Claude)
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
- **Escalation path is critical.** Without `ci-blocked → reviewer fixes`, the planner spins endlessly documenting the error instead of solving it.
- **Plan in parallel while blocked.** The planner should plan new features while waiting on CI/review. Otherwise the entire workflow stalls.
- **Reviewer must commit and push.** If the reviewer only changes files locally, the planner never sees the changes.
- **External feedback (Gemini) is valuable.** The reviewer evaluates and incorporates relevant points into reviews. No special status needed — just check if the assessment section is missing.
- **The workflow improves itself.** Early reviews were unstructured, later ones followed clear format. Quality increases with each cycle.

### What Does NOT Work

- **Heavy local tests in planner sandbox.** MLX, Docker, Metal — none of these run in a sandboxed planner. Local tests must be lightweight, CI runs remotely.
- **`gh` CLI in planner.** No network = no `gh`. Planner pushes blind, reviewer checks CI.
- **Web searches for CI status.** The planner tries to crawl google/github.com when `gh` fails. Explicitly forbid this.
- **Status without exit path.** Never introduce a status that has no way out. Always define a clear path back.
- **Manual intervention from monitoring session.** The loop must be self-sustaining. Otherwise changes sit locally and the loop never sees them.

### Typical Throughput

~1 feature per hour after workflow stabilization. The first hour goes to setup.
