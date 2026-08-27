<!-- repo-conventions:begin v2 -->
# Repository conventions

> Managed by the repo-conventions skills. Curate with `repo-conventions-curator`; during ordinary implementation, change nothing here except appending to `Pending observations`. Keep it concise, human-readable, and evidence-backed - a policy, not a task log.

## Working contract

- Precedence order: current user request, explicit user directives below, confirmed repository conventions, repository evidence, then agent preference.
- Follow the established patterns recorded here and visible in the surrounding files before introducing a new abstraction, layout, naming scheme, dependency, or workflow.
- Code written under this policy must be worth keeping: optimised, concise, and human-readable, in the repository's established style. Match the repository's commenting practice, with an explicit user preference overriding it. Never leave generated boilerplate, dead paths, duplicated logic, or unexplained complexity behind.
- A change is not done until it is verified: run the repository's authoritative build, test, and lint commands (as recorded in this policy or discovered in its tooling) over the affected area, and exercise the change directly when no automated check covers it. Watch for regressions beyond the changed lines - callers, dependents, shared code, existing tests. Report results honestly: failures are reported as failures, never hidden, skipped, or papered over.
- When a framework, library, or tool in use is unfamiliar, look it up: read the official documentation for the version this repository pins (check manifests and lockfiles) the way a person would - the relevant pages in full, not one skimmed snippet - and verify what it says against the repository's actual behavior before acting on it or recording it. Do not guess from memory.
- Where this policy is silent or still young on a topic, follow the strongest pattern in the surrounding files and append what you learned to `Pending observations`; do not invent a rule.
- If a genuinely better, still human-readable alternative would materially change architecture, behavior, APIs, data, dependencies, or a documented convention: stop and propose it with its tradeoffs before implementing. Continuing with the task is not approval.
- Do not silently refactor unrelated code, and do not edit this block to justify an unapproved implementation.
- Do not add a rule from a one-off implementation or a speculative preference.
- At the end of a task that confirmed, contradicted, or newly discovered a durable pattern - or where the user decided a convention question - append one entry stamped with the current UTC datetime to `Pending observations` with its evidence. Entries there carry no authority until the curator promotes them.

## User directives

- Keep repository conventions enforced rather than substituting a personal or generic style.
- Keep this policy curated; remove stale, duplicated, or unsupported information instead of letting it grow.
- Commits in this repository carry no agent co-author trailers.
- The convention layer must be plug-and-play: conservative at bootstrap, learning continuously through the `Pending observations` inbox, hardening through curation.
- This repository commits its own convention layer and skills (an explicit opt-out of the layer's ignore-by-default) because it is the canonical source for them.

## Confirmed conventions

- Documentation-and-scripts repository: no build or package toolchain. The only automated check is the skill-mirror sync verification. Scope: whole repo. Evidence: repository tree, `.github/workflows/check-sync.yml`. Verified: 2026-08-27. Status: active.
- Canonical skill sources live in `.github/skills/`; `.claude/skills/` is a generated mirror. Edit the canonical copy, then run `scripts/sync-skills.sh` or `scripts/sync-skills.ps1`; CI fails when the two drift. Scope: skills. Evidence: `scripts/`, `.github/workflows/check-sync.yml`. Verified: 2026-08-27. Status: active.
- Agent-instruction files hold generated content inside idempotent managed blocks delimited by the `repo-conventions` begin/end HTML comment markers; content outside a block is user-owned and preserved. Prose that is placed inside a managed block must never contain the literal marker strings, or block replacement will truncate. Scope: instruction files, shims, installers. Evidence: `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `install.sh`. Verified: 2026-08-27. Status: active.
- Skills follow the Agent Skills format: a `SKILL.md` with a lowercase-hyphenated `name` and a `description` stating when to use it. Scope: `.github/skills/`. Evidence: both `SKILL.md` files. Verified: 2026-08-27. Status: active.
- Policy and skill prose is harness-neutral ("coding agent"); specific products are named only in the README, shims, workflow examples, and installers. Scope: whole repo. Evidence: `global/agent-policy.md`, `.github/skills/`. Verified: 2026-08-27. Status: active.
- The installers support two scopes: global (default; every repository, installed into each agent's home configuration) and repo-scoped (`--repo` / `-Repo`; layer committed into one repository, no always-on policy). Both are idempotent and only write inside managed blocks. Scope: `install.sh`, `install.ps1`. Evidence: those files, `README.md`. Verified: 2026-08-27. Status: active.
- Everything the layer creates in a consumer repository defaults to a managed `.gitignore` section using `# repo-conventions` begin/end comment lines, following the same idempotent, content-preserving managed-block rules; the user opts out via `--shared` / `-Shared` or by asking to commit the layer. Files carrying any user content are never gitignored. Scope: `install.sh`, `install.ps1`, the bootstrap gitignore step. Evidence: those files. Verified: 2026-08-27. Status: active.
- Skills keep `SKILL.md` lean with third-person, trigger-rich descriptions and move bulky reference material into files referenced one level deep (for example the bootstrap `template.md` with its example entries), per Agent Skills best practice. Scope: `.github/skills/`. Evidence: `repo-conventions-bootstrap/SKILL.md`, `repo-conventions-bootstrap/template.md`. Verified: 2026-08-27. Status: active.
- Every learned or re-verified entry carries an ISO 8601 UTC datetime so curation can age it; uncorroborated pending observations go stale after about thirty days. Scope: template, skills. Evidence: `repo-conventions-bootstrap/template.md`, `repo-conventions-curator/SKILL.md`. Verified: 2026-08-27T13:38Z. Status: active.
- The working contract requires agent-written code to be optimised, concise, human-readable, and comment-matched to the repository or the user's stated preference; bootstrap verifies codebase health across multiple files and reports cleanup options to the user rather than refactoring unattended. Scope: template, skills, global policy. Evidence: `repo-conventions-bootstrap/template.md`, `repo-conventions-bootstrap/SKILL.md` step 6, `global/agent-policy.md`. Verified: 2026-08-27T13:38Z. Status: active.

## Agent observations

- Commit subjects are single-line imperative sentences; the history is still short, so this is weak evidence rather than a confirmed convention. Verified: 2026-08-27.

## Pending observations

Append-only inbox, triaged by the curator. Entry form: `YYYY-MM-DDTHH:MMZ - pattern - evidence - source (repo evidence | user decision)`.

- None recorded yet.

## Open questions

- None.

## Curation metadata

- Last bootstrapped: 2026-08-27 (v2 restructure: policy moved into this managed block; guard skill retired; learning inbox added).
- Last verification basis: full-tree review during the v2 restructure.
- Maturity: young.
- Health: sound - 2026-08-27T13:38Z - documentation-and-scripts repo, reviewed in full during the v2 restructure.
- Curator status: active.
<!-- repo-conventions:end -->
