# Ralph Loop

This is the practical runner side of the pairing workflow.

## What the Runner Does

The runner reads artifacts under `.workflow/` and derives the next Praxis step:

- Write plan
- Revise plan after review
- Start implementation
- Write delta plan after bad implementation review
- Write summary
- Or report that Theorie is up next

## Important Rule

After `changes-requested` in an implementation review, the runner deliberately does NOT jump straight back into implementation.

It first requires a new plan iteration or delta plan. This is intentional — it preserves the thinking cycle.

## Files

- `PRAXIS.md`: Runner-specific Praxis instructions
- `README.md`: This explanation
