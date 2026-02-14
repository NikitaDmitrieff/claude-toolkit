---
name: ralph-planner
description: "Plan features through collaborative brainstorming with expert subagents (Product Manager, Architecture, UI/UX), then generate a ready-to-launch Ralph loop command. Creates ultra-detailed specs by combining PRD, architecture, and UI specifications. Use when the user wants to plan AND implement a feature. Triggers on: 'let's build X', 'new feature', 'plan and loop', or any feature request that will need implementation."
---

# Ralph Planner

Five-step workflow: brainstorming → ask contributor → spawn expert subagents → assemble ultra-detailed artifacts → generate Ralph loop command.

**What's new in v2:** 3 expert subagents (Product Manager, Architecture, UI/UX) create PRD, ARCHITECTURE, and UI-SPEC artifacts, which are assembled into specs 3x more detailed than before.

## Workflow

### STEP 0: Parse Arguments and Display Configuration

**Parse the args parameter:**

The skill receives args as a string (e.g., "-b3 -pm4 -arch2 -uiux0").

Extract depth levels:
- `brainstormingDepth` = extract '-b' value, default 5
- `pmLevel` = extract '-pm' value, default 5
- `archLevel` = extract '-arch' value, default 5
- `uiuxLevel` = extract '-uiux' value, default 5

**Parsing logic:**
```javascript
// Pseudo-code for parsing
function extractLevel(args, flag, defaultValue = 5) {
  const match = args.match(new RegExp(`-${flag}(\\d)`))
  if (!match) return defaultValue
  const level = parseInt(match[1])
  if (level < 0 || level > 5) {
    throw new Error(`Invalid level ${level} for -${flag}. Must be 0-5.`)
  }
  return level
}

const brainstormingDepth = extractLevel(args, 'b')
const pmLevel = extractLevel(args, 'pm')
const archLevel = extractLevel(args, 'arch')
const uiuxLevel = extractLevel(args, 'uiux')
```

**Validation:**
- All levels must be 0-5
- If args is empty or undefined, use all defaults (5, 5, 5, 5)
- If invalid level found, show error with syntax reminder:
  ```
  ❌ Invalid level for -{flag}. Must be 0-5.

  Syntax: /ralph-planner [-bN] [-pmN] [-archN] [-uiuxN]
  Where N is 0-5 (0 = disabled for agents, 1-5 = depth level)
  ```

**Display configuration:**

After successful parsing, display to user:

```
🎛️ Ralph Planner Configuration:

Brainstorming depth: {brainstormingDepth}/5
Product Manager: {pmLevel > 0 ? pmLevel + '/5' : '❌ disabled'}
Architecture Expert: {archLevel > 0 ? archLevel + '/5' : '❌ disabled'}
UI/UX Expert: {uiuxLevel > 0 ? uiuxLevel + '/5' : '❌ disabled'}

{if all agents disabled: '⚠️ All agents disabled - spec will be created directly from design.md'}
```

**After displaying config, continue to STEP 1.**

---

### STEP 1: Invoke Brainstorming Skill

**Your very first action:**

```
Invoke Skill tool with:
- skill: "superpowers:brainstorming"
- args: "Depth level: {brainstormingDepth}/5. After creating and committing the design document, STOP. Do NOT invoke writing-plans. Ralph-planner will create the prodman artifacts (epic + spec) instead."
```

**What this does:**
- Brainstorming will run at depth level {brainstormingDepth}/5
- At lower levels (1-2): fewer questions, faster exploration, concise design
- At higher levels (4-5): comprehensive questions, thorough exploration, detailed design
- It will explore context, ask questions, propose approaches
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

### STEP 2: Spawn Expert Subagents (Conditional)

Once you have the design document and contributor info, conditionally spawn expert subagents based on their levels.

**Preparation:**

1. **Read the design document** from `docs/plans/YYYY-MM-DD-{topic}-design.md`
2. **Read current counter** from `.prodman/config.yaml` for the contributor (TB or ND)
3. **Calculate epic ID**: `EP-{CONTRIBUTOR}-{NEXT_NUMBER}` (e.g., `EP-TB-003`)
4. **Extract feature slug** from design.md or epic title
5. **Create artifacts directory**: `.artefacts/{feature-slug}/`

