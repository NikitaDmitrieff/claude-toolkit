# Ralph Planner Parameterization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add flexible parameterization to ralph-planner for controlling brainstorming depth and expert agent levels

**Architecture:** Parse arguments in SKILL.md STEP 0, conditionally spawn agents in STEP 2 based on levels, adaptively assemble artifacts in STEP 3, generate dynamic Ralph loop prompt in STEP 4. Add calibration sections to all 3 agent prompts.

**Tech Stack:** Markdown (SKILL.md, agent prompts), template system (prompt-template.md)

---

## Task 1: Add Argument Parsing to SKILL.md

**Files:**
- Modify: `ralph-planner/SKILL.md:1-50`

**What:** Add new STEP 0 that parses arguments and displays configuration to user.

**Step 1: Add STEP 0 section**

Insert after the header section (before current STEP 1):

```markdown
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
```

**Step 2: Update step numbering**

Renumber all subsequent steps:
- Current STEP 1 → STEP 1 (stays same)
- Current STEP 1.5 → STEP 1.5 (stays same)
- Current STEP 2 → STEP 2 (stays same)
- Current STEP 3 → STEP 3 (stays same)
- Current STEP 4 → STEP 4 (stays same)

(No renumbering needed, just insert STEP 0 before STEP 1)

**Step 3: Commit**

```bash
git add ralph-planner/SKILL.md
git commit -m "feat(ralph-planner): add STEP 0 for argument parsing

Add argument parsing logic to extract depth levels from args.
Validates levels (0-5) and displays configuration to user.
Defaults to 5 for all parameters if not specified."
```

---

## Task 2: Modify STEP 1 - Brainstorming with Depth

**Files:**
- Modify: `ralph-planner/SKILL.md:14-32`

**What:** Pass brainstorming depth level to the brainstorming skill invocation.

**Step 1: Update brainstorming invocation**

Replace the current STEP 1 invocation instructions with:

```markdown
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
```

**Step 2: Commit**

```bash
git add ralph-planner/SKILL.md
git commit -m "feat(ralph-planner): pass depth level to brainstorming skill

Brainstorming now receives depth level and adjusts its behavior:
- Fewer/more questions based on depth
- Design document detail scales with depth"
```

---

## Task 3: Modify STEP 2 - Conditional Agent Spawning

**Files:**
- Modify: `ralph-planner/SKILL.md:52-142`

**What:** Make agent spawning conditional based on level (0 = skip, 1-5 = spawn with depth).

**Step 1: Update STEP 2 header and intro**

Replace current STEP 2 header section with:

```markdown
### STEP 2: Spawn Expert Subagents (Conditional)

Once you have the design document and contributor info, conditionally spawn expert subagents based on their levels.

**Preparation:**

1. **Read the design document** from `docs/plans/YYYY-MM-DD-{topic}-design.md`
2. **Read current counter** from `.prodman/config.yaml` for the contributor (TB or ND)
3. **Calculate epic ID**: `EP-{CONTRIBUTOR}-{NEXT_NUMBER}` (e.g., `EP-TB-003`)
4. **Create artifacts directory**: `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/`

**Track available artifacts:** Start with `[design.md]`

**Actions - Conditionally spawn agents based on levels:**

Each agent section below should only execute if its level > 0.
```

**Step 2: Update Product Manager section**

Replace the current PM section with:

```markdown
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
- `PRD.md` saved to `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/PRD.md`
- Contains: problem statement, success metrics, user stories, acceptance criteria, scope, NFRs
- Detail level scales with pmLevel (1-2 = concise, 3 = standard, 4-5 = comprehensive)

**Inform user:**
```
🤖 Spawning Product Manager expert (depth {pmLevel}/5)...
```

**After completion:**
```
✓ PRD created at .prodman/artifacts/{epic}/PRD.md
```

**Update available artifacts:** `[design.md, PRD.md]`
```

**Step 3: Update Architecture Expert section**

Replace the current Arch section with:

```markdown
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
- `ARCHITECTURE.md` saved to `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/ARCHITECTURE.md`
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
✓ Architecture document created at .prodman/artifacts/{epic}/ARCHITECTURE.md
```

