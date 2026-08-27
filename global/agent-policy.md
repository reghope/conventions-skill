# Global repository convention policy

This policy is always active in every coding agent it is installed into. It applies to every repository and user-selected workspace folder, including one opened for the first time.

## Start of conversation

- If no repository or workspace folder is available yet, ignore this policy and do not create files.
- Once a scope is available, use the git root when one exists; otherwise use the selected folder.
- Before normal work in that scope, check the root `AGENTS.md` for the managed `repo-conventions` block (delimited by HTML comment markers).
- If the block exists, read the whole file and treat it as required context for the entire conversation.
- If the block is missing or from an older version of this layer, run the `repo-conventions-bootstrap` skill immediately; if this agent cannot load skills, follow the procedure in `~/.agent-conventions/skills/repo-conventions-bootstrap/SKILL.md`. The user has opted in to this setup, so do not ask for confirmation or pause the user's task solely to create the convention layer.
- If the folder is not writable, or existing instruction files conflict in a way that cannot be merged safely, say so clearly and preserve the user's files; do not silently continue as though the layer were active.

## Enforcement

- Apply this precedence order: current user request, explicit user directives in the convention policy, confirmed repository conventions, current repository evidence, then agent preference.
- Follow confirmed repository patterns before introducing a new abstraction, layout, naming scheme, dependency, or workflow.
- Do not silently refactor unrelated code or replace an established pattern because another approach is more familiar.
- If a proposed alternative would materially change architecture, behavior, APIs, data, dependencies, or a documented convention: stop, explain the current convention, the alternative, and the tradeoffs, then wait for approval. Continuing with the task is not approval.
- For a local implementation choice that does not change an established convention, use the safest consistent option and mention the alternative only when it materially matters.
- Do not change the convention policy to justify an unapproved implementation.
- Code written in the repository must be worth keeping: optimised, concise, and human-readable, in the repository's established style. Match the repository's commenting practice - comment where it comments, stay quiet where it does not - with an explicit user preference overriding both. Never leave generated boilerplate, dead paths, duplicated logic, or unexplained complexity behind.
- When a framework, library, or tool in use is unfamiliar, look it up: read the official documentation for the version this repository pins (check manifests and lockfiles) the way a person would - the relevant pages in full, not one skimmed snippet - and verify what it says against the repository's actual behavior before acting on it or recording it. Do not guess from memory.
- If work surfaces credible signs that the codebase is largely unmaintainable generated code, verify across several independent files and modules, then tell the user plainly and lay out cleanup options; never begin a cleanup unattended.
- During ordinary implementation, change nothing in the managed convention block except appending candidate entries to its `Pending observations` inbox. Only the `repo-conventions-curator` skill, or the user directly, may change the rest.

## Learning

- Where the policy is silent or still young on a topic, follow the strongest pattern in the surrounding code and append what you learned to `Pending observations`; do not invent a rule.
- At the end of a task that confirmed, contradicted, or newly discovered a durable pattern - or where the user decided a convention question - append one entry stamped with the current UTC datetime (ISO 8601) to `Pending observations` with its evidence and source. Entries there carry no authority until the curator promotes them.
- When the inbox has accumulated several entries, suggest running `repo-conventions-curator` rather than triaging it yourself mid-task.

## Curation

- The managed block in `AGENTS.md` is a concise, evidence-backed policy, not a task log or a dump of every observed implementation detail.
- Use `repo-conventions-curator` when the block needs to be initialized, refreshed, reviewed, deduplicated, or checked for stale information - especially after changes to project structure, tooling, or architecture. If skills are unavailable, follow `~/.agent-conventions/skills/repo-conventions-curator/SKILL.md`.
- Preserve explicit user directives. Record agent observations only when they are durable, relevant beyond one task, and backed by repository evidence.
- Scheduled convention reviews are read-only: they report drift and propose curation, and never change policy or product code unattended.
- Every applied curation ends with a brief report of what changed and why, including the supporting evidence or user decision. Never update the policy silently.
- If evidence conflicts, or a proposed rule would materially change the project's direction, surface the conflict and ask the user instead of choosing silently.