**Track available artifacts:** Start with `[design.md]`

**Actions - Conditionally spawn agents based on levels:**

Each agent section below should only execute if its level > 0.

#### Subagent 1: Product Manager Expert (if pmLevel > 0)

**Check:** If `pmLevel == 0`, skip this agent entirely and proceed to Architecture Expert.

**If pmLevel >= 1, spawn with Task tool:**

- `subagent_type`: "general-purpose"
- `description`: "Create PRD for {feature name} at depth {pmLevel}/5"
- `prompt`: Construct prompt as follows:

**Prompt construction:**
1. Read `ralph-planner/subagents/product-manager-prompt.md`
2. Replace all instances of `{LEVEL}` with the actual `pmLevel` value
3. Pass the resulting prompt to the Task tool

**Input to provide in the prompt:**
- The design.md content
- Epic ID (e.g., `EP-TB-003`)
- Depth level: {pmLevel}/5
- Project context (tech stack, existing features)

**Expected output:**
- `PRD.md` saved to `.artefacts/{feature-slug}/PRD.md`
- Contains: problem statement, success metrics, user stories, acceptance criteria, scope, NFRs
- Detail level scales with pmLevel (1-2 = concise, 3 = standard, 4-5 = comprehensive)

**Inform user:**
```
🤖 Spawning Product Manager expert (depth {pmLevel}/5)...
```

**After completion:**
```
✓ PRD created at .artefacts/{feature-slug}/PRD.md
```

**Update available artifacts:** `[design.md, PRD.md]`

---

#### Subagent 2: Architecture Expert (if archLevel > 0)

**Check:** If `archLevel == 0`, skip this agent entirely and proceed to UI/UX Expert.

**If archLevel >= 1, spawn with Task tool:**

- `subagent_type`: "general-purpose"
- `description`: "Create architecture doc for {feature name} at depth {archLevel}/5"
- `prompt`: Construct prompt as follows:

**Prompt construction:**
1. Read `ralph-planner/subagents/architecture-expert-prompt.md`
2. Replace all instances of `{LEVEL}` with the actual `archLevel` value
3. Pass the resulting prompt to the Task tool

**Input to provide in the prompt:**
- The design.md content
- The PRD.md from Product Manager **if it exists** (check if pmLevel > 0)
  - If PRD exists: include it in context
  - If PRD doesn't exist: note "⚠️ No PRD available. Extract product requirements from design.md directly."
- Epic ID
- Depth level: {archLevel}/5
- Project context (existing architecture, tech stack, database schema)

**Expected output:**
- `ARCHITECTURE.md` saved to `.artefacts/{feature-slug}/ARCHITECTURE.md`
- Contains: ADRs, C4 diagrams, database schema, API specs, NFR coverage, implementation guidance
- Detail level scales with archLevel (1-2 = core only, 3 = standard, 4-5 = comprehensive)

**Inform user:**
```
🤖 Spawning Architecture expert (depth {archLevel}/5)...
{if PRD available: '   Using PRD as input'}
{if no PRD: '   ⚠️ No PRD available, using design.md only'}
```

**After completion:**
```
✓ Architecture document created at .artefacts/{feature-slug}/ARCHITECTURE.md
```

**Update available artifacts:** `[design.md, {PRD.md if exists}, ARCHITECTURE.md]`

---

#### Subagent 3: UI/UX Expert (if uiuxLevel > 0)

**Check:** If `uiuxLevel == 0`, skip this agent entirely and proceed to STEP 3.

**If uiuxLevel >= 1, spawn with Task tool:**

- `subagent_type`: "general-purpose"
- `description`: "Create UI specification for {feature name} at depth {uiuxLevel}/5"
- `prompt`: Construct prompt as follows:

**Prompt construction:**
1. Read `ralph-planner/subagents/ui-ux-expert-prompt.md`
2. Replace all instances of `{LEVEL}` with the actual `uiuxLevel` value
3. Pass the resulting prompt to the Task tool