**Update available artifacts:** `[design.md, {PRD.md if exists}, ARCHITECTURE.md]`
```

**Step 4: Update UI/UX Expert section**

Replace the current UI/UX section with:

```markdown
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
- `UI-SPEC.md` saved to `.prodman/artifacts/EP-{ID}-{NUM}-{slug}/UI-SPEC.md`
- Contains: design tokens, component library, accessibility requirements, responsive design, interaction flows
- Detail level scales with uiuxLevel (1-2 = essentials, 3 = standard, 4-5 = comprehensive)

**Inform user:**
```
🤖 Spawning UI/UX expert (depth {uiuxLevel}/5)...
{list which docs are available as input}
```

**After completion:**
```
✓ UI specification created at .prodman/artifacts/{epic}/UI-SPEC.md
```

**Update available artifacts:** `[design.md, {PRD.md if exists}, {ARCHITECTURE.md if exists}, UI-SPEC.md]`
```

**Step 5: Update execution strategy note**

Replace current execution strategy with:

```markdown
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
```

**Step 6: Commit**

```bash
git add ralph-planner/SKILL.md
git commit -m "feat(ralph-planner): add conditional agent spawning in STEP 2

Agents now spawn only if level > 0.
Each agent receives available artifacts from previous agents.
Agents can handle missing inputs (fall back to design.md).
User informed about which agents run and their depth levels."
```

---

## Task 4: Modify STEP 3 - Adaptive Artifact Assembly

**Files:**
- Modify: `ralph-planner/SKILL.md:145-233`

**What:** Make epic and spec assembly adaptive based on which artifacts are available.

**Step 1: Update STEP 3 header**

Replace current STEP 3 intro with:

```markdown
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
```

**Step 2: Update epic creation section**

Replace the current epic creation instructions with:

```markdown
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
```

**Step 3: Update spec creation section**

Replace current spec creation instructions with:

```markdown
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
```

**Step 4: Commit**

```bash
git add ralph-planner/SKILL.md
git commit -m "feat(ralph-planner): add adaptive artifact assembly in STEP 3

Epic and spec now scale based on available artifacts.
Tasks synthesize info from all available sources (design, PRD, ARCH, UI-SPEC).
Result: detail level matches the planning depth chosen by user."
```

---

## Task 5: Modify STEP 4 - Dynamic Ralph Loop Prompt

**Files:**
- Modify: `ralph-planner/SKILL.md:235-275`

**What:** Generate Ralph loop prompt dynamically, referencing only artifacts that exist.

**Step 1: Update STEP 4 header**

Replace current STEP 4 intro with:

```markdown
### STEP 4: Generate Ralph Loop Command (Dynamic)

Generate a `/ralph-wiggum:ralph-loop` command that references only the artifacts that were created.

**Iteration estimate:**
- Count tasks in spec
- Multiply by 2-3 (buffer for iterations)
- Add 2-3 extra buffer
- Present: "I estimate ~N iterations based on X tasks"

**Completion promise:** Always `EP-{CONTRIBUTOR}-{NUMBER} COMPLETE` (e.g., `EP-TB-003 COMPLETE`)

**Codex review:** Ask user if they want codex review gate. If yes, add `WITH CODEX REVIEW` to prompt.
```

**Step 2: Update prompt structure section**

Replace the current prompt structure instructions with:

```markdown
**Prompt structure (adaptive):**

Build the prompt dynamically based on which artifacts exist.

**Base template:** See [references/prompt-template.md](references/prompt-template.md) for full template.

**Adaptive context section:**

The "EXPERT ARTIFACTS" section should only reference files that exist:

```
EXPERT ARTIFACTS (reference during implementation):
{{IF PRD.md exists (pmLevel > 0)}}
- PRD: {absolute path to .prodman/artifacts/EP-{ID}/PRD.md}
{{END}}
{{IF ARCHITECTURE.md exists (archLevel > 0)}}
- Architecture: {absolute path to .prodman/artifacts/EP-{ID}/ARCHITECTURE.md}
{{END}}
{{IF UI-SPEC.md exists (uiuxLevel > 0)}}
- UI Spec: {absolute path to .prodman/artifacts/EP-{ID}/UI-SPEC.md}
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
  expertArtifacts.push(`- PRD: ${absolutePath}/.prodman/artifacts/${epicId}/PRD.md`)
}
if (archLevel > 0) {
  expertArtifacts.push(`- Architecture: ${absolutePath}/.prodman/artifacts/${epicId}/ARCHITECTURE.md`)
}
if (uiuxLevel > 0) {
  expertArtifacts.push(`- UI Spec: ${absolutePath}/.prodman/artifacts/${epicId}/UI-SPEC.md`)
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
```

