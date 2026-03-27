# Feedback

External feedback (e.g. from Gemini) goes here.
The reviewer reviews new feedback, assesses relevance, and incorporates actionable points into planner reviews.

## Format

Filename: `<date>-<source>-<short-description>.md` (see `templates/feedback.md`)

## Workflow

1. External reviewer writes feedback to `.workflow/feedback/<date>-<source>-<topic>.md`
2. Reviewer loop finds files without `## Reviewer Assessment`
3. Reviewer assesses relevance and writes assessment
4. If relevant: incorporates into next planner review or creates bug report