**Input to provide in the prompt:**
- The design.md content
- The PRD.md from Product Manager **if it exists** (check if pmLevel > 0)
- The ARCHITECTURE.md from Architecture Expert **if it exists** (check if archLevel > 0)
- Epic ID
- Depth level: {uiuxLevel}/5
- Project context (existing design system, UI framework)

**Context notes to include:**
- If both PRD and ARCHITECTURE exist: "You have full context from PM and Architecture experts."
- If only PRD exists: "⚠️ No architecture doc available. Infer technical constraints from design.md."
- If only ARCHITECTURE exists: "⚠️ No PRD available. Extract user requirements from design.md."
- If neither exists: "⚠️ No PRD or Architecture docs. Use design.md as sole source."

**Expected output:**
- `UI-SPEC.md` saved to `.artefacts/{feature-slug}/UI-SPEC.md`
- Contains: design tokens, component library, accessibility requirements, responsive design, interaction flows
- Detail level scales with uiuxLevel (1-2 = essentials, 3 = standard, 4-5 = comprehensive)

**Inform user:**
```
🤖 Spawning UI/UX expert (depth {uiuxLevel}/5)...
{list which docs are available as input}
```

**After completion:**
```
✓ UI specification created at .artefacts/{feature-slug}/UI-SPEC.md
```

**Update available artifacts:** `[design.md, {PRD.md if exists}, {ARCHITECTURE.md if exists}, UI-SPEC.md]`

---

**Execution Strategy:**

- **Sequential execution recommended** (not parallel) to allow each expert to build on previous work:
  1. Product Manager first (if enabled) - defines WHAT and WHY
  2. Architecture Expert second (if enabled) - defines HOW (technical), uses PRD if available
  3. UI/UX Expert third (if enabled) - defines HOW (interface), uses PRD and/or ARCHITECTURE if available

- **Agents handle missing inputs:** Each agent can work with design.md alone if previous agents were disabled

- **Inform user** while subagents are working (examples):
  ```
  🎛️ Configuration: PM 4/5, Arch 3/5, UI/UX 0 (disabled)

  🤖 Spawning Product Manager expert (depth 4/5)...
  ✓ PRD created
  🤖 Spawning Architecture expert (depth 3/5)...
     Using PRD as input
  ✓ Architecture document created
  ⏭️ Skipping UI/UX expert (disabled)
  ```

**After all enabled subagents complete, continue to STEP 3.**

---

### STEP 3: Assemble Ultra-Detailed Artifacts (Adaptive)

Now assemble epic and spec files from ALL available artifacts.

**Adaptive strategy:** Epic and spec detail will scale based on which artifacts were created.

**Actions:**

1. **Collect all available artifacts:**

   Start with base: `design.md` (always present)

   Check and add if they exist:
   - `PRD.md` (exists if pmLevel > 0)
   - `ARCHITECTURE.md` (exists if archLevel > 0)
   - `UI-SPEC.md` (exists if uiuxLevel > 0)

   Track which artifacts are available for assembly.

2. **Create epic** at `.prodman/epics/EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml`

**Epic format:** See [references/prodman-templates.md](references/prodman-templates.md)

**Adaptive assembly based on available artifacts:**

**Base (from design.md - always available):**
- **title**: Extract from design
- **description**: Problem statement from design
- **labels**: Basic labels from tech mentioned in design

**+ PRD (if pmLevel > 0):**
- **description**: Enhance with problem statement from PRD (more detailed)
- **acceptance_criteria**: Use structured criteria from PRD, organized by category
- **labels**: Add priority labels based on MoSCoW from PRD

**+ ARCHITECTURE (if archLevel > 0):**
- **technical_scope**: Extract components, APIs, database tables from ARCHITECTURE
- **labels**: Add tech stack labels from ARCHITECTURE (e.g., react, typescript, postgresql)

**+ UI-SPEC (if uiuxLevel > 0):**
- **labels**: Add UI framework labels from UI-SPEC (e.g., tailwind, shadcn-ui, accessibility)

**Result:** Epic detail scales with available artifacts.

3. **Create spec** at `.prodman/specs/SPEC-{CONTRIBUTOR}-{NUMBER}-{slug}.md`

