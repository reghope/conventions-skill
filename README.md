# Conventions skill

A portable repository-convention layer for coding agents. Each repository carries one concise, evidence-backed policy in a managed block in its root `AGENTS.md`; agents bootstrap it automatically on first open and curate it deliberately through a dedicated skill.

## How it works

- **`AGENTS.md` is the policy.** It is read natively by Codex, Cursor, Gemini CLI, Google Jules, Amp, the GitHub Copilot coding agent, and others - no wiring needed. The policy lives inside an idempotent managed block delimited by `repo-conventions` begin/end HTML comment markers; everything outside the block stays user-owned.
- **Shims cover the rest.** `CLAUDE.md` imports it with `@AGENTS.md` for Claude Code; `.github/copilot-instructions.md` covers Copilot CLI and chat; `GEMINI.md` covers default Gemini CLI setups. Shims contain only a managed block and never disturb existing user content.
- **`global/agent-policy.md`** is the always-on user-level policy: it makes agents load the repository policy, bootstrap it when missing, and follow the precedence order - current user request, explicit user directives, confirmed conventions, repository evidence, then agent preference.
- **Two skills do the work.** `repo-conventions-bootstrap` creates or upgrades the layer from repository evidence (assessing paradigm, architecture and layering, where shared code lives and how it is reused, naming, error handling, testing, and tooling); `repo-conventions-curator` is the only writer of the policy and runs read-only when scheduled.
- **It learns as it goes.** A fresh install starts conservative: bootstrap records only what the evidence supports and leaves the rest as open questions. During ordinary work, any agent appends what it learns - confirmed patterns, contradictions, user decisions - to an append-only `Pending observations` inbox inside the block; the curator later promotes corroborated entries into real conventions and directives, tracks the policy's maturity (`young` to `established`), and discards the rest. Plug it in, and the policy hardens with use.
- **Guards against AI slop.** Code written under the policy must be optimised, concise, and human-readable, with commenting matched to the repository's own practice (or the user's stated preference). Every learned entry carries a UTC datetime so curation can age out stale knowledge, and if a codebase itself shows verified signs of unmaintainable generated code - checked across multiple files, not one bad example - the layer reports it to the user with cleanup options instead of quietly making it worse.
- **Local by default.** Everything the layer creates is added to a managed `.gitignore` section (using `# repo-conventions` comment-line markers, following the same idempotent, content-preserving rules as every managed block), so it stays on your machine unless you opt out. Files that carry any user content are never gitignored.

## Installing

**Global (default)** - every repository you open, in every supported agent on this machine:

```bash
./install.sh
```

```powershell
./install.ps1
```

This installs the always-on policy into each agent's home configuration (`~/.copilot/copilot-instructions.md`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`) and the skills into `~/.copilot/skills/`, `~/.claude/skills/`, and `~/.agent-conventions/skills/` (a neutral copy any agent can be pointed at). Repositories are then bootstrapped automatically when first opened.

**Repo-scoped** - one repository only, with no always-on global policy:

```bash
./install.sh --repo /path/to/repo
```

```powershell
./install.ps1 -Repo -Path C:\path\to\repo
```

This seeds `AGENTS.md` with an unbootstrapped managed block; the first agent session in the repository completes the bootstrap from actual repository evidence. By default the created files are gitignored so the layer stays local to your machine. To opt out and commit the layer so collaborators get it too, add `--shared` (or `-Shared`) - rerunning with the flag removes the managed `.gitignore` section again.

Both installers are idempotent: rerunning them only rewrites the managed blocks and preserves everything else. Start a new agent session after installing.

## Repository layout

- `.github/skills/` - the canonical skill sources. Each skill keeps its `SKILL.md` lean and moves bulky reference material (like the bootstrap block template and example entries in `template.md`) into files loaded on demand.
- `.claude/skills/` - a generated mirror for Claude Code. Edit the canonical copy, then run `scripts/sync-skills.sh` or `scripts/sync-skills.ps1`; CI (`check-sync.yml`) fails when the two drift.
- `global/agent-policy.md` - the always-on policy the global install deploys.
- `AGENTS.md` - this repository dogfoods the layer; its own policy lives there and is committed deliberately, since this repo is the source.

## Scheduled review

`.github/workflows/conventions-review.yml.example` runs the curator daily in read-only mode and opens an issue with proposed curation. Rename it to `conventions-review.yml` and provide the agent CLI credential it needs to enable it. Scheduled runs never apply convention or product-code changes unattended.

## Policy

The convention block is evidence-backed and human-readable. User directives take precedence, material deviations require approval before implementation, and applied curation always ends with a report of what changed and why.