**Step 3: Update output format section**

Keep current output format but add note about dynamic context:

```markdown
**Output format:**

~~~
Here's your Ralph loop command (~N iterations estimated for X tasks):

```
/ralph-wiggum:ralph-loop "..." --completion-promise "EP-{CONTRIBUTOR}-{NUMBER} COMPLETE" --max-iterations N
```

**What it will do:**
- [1-line summary per major task group]

**Expert artifacts available:**
{List which artifacts were created and will be available during implementation}
- {if PRD: "✓ Product requirements (PRD.md)"}
- {if ARCH: "✓ Architecture document (ARCHITECTURE.md)"}
- {if UI-SPEC: "✓ UI/UX specification (UI-SPEC.md)"}
- {if none: "⚠️ No expert artifacts (design.md only)"}

**To launch:** Copy the command above and paste it.
**To cancel mid-loop:** `/ralph-wiggum:cancel-ralph`
~~~
```

**Step 4: Commit**

```bash
git add ralph-planner/SKILL.md
git commit -m "feat(ralph-planner): generate dynamic Ralph loop prompt in STEP 4

Prompt now references only artifacts that exist.
Context section adapts based on which agents ran.
Prevents broken file references in Ralph loop."
```

---

## Task 6: Add Calibration to Product Manager Prompt

**Files:**
- Modify: `ralph-planner/subagents/product-manager-prompt.md:1-15`

**What:** Add calibration section at the top of the PM prompt that explains how to adjust behavior based on depth level.

**Step 1: Insert calibration section**

After the expertise list (line ~11), before "Your Role in the Workflow" section, insert:

```markdown
---

## 📊 Calibration According to Depth Level

You are running at **depth level {LEVEL}/5**. Adjust your work accordingly:

### Level 1-2 (Quick & Focused)

**Objective:** Fast, focused PRD with essential requirements only.

- **Questions to user:** 0-2 clarifying questions maximum (only if critical info is missing)
- **Output length:** 2-3 pages
- **Sections to include:**
  - Problem Statement (brief)
  - Success Metrics (1-2 primary metrics only)
  - User Stories (3-5 core stories, must-haves only)
  - Acceptance Criteria (high-level, 2-3 per story)
  - Scope (brief IN/OUT list)
- **Details:** Core requirements only, minimal examples
- **Time investment:** Fast turnaround, skip nice-to-haves

**Skip at this level:** Detailed NFRs, competitive analysis, analytics implementation plan, edge case exploration

### Level 3 (Standard)

**Objective:** Balanced PRD with good coverage of requirements.

- **Questions to user:** 3-5 questions for key product decisions
- **Output length:** 4-6 pages
- **Sections to include:**
  - Problem Statement (detailed)
  - Success Metrics (2-3 primary + 2-3 secondary)
  - User Stories (8-12 stories with MoSCoW prioritization)
  - Acceptance Criteria (detailed, 4-6 per story)
  - Scope (clear IN/OUT with rationale)
  - NFRs (basic: performance, security, accessibility)
- **Details:** Good coverage with 1-2 concrete examples per section
- **Time investment:** Balanced depth, cover main user scenarios

**Include at this level:** Basic NFRs, prioritization rationale, main user flows

### Level 4-5 (Deep & Comprehensive)

**Objective:** Exhaustive PRD exploring all angles and edge cases.

- **Questions to user:** 6-10+ questions to explore edge cases, metrics, and product strategy
- **Output length:** 8-15 pages
- **Sections to include:**
  - All sections from template (current behavior)
  - Problem Statement (comprehensive with market context)
  - Success Metrics (detailed measurement plan with analytics approach)
  - User Stories (15-25+ stories covering all personas and edge cases)
  - Acceptance Criteria (exhaustive, 6-10 per story with edge cases)
  - Scope (detailed with future roadmap considerations)
  - NFRs (comprehensive: performance targets, security requirements, accessibility WCAG 2.1, scalability, monitoring)
  - Jobs-to-be-done analysis
  - Competitive analysis
- **Details:** Multiple examples, edge cases explored, future-proofing
- **Time investment:** Thorough analysis, consider long-term implications

**Include at this level:** All sections, competitive analysis, detailed analytics plan, comprehensive NFRs, edge case handling

---
```

**Step 2: Update "Your Mission" section**

