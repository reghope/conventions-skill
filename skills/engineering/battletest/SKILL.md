---
name: battletest
description: Simulated users test the app like real people - bugs, UX friction, and rough edges filed as tickets, folded into one report
disable-model-invocation: true
---

**More than just finding bugs.** A project's developer cannot use it the way a stranger does, and a test suite cannot tell you the onboarding is confusing, the empty state feels broken, the wording changes tone mid-flow, or the third step of the core journey is where impatient people give up. Battletesting fields a **team of simulated users** — each a subagent with its own persona, temperament, and screen size — who use the project the way real users would, keep a diary of the experience, and file a ticket the moment something is wrong *or merely feels wrong*. When the last tester finishes, the findings are deduped and folded into one report with themes and a suggested fix order: part QA pass, part usability lab, part first-impressions panel.

**Project-agnostic.** Battletest is not just for the web — testers use whatever the project offers:

- **Web app or site**: browsed at real viewports (desktop, phone, tablet), screenshot by screenshot.
- **Desktop/Electron app**: launched with a remote debugging port and driven over CDP.
- **CLI or TUI**: the binary run for real — commands, flags, prompts, help text, first-run experience, error messages under weird input.
- **Library, API, or SDK**: its user is a developer, so the tester becomes one — following the README quickstart in a scratch project, running the documented examples exactly as written, and judging install friction, time to first success, and how the errors read.

Invoked as `/battletest [count] [focus]`: an optional focus is an area to concentrate on, or a hosted URL to test directly instead of launching anything locally. A model for the testers can be named in plain words ("on opencode minimax-m3", "use mimo v2.5") — otherwise **testers run on the session's own model; never pick one for the user**. When a named model exists on several providers, prefer the session's current provider, then subscription providers, with aggregators as the failsafe.

## Size the team to the project

With an explicit count (`/battletest 5`), deal that many personas from the deck below. **Without a count, the orchestrator sizes the team itself, at most 3 testers** — and most projects need exactly one:

- **Default: one balanced generalist** who goes over everything, breadth before depth. Before adding anyone else, ask whether the generalist already covers it: viewports (desktop vs mobile vs tablet), walking every screen, ordinary error paths, and wording/consistency are all inside one generalist's pass — none of those justify a second tester.
- **Up to two specialists**, each defined by a short focus phrase, only where the project concentrates its risk in a domain that rewards sustained expert attention: security posture and hostile input, deep accessibility (keyboard/screen-reader), a payments or data-loss flow, a protocol or offline edge.
- **Pick on form when you have it.** If earlier runs left performance records (see below), weigh which archetypes, traits, and briefs actually found problems before dealing blind.

## Preflight before anyone is dispatched

Two cheap checks that have each saved entire runs:

1. **Is the target fresh?** If testers will run a built artifact (a dist/, a bundle, a packaged app), confirm the build is current — newest source mtime vs newest build mtime, or a version probe. A stale build once burned a third of a fleet on "missing" features that were simply unbuilt, including the run's only blocker ticket. If testers mid-run start reporting known features as missing, suspect the build before believing the tickets: stop, rebuild, resume.
2. **Can a fixture exercise the core behavior?** Features gated on real external state (credentials, paid accounts, live services) often have a test seam in the codebase already — a faux provider, a mock transport, a scriptable error. Wiring one up turns "untestable, covered by unit tests only" into the run's main event; without it, a run validates everything *around* the feature and never the feature. If a fixture exists or is cheap, name it in the focus so the testers use it.

## The team is dealt, not designed

Real user bases are not deterministic, so counted teams are dealt fresh every run:

