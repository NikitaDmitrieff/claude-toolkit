---
name: ralph-launch
description: "Generate a Ralph loop command from a feature description — quick refinement questions, then straight to prodman artifacts and loop generation. Use when the user has a clear idea and just needs the implementation plan + loop command. Triggers on: 'ralph launch', 'just build it', 'skip brainstorm', or when the user provides a feature description ready for implementation."
---

# Ralph Launch

Quick refinement, then straight from feature description to prodman artifacts and a Ralph loop command. No full brainstorm — just enough questions to nail the spec.

## Process Overview

```
Phase 1: Context   → Quick codebase scan
Phase 2: Refine    → 2-4 targeted questions to sharpen the feature
Phase 3: Artifacts → Create epic + spec
Phase 4: Launch    → Generate /ralph-wiggum:ralph-loop command
```

## Phase 1: Quick Context Scan

Gather context to inform your refinement questions.

- Read `.prodman/roadmap.yaml` and recent epics in `.prodman/epics/` for project state
- Explore relevant codebase areas based on the user's description
- Read `CLAUDE.md` and `AGENTS.md` for project conventions

## Phase 2: Refinement Questions

Ask **2-4 targeted questions** using AskUserQuestion to sharpen what the user wants. Focus on things that would materially change the implementation:

- **Scope boundaries** — What's in vs. out? (e.g., "Should this also handle X or just Y?")
- **Key UX/behavior decisions** — How should it work from the user's perspective? (e.g., "Inline editing or modal?")
- **Integration points** — Where does this connect to existing features? (e.g., "Should this update the dashboard too?")
- **Edge cases that affect architecture** — Only if they'd change the technical approach

**Rules:**
- Keep it to ONE round of questions (no back-and-forth)
- Don't ask about things you can infer from the codebase or conventions
- Don't ask about implementation details you can decide yourself
- If the user's description is already very detailed, you can skip to Phase 3 with a brief confirmation instead

## Phase 3: Prodman Artifacts

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

## Phase 4: Generate Ralph Loop Command

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

- **Refine, don't brainstorm** — Ask 2-4 targeted questions to sharpen scope, then move on. One round only.
- **Speed** — Get to the loop command fast, the refinement step should take under a minute
- **Same quality** — Same spec format, same progress tracking, same best-practices checklist as ralph-planner (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md))
- **YAGNI** — Only plan what was described, no bonus features
