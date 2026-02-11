---
name: ralph-launch
description: "Generate a Ralph loop command from a feature description — quick refinement questions, then straight to prodman artifacts and loop generation. Use when the user has a clear idea and just needs the implementation plan + loop command. Triggers on: 'ralph launch', 'just build it', 'skip brainstorm', or when the user provides a feature description ready for implementation."
---

# Ralph Launch

Quick refinement, then straight from feature description to prodman artifacts and a Ralph loop command. No full brainstorm — just enough questions to nail the spec.

## Process Overview

```
Phase 1: Context   → Structured context discovery (same as ralph-planner, but faster)
Phase 2: Refine    → 2-4 targeted questions to sharpen the feature
Phase 3: Artifacts → Create epic + spec
Phase 4: Launch    → Generate /ralph-wiggum:ralph-loop command
```

## Phase 1: Structured Context Discovery

Gather context to inform your refinement questions. Use the same structured approach as ralph-planner, but prioritize speed.

### Step 1: Read project foundations (required)

1. `CLAUDE.md` - Project conventions and architecture overview
2. `.prodman/roadmap.yaml` - Current product state
3. `.prodman/config.yaml` - Current epic/spec counters

### Step 2: Explore feature domain (strategic but fast)

Based on the user's feature request, identify the domain:
- Auth/Users → "auth", "user", "session", "login"
- Billing/Payments → "payment", "stripe", "subscription", "checkout"
- Tasks/Content → "{feature-name}", "create", "update", "delete"

Then execute **targeted exploration**:

```bash
# Step A: Find relevant files
Grep pattern="{domain-keywords}" glob="**/*.{ts,js,tsx,jsx}"
output_mode="files_with_matches"

# Step B: Identify data models (if relevant)
Grep pattern="{Domain}|{domain}" glob="**/schema.prisma"
output_mode="content"
OR
Grep pattern="model {Domain}" glob="**/models/*.ts"
output_mode="content"

# Step C: Read 1-2 most relevant files to understand patterns
Read the top 1-2 files from Step A to understand:
- How similar features are structured
- State management patterns
- Error handling conventions
```

**If CLAUDE.md has "Exploration Hints":** Follow them exactly.

**If exploration finds > 10 relevant files:** Use Task tool with subagent_type="Explore" and thoroughness="quick" to get a focused summary.

## Phase 2: Refinement Questions

**Now that you have context**, ask **2-4 targeted questions** using AskUserQuestion to sharpen what the user wants. Focus on things that would materially change the implementation:

- **Scope boundaries** — What's in vs. out? (e.g., "Should this also handle X or just Y?")
- **Key UX/behavior decisions** — How should it work from the user's perspective? (e.g., "Inline editing or modal?")
- **Integration points** — Where does this connect to existing features? (e.g., "Should this update the dashboard too?")
- **Edge cases that affect architecture** — Only if they'd change the technical approach

**Rules:**
- Keep it to ONE round of questions (no back-and-forth)
- Don't ask about things you already learned from the context discovery
- Don't ask about implementation details you can decide yourself
- If the user's description is already very detailed, you can skip to Phase 3 with a brief confirmation instead

**Conclude Phase 2 when:**
- Feature scope is clear enough to write a detailed spec
- Technical approach aligns with existing patterns from your context discovery
- Files to create/modify are identified

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

- **Structured discovery** — Use the same structured context discovery as ralph-planner (read foundations, explore domain strategically), but prioritize speed (read 1-2 files vs 2-3, use thoroughness="quick" for Explore agent)
- **Refine, don't brainstorm** — Ask 2-4 targeted questions informed by your context discovery to sharpen scope, then move on. One round only.
- **Speed** — Get to the loop command fast. Context discovery should be focused and strategic, refinement should take under a minute.
- **Same quality** — Same spec format, same progress tracking, same best-practices checklist as ralph-planner (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md))
- **YAGNI** — Only plan what was described, no bonus features
