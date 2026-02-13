---
name: ralph-planner
description: "Plan features through collaborative brainstorming with expert subagents (Product Manager, Architecture, UI/UX), then generate a ready-to-launch Ralph loop command. Creates ultra-detailed specs by combining PRD, architecture, and UI specifications. Use when the user wants to plan AND implement a feature. Triggers on: 'let's build X', 'new feature', 'plan and loop', or any feature request that will need implementation."
---

# Ralph Planner

Five-step workflow: brainstorming → ask contributor → spawn expert subagents → assemble ultra-detailed artifacts → generate Ralph loop command.

**What's new in v2:** 3 expert subagents (Product Manager, Architecture, UI/UX) create PRD, ARCHITECTURE, and UI-SPEC artifacts, which are assembled into specs 3x more detailed than before.

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

**After brainstorming completes, continue to STEP 1.5.**

---

### STEP 1.5: Ask Contributor

**Before spawning subagents, ask the user:**

"Who is creating this epic? (TB or ND)"

**Wait for user response.**

**What this determines:**
- Which counter to use from `.prodman/config.yaml`
- Epic/spec filename format: `EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml`
- Example: If user says "TB" and counter is 2, next epic will be `EP-TB-003`

**After getting contributor, continue to STEP 2.**

---

### STEP 2: Spawn Expert Subagents

Once you have the design document and contributor info, spawn 3 expert subagents to create detailed specifications.

**Preparation:**

1. **Read the design document** from `docs/plans/YYYY-MM-DD-{topic}-design.md`
2. **Read current counter** from `.prodman/config.yaml` for the contributor (TB or ND)
3. **Calculate epic ID**: `EP-{CONTRIBUTOR}-{NEXT_NUMBER}` (e.g., `EP-TB-003`)
4. **Create artifacts directory**: `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/`

**Actions - Spawn 3 subagents using Task tool:**

You MUST spawn all 3 subagents to create the expert specifications.

#### Subagent 1: Product Manager Expert

**Spawn with Task tool:**
- `subagent_type`: "general-purpose"
- `description`: "Create PRD for {feature name}"
- `prompt`: Read and use the full prompt from `ralph-planner/subagents/product-manager-prompt.md`

**Input to provide:**
- The design.md content
- Epic ID (e.g., `EP-TB-003`)
- Project context (tech stack, existing features)

**Expected output:**
- `PRD.md` saved to `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/PRD.md`
- Contains: problem statement, success metrics, user stories, acceptance criteria, scope, NFRs

---

#### Subagent 2: Architecture Expert

**Spawn with Task tool:**
- `subagent_type`: "general-purpose"
- `description`: "Create architecture doc for {feature name}"
- `prompt`: Read and use the full prompt from `ralph-planner/subagents/architecture-expert-prompt.md`

**Input to provide:**
- The design.md content
- The PRD.md from Product Manager (wait for it to complete first)
- Epic ID
- Project context (existing architecture, tech stack, database schema)

**Expected output:**
- `ARCHITECTURE.md` saved to `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/ARCHITECTURE.md`
- Contains: ADRs, C4 diagrams, database schema, API specs, NFR coverage, implementation guidance

---

#### Subagent 3: UI/UX Expert

**Spawn with Task tool:**
- `subagent_type`: "general-purpose"
- `description`: "Create UI specification for {feature name}"
- `prompt`: Read and use the full prompt from `ralph-planner/subagents/ui-ux-expert-prompt.md`

**Input to provide:**
- The design.md content
- The PRD.md from Product Manager
- The ARCHITECTURE.md from Architecture Expert
- Epic ID
- Project context (existing design system, UI framework)

**Expected output:**
- `UI-SPEC.md` saved to `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/UI-SPEC.md`
- Contains: design tokens, component library, accessibility requirements, responsive design, interaction flows

---

**Execution Strategy:**

- **Sequential execution recommended** (not parallel) to allow each expert to build on previous work:
  1. Product Manager first (defines WHAT and WHY)
  2. Architecture Expert second (defines HOW - technical)
  3. UI/UX Expert third (defines HOW - interface)

- **Inform user** while subagents are working:
  ```
  🤖 Spawning Product Manager expert...
  ✓ PRD created
  🤖 Spawning Architecture expert...
  ✓ Architecture document created
  🤖 Spawning UI/UX expert...
  ✓ UI specification created
  ```

**After all 3 subagents complete, continue to STEP 3.**

