---
name: repo-conventions-bootstrap
description: Initializes or upgrades a repository's convention layer - a managed policy block in the root AGENTS.md plus shims for coding agents that do not read AGENTS.md natively. Use when entering a repository or workspace folder whose root AGENTS.md has no completed repo-conventions block, when migrating a legacy v1 convention layout, or when the user asks to set up, initialize, or bootstrap repository conventions.
---

# Repository convention bootstrap

Create a small, repository-specific convention layer without inventing rules or overwriting existing instructions. Where this skill is installed globally, the user has opted in to this setup for every repository and workspace folder; where it arrived with a repo-scoped install, the opt-in covers that repository.

## Target layout

- `AGENTS.md` at the scope root - the mutable, human-readable policy, held inside an idempotent managed block. Agents that read `AGENTS.md` natively (Codex, Cursor, Gemini CLI, Jules, Amp, the GitHub Copilot coding agent, and others) load it with no further wiring. The full block template, with example entries showing the required form, is in `template.md` in this skill directory.
- Shims for agents in use that do not read `AGENTS.md`, each containing only a managed block that defers to it:
  - `CLAUDE.md` (Claude Code) - the block contains the import line `@AGENTS.md`.
  - `.github/copilot-instructions.md` (Copilot CLI and chat) - the block says to read and follow `AGENTS.md` before any work.
  - `GEMINI.md` (Gemini CLI with the default context file name) - same deferral.

If any file already exists, preserve its user-authored content and only add or replace the managed block. Never replace an existing instruction file wholesale.

## What to assess

Work through these dimensions when inspecting the repository, and record what the evidence supports - as a confirmed convention when the pattern is established, or as an open question when it is unclear or contested:

- Languages and paradigm actually in use: object-oriented, functional, procedural, or a deliberate mix - judged from representative source files, not from the language's defaults.
- Architecture and layering: module or package boundaries, dependency direction, entry points, and any enforced separation (for example domain vs I/O, core vs adapters).
- Reuse: where shared code lives (shared libraries, core packages, utility modules), how it is consumed (imports, composition, inheritance, dependency injection), and how reusable the pieces actually are - whether repeated logic is extracted into shared units or duplicated, and where new shared code is expected to go.
- Naming and file layout: casing schemes, file and folder organization, test file placement.
- Error handling and logging: the dominant strategy (exceptions, result types, error codes) and where cross-cutting concerns are handled.
- Testing: framework, test types present, and how tests mirror the source layout.
- Tooling and workflow: authoritative build, test, lint, and run commands, and any generated files that must not be hand-edited.
- Operational lore: non-obvious facts a fresh session would otherwise rediscover the hard way - required flags, tokens, or environment variables, tool quirks and their exact error strings, order-dependent steps, known dead ends with their working paths. Record each with the exact command as evidence; these entries repay their lines fastest.
- Maintainability and health: whether the code reads as deliberately built or as accumulated generated slop - near-duplicate blocks, dead or unreachable code, mixed contradictory styles, oversized functions, meaningless names, boilerplate comments, unused dependencies. Judge this across multiple files and modules; a single bad file is not a verdict.

When the stack is unfamiliar, read the official documentation for the versions the repository pins before judging its patterns - the relevant pages properly, as a person would - verify doc claims against the code, and cite the documentation as evidence where a convention rests on it.

## Procedure

1. Locate the git root; if there is none, use the selected workspace folder. With no repository or folder scope, do nothing.
2. If the root `AGENTS.md` already contains a completed `repo-conventions:begin v2` block - one with curation metadata - the layer is current: read it in full and return to the user's task. A repo-scoped install may instead leave an unbootstrapped seed block; complete it by following the remaining steps.
3. If the legacy v1 layout exists (`.github/skills/repo-conventions/repo-conventions.md`), migrate: move the content of its sections into the new managed block, remove the v1 managed block from `.github/copilot-instructions.md`, delete `.github/skills/repo-conventions/`, and report the migration.
4. Inspect the repository's instruction files, README or equivalent documentation, project manifests, build configuration, representative source files, tests, and version-control configuration, then assess the repository against the dimensions above.
5. Write the managed block in `AGENTS.md` from `template.md`, creating the file if needed and preserving any existing content outside the block. Record only durable rules: each confirmed convention needs a short scope, an evidence path, a verification datetime (ISO 8601 UTC), and a status. Do not include secrets, generated files, temporary task details, negative guesses, or unsupported preferences. Mark uncertain findings as open questions rather than presenting them as rules. Early in a repository's life, prefer open questions and pending observations over confirmed rules and set `Maturity: young`; the curator raises it to `established` once rules have been confirmed across several tasks or by the user.
6. If the assessment surfaces credible signs that the codebase is largely unmaintainable generated code, verify to the best of your ability: confirm the signals across several independent files and modules, and separate genuine slop from an unfamiliar but consistent style. When verified, record it in the `Health` line of the curation metadata and tell the user plainly, with their options - a scoped cleanup (deduplicate, delete dead code, extract shared units), incremental cleanup rules added to this policy so new work stops making it worse, a deeper module-by-module refactor, or leaving it as-is with the risk stated. Never start the cleanup unattended.
7. Ensure a shim exists for the agent currently running, and repair the managed block of any shim already present. Do not create shims for agents that show no sign of use in the repository.
8. Unless the user has opted to commit and share the layer, list the files this bootstrap created - never files that already existed or are already tracked - in a managed `.gitignore` section delimited by `# repo-conventions` begin/end comment lines, following the same rules as every managed block: idempotent replacement, all other content preserved, no marker strings among the entries. If the user opts to share the layer, remove that section instead.
9. If an existing instruction file conflicts with this layer in a way that cannot be merged safely, preserve the user's content and report the conflict; do not silently merge policies.
10. Do not ask for confirmation solely for this opted-in bootstrap. Do not commit, push, reset, or modify unrelated files. When the layer is ready, continue the user's task normally and report any convention question that needs a decision.
11. Where a scheduling system is available, ensure the scope is covered by the daily convention-drift review. The scheduled review is read-only and reports proposed curation rather than applying it unattended.

## Validate before finishing

- `AGENTS.md` has exactly one begin marker, one end marker, and all seven sections from the template.
- No literal marker strings appear inside section content or among `.gitignore` entries.
- Every shim present contains only its managed block plus pre-existing user content, and defers to `AGENTS.md`.
- `.gitignore` matches the user's sharing choice.
- User content outside every managed block is preserved unchanged.

## Quality bar

Bootstrap is complete only when a fresh conversation in any supported agent loads the policy - natively through `AGENTS.md` or through a shim - the policy is specific enough to preserve the repository's existing patterns without becoming a second copy of the codebase, and every later session knows where to record what it learns.
