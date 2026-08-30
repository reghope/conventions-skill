---
name: repo-conventions-curator
description: Curates the managed repository-convention block in the root AGENTS.md so it stays concise, current, evidence-backed, and free of duplicated or speculative rules. Use when the user asks to review, refresh, curate, deduplicate, or clean up repository conventions, when the Pending observations inbox needs triage, or when invoked by the scheduled convention-drift review.
---

# Repository convention curator

This skill is the only normal writer of the convention policy, with one exception: any agent may append candidate entries to the `Pending observations` inbox during ordinary work. It is not a general implementation workflow. The authoritative policy is the managed `repo-conventions` block in the root `AGENTS.md`. Content outside the block is user-owned and out of scope.

## Scheduled review mode

When invoked by the scheduled convention-drift review, inspect the current repository or workspace folder in read-only mode. Do not write the policy or product code. Report any stale or contradicted rules, the evidence, a concise proposed curation for a later user-approved run, the size and notable entries of the `Pending observations` inbox, and the current `Health` assessment with whether it has degraded since the last curation.

## Curation procedure

1. Read the complete managed block, and confirm any shims present (`CLAUDE.md`, `.github/copilot-instructions.md`, `GEMINI.md`) still defer to `AGENTS.md`, and confirm any managed `.gitignore` section still matches the user's sharing choice. If no repository or workspace folder is available, do nothing.
2. Inspect the current repository state, project manifests, relevant documentation, representative code, tests, and recent history related to the conventions under review. Re-check the assessment dimensions from the bootstrap skill - paradigm, architecture and layering, shared-code location and reuse, naming, error handling, testing, and tooling - so drift in those areas is caught, not just drift in already-written rules.
3. Triage `Pending observations`:
   - Merge entries describing the same pattern before judging them; their combined datetimes and evidence count as corroboration.
   - Promote entries marked as user decisions to `User directives`.
   - Promote candidates corroborated by repeated sightings or independent repository evidence to `Confirmed conventions` or curated `Agent observations`.
   - When space is tight, promote in this priority: user preferences and corrections; then operational lore (exact commands, required flags or tokens, tool quirks, exact error strings, workarounds) - the entries that save the most rediscovery per line; then procedures; then structural observations.
   - Move unclear but plausible entries to `Open questions`.
   - Delete stale, trivial, or contradicted entries; treat each entry's datetime as its age, and drop or convert to an open question any uncorroborated entry older than about thirty days.
   - Clear every promoted or discarded entry from the inbox and note the triage outcome in the curation metadata.
4. Build an evidence check for every existing rule:
   - Keep confirmed rules that still match the repository, refreshing their verification datetime.
   - Use each rule's verification datetime to prioritise: the older the last verification, the harder it must be re-checked against current evidence.
   - Preserve explicit user directives unless the user changes them.
   - Remove or rewrite stale rules only when current evidence contradicts them, and record the reason in the curation metadata.
   - Move uncertain or one-off observations to `Open questions` or remove them; do not promote them to policy.
5. Deduplicate rules and keep each rule to one durable idea with a clear scope, evidence path, verification datetime (ISO 8601 UTC), and status.
6. Hold the block to its size budget - about 120 lines, each rule at most three - judged against the final state of the whole pass, not edit by edit: one curation may retire, merge, and add together, so making room and adding new rules land atomically. Never let the block grow past budget intending to prune later, and never silently drop a user directive to make room - surface the tension instead.
7. Propose the complete change in human-readable form before writing it, unless the user explicitly asked to apply the curation. If there is a conflict between established patterns, stop and ask the user which direction is authoritative.
8. After approval, update only the managed block and its curation metadata: refresh the `Health` line, and set `Maturity`: keep `young` while rules are few or lightly corroborated, and raise it to `established` once the core rules have held across several tasks or been confirmed by the user. Do not rewrite product code to make the policy look consistent, and do not touch user content outside the block.
9. Whenever a change is applied, end the response with a brief report:
   - `Changed`: the sections or rules added, changed, or removed, including inbox promotions.
   - `Why`: the evidence or explicit user decision that required the change.
   - `Open`: any unresolved question, or `None`.

   Keep this report short and visible even when the user explicitly asked for the curation. If no file change was applied, say so instead of reporting a successful update.

## Slop-prevention rules

- Do not record every implementation detail, file name, or task decision.
- Do not infer a convention from a single accidental example when the repository contains contrary or insufficient evidence.
- Judge maintainability across multiple files and modules before calling code slop; an unfamiliar but consistent style is not slop.
- Promote a pending observation only on corroboration - repeated sightings, independent evidence, or an explicit user decision; never merely because it sits in the inbox.
- Do not add generic style advice that is not visible in this repository.
- Do not treat agent-generated code as evidence of a project convention unless the user explicitly accepts it or the same pattern is independently established.
- Keep `User directives`, `Confirmed conventions`, `Agent observations`, `Pending observations`, and `Open questions` separate.
- Every confirmed convention needs evidence, scope, status, and a verification datetime; every agent observation needs a reason to remain useful and a verification datetime.
- Prefer stable evidence such as file paths, symbols, project settings, and repeated patterns over line numbers that drift.
- Where a rule rests on framework or library behavior you are not certain of, read the official documentation for the version the repository pins before keeping, rewriting, or removing it; do not judge it from memory.
- When a better approach is found, suggest it to the user before changing either the code or the policy.
