---
name: battletest
description: More than just finding bugs - send a team of simulated users through whatever the project is (web app, desktop app, CLI, TUI, or library) to learn how it actually feels to use. Distinct personas across screen sizes surface bugs, UI inconsistencies, UX friction, performance problems, and bad wording as tickets, folded into one triaged report.
disable-model-invocation: true
---

**More than just finding bugs.** A project's developer cannot use it the way a stranger does, and a test suite cannot tell you the onboarding is confusing, the empty state feels broken, the wording changes tone mid-flow, or the third step of the core journey is where impatient people give up. Battletesting fields a **team of simulated users** — each a subagent with its own persona, temperament, and screen size — who use the project the way real users would, keep a diary of the experience, and file a ticket the moment something is wrong *or merely feels wrong*. When the last tester finishes, the findings are deduped and folded into one report with themes and a suggested fix order: part QA pass, part usability lab, part first-impressions panel.

**Project-agnostic.** Battletest is not just for the web — testers use whatever the project offers:

- **Web app or site**: browsed at real viewports (desktop, phone, tablet), screenshot by screenshot.
- **Desktop/Electron app**: launched with a remote debugging port and driven over CDP.
- **CLI or TUI**: the binary run for real — commands, flags, prompts, help text, first-run experience, error messages under weird input.
- **Library, API, or SDK**: its user is a developer, so the tester becomes one — following the README quickstart in a scratch project, running the documented examples exactly as written, and judging install friction, time to first success, and how the errors read.

Invoked as `/battletest <count> [focus]`: `count` testers (default 3, keep it ≤ 25), and an optional focus — an area to concentrate on, or a hosted URL to test directly instead of launching anything locally.

## The team is dealt, not designed

Real user bases are not deterministic, so neither is the team. Deal personas fresh every run:

- **Archetypes without replacement**, so N testers cover N distinct angles: *first-timer* (onboarding, discoverability), *power-user* (shortcuts, efficiency), *skimmer* (impatient, doesn't read), *auditor* (visual and behavioural consistency), *accessibility-advocate* (keyboard-only, contrast, focus, target sizes), *performance-hawk* (latency, jank, big inputs), *wordsmith* (copy, terminology, truncation, tone), *chaos-monkey* (weird input, interrupted operations, rapid clicking), *everyday-regular* (the happy path done repeatedly, state persistence), *skeptic* (error handling, data integrity, whether feedback tells the truth). A team bigger than the deck repeats archetypes with fresh trait rolls.
- **Traits rolled per tester**: patience (low/medium/high), expertise (novice/comfortable/expert), temperament (forgiving/blunt/exacting), thoroughness (skims/balanced/exhaustive). Give each tester a human name; diaries and tickets should read like a person wrote them.
- **Viewports dealt in a fixed cycle** — desktop, mobile, desktop, tablet — so any run of two or more includes a phone-sized screen and any run of four or more a tablet. Mobile testers do *everything* at an emulated 375x812 with touch; tablet testers at 768x1024; desktop testers still narrow the window at least once mid-session.

## Each tester is a user, not a developer

Spawn each tester as its own subagent with a brief that holds its persona, traits, viewport, and these standing rules:

- **Run it isolated.** Discover how to launch the app from the repo (README, package scripts, launch config) — unless the focus names a hosted target, in which case test that URL directly. Each tester gets its own port offset and its own profile/scratch directory; nothing it writes leaves that directory.
- **See it like a user.** Judge from pixels, not markup: after every navigation and meaningful state change, capture a screenshot (headless browser over CDP: `Page.captureScreenshot`) and actually look at it. Any visual claim in a ticket — misaligned, overlapping, truncated, hidden — must come from a screenshot the tester viewed.
- **Stay in character.** Traits show in what the tester tries, how long it persists, and how findings are phrased. An impatient skimmer abandoning a slow flow *is* the data.
- **Never touch the code.** Testers do not read source to explain problems away, do not fix or work around anything, and never modify the app's files. If it confused the tester, it confused the tester.
- **Record continuously.** A diary note after every meaningful step (what it tried, what it expected, how it went — including what worked), and one ticket per distinct problem, filed the moment it is hit, never batched at the end.

## Tickets

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
```

Steps must let a stranger reproduce the problem without the tester. Severity is honest: blocker = cannot proceed, major = badly hurts the experience, minor = noticeable friction, polish = small but real.

## Safety: self-judged, escalated, never asked of a human

The run is unattended and must never stop for human permission. Testers judge every action before taking it. **Forbidden outright** (never escalated, always denied): buying anything or entering payment details; creating real accounts or entering real credentials or personal data; submitting anything that reaches a real person or service (filling a form to test validation is fine, submitting valid data is not); deleting or corrupting any data the app manages, even where its own UI offers it. Walking to the edge and recording what is there *is* the test — the checkout never placed, the delete dialog never confirmed.

For the gray zone, a **clearance loop**: the tester describes the exact action and its risk to the orchestrating agent and pauses until it rules. The orchestrator judges against the doctrine — allow only actions with no real-world footprint, deny when in doubt — and answers with one line of guidance. An unanswered request denies itself after a timeout so no tester ever hangs.

## The tester brief

Everything above only works if it reaches the testers verbatim: a tester subagent sees nothing but its brief, so the brief IS the method. Use `tester-brief.md` (beside this file) as the template — fill its placeholders per persona and do not soften its rules. The load-bearing parts, in case you are tempted to trim: the in-character trait sentence (it is what makes a skimmer skim), the screenshot-evidence rule (without it testers judge from markup), the two-pass coverage plan with an action budget and a novelty stop rule (without them the slowest tester sets the wall clock), the file-when-you-hit-it ticket rule (batched tickets lose their reproduction steps), and the full safety block.

## Running it by hand (any harness)

Where battletest is not built in, orchestrate it directly:

1. **Create the run directory**: `<project>/.battletest/<yyyymmdd-hhmm>[-focus]/` with `run.md` (personas, focus, status: testing), plus empty `notes/`, `tickets/`, `profiles/`, `clearance/`.
2. **Deal the team**: shuffle the archetype deck and deal without replacement; roll the four traits per tester; assign viewports on the desktop→mobile→desktop→tablet cycle; give each a human name. Record the full team in `run.md`.
3. **Resolve the target once**: if the focus names a URL, every brief says "goto this, launch nothing"; otherwise the briefs carry the project-type table and each tester gets its own port offsets (base + index) and profile directory. Never make ten testers rediscover the same launch command — pre-flight anything shareable. Share *mechanics*, never *opinions*: testers must not see each other's findings mid-run, or independent confirmation dies.
4. **Spawn all testers in parallel** as subagents (Task tool, background agents — whatever the harness offers), each with only its filled brief. They write their own diaries and tickets straight into the run directory.
5. **Stay on watch, usefully**: poll the run directory between checks; surface tickets to the user as they land (persona, severity, title); answer clearance files promptly (deny when in doubt — an unanswered request is a deny after 5 minutes); triage incrementally — mark obvious duplicates while testers still run, so synthesis is mostly done when the last one finishes; and if a straggler drags long after the rest, send it a wrap-up message: file what you have, write the closing note, finish.
6. **Synthesize** when all have returned (or the user stops the run — a stopped run still gets its report from whatever is on disk).

## Synthesis: verify before you believe

Deduplication is not clerical work — it is adversarial reconciliation, and it is where the report earns its trust:

- **Independent duplicates are evidence, not noise.** Seven testers independently filing "the 404 page is a dead end" tells you frequency and severity no single report can. Count them in the canonical ticket before marking duplicates.
- **Cross-examine the clusters.** Real runs produce confident false positives: a "button gives no feedback" cluster that was a screenshot-timing artifact (the flash outlives the click but not the capture cycle), "ghost text through the header" that was headless rendering of backdrop-filter, a "contradiction" that was the tester's own toggle state. Before a finding leads the report, check whether any tester verified the opposite — the skeptic archetype exists for this — and re-test cheap claims yourself. Dismissals go in the report too, labelled *investigated and dismissed*, so nobody re-litigates them later.
- **Honor retractions.** A tester who re-tested and withdrew its own ticket did the method proud; reflect the retraction, don't resurrect the ticket.

Then write `report.md` beside the tickets — **Overview** (what was tested, by whom, for how long), **Findings by severity** (deduped, with how many testers hit each), **Investigated and dismissed**, **Experience by persona** (a capsule each, in their voice), **Themes**, **Suggested fix order** — and show the user the findings directly in chat: headline issues, themes, what the testers actually said. They must be able to judge the state of the project without opening a single file.

Nothing is fixed during the run; tickets are for later sessions, which mark them `fixed` as they land.

> smolt users: this skill is implemented natively as the `/battletest` extension — a per-tester `browse` tool (private headless browser, screenshot per action), storage under `.smolt/battletest/<run>/`, live ticket feed and per-tester action/ticket counters in the TUI, and the clearance loop wired through the `battletest` tool's `wait`/`decide` actions.