**Spec format:** See [references/prodman-templates.md](references/prodman-templates.md) for template.

**Adaptive task synthesis based on available artifacts:**

For each task in the spec, synthesize information from available sources.

**Base task structure (from design.md only):**
```markdown
### Task N: {Component/Feature Name}

**Files:**
- Create: `{paths from design}`

**Implementation Steps:**
1. {High-level steps from design}

**Commit:** `feat({scope}): {description}`
```

**Enhanced with PRD (if available):**
Add to each task:
```markdown
**Product Requirements (from PRD.md):**
{Relevant user stories and acceptance criteria for this task}
{Success metrics this task contributes to}
```

**Enhanced with ARCHITECTURE (if available):**
Add to each task:
```markdown
**Architecture Context (from ARCHITECTURE.md):**
{Relevant component design, API contracts, data models}
{Architecture decisions (ADRs) affecting this task}
{Data flow and integration points}
```

**Enhanced with UI-SPEC (if available):**
Add to each task:
```markdown
**UI Specification (from UI-SPEC.md):**
- Layout: {Component layout and structure}
- States: {loading, error, success states}
- Interactions: {User interactions and flows}
- Design Tokens: {Specific tokens to use}
- Accessibility: {WCAG requirements, ARIA labels}
```

**Example - Full task with all artifacts:**
```markdown
### Task 3: Create UserProfileCard Component

**Files:**
- Create: `src/components/UserProfileCard/UserProfileCard.tsx`
- Create: `src/components/UserProfileCard/UserProfileCard.styles.ts`
- Create: `src/components/UserProfileCard/types.ts`

**Product Requirements (from PRD.md):**
Fulfills user story US-2: "As a user, I want to see other users' profiles..."
Must display user online status in real-time (AC-2.1), support accessibility,
and meet performance target of < 1s status update latency.

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

**Implementation Steps:**
1. Create type definitions in types.ts (User, ProfileCardProps)
2. Implement component structure in UserProfileCard.tsx
3. Add styled-components in .styles.ts using design tokens
4. Wire up UserService.subscribe() for real-time updates
5. Add ARIA labels for screen readers
6. Test with keyboard navigation and screen reader

**Commit:** `feat(profile): add UserProfileCard component with real-time status`
```

**Example - Minimal task (design.md only, all agents disabled):**
```markdown
### Task 3: Create UserProfileCard Component

**Files:**
- Create: `src/components/UserProfileCard.tsx`

**Implementation Steps:**
1. Create component with basic user info display
2. Add styling
3. Test component renders correctly

**Commit:** `feat(profile): add UserProfileCard component`
```

**Task breakdown sources:**
- **From design.md**: High-level features → tasks
- **From PRD** (if available): User stories → features → tasks, acceptance criteria → verification
- **From ARCHITECTURE** (if available): File structure, component boundaries, API endpoints, database tables
- **From UI-SPEC** (if available): Component states, design tokens, accessibility, responsive behavior

**Testing approach:**
- Do NOT require per-task unit tests or TDD
- For substantial features: final task writes e2e/functional tests
- Tests mirror real user flow from PRD user stories (if PRD available)
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

### STEP 4: Generate Ralph Loop Command (Dynamic)

Generate a `/ralph-wiggum:ralph-loop` command that references only the artifacts that were created.

**Iteration estimate:**
- Count tasks in spec
- Multiply by 2-3 (buffer for iterations)
- Add 2-3 extra buffer
- Present: "I estimate ~N iterations based on X tasks"

**Completion promise:** Always `EP-{CONTRIBUTOR}-{NUMBER} COMPLETE` (e.g., `EP-TB-003 COMPLETE`)

**Codex review:** Ask user if they want codex review gate. If yes, add `WITH CODEX REVIEW` to prompt.

**Prompt structure (adaptive):**

Build the prompt dynamically based on which artifacts exist.

**Base template:** See [references/prompt-template.md](references/prompt-template.md) for full template.

**Adaptive context section:**

The "EXPERT ARTIFACTS" section should only reference files that exist:

