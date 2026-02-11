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
Phase 3: Launch     → Generate PROMPT.md + ralph.sh launch command
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

## Phase 3: Generate PROMPT.md + Launch Command

Generate the prompt file and launch command for the Ralph bash loop.

**Steps:**

1. **Create `PROMPT.md`** at the project root with the full prompt (see [references/prompt-template.md](references/prompt-template.md) for the template)
2. **Generate the launch command** for the user to copy-paste into their terminal

**Iteration estimate:**
- Count the number of tasks in the spec
- Multiply by 2-3 (each task may take multiple iterations)
- Add 2-3 buffer iterations for unexpected issues
- Present: "I estimate ~N iterations based on X tasks. Adjust as needed."

**Completion promise:** Always `EP-{XXX} COMPLETE` (standardized format).

**Codex review flag:** Ask the user if they want the codex review gate enabled. If yes, add the codex steps to PROMPT.md. If no (default), skip it.

**Output format:**

~~~
PROMPT.md has been created at the project root.

**What it will do** (~N iterations estimated for X tasks):
- [1-line summary per major task group]

**To launch**, run this from your terminal:
```bash
cd {absolute project path} && ~/.claude/scripts/ralph.sh --promise "EP-XXX COMPLETE" --max-iterations N
```

**To stop:** Ctrl+C
**To edit the prompt before launching:** Open `PROMPT.md` in your editor.
~~~

## Key Principles

- **Plans are specs** — The spec in `.prodman/specs/` is the single source of truth
- **Progress tracking** — The loop uses `progress.txt` at project root to track completed tasks across iterations
- **Anti-premature-completion** — The prompt has explicit guardrails against outputting `<promise>` before ALL tasks are done
- **Best practices** — The loop runs the shared best-practices checklist (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md)) after implementation: code simplification, artefacts, CLAUDE.md maintenance, convention compliance, YAGNI check, and optional codex review
- **User launches** — Always write PROMPT.md and output the terminal command, never auto-launch
- **Bash loop** — Uses `~/.claude/scripts/ralph.sh` (original Ralph technique), not the broken plugin
