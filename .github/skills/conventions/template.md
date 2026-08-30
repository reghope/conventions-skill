# Managed block template

Copy this block into the root `AGENTS.md` (or replace the unbootstrapped seed block), filling the sections from repository evidence. Never place the literal begin/end marker strings inside section content. Stamp every entry with the current UTC datetime (ISO 8601, minutes precision) so curation can age it.

~~~markdown
<!-- repo-conventions:begin v2 -->
# Repository conventions

> Managed by the conventions skills. Curate with `conventions-curator`; during ordinary implementation, change nothing here except appending to `Pending observations`. Keep it concise, human-readable, and evidence-backed - a policy, not a task log. Size budget: about 120 lines for the whole block; curation makes room and adds in the same pass rather than letting it grow.

## Working contract

- Precedence order: current user request, explicit user directives below, confirmed repository conventions, repository evidence, then agent preference.
- Follow the established patterns recorded here and visible in the surrounding code before introducing a new abstraction, layout, naming scheme, dependency, or workflow.
- Code written under this policy must be worth keeping: optimised, concise, and human-readable, in the repository's established style. Match the repository's commenting practice - comment where it comments, stay quiet where it does not - and let an explicit user preference override both. Never leave generated boilerplate, dead paths, duplicated logic, or unexplained complexity behind.
- A change is not done until it is verified: run the repository's authoritative build, test, and lint commands (as recorded in this policy or discovered in its tooling) over the affected area, and exercise the change directly when no automated check covers it. Watch for regressions beyond the changed lines - callers, dependents, shared code, existing tests. Report results honestly: failures are reported as failures, never hidden, skipped, or papered over.
- When a framework, library, or tool in use is unfamiliar, look it up: read the official documentation for the version this repository pins (check manifests and lockfiles) the way a person would - the relevant pages in full, not one skimmed snippet - and verify what it says against the repository's actual behavior before acting on it or recording it. Do not guess from memory.
- Where this policy is silent or still young on a topic, follow the strongest pattern in the surrounding code and append what you learned to `Pending observations`; do not invent a rule.
- If a genuinely better, still human-readable alternative would materially change architecture, behavior, APIs, data, dependencies, or a documented convention: stop and propose it with its tradeoffs before implementing. Continuing with the task is not approval.
- Do not silently refactor unrelated code, and do not edit this block to justify an unapproved implementation.
- Do not add a rule from a one-off implementation or a speculative preference.
- End every task with a short consolidation pass: if it confirmed, contradicted, or newly discovered a durable pattern, if the user stated a preference, correction, or decision, or if you recovered from errors or dead ends to a working path the next session should not rediscover - append one entry per durable learning, stamped with the current UTC datetime, to `Pending observations` with its evidence. Entries there carry no authority until the curator promotes them.
- Record user preferences and corrections first, then operational lore (exact commands, required flags or tokens, tool quirks, exact error strings, workarounds), then procedures, then structural observations. Skip trivial facts, anything cheaply re-derived from the code, raw output dumps, and task logs. A fact that only appeared in command output is easiest to lose - quote the command and the decisive output line as evidence. Corroborate an existing inbox entry rather than duplicating it.

## User directives

- None recorded yet.

## Confirmed conventions

- None recorded yet.

## Agent observations

- None recorded yet.

## Pending observations

Append-only inbox, triaged by the curator. Entry form: `YYYY-MM-DDTHH:MMZ - pattern - evidence - source (repo evidence | user decision)`.

- None recorded yet.

## Open questions

- None recorded yet.

## Curation metadata

- Last bootstrapped: <datetime>.
- Last verification basis: <what was inspected>.
- Maturity: young.
- Health: <sound | mixed | slop-risk> - <datetime> - <one-line basis>.
- Curator status: active.
<!-- repo-conventions:end -->
~~~

## Example entries

A confirmed convention always carries scope, evidence, verification datetime, and status:

- Services return `Result<T, DomainError>` instead of throwing; exceptions are reserved for programmer error. Scope: `src/services/`. Evidence: `src/services/*.ts`, `docs/errors.md`. Verified: 2026-08-27T14:05Z. Status: active.

A pending observation from repository evidence:

- 2026-08-27T14:05Z - New API handlers are being placed in `src/api/handlers/` rather than alongside routes - `src/api/handlers/orders.ts`, `src/api/handlers/billing.ts` - repo evidence.

A pending observation from a user decision:

- 2026-08-27T16:40Z - Integration tests live in `tests/integration/`, not next to source - stated by the user during a task - user decision.

Operational lore - the entries that save the most rediscovery - looks like this. A confirmed convention recording a tool quirk with its exact command:

- The integration rig refuses to run without `--rig-token` (exits 2: "missing or wrong --rig-token"); the token is documented in `rig/README.md`. Run stages with `node rig/check.mjs stage1 --rig-token <token>`. Scope: rig/. Evidence: `rig/check.mjs`, `rig/README.md`. Verified: 2026-08-27T18:12Z. Status: active.

A pending observation recording a dead end recovered to a working path, with command-output evidence:

- 2026-08-27T18:30Z - `npm test` from the repo root hangs on Windows; the working path is `npm test --workspace packages/core` (root run stalled at "collecting tests", workspace run completes in 40s) - command output from both runs - repo evidence.