```
EXPERT ARTIFACTS (reference during implementation):
{{IF PRD.md exists (pmLevel > 0)}}
- PRD: {absolute path to .artefacts/{feature-slug}/PRD.md}
{{END}}
{{IF ARCHITECTURE.md exists (archLevel > 0)}}
- Architecture: {absolute path to .artefacts/{feature-slug}/ARCHITECTURE.md}
{{END}}
{{IF UI-SPEC.md exists (uiuxLevel > 0)}}
- UI Spec: {absolute path to .artefacts/{feature-slug}/UI-SPEC.md}
{{END}}

{{IF at least one artifact exists}}
These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.
{{ELSE}}
Note: No expert artifacts available. Refer to the spec and design document for guidance.
{{END}}
```

**Example scenarios:**

| Config | Context section |
|--------|----------------|
| All agents enabled (5,5,5) | All 3 artifacts referenced (current behavior) |
| PM + Arch only (pm:4, arch:3, uiux:0) | Only PRD and Architecture referenced |
| PM only (pm:3, arch:0, uiux:0) | Only PRD referenced |
| No agents (pm:0, arch:0, uiux:0) | "No expert artifacts available" note |

**Implementation in prompt construction:**

```javascript
// Build context section dynamically
let expertArtifacts = []

if (pmLevel > 0) {
  expertArtifacts.push(`- PRD: ${absolutePath}/.artefacts/${featureSlug}/PRD.md`)
}
if (archLevel > 0) {
  expertArtifacts.push(`- Architecture: ${absolutePath}/.artefacts/${featureSlug}/ARCHITECTURE.md`)
}
if (uiuxLevel > 0) {
  expertArtifacts.push(`- UI Spec: ${absolutePath}/.artefacts/${featureSlug}/UI-SPEC.md`)
}

let contextSection
if (expertArtifacts.length > 0) {
  contextSection = `EXPERT ARTIFACTS (reference during implementation):
${expertArtifacts.join('\n')}

These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.`
} else {
  contextSection = `Note: No expert artifacts available. Refer to the spec and design document for guidance.`
}

// Insert contextSection into prompt template
finalPrompt = promptTemplate.replace('{{EXPERT_ARTIFACTS}}', contextSection)
```

**Save the prompt:**

Before displaying to user, save the complete prompt to `.artefacts/{feature-slug}/PROMPT.md`:

Write the finalPrompt content directly (without markdown wrapper):

```
{The complete finalPrompt content - the actual prompt that will be piped to Claude}
```

This file is used by ralph.sh to execute the implementation loop.

**Output format:**

~~~
Here's your Ralph loop command (~N iterations estimated for X tasks):

```bash
./ralph.sh --dir .artefacts/{feature-slug} --promise "EP-{CONTRIBUTOR}-{NUMBER} COMPLETE" --max-iterations N
```

**What it will do:**
- [1-line summary per major task group]

**Expert artifacts available:**
{List which artifacts were created and will be available during implementation}
- {if PRD: "✓ Product requirements (PRD.md)"}
- {if ARCH: "✓ Architecture document (ARCHITECTURE.md)"}
- {if UI-SPEC: "✓ UI/UX specification (UI-SPEC.md)"}
- {if none: "⚠️ No expert artifacts (design.md only)"}

**Files created:**
- Epic: `.prodman/epics/EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml`
- Spec: `.prodman/specs/SPEC-{CONTRIBUTOR}-{NUMBER}-{slug}.md`
- Prompt: `.artefacts/{feature-slug}/PROMPT.md`
- Artifacts: `.artefacts/{feature-slug}/` (PRD, ARCHITECTURE, UI-SPEC if created)

**To launch:** Copy the command above and paste it in your terminal.
**To stop:** Press Ctrl+C
~~~

## Key Principles

- **Plans are specs** — The spec in `.prodman/specs/` is the single source of truth
- **Progress tracking** — Loop uses `progress.txt` to track completed tasks
- **Anti-premature-completion** — Explicit guardrails against early `<promise>` output
- **Best practices** — Loop runs shared checklist after implementation (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md))
- **User launches** — Always output command for copy-paste, never auto-launch
