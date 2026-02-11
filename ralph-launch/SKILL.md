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
Phase 4: Launch    → Generate PROMPT.md + ralph.sh launch command
```

## Phase 1: Quick Context Scan

### Structured Context Discovery (BEFORE questioning)

**Read project foundations (required):**
1. `CLAUDE.md` - Project conventions and architecture overview
2. `.prodman/roadmap.yaml` - Current product state
3. `.prodman/config.yaml` - Current epic/spec counters

**Explore feature domain (strategic):**

Based on the user's feature request, identify the domain:
- Auth/Users → "auth", "user", "session", "login"
- Billing/Payments → "payment", "stripe", "subscription", "checkout"
- Tasks/Content → "{feature-name}", "create", "update", "delete"

Then execute targeted exploration:

```bash
# Step A: Find relevant files
Grep pattern="{domain-keywords}" glob="**/*.{ts,js,tsx,jsx}"
output_mode="files_with_matches"

# Step B: Identify data models
Grep pattern="{Domain}|{domain}" glob="**/schema.prisma"
output_mode="content"
OR
Grep pattern="model {Domain}" glob="**/models/*.ts"
output_mode="content"

# Step C: Find existing patterns
Read the 2-3 most relevant files from Step A to understand:
- How similar features are structured
- State management patterns
- Error handling conventions
- Testing approaches
```

**If CLAUDE.md has "Exploration Hints":** Follow them exactly - the user has pre-defined exploration paths.

**If exploration finds > 10 relevant files OR spans multiple apps:** Use Task tool with subagent_type="Explore" and thoroughness="medium" to get a comprehensive summary.


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

1. **Identify contributor** — determine the contributor's initials (e.g., `ND`, `TB`) from `.prodman/config.yaml`
2. **Read current counters** from `.prodman/config.yaml` under `contributors.{ID}.counters`
3. **Create epic** at `.prodman/epics/EP-{ID}-{next}-{slug}.yaml`
4. **Create spec** at `.prodman/specs/SPEC-{ID}-{next}-{slug}.md`
5. **Update counters** in `.prodman/config.yaml` under the contributor's key

**Testing approach:**
- No per-task tests or TDD
- For substantial features: include a final task for e2e/functional tests that mirror real user flows
- For trivial features: no tests needed

## Phase 4: Generate PROMPT.md + Launch Command

Generate the prompt file and launch command. Follow the exact same template as ralph-planner:

**Read [the prompt template](../ralph-planner/references/prompt-template.md) for the exact structure.**

**Steps:**

1. **Create `.artefacts/{slug}/`** directory (the artefact folder for this epic)
2. **Create `.artefacts/{slug}/PROMPT.md`** with the full prompt
3. **Generate the launch command** with `--dir .artefacts/{slug}` for the user to run in their terminal

**Iteration estimate:** Same formula — `(tasks × 2.5) + 3 buffer`, rounded up to nearest 5.

**Codex review:** Off by default. If the user says `--codex` or asks for codex review, include it.

**Output format:**

~~~
.artefacts/{slug}/PROMPT.md has been created.

**What it will do** (~N iterations estimated for X tasks):
- [1-line summary per major task group]

**To launch**, run this from your terminal:
```bash
cd {absolute project path} && ~/.claude/scripts/ralph.sh --dir .artefacts/{slug} --promise "EP-{ID}-XXX COMPLETE" --max-iterations N
```

**To stop:** Ctrl+C
**To edit the prompt:** Open `.artefacts/{slug}/PROMPT.md`
~~~

## Key Principles

- **Refine, don't brainstorm** — Ask 2-4 targeted questions to sharpen scope, then move on. One round only.
- **Speed** — Get to the loop command fast, the refinement step should take under a minute
- **Same quality** — Same spec format, same artefact-scoped progress tracking, same best-practices checklist as ralph-planner (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md))
- **Bash loop** — Uses `~/.claude/scripts/ralph.sh` (original Ralph technique), not the broken plugin
- **YAGNI** — Only plan what was described, no bonus features
