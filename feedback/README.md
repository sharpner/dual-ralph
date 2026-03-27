# Feedback

External feedback (e.g. from Gemini) goes here.
Claude reviews new feedback, assesses relevance, and incorporates actionable points into Codex reviews.

## Format

Filename: `<date>-<source>-<short-description>.md` (see `templates/feedback.md`)

## Workflow

1. External reviewer writes feedback to `.workflow/feedback/<date>-<source>-<topic>.md`
2. Claude review loop finds files without `## Claude Assessment`
3. Claude assesses relevance and writes assessment
4. If relevant: incorporates into next Codex review or creates bug report
