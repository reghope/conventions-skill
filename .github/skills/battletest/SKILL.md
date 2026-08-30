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

## Orchestration and the report

The orchestrating agent dispatches the team, then stays on watch: it surfaces each ticket as it lands (persona, severity, title), tracks per-tester activity (actions taken, tickets filed), and rules on clearance requests promptly. When every tester has finished:

1. Read every diary and any ticket bodies needed in full.
2. Dedupe: where testers hit the same underlying issue, keep the clearest ticket and mark the rest duplicates pointing at it.
3. Write `report.md` beside the tickets: **Overview** (what was tested, by whom), **Experience by persona** (a short capsule each, in their voice), **Findings by severity** (every non-duplicate ticket, one line each), **Themes** (patterns recurring across testers), **Suggested fix order**.
4. Show the user the findings directly — headline issues, themes, what the testers actually said — so they can judge the state of the app without opening a single file.

Nothing is fixed during the run; tickets are for later sessions, which mark them `fixed` as they land.

> smolt users: this skill is implemented natively as the `/battletest` extension — storage under `.smolt/battletest/<run>/`, live ticket feed and per-tester counters in the TUI, and the clearance loop wired through the `battletest` tool's `wait`/`decide` actions.