---

### STEP 3: Assemble Ultra-Detailed Artifacts

Now that you have PRD, ARCHITECTURE, and UI-SPEC, assemble them into epic and spec files.

**Actions:**

1. **Read the 3 expert artifacts:**
   - `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/PRD.md`
   - `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/ARCHITECTURE.md`
   - `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/UI-SPEC.md`

2. **Create epic** at `.prodman/epics/EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml`

**Epic format:** See [references/prodman-templates.md](references/prodman-templates.md)

**Enhancements from expert artifacts:**
- **description**: Use problem statement from PRD
- **technical_scope**: Extract from ARCHITECTURE (components, APIs, database)
- **acceptance_criteria**: Use from PRD, organized by category
- **labels**: Add based on tech stack from ARCHITECTURE and UI framework from UI-SPEC

3. **Create spec** at `.prodman/specs/SPEC-{CONTRIBUTOR}-{NUMBER}-{slug}.md`

**Spec format:** See [references/prodman-templates.md](references/prodman-templates.md) for enhanced template.

**Converting artifacts to ultra-detailed spec:**

For each task in the spec, synthesize information from all 3 artifacts:

**Example Task Structure:**
```markdown
### Task 3: Create UserProfileCard Component

**Files:**
- Create: `src/components/UserProfileCard/UserProfileCard.tsx`
- Create: `src/components/UserProfileCard/UserProfileCard.styles.ts`
- Create: `src/components/UserProfileCard/types.ts`

**Architecture Context (from ARCHITECTURE.md):**
This component is part of the Profile module, implements the Observer pattern
for real-time updates, and uses the UserService API contract defined in
services/user.ts. Data flow: API → Cache → Component state.

**UI Specification (from UI-SPEC.md):**
- Layout: Card with avatar (64px), name, status badge
- States: loading, error, success
- Interactions: Click opens profile modal, hover shows tooltip
- Design Tokens: spacing-md, color-primary-500, shadow-sm
- Accessibility: ARIA labels required, WCAG 2.1 AA contrast

**Product Requirements (from PRD.md):**
Must display user online status in real-time (AC-2.1), support accessibility,
and meet performance target of < 1s status update latency.

**Implementation Steps:**
1. Create type definitions in types.ts (User, ProfileCardProps)
2. Implement component structure in UserProfileCard.tsx
3. Add styled-components in .styles.ts using design tokens from UI-SPEC
4. Wire up UserService.subscribe() for real-time updates (from ARCHITECTURE)
5. Add ARIA labels for screen readers (from UI-SPEC accessibility)
6. Test with keyboard navigation and screen reader

**Commit:** `feat(profile): add UserProfileCard component with real-time status`
```

**Task breakdown strategy:**
- **From ARCHITECTURE**: File structure, component boundaries, API endpoints, database tables
- **From UI-SPEC**: Component states, design tokens, accessibility requirements, responsive behavior
- **From PRD**: User stories → features → tasks, acceptance criteria → verification steps

**Testing approach:**
- Do NOT require per-task unit tests or TDD
- For substantial features: final task writes e2e/functional tests
- Tests mirror real user flow from PRD user stories
- For trivial features: no tests needed

4. **Update counters** in `.prodman/config.yaml`

Increment the counter for the contributor:
```yaml
contributors:
  {CONTRIBUTOR}:
    counters:
      epic: {previous + 1}
      spec: {previous + 1}
```

**After creating epic and spec, continue to STEP 4.**

---

### STEP 4: Generate Ralph Loop Command

Generate a `/ralph-wiggum:ralph-loop` command for the user to copy-paste.

**Iteration estimate:**
- Count tasks in spec
- Multiply by 2-3 (buffer for iterations)
- Add 2-3 extra buffer
- Present: "I estimate ~N iterations based on X tasks"

**Completion promise:** Always `EP-{CONTRIBUTOR}-{NUMBER} COMPLETE` (e.g., `EP-TB-003 COMPLETE`)

**Codex review:** Ask user if they want codex review gate. If yes, add `WITH CODEX REVIEW` to prompt.

**Prompt structure:** See [references/prompt-template.md](references/prompt-template.md) for exact template.

**Output format:**

~~~
Here's your Ralph loop command (~N iterations estimated for X tasks):

```
/ralph-wiggum:ralph-loop "..." --completion-promise "EP-{CONTRIBUTOR}-{NUMBER} COMPLETE" --max-iterations N
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
