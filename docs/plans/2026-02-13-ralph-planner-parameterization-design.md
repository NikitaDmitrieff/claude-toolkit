# Ralph Planner Parameterization Design

> **Created:** 2026-02-13
> **Purpose:** Add flexible parameterization to ralph-planner for controlling brainstorming depth and expert agent activation/detail levels

---

## Problem Statement

The current ralph-planner always runs at maximum depth: full brainstorming (many questions), all 3 expert agents (PM, Architecture, UI/UX), and ultra-detailed specifications. This is excellent for complex features but overkill for simple ones.

**Users need:**
- Quick path for simple features (minimal brainstorming, no agents, basic spec)
- Balanced path for moderate features (some agents, moderate detail)
- Current deep path for complex features (all agents, maximum detail)

**Current workaround:** Users must choose between ralph-planner (always slow/detailed) or manual spec writing (no expert guidance).

---

## Success Criteria

**Must have:**
1. Parameterized invocation: `/ralph-planner -b{N} -pm{N} -arch{N} -uiux{N}` where N=0-5
2. Backward compatibility: `/ralph-planner` (no args) behaves like current version (all at level 5)
3. Robustness: Any combination of parameters produces valid epic + spec + Ralph loop command
4. Coherent output: Lower levels → fewer questions, less detail, faster execution

**Success metrics:**
- Simple features: 5-10 min instead of 30-60 min (ralph-planner -b2 -pm2 -arch0 -uiux0)
- All combinations (0-5 for each param) work without errors
- Generated specs remain executable by Ralph loop

---

## Design Approach

### 1. Argument Parsing

**Syntax:**
```
/ralph-planner [-bN] [-pmN] [-archN] [-uiuxN]
```

**Parameters:**
- `-bN`: Brainstorming depth (1-5, default 5)
- `-pmN`: Product Manager level (0=disabled, 1-5=depth, default 5)
- `-archN`: Architecture Expert level (0=disabled, 1-5=depth, default 5)
- `-uiuxN`: UI/UX Expert level (0=disabled, 1-5=depth, default 5)

**Examples:**
- `/ralph-planner` → `-b5 -pm5 -arch5 -uiux5` (current behavior)
- `/ralph-planner -b2 -pm3 -arch0 -uiux0` → quick brainstorm, PM only at moderate depth
- `/ralph-planner -b1 -pm0 -arch0 -uiux0` → minimal brainstorm, no agents, design.md → spec directly

**Validation:**
- All levels must be 0-5
- If invalid: clear error message with syntax reminder

---

### 2. Depth Level Semantics

**What levels control (applies to brainstorming AND agents):**

| Aspect | Level 1-2 (Quick) | Level 3 (Standard) | Level 4-5 (Deep) |
|--------|-------------------|-------------------|------------------|
| **Questions asked** | 0-3 essential only | 3-7 key decisions | 6-15+ comprehensive |
| **Reflection time** | Fast, focused | Balanced | Thorough, exploratory |
| **Output length** | 1-3 pages | 4-6 pages | 8-15+ pages |
| **Sections included** | Core essentials only | Standard sections | All sections + extras |
| **Examples provided** | Minimal or none | 1-2 concrete examples | Multiple examples + edge cases |
| **Coverage** | Must-haves only | Should-haves included | Could-haves explored |

**Level 0 (for agents only):** Agent completely disabled, no artifact created.

---

### 3. Brainstorming Integration

**STEP 1 modified:**

Invoke brainstorming skill with depth parameter:

```markdown
Invoke Skill tool with:
- skill: "superpowers:brainstorming"
- args: "Depth level: {brainstormingDepth}/5. After creating and committing the design document, STOP. Do NOT invoke writing-plans. Ralph-planner will create the prodman artifacts instead."
```

**Brainstorming skill modifications:**

Add calibration section at the top:

