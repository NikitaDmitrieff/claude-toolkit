---
name: ralph-launch
description: "Generate a Ralph loop command from a clear feature description — no brainstorming, straight to prodman artifacts and loop generation. Use when the user already knows exactly what they want and just needs the implementation plan + loop command. Triggers on: 'ralph launch', 'just build it', 'skip brainstorm', or when the user provides a detailed feature description ready for implementation."
---

# Ralph Launch

Skip brainstorming — go straight from a clear feature description to prodman artifacts and a Ralph loop command.

## Process Overview

```
Phase 1: Context   → Quick codebase scan (no questions asked)
Phase 2: Artifacts → Create epic + spec
Phase 3: Launch    → Generate /ralph-wiggum:ralph-loop command
```

## Phase 1: Quick Context Scan

Silently gather context without asking questions. The user already knows what they want.

- Read `.prodman/roadmap.yaml` and recent epics in `.prodman/epics/` for project state
- Explore relevant codebase areas based on the user's description
- Read `CLAUDE.md` and `AGENTS.md` for project conventions

If something is genuinely ambiguous (e.g., conflicting patterns in the codebase, unclear which existing component to extend), ask ONE clarifying question. Otherwise, make reasonable decisions and move on.

## Phase 2: Prodman Artifacts

Create the epic and spec. Follow the exact same format as ralph-planner — see the shared reference:

**Read [the prodman templates](../ralph-planner/references/prodman-templates.md) for exact formats.**

**Steps:**

1. **Read current counters** from `.prodman/config.yaml`
2. **Create epic** at `.prodman/epics/EP-{next}-{slug}.yaml`
3. **Create spec** at `.prodman/specs/SPEC-{next}-{slug}.md`
4. **Update counters** in `.prodman/config.yaml`

**Testing approach:**
- No per-task tests or TDD
- For substantial features: include a final task for e2e/functional tests that mirror real user flows
- For trivial features: no tests needed

## Phase 3: Generate Ralph Loop Command

Generate a `/ralph-wiggum:ralph-loop` command. Follow the exact same template as ralph-planner:

**Read [the prompt template](../ralph-planner/references/prompt-template.md) for the exact structure.**

**Iteration estimate:** Same formula — `(tasks × 2.5) + 3 buffer`, rounded up to nearest 5.

**Codex review:** Off by default. If the user says `--codex` or asks for codex review, include it.

**Output format:**

~~~
Here's your Ralph loop command (~N iterations estimated for X tasks):

```
/ralph-wiggum:ralph-loop "..." --completion-promise "EP-XXX COMPLETE" --max-iterations N
```

**What it will do:**
- [1-line summary per major task group]

**To launch:** Copy the command above and paste it.
**To cancel mid-loop:** `/ralph-wiggum:cancel-ralph`
~~~

## Key Principles

- **No questions unless genuinely ambiguous** — The user said what they want, respect that
- **Speed** — Get to the loop command fast
- **Same quality** — Same spec format, same progress tracking, same best-practices checklist as ralph-planner (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md))
- **YAGNI** — Only plan what was described, no bonus features