Add a note referencing the calibration:

```markdown
## Your Mission

Transform the design document into an **executable, comprehensive PRD** that:

1. **Clarifies the WHAT and WHY** (not the HOW - that's for Architecture Expert)
2. **Defines success metrics** upfront (quantifiable targets)
3. **Breaks down features** into user stories with acceptance criteria
4. **Prioritizes ruthlessly** (MoSCoW: Must/Should/Could/Won't)
5. **Documents scope explicitly** (what's IN and what's OUT)
6. **Provides context** for technical and design decisions

**IMPORTANT:** Adjust the depth and detail of your work according to the depth level calibration above. Running at level {LEVEL}/5.
```

**Step 3: Commit**

```bash
git add ralph-planner/subagents/product-manager-prompt.md
git commit -m "feat(ralph-planner): add depth calibration to Product Manager prompt

PM now adjusts output based on depth level {LEVEL}/5:
- Level 1-2: Quick, essential requirements only (2-3 pages)
- Level 3: Balanced coverage (4-6 pages)
- Level 4-5: Comprehensive analysis (8-15 pages)"
```

---

## Task 7: Add Calibration to Architecture Expert Prompt

**Files:**
- Modify: `ralph-planner/subagents/architecture-expert-prompt.md:1-15`

**What:** Add calibration section that explains how to adjust architecture document based on depth level.

**Step 1: Insert calibration section**

After the expertise list (line ~12), before "Your Role in the Workflow" section, insert:

```markdown
---

## 📊 Calibration According to Depth Level

You are running at **depth level {LEVEL}/5**. Adjust your work accordingly:

### Level 1-2 (Quick & Focused)

**Objective:** Fast architecture overview with core technical decisions.

- **Questions to user:** 0-2 technical clarifications only if critical
- **Output length:** 2-3 pages
- **Sections to include:**
  - System Overview (brief architecture vision)
  - Key Architecture Decisions (1-2 ADRs for most critical decisions only)
  - Component Design (high-level component list with responsibilities)
  - Data Model (basic schema: tables and key relationships only)
  - API Specification (main endpoints with request/response types)
- **Details:** Core architecture only, minimal diagrams
- **Time investment:** Fast, focus on what's needed to start implementation

**Skip at this level:** C4 diagrams, detailed ADRs, NFR coverage deep-dive, migration strategies, monitoring plan

### Level 3 (Standard)

**Objective:** Solid architecture document covering standard concerns.

- **Questions to user:** 3-5 questions for key technical decisions (patterns, tech choices)
- **Output length:** 4-6 pages
- **Sections to include:**
  - System Overview (quality attributes from PRD NFRs)
  - Architecture Decisions (3-5 ADRs covering key decisions)
  - Component Design (C4 Container diagram, component responsibilities)
  - Data Model (detailed schema with types, constraints, indexes)
  - API Specification (all endpoints with full contracts)
  - NFR Coverage (how architecture addresses performance, security, scalability)
  - File Structure (recommended directory organization)
- **Details:** Good technical coverage with concrete examples
- **Time investment:** Balanced, cover main technical concerns

**Include at this level:** Basic C4 diagrams, solid ADRs, NFR coverage, implementation guidance

### Level 4-5 (Deep & Comprehensive)

**Objective:** Exhaustive architecture exploring all technical angles.

- **Questions to user:** 6-10+ questions exploring patterns, edge cases, scaling, monitoring
- **Output length:** 8-15 pages
- **Sections to include:**
  - All sections from template (current behavior)
  - System Overview (comprehensive quality attributes)
  - Architecture Decisions (8-12 ADRs covering all significant decisions)
  - C4 Diagrams (Context, Container, Component levels)
  - Component Design (detailed responsibilities, patterns, interactions)
  - Data Model (comprehensive with migrations, indexing strategy, partitioning if needed)
  - API Specification (full contracts with error codes, rate limiting, versioning)
  - NFR Coverage (detailed: performance targets, security model, scalability strategy, resilience, observability)
  - Integration Architecture (external systems, message queues, caching)
  - Testing Strategy (unit, integration, e2e, performance)
  - Deployment & Infrastructure
  - Monitoring & Observability
- **Details:** Multiple diagrams, edge cases, production considerations
- **Time investment:** Thorough, future-proof, consider scale and operations

**Include at this level:** Full C4 model, comprehensive ADRs, detailed NFRs, testing strategy, deployment, monitoring

---
```