```markdown
## Calibration According to Depth Level

You are running at **depth level {LEVEL}/5**. Adjust your work accordingly:

**Level 1-2 (Quick):**
- Ask 2-3 essential questions only
- Design: 1-2 paragraphs per section
- Sections: architecture overview, main components only
- Skip alternatives, go direct to solution

**Level 3 (Standard):**
- Ask 5-7 clarifying questions
- Design: 3-4 paragraphs per section
- Sections: architecture, components, data flow, error handling

**Level 4-5 (Deep):**
- Ask 10+ comprehensive questions
- Design: detailed coverage (current behavior)
- All sections: architecture, components, data flow, error handling, testing, edge cases, performance
```

**Impact:** `design.md` output scales with level.

---

### 4. Expert Agent Orchestration

**STEP 2 modified - Conditional spawning:**

```markdown
### STEP 2: Spawn Expert Subagents (Conditional)

Track available artifacts: [design.md]

#### Product Manager (if pmLevel > 0)
- Read: ralph-planner/subagents/product-manager-prompt.md
- Replace {LEVEL} with {pmLevel}
- Input: design.md, epic ID, project context
- Output: PRD.md → add to available artifacts

#### Architecture Expert (if archLevel > 0)
- Read: ralph-planner/subagents/architecture-expert-prompt.md
- Replace {LEVEL} with {archLevel}
- Input: design.md + PRD.md (if exists), epic ID, project context
- Output: ARCHITECTURE.md → add to available artifacts

#### UI/UX Expert (if uiuxLevel > 0)
- Read: ralph-planner/subagents/ui-ux-expert-prompt.md
- Replace {LEVEL} with {uiuxLevel}
- Input: design.md + PRD.md (if exists) + ARCHITECTURE.md (if exists), epic ID
- Output: UI-SPEC.md → add to available artifacts
```

**Key principles:**
- **Sequential execution** (PM → Arch → UI/UX)
- **Each agent receives all prior artifacts** if they exist
- **Level 0 = skip entirely** (no artifact created)
- **Agents handle missing inputs gracefully** (can work with design.md alone)

---

### 5. Agent Prompt Modifications

**Structure for each expert prompt:**

Add calibration section at the beginning of:
- `product-manager-prompt.md`
- `architecture-expert-prompt.md`
- `ui-ux-expert-prompt.md`

**Template:**

```markdown
# {Agent Name} Expert - System Prompt

> **DEPTH LEVEL: {LEVEL}/5**

## 📊 Calibration According to Depth Level

You are running at **depth level {LEVEL}**. Adjust your work accordingly:

### Level 1-2 (Quick & Focused)
- **Questions to user:** 0-2 clarifying questions maximum
- **Output length:** 2-3 pages, essential sections only
- **Details:** Core {requirements/architecture/UI} only, minimal examples
- **Sections to include:** {list minimal sections}
- **Time investment:** Fast turnaround, focus on must-haves

### Level 3 (Standard)
- **Questions to user:** 3-5 questions for key decisions
- **Output length:** 4-6 pages, standard sections
- **Details:** Good coverage with concrete examples
- **Sections to include:** {list standard sections}
- **Time investment:** Balanced depth, cover main scenarios

### Level 4-5 (Deep & Comprehensive)
- **Questions to user:** 6-10+ questions to explore edge cases
- **Output length:** 8-15 pages, all sections with rich detail
- **Details:** Exhaustive coverage, multiple examples, edge cases
- **Sections to include:** {all sections from current template}
- **Time investment:** Thorough analysis, future-proofing

---

## Your Role in the Workflow
[... rest of current prompt ...]
```

**Agent-specific calibration details:**

**Product Manager:**
- Level 1-2: Problem statement, 3-5 user stories, core acceptance criteria
- Level 3: + Success metrics, MoSCoW prioritization, basic NFRs
- Level 4-5: + Edge cases, analytics plan, competitive analysis, detailed NFRs

**Architecture Expert:**
- Level 1-2: Component overview, main API endpoints, basic file structure
- Level 3: + 2-3 ADRs, data model, integration points
- Level 4-5: + C4 diagrams, all ADRs, detailed schemas, NFR coverage, migration plan

**UI/UX Expert:**
- Level 1-2: Component list, basic layout, key interactions
- Level 3: + Design tokens, responsive behavior, accessibility basics
- Level 4-5: + Full design system, interaction flows, animations, WCAG 2.1 AA compliance

---

### 6. Adaptive Artifact Assembly

