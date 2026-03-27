# Dual-Ralph Setup Guide

You are helping the user set up the Dual-Ralph workflow for their project. This is an interactive process — investigate the repo first, then ask questions to fill in the gaps.

## Step 1: Investigate the Repo

Before asking anything, explore the project:

1. Read `README.md`, `CLAUDE.md`, `AGENTS.md`, `VISION.md` — do any of these exist already?
2. Check the language/stack: `go.mod`? `package.json`? `pyproject.toml`? `Cargo.toml`?
3. Check for existing tests: `Makefile`? `go test`? `pytest`? `npm test`?
4. Check for CI: `.github/workflows/`? `.gitlab-ci.yml`?
5. Check git remote: `git remote -v` — GitHub? GitLab? Other?
6. Read `.workflow/config.sh` to see what needs to be configured.

Report what you found to the user before proceeding.

## Step 2: Ask the User

Based on what you found, ask these questions (skip any you can already answer from the repo):

1. **What is this project?** One sentence — what does it do, who is it for?
2. **What is the current goal?** What should Codex work on first? What's the vision for the next weeks/months?
3. **What are the hard constraints?** Architecture rules, forbidden patterns, non-negotiable quality standards.
4. **What is the test command?** What command runs tests locally without network access?
5. **Are there areas Codex should NOT touch?** Protected files, stable modules, external integrations.

## Step 3: Create the Files

Based on the investigation and answers, create or update these files:

### VISION.md (in repo root)
This is what Codex reads to plan features. It should contain:
- Project purpose (1 paragraph)
- Current milestone / focus area
- Concrete feature goals (ordered by priority)
- What "done" looks like for each goal
- What is explicitly NOT a goal right now

Keep it short and actionable. Codex reads this every iteration — brevity matters.

### AGENTS.md (in repo root)
This is what both Codex and Claude read before every action. It should contain:
- Project state (what works today, what doesn't)
- Architecture boundaries (what's allowed, what's forbidden)
- Relevant paths (where to find what)
- Standard workflow (how to build, test, run)
- Change rules (coding style, patterns to follow/avoid)

Pull as much as possible from existing docs. Don't invent constraints — ask the user.

### CLAUDE.md (in repo root)
Claude's role definition. Start with this template and adapt:

```markdown
# CLAUDE.md

## Role
Claude is reviewer, bug-fixer, and feedback evaluator. Claude does NOT implement features.

## Routing
Claude acts when a plan or bug is `assigned-to: claude`:

Plans (in `.workflow/plans/`):
- `awaiting-opus-review` → Write plan review
- `awaiting-implementation-review` → Write implementation review
- `ci-blocked` → Diagnose and fix blocker

Bugs (in `.workflow/bugs/`):
- `open` + `assigned-to: claude` → Fix bug, commit, set Status: fixed

Feedback (in `.workflow/feedback/`):
- Files without `## Claude Assessment` → Evaluate and incorporate

## What Claude does NOT do
- Implement features
- Change plan status (Codex does that, except: Claude may set ci-blocked → implementing after fixing)
```

### .workflow/config.sh
Update with the correct values:
- `VISION_FILE` → path to VISION.md
- `LOCAL_TEST_CMD` → the test command from Step 2
- `CI_SYSTEM` → `github-actions` or `none`
- `AGENTS_FILE` → path to AGENTS.md
- `CLAUDE_FILE` → path to CLAUDE.md

### .workflow/acceptance-criteria.md
Review the default criteria. Ask the user if they want to add project-specific criteria (e.g., "no mocking", "guard clauses only", "100% test coverage for new code").

## Step 4: Verify

1. Confirm all files exist: `VISION.md`, `AGENTS.md`, `CLAUDE.md`, `.workflow/config.sh`
2. Run the test command once to verify it works
3. Show the user a summary of what was configured
4. Ask: "Ready to start the loops? Run `.workflow/codex-plan-work.sh` for Codex and `.workflow/claude-review.sh` for Claude."

## Important Notes

- Don't make up project goals — ask the user
- Don't add constraints the user didn't mention
- Keep VISION.md under 50 lines — Codex reads it every iteration
- Keep AGENTS.md focused on facts, not aspirations
- If the user already has good docs, reference them from VISION.md instead of duplicating
- Commit all created files when done
