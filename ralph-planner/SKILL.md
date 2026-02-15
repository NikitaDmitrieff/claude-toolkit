---
name: ralph-planner
description: "Plan features through collaborative brainstorming with expert subagents (Product Manager, Architecture, UI/UX), then generate a ready-to-launch Ralph loop command. Creates ultra-detailed specs by combining PRD, architecture, and UI specifications. Use when the user wants to plan AND implement a feature. Triggers on: 'let's build X', 'new feature', 'plan and loop', or any feature request that will need implementation."
---

# Ralph Planner

Five-step workflow: brainstorming → ask contributor → spawn expert subagents → assemble ultra-detailed artifacts → generate Ralph loop command.

**What's new in v2:** 3 expert subagents (Product Manager, Architecture, UI/UX) create PRD, ARCHITECTURE, and UI-SPEC artifacts, which are assembled into specs 3x more detailed than before.

## Workflow

### STEP 0: Parse Arguments and Display Configuration

Parse args string (e.g., "-b3 -pm4 -arch2 -uiux0") to extract depth levels:
- `-b<N>`: brainstormingDepth (default 5)
- `-pm<N>`: pmLevel (default 5)
- `-arch<N>`: archLevel (default 5)
- `-uiux<N>`: uiuxLevel (default 5)

All levels must be 0-5. Level 0 disables the agent. Show error if invalid:
```
Syntax: /ralph-planner [-bN] [-pmN] [-archN] [-uiuxN]
Where N is 0-5 (0 = disabled for agents, 1-5 = depth level)
```

Display configuration to user, then continue to STEP 1.

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
1. Read `ralph-planner/subagents/_base-expert-prompt.md`
2. Read `ralph-planner/subagents/product-manager.md`
3. Compose full prompt: base (with placeholders replaced) + expert-specific content
4. Replace placeholders in base prompt:
   - `{ROLE}` → "Product Manager"
   - `{DOMAIN}` → "product requirements"
   - `{OUTPUT_ARTIFACT}` → "PRD.md"
   - `{LEVEL}` → actual pmLevel value
5. Pass composed prompt to Task tool

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
1. Read `ralph-planner/subagents/_base-expert-prompt.md`
2. Read `ralph-planner/subagents/architecture.md`
3. Compose full prompt: base (with placeholders replaced) + expert-specific content
4. Replace placeholders in base prompt:
   - `{ROLE}` → "Architecture Expert"
   - `{DOMAIN}` → "system architecture"
   - `{OUTPUT_ARTIFACT}` → "ARCHITECTURE.md"
   - `{LEVEL}` → actual archLevel value
5. Pass composed prompt to Task tool

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
1. Read `ralph-planner/subagents/_base-expert-prompt.md`
2. Read `ralph-planner/subagents/ui-ux.md`
3. Compose full prompt: base (with placeholders replaced) + expert-specific content
4. Replace placeholders in base prompt:
   - `{ROLE}` → "UI/UX Expert"
   - `{DOMAIN}` → "user interface design"
   - `{OUTPUT_ARTIFACT}` → "UI-SPEC.md"
   - `{LEVEL}` → actual uiuxLevel value
5. Pass composed prompt to Task tool

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

**Execution Strategy:** Sequential (PM → Arch → UI/UX) so each expert builds on previous work. Agents handle missing inputs gracefully (fall back to design.md). Inform user of progress as each agent starts/completes.

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

**Epic format:** See [references/prodman-spec-format.md](references/prodman-spec-format.md)

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

**Spec format:** See [references/prodman-spec-format.md](references/prodman-spec-format.md) for template.

**Adaptive task synthesis:** For each task, synthesize from available sources:

- **Base** (design.md): Files, implementation steps, commit message
- **+ PRD**: Relevant user stories, acceptance criteria, success metrics
- **+ ARCHITECTURE**: Component design, API contracts, ADRs, data flow
- **+ UI-SPEC**: Layout, states, interactions, design tokens, accessibility

See [references/prodman-spec-format.md](references/prodman-spec-format.md) for full task format example.

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

Build the "EXPERT ARTIFACTS" section dynamically - only reference files that exist (based on agent levels > 0):
- PRD.md (if pmLevel > 0)
- ARCHITECTURE.md (if archLevel > 0)
- UI-SPEC.md (if uiuxLevel > 0)

If at least one artifact exists, include: "These artifacts provide deep context. Consult them when you need clarification on WHY or HOW."

If no artifacts exist: "No expert artifacts available. Refer to the spec and design document for guidance."

**Save the prompt** to `.artefacts/{feature-slug}/PROMPT.md` (used by ralph.sh).

**Output to user:**

```bash
./ralph.sh --dir .artefacts/{feature-slug} --promise "EP-{CONTRIBUTOR}-{NUMBER} COMPLETE" --max-iterations N
```

Include: task summary, list of available expert artifacts, list of created files (epic, spec, prompt, artifacts dir).

## Key Principles

- **Plans are specs** — The spec in `.prodman/specs/` is the single source of truth
- **Progress tracking** — Loop uses `progress.txt` to track completed tasks
- **Anti-premature-completion** — Explicit guardrails against early `<promise>` output
- **Best practices** — Loop runs shared checklist after implementation (see [../follow-best-practices/references/checklist.md](../follow-best-practices/references/checklist.md))
- **User launches** — Always output command for copy-paste, never auto-launch