**Step 2: Update "Your Mission" section**

Add calibration reference:

```markdown
## Your Mission

Transform the design and PRD into a **comprehensive architecture document** that:

1. **Defines the technical HOW** (components, data models, APIs)
2. **Documents architecture decisions** with ADRs (context, decision, consequences)
3. **Designs system components** with clear boundaries and responsibilities
4. **Specifies data architecture** (schemas, flows, migrations)
5. **Covers all NFRs** from PRD (performance, security, scalability, resilience)
6. **Provides implementation guidance** (file structure, patterns, conventions)

**IMPORTANT:** Adjust the depth and detail of your work according to the depth level calibration above. Running at level {LEVEL}/5.

**Handling missing PRD:** If no PRD.md is available, extract product requirements and NFRs directly from design.md.
```

**Step 3: Commit**

```bash
git add ralph-planner/subagents/architecture-expert-prompt.md
git commit -m "feat(ralph-planner): add depth calibration to Architecture Expert prompt

Architecture Expert now adjusts output based on depth level {LEVEL}/5:
- Level 1-2: Core architecture overview (2-3 pages)
- Level 3: Solid technical coverage with C4 diagrams (4-6 pages)
- Level 4-5: Comprehensive architecture with all diagrams and NFRs (8-15 pages)"
```

---

## Task 8: Add Calibration to UI/UX Expert Prompt

**Files:**
- Modify: `ralph-planner/subagents/ui-ux-expert-prompt.md:1-15`

**What:** Add calibration section explaining how to adjust UI specification based on depth level.

**Step 1: Insert calibration section**

After the expertise list (line ~12), before "Your Role in the Workflow" section, insert:

```markdown
---

## 📊 Calibration According to Depth Level

You are running at **depth level {LEVEL}/5**. Adjust your work accordingly:

### Level 1-2 (Quick & Focused)

**Objective:** Fast UI specification with essential interface design.

- **Questions to user:** 0-2 UI clarifications only if critical
- **Output length:** 2-3 pages
- **Sections to include:**
  - Design Thinking (brief purpose and audience)
  - Component Library (list of components needed with basic props)
  - Layout & Structure (simple wireframe descriptions)
  - Key Interactions (main user flows only)
- **Details:** Essential UI elements only, minimal design tokens
- **Time investment:** Fast, enough to start building the interface

**Skip at this level:** Full design token system, comprehensive accessibility spec, animation details, responsive breakpoint specs

### Level 3 (Standard)

**Objective:** Balanced UI spec with good design coverage.

- **Questions to user:** 3-5 questions for key design decisions (layout approach, component choices)
- **Output length:** 4-6 pages
- **Sections to include:**
  - Design Thinking (purpose, audience, usage patterns)
  - Design Tokens (core tokens: colors, typography, spacing)
  - Component Library (components with states and variants)
  - Layout & Structure (responsive behavior at key breakpoints)
  - Interaction Design (user flows, states, basic animations)
  - Accessibility (basic WCAG 2.1 AA requirements: contrast, keyboard nav, ARIA)
- **Details:** Good coverage with 1-2 examples per component
- **Time investment:** Balanced, cover main UI scenarios

**Include at this level:** Basic design tokens, component states, core accessibility, responsive design

### Level 4-5 (Deep & Comprehensive)

**Objective:** Exhaustive UI spec with full design system.

- **Questions to user:** 6-10+ questions exploring interactions, edge states, accessibility
- **Output length:** 8-15 pages
- **Sections to include:**
  - All sections from template (current behavior)
  - Design Thinking (comprehensive user research context)
  - Design Tokens (full system: colors, typography, spacing, shadows, borders, animations)
  - Component Library (all components with states, variants, props, examples)
  - Layout & Structure (detailed responsive design with all breakpoints)
  - Interaction Design (comprehensive user flows, animations, transitions, micro-interactions)
  - Accessibility (full WCAG 2.1 AA compliance: keyboard nav, screen readers, ARIA, focus management, color contrast)
  - Visual Design (imagery guidelines, iconography, illustrations)
  - Error States & Edge Cases (loading, empty, error handling from UI perspective)
  - Design System Integration (how this fits with existing system)
- **Details:** Multiple examples, edge cases, full design token system
- **Time investment:** Thorough, design system quality, production-ready spec

**Include at this level:** Full design token system, comprehensive component library, detailed accessibility, all interaction flows

---
```

