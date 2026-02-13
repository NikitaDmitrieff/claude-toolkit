---
name: ralph-planner
description: "Plan features through collaborative brainstorming, then generate a ready-to-launch Ralph loop command. Use when the user wants to plan AND implement a feature — covers brainstorming, prodman artifact creation (epics/specs), and Ralph loop prompt generation. Triggers on: 'let's build X', 'new feature', 'plan and loop', or any feature request that will need implementation."
---

# Ralph Planner

Three-step workflow: invoke brainstorming skill → create prodman artifacts → generate Ralph loop command.

## Workflow

### STEP 1: Invoke Brainstorming Skill

**Your very first action:**

```
Invoke Skill tool with:
- skill: "superpowers:brainstorming"
- args: "After creating and committing the design document, STOP. Do NOT invoke writing-plans. Ralph-planner will create the prodman artifacts (epic + spec) instead."
```

**What this does:**
- Brainstorming will explore context, ask questions, propose approaches
- It will present a design section by section
- It will create `docs/plans/YYYY-MM-DD-{topic}-design.md`
- It will commit the design doc
- Then it will STOP (not invoke writing-plans)

**After brainstorming completes, continue to STEP 2.**

---

### STEP 2: Create Prodman Artifacts

Once you have the design document from brainstorming, create the epic and spec.

**Actions:**

1. **Read the design document** from `docs/plans/YYYY-MM-DD-{topic}-design.md`
2. **Read current counters** from `.prodman/config.yaml`
3. **Create epic** at `.prodman/epics/EP-{next}-{slug}.yaml`
4. **Create spec** at `.prodman/specs/SPEC-{next}-{slug}.md`
5. **Update counters** in `.prodman/config.yaml` (increment `epic` and `spec`)

**Converting design to spec:**

The spec is a bite-sized task list derived from the design:
- Architecture section → identify components/files to create
- Data flow section → identify integration points
- Testing strategy → create final testing task
- Break into sequential tasks (each = one commit)

**Spec format:** See [references/prodman-templates.md](references/prodman-templates.md)

**Each task MUST include:**
- Exact files to create/modify with paths
- Clear implementation description
- Commit message

**Testing approach:**
- Do NOT require per-task unit tests or TDD
- For substantial features: final task writes e2e/functional tests
- Tests mirror real user flow
- For trivial features: no tests needed

---

### STEP 3: Generate Ralph Loop Command

Generate a `/ralph-wiggum:ralph-loop` command for the user to copy-paste.

**Iteration estimate:**
- Count tasks in spec
- Multiply by 2-3 (buffer for iterations)
- Add 2-3 extra buffer
- Present: "I estimate ~N iterations based on X tasks"

**Completion promise:** Always `EP-{XXX} COMPLETE`

**Codex review:** Ask user if they want codex review gate. If yes, add `WITH CODEX REVIEW` to prompt.

**Prompt structure:** See [references/prompt-template.md](references/prompt-template.md) for exact template.

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
- **Progress tracking** — Loop uses `progress.txt` to track completed tasks
- **Anti-premature-completion** — Explicit guardrails against early `<promise>` output
- **Best practices** — Loop runs shared checklist after implementation (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md))
- **User launches** — Always output command for copy-paste, never auto-launch
