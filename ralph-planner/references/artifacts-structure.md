# Artifacts Structure - Ralph Planner v2

This document explains the structure and purpose of expert artifacts created by ralph-planner v2.

---

## Overview

Ralph-planner v2 uses **3 expert subagents** to create comprehensive specifications:
1. **Product Manager Expert** → PRD.md
2. **Architecture Expert** → ARCHITECTURE.md
3. **UI/UX Expert** → UI-SPEC.md

These artifacts are stored in `.artefacts/{feature-slug}/` and provide deep context for implementation.

---

## Directory Structure

```
.prodman/
├── config.yaml                    # Contributor counters (TB, ND)
├── epics/
│   ├── EP-TB-001-feature-a.yaml  # Epic metadata
│   ├── EP-TB-002-feature-b.yaml
│   ├── EP-ND-001-feature-c.yaml
│   └── ...
└── specs/
    ├── SPEC-TB-001-feature-a.md  # Ultra-detailed implementation tasks
    ├── SPEC-TB-002-feature-b.md
    ├── SPEC-ND-001-feature-c.md
    └── ...

.artefacts/                        # ⭐ NEW IN V2 - Expert artifacts
├── feature-a/
│   ├── PRD.md                     # Product requirements (from PM expert)
│   ├── ARCHITECTURE.md            # Architecture design (from Arch expert)
│   ├── UI-SPEC.md                 # UI specification (from UI expert)
│   ├── PROMPT.md                  # Ralph loop prompt
│   ├── progress.txt               # Implementation progress tracking (Ralph loop)
│   ├── TESTING.md                 # Testing guide (created during implementation)
│   └── CHANGELOG.md               # Change summary (created during implementation)
├── feature-b/
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   ├── UI-SPEC.md
│   ├── PROMPT.md
│   └── progress.txt
└── ...
```

---

## Artifact Files

### PRD.md (Product Requirements Document)

**Created by:** Product Manager Expert subagent
**Purpose:** Defines WHAT to build and WHY