**Step 2: Update "Your Mission" section**

Add calibration reference:

```markdown
## Your Mission

Transform the design, PRD, and architecture into a **comprehensive UI/UX specification** that:

1. **Defines the interface design** (components, layouts, interactions)
2. **Establishes design tokens** (typography, colors, spacing, animations)
3. **Specifies component library** (states, variants, props)
4. **Ensures accessibility** (WCAG 2.1 AA compliance)
5. **Designs responsive layouts** (mobile-first approach)
6. **Maps interaction flows** (user journeys, animations, loading states)
7. **Provides implementation guidance** (CSS framework, component library)

**IMPORTANT:** Adjust the depth and detail of your work according to the depth level calibration above. Running at level {LEVEL}/5.

**Handling missing inputs:**
- If no PRD: Extract user requirements from design.md
- If no ARCHITECTURE: Infer technical constraints from design.md
- If neither: Use design.md as sole source for UI decisions
```

**Step 3: Commit**

```bash
git add ralph-planner/subagents/ui-ux-expert-prompt.md
git commit -m "feat(ralph-planner): add depth calibration to UI/UX Expert prompt

UI/UX Expert now adjusts output based on depth level {LEVEL}/5:
- Level 1-2: Essential interface design (2-3 pages)
- Level 3: Balanced UI spec with design tokens and accessibility (4-6 pages)
- Level 4-5: Full design system specification (8-15 pages)"
```

---

## Task 9: Update Prompt Template for Dynamic Context

**Files:**
- Modify: `ralph-planner/references/prompt-template.md:10-30`

**What:** Make the "EXPERT ARTIFACTS" section conditional based on what artifacts exist.

**Step 1: Replace static artifacts section**

In the "Prompt Structure" section, replace the current EXPERT ARTIFACTS section (lines ~18-24) with:

```markdown
{{EXPERT_ARTIFACTS_SECTION}}
```

**Step 2: Add conditional sections documentation**

After the existing prompt structure, add new section:

```markdown
### Dynamic Sections

The `{{EXPERT_ARTIFACTS_SECTION}}` placeholder should be replaced with content based on which artifacts were created:

**If at least one artifact exists:**

```
EXPERT ARTIFACTS (reference during implementation):
{{IF PRD.md exists}}
- PRD: {absolute path to .prodman/artifacts/EP-{CONTRIBUTOR}-{NUMBER}-{slug}/PRD.md}
{{END}}
{{IF ARCHITECTURE.md exists}}
- Architecture: {absolute path to .prodman/artifacts/EP-{CONTRIBUTOR}-{NUMBER}-{slug}/ARCHITECTURE.md}
{{END}}
{{IF UI-SPEC.md exists}}
- UI Spec: {absolute path to .prodman/artifacts/EP-{CONTRIBUTOR}-{NUMBER}-{slug}/UI-SPEC.md}
{{END}}

These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.
```

**If no artifacts exist (all agents disabled):**

```
Note: No expert artifacts available. Refer to the spec and design document for guidance.
```

**Construction logic:**

When building the prompt in SKILL.md STEP 4:

```javascript
let artifacts = []
if (pmLevel > 0) artifacts.push(`- PRD: ${absolutePath}/.prodman/artifacts/${epicId}/PRD.md`)
if (archLevel > 0) artifacts.push(`- Architecture: ${absolutePath}/.prodman/artifacts/${epicId}/ARCHITECTURE.md`)
if (uiuxLevel > 0) artifacts.push(`- UI Spec: ${absolutePath}/.prodman/artifacts/${epicId}/UI-SPEC.md`)

let artifactsSection
if (artifacts.length > 0) {
  artifactsSection = `EXPERT ARTIFACTS (reference during implementation):
${artifacts.join('\n')}

These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.`
} else {
  artifactsSection = `Note: No expert artifacts available. Refer to the spec and design document for guidance.`
}

finalPrompt = promptTemplate.replace('{{EXPERT_ARTIFACTS_SECTION}}', artifactsSection)
```
```

**Step 3: Update example**

Update the example section (lines ~119-189) to show a dynamic artifacts case:

```markdown
## Example - Dynamic Artifacts

For a 6-task plan creating EP-TB-003 with only PM and Architecture enabled (no UI/UX):

```
/ralph-wiggum:ralph-loop "Implement user authentication following the spec at /home/tom/projects/connect-coby/.prodman/specs/SPEC-TB-003-user-auth.md.

