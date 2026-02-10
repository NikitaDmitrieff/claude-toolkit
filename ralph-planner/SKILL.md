---
name: ralph-planner
description: "Plan features through collaborative brainstorming, then generate a ready-to-launch Ralph loop command. Use when the user wants to plan AND implement a feature — covers brainstorming, prodman artifact creation (epics/specs), and Ralph loop prompt generation. Triggers on: 'let's build X', 'new feature', 'plan and loop', or any feature request that will need implementation."
---

# Ralph Planner

Plan features collaboratively, create prodman artifacts, and generate a tailored Ralph loop command.

## Process Overview

```
Phase 1: Brainstorm → Understand what to build
Phase 2: Artifacts  → Create epic + spec (the implementation plan)
Phase 3: Launch     → Generate /ralph-wiggum:ralph-loop command for the user to copy
```

## Phase 1: Brainstorm

Understand the feature through adaptive questioning.

**Start by exploring context:**
- Read `.prodman/roadmap.yaml` and recent epics in `.prodman/epics/` for project state
- Explore relevant codebase areas (files, patterns, existing components)
- Read `CLAUDE.md` and `AGENTS.md` for project conventions

**Adaptive questioning rules:**
- **Ambiguous feature:** One question per message, prefer multiple choice, propose 2-3 approaches with your recommendation
- **Shape becomes clear:** Can ask 2-3 related questions per message, mix open-ended and multiple choice
- **Signal to move on:** When you can describe the feature's scope, files affected, and approach without uncertainty

**Conclude Phase 1 when:**
- Feature scope is clear
- Technical approach is decided
- Files to create/modify are identified
- Edge cases and constraints are understood

## Phase 2: Prodman Artifacts

Create the epic and spec. See [references/prodman-templates.md](references/prodman-templates.md) for exact formats.

**Steps:**

1. **Read current counters** from `.prodman/config.yaml`
2. **Create epic** at `.prodman/epics/EP-{next}-{slug}.yaml`
3. **Create spec** at `.prodman/specs/SPEC-{next}-{slug}.md` — this IS the implementation plan
4. **Update counters** in `.prodman/config.yaml` (increment `epic` and `spec`)

**Spec format:** Bite-sized tasks with exact file paths and commit points. See [references/prodman-templates.md](references/prodman-templates.md) for the full template.

**Each task in the spec MUST include:**
- Exact files to create/modify with paths
- Clear implementation description
- Commit message

**Testing approach (in the spec):**
- Do NOT require per-task unit tests or TDD
- For substantial features: include a final task to write e2e/functional tests that exercise the real user flow
- Tests should be comprehensible to a non-developer — they mirror what a user would actually do
- For trivial features (copy changes, config tweaks, small UI fixes): no tests needed

## Phase 3: Generate Ralph Loop Command

Generate a `/ralph-wiggum:ralph-loop` command the user can copy-paste.

**Iteration estimate:**
- Count the number of tasks in the spec
- Multiply by 2-3 (each task may take multiple iterations)
- Add 2-3 buffer iterations for unexpected issues
- Present: "I estimate ~N iterations based on X tasks. Adjust as needed."

**Completion promise:** Always `EP-{XXX} COMPLETE` (standardized format).

**Codex review flag:** Ask the user if they want the codex review gate enabled. If yes, add `WITH CODEX REVIEW` to the prompt. If no (default), skip it.

**Prompt structure:** See [references/prompt-template.md](references/prompt-template.md) for the exact template.

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

- **Plans are specs** — The spec in `.prodman/specs/` is the single source of truth
- **Progress tracking** — The loop uses `progress.txt` at project root to track completed tasks across iterations
- **Anti-premature-completion** — The prompt has explicit guardrails against outputting `<promise>` before ALL tasks are done
- **Best practices** — The loop runs the shared best-practices checklist (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md)) after implementation: code simplification, artefacts, CLAUDE.md maintenance, convention compliance, YAGNI check, and optional codex review
- **User launches** — Always output the command for copy-paste, never auto-launch