**STEP 3 modified - Source-aware synthesis:**

```markdown
### STEP 3: Assemble Artifacts from Available Sources

**Collect available artifacts:**
1. design.md (always present)
2. PRD.md (if pmLevel > 0)
3. ARCHITECTURE.md (if archLevel > 0)
4. UI-SPEC.md (if uiuxLevel > 0)

**Create epic by merging sources:**
- **Base:** design.md (description, high-level scope)
- **+ PRD (if available):** success metrics, acceptance criteria, user stories
- **+ ARCHITECTURE (if available):** technical_scope (components, APIs, database)
- **+ UI-SPEC (if available):** labels for UI framework/design system

**Create spec by synthesizing available sources:**

Task structure strategy:
- **Base (design.md only):** Extract tasks from design thinking, basic implementation steps
- **+ PRD:** Organize by user stories, add acceptance criteria per task
- **+ ARCHITECTURE:** Add file structure, API specs, technical context per task
- **+ UI-SPEC:** Add design tokens, component states, accessibility requirements per task

Result: Spec detail scales with available artifacts.
```

**Example scenarios:**

| Config | Sources | Epic/Spec Content |
|--------|---------|-------------------|
| `-b2 -pm0 -arch0 -uiux0` | design.md only | Basic tasks from design thinking, minimal detail |
| `-b3 -pm3 -arch0 -uiux0` | design.md + PRD | Tasks organized by user stories, acceptance criteria added |
| `-b4 -pm4 -arch3 -uiux0` | design.md + PRD + ARCH | + Technical context, file structure, API specs per task |
| `-b5 -pm5 -arch5 -uiux5` | All artifacts | Ultra-detailed tasks with product + architecture + UI context |

**Guarantees:**
- Epic and spec are ALWAYS created (mandatory outputs)
- PRD/ARCHITECTURE/UI-SPEC are optional (only if agents activated)
- Spec is always executable by Ralph loop (varying detail level)

---

### 7. Dynamic Ralph Loop Prompt

**STEP 4 modified - Context-aware prompt generation:**

Build Ralph loop prompt dynamically based on available artifacts:

```markdown
You are implementing {Epic ID}: {Feature Name}

**Specification:** Read `.prodman/specs/SPEC-{ID}.md` - this is your implementation guide.

**Context documents available:**

{{IF design.md EXISTS}}
- **Design thinking:** `docs/plans/{date}-{topic}-design.md`
  - Initial design decisions and approach
{{END}}

{{IF PRD.md EXISTS}}
- **Product requirements:** `.prodman/artifacts/{epic}/PRD.md`
  - Success metrics, user stories, acceptance criteria
{{END}}

{{IF ARCHITECTURE.md EXISTS}}
- **Architecture:** `.prodman/artifacts/{epic}/ARCHITECTURE.md`
  - Technical decisions, component structure, API specifications
{{END}}

{{IF UI-SPEC.md EXISTS}}
- **UI/UX specification:** `.prodman/artifacts/{epic}/UI-SPEC.md`
  - Design tokens, component library, accessibility requirements
{{END}}

**Your mission:** Follow the spec task by task, commit after each task...
[rest of current template]
```

**Implementation in SKILL.md:**

```javascript
// Build context section dynamically
let contextDocs = []
contextDocs.push('- **Design thinking:** `docs/plans/...-design.md`')

if (pmLevel > 0) {
  contextDocs.push('- **Product requirements:** `.prodman/artifacts/.../PRD.md`\n  - Success metrics, user stories, acceptance criteria')
}
if (archLevel > 0) {
  contextDocs.push('- **Architecture:** `.prodman/artifacts/.../ARCHITECTURE.md`\n  - Technical decisions, component structure, API specs')
}
if (uiuxLevel > 0) {
  contextDocs.push('- **UI/UX specification:** `.prodman/artifacts/.../UI-SPEC.md`\n  - Design tokens, component library, accessibility')
}

finalPrompt = promptTemplate.replace('{{CONTEXT_DOCS}}', contextDocs.join('\n\n'))
```

**Result:** Ralph loop always references correct files, no broken links.

---

## Robustness Guarantees

**Critical requirements for stability:**