EXPERT ARTIFACTS (reference during implementation):
- PRD: /home/tom/projects/connect-coby/.prodman/artifacts/EP-TB-003-user-auth/PRD.md
- Architecture: /home/tom/projects/connect-coby/.prodman/artifacts/EP-TB-003-user-auth/ARCHITECTURE.md

These artifacts provide deep context on requirements and architecture decisions.
Consult them when you need clarification on WHY or HOW something should be implemented.

[... rest of prompt template ...]
```

---

For a minimal feature with no agents (only design.md):

```
/ralph-wiggum:ralph-loop "Implement quick utility feature following the spec at /home/tom/projects/app/.prodman/specs/SPEC-TB-005-util.md.

Note: No expert artifacts available. Refer to the spec and design document for guidance.

[... rest of prompt template ...]
```
```

**Step 4: Commit**

```bash
git add ralph-planner/references/prompt-template.md
git commit -m "feat(ralph-planner): make prompt template support dynamic artifacts

EXPERT ARTIFACTS section now conditional based on which agents ran.
Prevents referencing non-existent files in Ralph loop.
Template uses {{EXPERT_ARTIFACTS_SECTION}} placeholder."
```

---

## Task 10: Test End-to-End Scenarios

**Files:**
- Create: `ralph-planner/TESTING.md`

**What:** Document test scenarios and expected behaviors for various parameter combinations.

**Step 1: Create testing documentation**

```markdown
# Ralph Planner Parameterization - Testing Guide

## Test Scenarios

### Scenario 1: Minimal (All Disabled)

**Command:**
```
/ralph-planner -b1 -pm0 -arch0 -uiux0
```

**Expected behavior:**
1. STEP 0: Parse args, display config showing all agents disabled
2. STEP 1: Quick brainstorming (1-3 questions, concise design.md)
3. STEP 1.5: Ask contributor
4. STEP 2: Skip all agents (inform user)
5. STEP 3: Create epic/spec from design.md only
6. STEP 4: Generate Ralph loop with no expert artifacts

**Validation:**
- ✓ Epic and spec created
- ✓ No PRD/ARCHITECTURE/UI-SPEC files
- ✓ Ralph loop prompt references design.md only
- ✓ Spec has basic tasks from design

---

### Scenario 2: PM Only

**Command:**
```
/ralph-planner -b2 -pm3 -arch0 -uiux0
```

**Expected behavior:**
1. STEP 0: Display "PM 3/5, Arch disabled, UI/UX disabled"
2. STEP 1: Quick-moderate brainstorming
3. STEP 2: Spawn PM at depth 3, skip Arch and UI/UX
4. STEP 3: Create epic/spec from design.md + PRD
5. STEP 4: Ralph loop references PRD only

**Validation:**
- ✓ PRD.md created (4-6 pages)
- ✓ No ARCHITECTURE.md or UI-SPEC.md
- ✓ Epic includes acceptance criteria from PRD
- ✓ Spec tasks reference user stories from PRD
- ✓ Ralph loop prompt includes PRD path only

---

### Scenario 3: PM + Arch (No UI)

**Command:**
```
/ralph-planner -b3 -pm4 -arch3 -uiux0
```

**Expected behavior:**
1. STEP 0: Display "PM 4/5, Arch 3/5, UI/UX disabled"
2. STEP 1: Standard brainstorming
3. STEP 2: Spawn PM at depth 4, then Arch at depth 3 (with PRD input)
4. STEP 3: Create epic/spec from design.md + PRD + ARCHITECTURE
5. STEP 4: Ralph loop references PRD and ARCHITECTURE

**Validation:**
- ✓ PRD.md created (8-15 pages)
- ✓ ARCHITECTURE.md created (4-6 pages)
- ✓ No UI-SPEC.md
- ✓ Epic includes technical_scope from ARCHITECTURE
- ✓ Spec tasks include architecture context
- ✓ Ralph loop prompt includes both PRD and ARCHITECTURE paths

---

### Scenario 4: Full (All Enabled - Default)

**Command:**
```
/ralph-planner
```
or
```
/ralph-planner -b5 -pm5 -arch5 -uiux5
```

**Expected behavior:**
1. Current ralph-planner behavior (all at level 5)
2. All agents spawn and create artifacts
3. Ultra-detailed epic and spec

**Validation:**
- ✓ Identical to current ralph-planner v2 behavior
- ✓ All 3 artifacts created (PRD, ARCHITECTURE, UI-SPEC)
- ✓ Full detail in all documents
- ✓ Ralph loop references all 3 artifacts

---

### Scenario 5: Arch Only (Edge Case)

**Command:**
```
/ralph-planner -b2 -pm0 -arch3 -uiux0
```

**Expected behavior:**
1. STEP 2: Skip PM, spawn Arch with design.md only (no PRD)
2. Arch prompt includes warning: "No PRD available. Extract requirements from design.md."
3. STEP 3: Create epic/spec from design.md + ARCHITECTURE

**Validation:**
- ✓ No PRD.md
- ✓ ARCHITECTURE.md created
- ✓ Architecture used design.md as source
- ✓ Spec includes architecture context without PRD user stories

---

### Scenario 6: Inconsistent Depths

**Command:**
```
/ralph-planner -b1 -pm5 -arch5 -uiux5
```

**Expected behavior:**
1. Quick brainstorming (concise design.md)
2. All agents run at depth 5 (comprehensive)
3. Agents work with brief design.md as input

**Validation:**
- ✓ System allows this (user has full control)
- ✓ Design.md is brief
- ✓ Agents produce comprehensive artifacts despite brief design
- ✓ No errors or inconsistencies

---

## Error Cases

### Invalid Level

**Command:**
```
/ralph-planner -b6 -pm3
```

**Expected:**
```
❌ Invalid level 6 for -b. Must be 0-5.