- **Archetypes without replacement**, so N testers cover N distinct angles: *first-timer* (onboarding, discoverability), *power-user* (shortcuts, efficiency), *skimmer* (impatient, doesn't read), *auditor* (visual and behavioural consistency), *accessibility-advocate* (keyboard-only, contrast, focus, target sizes), *performance-hawk* (latency, jank, big inputs), *wordsmith* (copy, terminology, truncation, tone), *chaos-monkey* (weird input, interrupted operations, rapid clicking), *everyday-regular* (the happy path done repeatedly, state persistence), *skeptic* (error handling, data integrity, whether feedback tells the truth). Supervisor-sized teams use a *generalist* backbone plus *specialist* personas built from the focus phrases. A team bigger than the deck repeats archetypes with fresh trait rolls.
- **Traits rolled per tester**: patience (low/medium/high), expertise (novice/comfortable/expert), temperament (forgiving/blunt/exacting), thoroughness (skims/balanced/exhaustive). Give each tester a human name — first names of scientists, philosophers, and historical figures read well — so diaries and tickets sound like people.
- **Viewports dealt in a fixed cycle** — desktop, mobile, desktop, tablet — so any run of two or more includes a phone-sized screen and any run of four or more a tablet. Mobile testers do *everything* at an emulated 375x812 with touch; tablet testers at 768x1024; desktop testers still narrow the window at least once mid-session.

## Each tester is a user, not a developer

Spawn each tester as its own subagent with a brief that holds its persona, traits, viewport, and these standing rules:

- **Run it isolated.** Discover how to launch the app from the repo (README, package scripts, launch config) — unless the focus names a hosted target, in which case test that URL directly. Each tester gets its own port offset and its own profile/scratch directory (under the OS temp dir, never inside the project — browser profiles are gigabytes of junk that git and sync tools will choke on); nothing it writes leaves that directory.
- **See it like a user.** Judge from pixels, not markup: after every navigation and meaningful state change, capture a screenshot (headless browser over CDP: `Page.captureScreenshot`) and actually look at it. Any visual claim in a ticket — misaligned, overlapping, truncated, hidden — must come from a screenshot the tester viewed.
- **Verify state claims.** After any action that claims to change state — a save, an add, a remove, a setting — check the app's own story against reality: re-open the screen, re-list the items, read the file if the app names one. "It said saved but nothing changed" and "status disagrees with what's on disk" are among the best tickets a run produces; hand this lens to every tester rather than hoping one rolls exhaustive.
- **Narrate in the action itself.** Every tool call carries a few present-tense words on what the tester is doing ("checking the docs button"; shell commands start with a `# intent` comment line), so a live roster can show what each tester is on without a separate narration channel.
- **Stay in character.** Traits show in what the tester tries, how long it persists, and how findings are phrased. An impatient skimmer abandoning a slow flow *is* the data.
- **Never touch the code.** Testers do not read source to explain problems away, do not fix or work around anything, and never modify the app's files. If it confused the tester, it confused the tester.
- **Record continuously.** A diary note after every meaningful step (what it tried, what it expected, how it went — including what worked), and one ticket per distinct problem, filed the moment it is hit, never batched at the end.
- **Run lean.** Testers do not need deep reasoning to press buttons — run them at low thinking (measured: model deliberation was ~70% of an 80-minute run's wall clock at high effort). Never sleep longer than ~5 seconds in one call (poll in short beats); chain quick related shell commands into one call instead of paying a round-trip each.

## Tickets — one problem, one ticket, across the whole team

One file per ticket in the run's `tickets/` directory, frontmatter plus sections, so the tracker is grep-able and git-mergeable:

```markdown
---
title: Save button never enables
persona: dexter-power-user
severity: major        # blocker | major | minor | polish
category: bug          # bug | ui | ux | performance | copy | accessibility | other
area: settings
status: open           # open | fixed | wont-fix | duplicate (+ duplicateOf)
---

## What happened
## Expected
## Steps to reproduce
## Also seen            # other testers' corroborating observations, attributed
```

Steps must let a stranger reproduce the problem without the tester. Severity is honest: blocker = cannot proceed, major = badly hurts the experience, minor = noticeable friction, polish = small but real.

**Dedupe at filing time, not just at synthesis.** Testers file blind to each other, and unchecked that produces the same finding five times over. Before filing, check whether an existing ticket already covers the problem (same area, same title in other words). If it does: **stand down from that bug** — the time is better spent on uncovered territory — and append anything genuinely new to the original under `## Also seen`, attributed by persona. Only file separately when it is truly a different problem wearing a similar name, with a title that names the difference. A filing that lands successfully should still glance at the other open tickets in its area, so the next near-miss becomes an append instead of a duplicate.

## Safety: self-judged, escalated, never asked of a human

The run is unattended and must never stop for human permission. Testers judge every action before taking it. **Forbidden outright** (never escalated, always denied): buying anything or entering payment details; creating real accounts or entering real credentials or personal data; submitting anything that reaches a real person or service (filling a form to test validation is fine, submitting valid data is not); deleting or corrupting any data the app manages, even where its own UI offers it. Walking to the edge and recording what is there *is* the test — the checkout never placed, the delete dialog never confirmed.

For the gray zone, a **clearance loop**: the tester describes the exact action and its risk to the orchestrating agent and pauses until it rules. The orchestrator judges against the doctrine — allow only actions with no real-world footprint, deny when in doubt — and answers with one line of guidance. An unanswered request denies itself after a timeout so no tester ever hangs.

**A user's Stop means stop.** The run itself must not be interrupted by the harness, but when the human explicitly aborts the supervising turn, no automatic continuation restarts it — the run's artifacts stay on disk, reportable and resumable whenever they come back.

## The tester brief

Everything above only works if it reaches the testers verbatim: a tester subagent sees nothing but its brief, so the brief IS the method. Use `tester-brief.md` (beside this file) as the template — fill its placeholders per persona and do not soften its rules. The load-bearing parts, in case you are tempted to trim: the in-character trait sentence (it is what makes a skimmer skim), the screenshot-evidence rule (without it testers judge from markup), the state-verification rule (the data-integrity ticket class lives or dies on it), the two-pass coverage plan with an action budget and a novelty stop rule (without them the slowest tester sets the wall clock), the filing-time dedupe rule (without it synthesis drowns in duplicates), the file-when-you-hit-it ticket rule (batched tickets lose their reproduction steps), and the full safety block.

**Budgets are ceilings, not suggestions.** A tester meaningfully past its budget (~120%) gets one supervisor message: stop exploring, file what you have, write the closing note, finish. Stragglers are what turn a thirty-minute run into an eighty-minute one.

## Show the run while it happens

A battletest that runs in silence looks broken and wastes its best property: findings that land live. The person watching must never stare at a bare "running tools" line for minutes. Non-negotiable output contract for the orchestrator:

- **Announce each phase in one line as it starts**: preflight result ("build is current" / "rebuilt dist first"), the team as it is dealt (one line per tester: name, archetype, viewport, one-phrase angle), dispatch, and later wrap-ups and synthesis.
- **Print a roster between every poll of the run directory** (every couple of minutes while testers run), one line per tester in this shape, built from what is on disk — diary length and last `### HH:MM — <area>` heading, tickets filed under their persona:

  ```
  Ada (generalist, desktop) · 14 notes · 2 tickets · testing checkout
  Marie (specialist: accessibility, mobile) · 9 notes · 4 tickets · in settings
  ```

- **Surface every ticket the moment it lands**, as its own line: `Marie filed [major/accessibility] "Focus trap in the payment modal" — checkout`. The user should be able to stop the run early because the findings already told them enough — that is a feature.
- **Say what changed, not everything again**: after the first roster, lead with deltas (new tickets, testers finished, a straggler warned) and keep the roster compact beneath.
- **Never go dark**: if a poll finds nothing new, one short line ("all four still testing, nothing new since last check") beats silence.

## Running it by hand (any harness)

Where battletest is not built in, orchestrate it directly:

1. **Preflight** (above): target freshness, fixture question, team size.
2. **Create the run directory**: `<project>/.battletest/<yyyymmdd-hhmm>[-focus]/` with `run.md` (personas, focus, status: testing), plus empty `notes/`, `tickets/`, `metrics/`, `clearance/`. Tester scratch (browser profiles, driver files) goes under the OS temp dir, keyed by run and persona.
3. **Deal or design the team** per the sizing rules; record the full team in `run.md`.
4. **Resolve the target once**: if the focus names a URL, every brief says "goto this, launch nothing"; otherwise the briefs carry the project-type table and each tester gets its own port offsets (base + index) and profile directory. Never make ten testers rediscover the same launch command — pre-flight anything shareable. Share *mechanics*, never *opinions*: testers must not see each other's findings mid-run, or independent confirmation dies — the tickets directory is the one deliberate exception, for filing-time dedupe.
5. **Spawn all testers in parallel** as subagents (Task tool, background agents — whatever the harness offers), each with only its filled brief, at low thinking. They write their own diaries and tickets straight into the run directory.
6. **Stay on watch, visibly**: poll the run directory on a short cadence and narrate per the output contract above — roster lines, tickets as they land, deltas between checks. Answer clearance files promptly (deny when in doubt — an unanswered request is a deny after 5 minutes); triage incrementally — mark obvious duplicates while testers still run, so synthesis is mostly done when the last one finishes; and send a budget-breaker or straggler its wrap-up message. If testers start reporting known features as missing, check for a stale build before believing them.
7. **Record the form** when all have returned: for each tester, a severity-weighted score of their non-duplicate tickets (blocker 8, major 4, minor 2, polish 1), actions, tokens, wall clock, and the full brief they ran under — one file per run plus a cumulative log across runs. This is what future team sizing reads; name the strongest tester in the report.
8. **Synthesize** (or when the user stops the run — a stopped run still gets its report from whatever is on disk).

## Synthesis: verify before you believe

Deduplication is not clerical work — it is adversarial reconciliation, and it is where the report earns its trust:

- **Independent duplicates are evidence, not noise.** Seven testers independently filing "the 404 page is a dead end" tells you frequency and severity no single report can. Count them (and the `## Also seen` corroborations) in the canonical ticket before marking duplicates.
- **Cross-examine the clusters.** Real runs produce confident false positives: a "button gives no feedback" cluster that was a screenshot-timing artifact (the flash outlives the click but not the capture cycle), "ghost text through the header" that was headless rendering of backdrop-filter, a "contradiction" that was the tester's own toggle state. Before a finding leads the report, check whether any tester verified the opposite — the skeptic archetype exists for this — and re-test cheap claims yourself. Dismissals go in the report too, labelled *investigated and dismissed*, so nobody re-litigates them later.
- **Honor retractions.** A tester who re-tested and withdrew its own ticket did the method proud; reflect the retraction, don't resurrect the ticket.

Then write `report.md` beside the tickets — **Overview** (what was tested, by whom, for how long), **Findings by severity** (deduped, with how many testers hit each), **Investigated and dismissed**, **Experience by persona** (a capsule each, in their voice), **Run performance** (where the time went — which tool ate the run, whether tools or the model dominated, the strongest tester by score), **Themes**, **Suggested fix order** — and show the user the findings directly in chat: headline issues, themes, what the testers actually said. They must be able to judge the state of the project without opening a single file.

Nothing is fixed during the run; tickets are for later sessions, which mark them `fixed` as they land.

> This skill is harness-agnostic: everything above runs on any agent that can spawn subagents and read files, and the by-hand section is the portable path. Where a harness ships battletest natively, prefer the native implementation and treat this document as its method reference — for example, smolt implements it as the `/battletest` extension (per-tester headless browser, live self-narrated roster, filing-time dedupe with appends, per-action metrics, enforced budgets, performance records, and the clearance loop as tool actions).