1. **Any combination works:**
   - All 256 combinations (4 params × 6 values each) produce valid outputs
   - No crashes, no missing files, no broken references

2. **Graceful degradation:**
   - Fewer artifacts → simpler spec (not broken spec)
   - Missing agent inputs → agent uses design.md fallback

3. **Mandatory outputs always created:**
   - Epic YAML
   - Spec markdown
   - Ralph loop command (referencing only existing files)

4. **Backward compatibility:**
   - `/ralph-planner` (no args) = current behavior
   - Existing workflows unaffected

5. **Clear user feedback:**
   - Display config at start: "🎛️ Configuration: Brainstorming 3/5, PM 4/5, Arch 0 (disabled), UI/UX 2/5"
   - Inform user which agents are running: "🤖 Spawning Product Manager expert (level 4/5)..."
   - Show what's being skipped: "⏭️ Skipping Architecture Expert (level 0)"

---

## Implementation Checklist

**Files to modify:**

1. **ralph-planner/SKILL.md**
   - Add STEP 0: Parse arguments
   - Modify STEP 1: Pass depth to brainstorming
   - Modify STEP 2: Conditional agent spawning
   - Modify STEP 3: Adaptive artifact assembly
   - Modify STEP 4: Dynamic prompt generation

2. **superpowers/brainstorming/SKILL.md** (or equivalent)
   - Add calibration section with level 1-2 / 3 / 4-5 guidelines

3. **ralph-planner/subagents/product-manager-prompt.md**
   - Add calibration section at top
   - Define level 1-2 / 3 / 4-5 behaviors

4. **ralph-planner/subagents/architecture-expert-prompt.md**
   - Add calibration section at top
   - Define level 1-2 / 3 / 4-5 behaviors

5. **ralph-planner/subagents/ui-ux-expert-prompt.md**
   - Add calibration section at top
   - Define level 1-2 / 3 / 4-5 behaviors

6. **ralph-planner/references/prompt-template.md**
   - Add conditional context document sections
   - Make references dynamic based on available artifacts

**Testing strategy:**

Test key combinations:
- Minimal: `-b1 -pm0 -arch0 -uiux0`
- PM only: `-b2 -pm3 -arch0 -uiux0`
- Arch only: `-b2 -pm0 -arch3 -uiux0`
- PM + Arch: `-b3 -pm3 -arch3 -uiux0`
- Full (default): no args or `-b5 -pm5 -arch5 -uiux5`

Verify for each:
- ✓ Correct agents spawned
- ✓ Epic and spec created
- ✓ Ralph loop command valid
- ✓ All file references resolve

---

## Migration Path

**Phase 1: Core implementation**
- Argument parsing in SKILL.md
- Conditional agent spawning
- Adaptive assembly logic

**Phase 2: Agent calibration**
- Add calibration sections to all 3 agent prompts
- Test each agent at levels 1, 3, 5

**Phase 3: Brainstorming integration**
- Add calibration to brainstorming skill
- Test depth levels 1, 3, 5

**Phase 4: Prompt template**
- Make Ralph loop prompt dynamic
- Test with various artifact combinations

**Phase 5: Documentation & polish**
- Update ralph-planner README
- Add examples to SKILL.md
- User-facing documentation

---

## Edge Cases

**Invalid inputs:**
- Level > 5 or < 0 → Error: "Invalid level N for -b. Must be 1-5."
- Malformed args → Error with syntax reminder

**All agents disabled:**
- `-b1 -pm0 -arch0 -uiux0` → Valid! Use design.md directly to create minimal spec

**Inconsistent depth:**
- `-b1 -pm5 -arch5 -uiux5` → Valid (quick brainstorm, deep agents)
- User gets control, no forced coherence

**Missing intermediate agent:**
- `-b3 -pm0 -arch4 -uiux0` → Valid (Arch uses design.md only)

---

## Future Enhancements (Out of Scope)

- Named presets: `-preset quick` → `-b1 -pm2 -arch0 -uiux0`
- Auto-detect complexity: analyze design.md and suggest levels
- Codex review control: `-codex` / `-no-codex` flags
- Custom agent prompts: `-pm-prompt custom-pm.md`