Syntax: /ralph-planner [-bN] [-pmN] [-archN] [-uiuxN]
Where N is 0-5 (0 = disabled for agents, 1-5 = depth level)
```

---

### Malformed Args

**Command:**
```
/ralph-planner -pm -b2
```

**Expected:**
```
❌ Malformed argument: -pm

Syntax: /ralph-planner [-bN] [-pmN] [-archN] [-uiuxN]
Where N is 0-5 (0 = disabled for agents, 1-5 = depth level)
```

---

## Manual Testing Checklist

Before considering implementation complete:

- [ ] Test scenario 1 (all disabled)
- [ ] Test scenario 2 (PM only)
- [ ] Test scenario 3 (PM + Arch)
- [ ] Test scenario 4 (full/default)
- [ ] Test scenario 5 (Arch only edge case)
- [ ] Test invalid level error
- [ ] Verify backward compatibility (no args = level 5)
- [ ] Check Ralph loop prompt in all scenarios (no broken file references)
- [ ] Verify epic/spec quality scales with depth
- [ ] Test a real feature with minimal config (-b2 -pm2 -arch0 -uiux0)
- [ ] Test a real feature with full config (default)
```

**Step 2: Commit**

```bash
git add ralph-planner/TESTING.md
git commit -m "docs(ralph-planner): add comprehensive testing guide

Document test scenarios for parameterization:
- 6 main scenarios (minimal, PM only, PM+Arch, full, edge cases)
- Error cases (invalid levels, malformed args)
- Manual testing checklist for validation"
```

---

## Final Verification

Before marking complete:

1. Review all modified files for consistency
2. Verify SKILL.md workflow is coherent
3. Check that all 3 agent prompts have calibration
4. Ensure prompt template supports dynamic artifacts
5. Run through at least 2-3 test scenarios manually
6. Update ralph-planner README if needed
7. Consider updating CLAUDE.md with new ralph-planner usage

---

## Summary

**Files modified:**
1. `ralph-planner/SKILL.md` - Added STEP 0, modified STEPs 1-4 for parameterization
2. `ralph-planner/subagents/product-manager-prompt.md` - Added depth calibration
3. `ralph-planner/subagents/architecture-expert-prompt.md` - Added depth calibration
4. `ralph-planner/subagents/ui-ux-expert-prompt.md` - Added depth calibration
5. `ralph-planner/references/prompt-template.md` - Made artifacts section dynamic

**Files created:**
1. `ralph-planner/TESTING.md` - Test scenarios and validation

**Key features:**
- Flexible parameterization via `-bN -pmN -archN -uiuxN` syntax
- Backward compatible (no args = current behavior)
- Robust handling of all 256 combinations
- Adaptive artifact assembly
- Dynamic Ralph loop prompt generation
- Agents scale depth based on level (1-2 quick, 3 standard, 4-5 deep)