**Contains:**
- Problem statement (what problem are we solving?)
- Success metrics (how we'll measure success)
- User stories & jobs-to-be-done
- Feature breakdown with acceptance criteria
- Scope definition (in-scope / out-of-scope)
- User personas
- Non-functional requirements (NFRs)
- Assumptions, constraints, risks

**When to consult:**
- Need to understand user value or business rationale
- Clarifying acceptance criteria
- Understanding success metrics
- Validating scope boundaries

**Example path:**
```
.artefacts/user-auth/PRD.md
```

---

### ARCHITECTURE.md (Architecture Document)

**Created by:** Architecture Expert subagent
**Purpose:** Defines HOW to build it (technical)

**Contains:**
- Architecture Decision Records (ADRs) - major technical decisions with rationale
- C4 model diagrams (Context, Container, Component)
- Database schema (tables, columns, relationships, indexes)
- API specifications (endpoints, auth, errors)
- Integration architecture (external services, event flows)
- Non-functional requirements coverage (performance, security, scalability)
- Deployment architecture
- Implementation guidance (file structure, naming conventions, patterns)

**When to consult:**
- Need to understand system design or component structure
- Clarifying data models or API contracts
- Understanding performance or security requirements
- Looking for file path guidance
- Understanding why a technical decision was made (ADRs)

**Example path:**
```
.artefacts/user-auth/ARCHITECTURE.md
```

---

### UI-SPEC.md (UI/UX Specification)

**Created by:** UI/UX Expert subagent
**Purpose:** Defines HOW to build it (interface)

**Contains:**
- Design thinking (purpose, audience, aesthetic direction)
- Design tokens (typography, colors, spacing, shadows, animations)
- Component library (states, variants, props, usage guidelines)
- Layout specifications (page structure, grid system, responsive breakpoints)
- Interaction flows (user journeys, animations, loading/error states)
- Accessibility requirements (WCAG 2.1 AA compliance)
- Responsive design strategy (mobile-first, breakpoint behavior)
- Integration with tech stack (CSS framework, component library, state management)

**When to consult:**
- Need to understand UI design or component specifications
- Clarifying design tokens (colors, spacing, fonts)
- Understanding component states or interactions
- Validating accessibility requirements
- Understanding responsive behavior

**Example path:**
```
.artefacts/user-auth/UI-SPEC.md
```

---

## How Artifacts Are Used

### 1. During Spec Creation (ralph-planner)

Ralph-planner **assembles** PRD, ARCHITECTURE, and UI-SPEC into ultra-detailed spec tasks.

**Example task synthesis:**
```markdown
### Task 3: Create UserProfileCard Component

**Files:** (from ARCHITECTURE.md file structure)
- Create: src/components/UserProfileCard/UserProfileCard.tsx
- Create: src/components/UserProfileCard/UserProfileCard.styles.ts

**Architecture Context:** (from ARCHITECTURE.md)
Component uses Observer pattern for real-time updates, subscribes to
UserService WebSocket for status changes.

**UI Specification:** (from UI-SPEC.md)
- Design tokens: avatar 64px, spacing-md, color-success
- States: loading, success, error
- Accessibility: ARIA labels, keyboard navigation

**Product Requirements:** (from PRD.md)
Must meet AC-2.1: status updates < 1s latency
Impacts success metric: 15% increase in team engagement

**Implementation Steps:**
1. Create types
2. Implement component structure
3. Add styled-components with design tokens
4. Wire up WebSocket subscription
5. Add ARIA labels for accessibility
```

---

### 2. During Implementation (ralph-loop)

Ralph loop **references** artifacts when tasks need clarification.

**Ralph loop prompt includes:**
```
EXPERT ARTIFACTS (reference during implementation):
- PRD: /path/to/.artefacts/user-auth/PRD.md
- Architecture: /path/to/.artefacts/user-auth/ARCHITECTURE.md
- UI Spec: /path/to/.artefacts/user-auth/UI-SPEC.md

Consult them when you need clarification on WHY or HOW something should be implemented.
```

**When Ralph loop should consult:**
- Task says "use Observer pattern" → Read ARCHITECTURE.md for pattern details
- Task says "use spacing-md" → Read UI-SPEC.md for token value
- Task says "meet AC-2.1" → Read PRD.md for acceptance criteria details
- Unclear about user value → Read PRD.md user stories
- Unclear about API endpoint format → Read ARCHITECTURE.md API specs

---

### 3. During Code Review (manual or codex-review)

Reviewers **validate** implementation against all 3 artifacts.

**Validation checklist:**
- ✅ PRD acceptance criteria met?
- ✅ ARCHITECTURE patterns followed?
- ✅ UI-SPEC design tokens used?
- ✅ ARCHITECTURE NFRs addressed (performance, security, scalability)?
- ✅ UI-SPEC accessibility requirements met (WCAG 2.1 AA)?

---

## Artifact Lifecycle

### Creation

1. **Brainstorming** creates `design.md`
2. **Ralph-planner** asks contributor (TB/ND)
3. **Ralph-planner** spawns 3 subagents:
   - Product Manager reads design.md → creates PRD.md
   - Architecture Expert reads design.md + PRD.md → creates ARCHITECTURE.md
   - UI/UX Expert reads design.md + PRD.md + ARCHITECTURE.md → creates UI-SPEC.md
4. **Ralph-planner** assembles artifacts → creates epic + ultra-detailed spec

### Storage

- Artifacts stored in: `.artefacts/{feature-slug}/`
- Naming convention: `{feature-slug}/` (e.g., `user-auth/`, `data-export/`)
- Planning files (created by ralph-planner): `PRD.md`, `ARCHITECTURE.md`, `UI-SPEC.md`, `PROMPT.md`
- Implementation files (created by Ralph loop): `progress.txt`, `TESTING.md`, `CHANGELOG.md`

### Usage

- **During spec creation**: ralph-planner synthesizes tasks from artifacts
- **During implementation**: Ralph loop consults artifacts for clarification
- **During review**: Reviewers validate against artifact requirements
- **Long-term**: Documentation for future refactoring or new team members

### Maintenance

- **Immutable once created**: Artifacts are snapshots of planning decisions
- **If requirements change**: Create new epic with new artifacts
- **If small tweaks needed**: Update epic acceptance criteria, not artifacts
- **Version control**: Artifacts are committed to git like all other files

---

## Benefits of Artifacts

### 1. Traceability

Clear lineage from requirements to implementation:
```
PRD user story → ARCHITECTURE component → UI-SPEC design → Spec task → Code
```

### 2. Reduced Ambiguity

Tasks have context from 3 expert perspectives:
- **Why** (PRD): User value, business rationale
- **How - Technical** (ARCHITECTURE): Patterns, schemas, APIs
- **How - Interface** (UI-SPEC): Design tokens, states, accessibility

### 3. Better Ralph Loop Performance

Ralph loop has deep context to consult when:
- Task description is unclear
- Edge cases arise
- Trade-off decisions needed

### 4. Knowledge Preservation

Artifacts document decisions for future reference:
- New team members understand rationale
- Refactoring maintains original intent
- Similar features can reference past decisions

### 5. Improved Code Review

Reviewers validate against comprehensive requirements:
- Not just "does it work?" but "does it meet all criteria?"
- NFRs are checked (performance, security, accessibility)
- Design consistency is enforced

---

## Example: Full Workflow

### User Request
"I want to add user authentication to the app"

### Step 1: Brainstorming
- Creates `docs/plans/2026-02-13-user-auth-design.md`
- Documents problem, approach, tech choices

### Step 2: Ralph-Planner
- Asks: "Who is creating this epic? (TB or ND)"
- User answers: "TB"
- Reads config: TB counter is 2, so next epic is `EP-TB-003`

### Step 3: Spawn Subagents
```
🤖 Spawning Product Manager expert...
   ✓ PRD created: .artefacts/user-auth/PRD.md

🤖 Spawning Architecture expert...
   ✓ Architecture created: .artefacts/user-auth/ARCHITECTURE.md

🤖 Spawning UI/UX expert...
   ✓ UI spec created: .artefacts/user-auth/UI-SPEC.md
```

### Step 4: Assemble Artifacts
- Reads all 3 artifacts
- Creates `EP-TB-003-user-auth.yaml` (epic with acceptance criteria from PRD)
- Creates `SPEC-TB-003-user-auth.md` (ultra-detailed tasks with PRD/ARCH/UI context)
- Updates config: TB counter → 3

### Step 5: Generate Ralph Loop Command
```bash
/ralph-wiggum:ralph-loop "..." --completion-promise "EP-TB-003 COMPLETE" --max-iterations 18
```

Prompt includes paths to artifacts for reference.

### Step 6: Ralph Loop Execution
- Reads spec task-by-task
- Consults PRD when unclear about requirements
- Consults ARCHITECTURE when unclear about patterns
- Consults UI-SPEC when unclear about design tokens
- Implements with full context

### Step 7: Code Review
- Reviewer checks PRD acceptance criteria ✅
- Reviewer checks ARCHITECTURE NFRs ✅
- Reviewer checks UI-SPEC accessibility ✅

---

## Migration from V1

### Backward Compatibility

- **Old epics/specs (v1)**: Still work, no artifacts directory
- **New epics/specs (v2)**: Have artifacts directory
- **No migration needed**: Old and new coexist

### Identifying Version

- **V1 epic**: No artifacts directory, simpler spec tasks
- **V2 epic**: Has `.artefacts/{feature-slug}/` with PRD, ARCHITECTURE, UI-SPEC, and PROMPT files

### Gradual Adoption

- New features use v2 (with artifacts)
- Old features remain v1 (no artifacts)
- Over time, codebase has mix of both
- No issues - Ralph loop works with both formats

---

## Troubleshooting

### Artifact Not Found

**Problem:** Ralph loop can't find artifact file
**Solution:** Check path in Ralph loop prompt matches actual artifact location

### Artifact Out of Sync

**Problem:** Spec was manually edited, no longer matches artifact
**Solution:** Artifacts are planning artifacts, spec is source of truth for implementation

### Missing Context

**Problem:** Task unclear, but artifact doesn't clarify
**Solution:** Update spec task description directly (artifacts are immutable planning docs)

### Too Much Context

**Problem:** Ralph loop reads entire artifact, wastes tokens
**Solution:** Spec tasks should extract relevant context, Ralph loop consults only when needed

---

## Best Practices

### For Ralph-Planner (when assembling)

1. **Extract relevant context** from artifacts into spec tasks
2. **Don't copy entire sections** - synthesize key points
3. **Link tasks to acceptance criteria** from PRD
4. **Reference specific design tokens** from UI-SPEC
5. **Include specific patterns** from ARCHITECTURE

### For Ralph Loop (when implementing)

1. **Read spec task first** - it has synthesized context
2. **Consult artifacts only when unclear** - avoid reading entire files
3. **Search artifacts** for specific terms (Ctrl+F for design token, API endpoint)
4. **Understand WHY** from PRD before implementing
5. **Follow patterns** from ARCHITECTURE

### For Reviewers (when validating)

1. **Check PRD acceptance criteria** are met
2. **Validate ARCHITECTURE NFRs** (performance, security, scalability)
3. **Verify UI-SPEC compliance** (design tokens, accessibility, responsive)
4. **Ensure traceability** from PRD → code
5. **Confirm no scope creep** (nothing beyond PRD scope)

---

## Summary

**Artifacts are the "why and how" documentation** that make ultra-detailed specs possible.

- **PRD.md** = Why build it (product requirements)
- **ARCHITECTURE.md** = How to build it (technical design)
- **UI-SPEC.md** = How to build it (interface design)

They are created once during planning, referenced during implementation, and preserved for future understanding.

This is what transforms ralph-planner from "good specs" to "ultra-detailed, context-rich specs" that enable faster, higher-quality implementation.
