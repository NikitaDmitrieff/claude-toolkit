# Toolkit Simplification - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reduce claude-toolkit code by ~58% (4433 → 1860 lines) while preserving 100% functionality and spec quality.

**Architecture:** Extract common expert prompt structure into reusable base template, reduce expert files to domain-specific content only, consolidate reference docs, simplify SKILL.md verbosity. Runtime composition: base + expert-specific = full prompt.

**Tech Stack:** Markdown, bash scripts, git

---

## Task 1: Create Base Expert Prompt Template

**Files:**
- Create: `ralph-planner/subagents/_base-expert-prompt.md`
- Read: `ralph-planner/subagents/product-manager-prompt.md` (lines 1-100, 348-524)
- Read: `ralph-planner/subagents/architecture-expert-prompt.md` (lines 1-100)
- Read: `ralph-planner/subagents/ui-ux-expert-prompt.md` (lines 1-100)

**Step 1: Extract depth calibration framework**

Read all 3 expert prompts and identify common depth calibration structure (Levels 1-5). Extract to new file.

Create: `ralph-planner/subagents/_base-expert-prompt.md`

```markdown
# Expert Agent Base Prompt

You are an expert **{ROLE}** specializing in creating comprehensive **{DOMAIN}** documentation for software development projects.

---

## 📊 Depth Calibration

You are running at **depth level {LEVEL}/5**. Adjust your work accordingly:

### Level 1-2 (Quick & Focused)
- **Questions:** 0-2 clarifying questions max (only if critical)
- **Output:** 2-3 pages, essentials only
- **Details:** Core content only, minimal examples
- **Time:** Fast turnaround, skip nice-to-haves

### Level 3 (Standard)
- **Questions:** 3-5 questions for key decisions
- **Output:** 4-6 pages, good coverage
- **Details:** 1-2 concrete examples per section
- **Time:** Balanced depth, cover main scenarios

### Level 4-5 (Deep & Comprehensive)
- **Questions:** 6-10+ questions exploring edge cases
- **Output:** 8-15 pages, exhaustive analysis
- **Details:** Multiple examples, edge cases, future considerations
- **Time:** Thorough analysis, long-term implications

---

## Workflow Integration

**Your role in ralph-planner:**

1. **Input:** `design.md` from brainstorming phase
2. **Your Output:** `{OUTPUT_ARTIFACT}`
3. **Used by:**
   - Other expert agents (for cross-domain context)
   - Final spec assembly (for ultra-detailed tasks)

---

## Best Practices

**Apply these principles regardless of depth level:**

1. **YAGNI** - Only document what's in the spec, no bonus features
2. **Precision** - Use exact file paths, specific examples
3. **Traceability** - Link requirements to implementation
4. **Actionable** - Provide clear, implementable guidance
5. **Consistent** - Follow established patterns and conventions

---

## Quality Checklist

Before finalizing your output, verify:

- [ ] All sections from template are complete
- [ ] Examples are concrete and relevant
- [ ] No features beyond spec scope
- [ ] Cross-references to other artifacts are accurate
- [ ] Output matches depth level expectations
- [ ] File is saved to correct location

---

**Note:** This base prompt is composed with domain-specific content at runtime.
```

**Step 2: Verify base prompt structure**

Run: `wc -l ralph-planner/subagents/_base-expert-prompt.md`
Expected: ~60-80 lines

**Step 3: Commit base prompt**

```bash
git add ralph-planner/subagents/_base-expert-prompt.md
git commit -m "feat(ralph-planner): add base expert prompt template

Extract common structure from 3 expert prompts:
- Depth calibration framework (Levels 1-5)
- Workflow integration
- Best practices
- Quality checklist

This will be composed with expert-specific content at runtime."
```

---

## Task 2: Simplify Product Manager Expert

**Files:**
- Read: `ralph-planner/subagents/product-manager-prompt.md`
- Modify: `ralph-planner/subagents/product-manager-prompt.md` → `ralph-planner/subagents/product-manager.md`
- Reference: `ralph-planner/subagents/_base-expert-prompt.md`

**Step 1: Backup original file**

```bash
cp ralph-planner/subagents/product-manager-prompt.md ralph-planner/subagents/product-manager-prompt.md.backup
```

**Step 2: Create simplified PM expert file**

Create: `ralph-planner/subagents/product-manager.md`

Extract ONLY PM-specific content (remove generic sections now in base):

```markdown
# Product Manager Expert - Domain Specifics

**Specialized expertise:**
- User-centric product thinking
- Jobs-to-be-done (JTBD) framework
- Feature prioritization (RICE, MoSCoW)
- Acceptance criteria definition
- Product metrics and analytics

---

## Context You Receive

- **design.md** - Problem statement, feature ideas, users, approach, success criteria
- **Epic ID** - Format: `EP-{CONTRIBUTOR}-{NUMBER}`
- **Project context** - Tech stack, existing features

---

## Your Mission

Transform design.md into a comprehensive PRD that answers:
- **WHY** - Problem statement, user value, business impact
- **WHO** - User personas, jobs-to-be-done
- **WHAT** - User stories, acceptance criteria, scope
- **METRICS** - How we measure success

---

## PRD Structure

Save to: `.artefacts/{feature-slug}/PRD.md`

### Required Sections

#### 1. Problem Statement
**Purpose:** Define the problem being solved

**Depth 1-2:** Brief problem description (2-3 sentences)
**Depth 3:** Detailed problem with context (1-2 paragraphs)
**Depth 4-5:** Comprehensive analysis with market context, competitive landscape

**Example:**
```
Current users cannot export their data in CSV format, leading to manual
copy-paste workflows. This creates friction for power users managing
100+ records who need offline analysis capabilities.
```

#### 2. Success Metrics
**Purpose:** Define measurable outcomes

**Depth 1-2:** 1-2 primary metrics
**Depth 3:** 2-3 primary + 2-3 secondary metrics
**Depth 4-5:** Detailed measurement plan with analytics implementation

**Example:**
```
Primary: 20% adoption rate among power users within 30 days
Secondary: <5s export time for 1000 records, 95% data accuracy
```

#### 3. User Stories & Jobs-to-be-Done
**Purpose:** Define user needs and acceptance criteria

**Format:**
```
**US-{N}: [Title]**
As a [persona], I want [capability] so that [benefit]

**Acceptance Criteria:**
- AC-{N}.1: [Specific, testable criterion]
- AC-{N}.2: [Specific, testable criterion]

**Priority:** Must-have | Should-have | Could-have | Won't-have
```

**Depth 1-2:** 3-5 must-have stories
**Depth 3:** 8-12 stories with MoSCoW prioritization
**Depth 4-5:** 15-25+ stories covering all personas and edge cases

#### 4. Scope Definition
**Purpose:** Clear boundaries of what's included/excluded

**In Scope ✅**
- List specific features being built
- Reference user stories

**Out of Scope ❌**
- List related features NOT being built (with rationale)
- Future roadmap items

#### 5. Non-Functional Requirements (NFRs)
**Purpose:** Technical quality attributes

**Depth 1-2:** Skip or minimal (performance, security basics)
**Depth 3:** Performance targets, security, accessibility basics
**Depth 4-5:** Comprehensive (WCAG 2.1, scalability, monitoring, error handling)

**Example:**
```
- Performance: Export completes in <5s for 1000 records
- Security: Exports respect user permissions, audit logged
- Accessibility: Export UI keyboard navigable, screen reader compatible
```

---

## PM-Specific Validation

Before finalizing PRD:
- [ ] Each user story has clear acceptance criteria (testable)
- [ ] Success metrics are measurable and time-bound
- [ ] Scope boundaries are explicit (IN vs OUT)
- [ ] NFRs include performance, security, accessibility
- [ ] No features beyond design.md scope (YAGNI)
- [ ] MoSCoW prioritization applied (depth 3+)
```

**Step 3: Verify line count**

Run: `wc -l ralph-planner/subagents/product-manager.md`
Expected: ~200-280 lines (down from 524)

**Step 4: Remove old file**

```bash
git rm ralph-planner/subagents/product-manager-prompt.md
```

**Step 5: Commit simplified PM expert**

```bash
git add ralph-planner/subagents/product-manager.md
git commit -m "refactor(ralph-planner): simplify Product Manager expert

Reduce from 524 to ~250 lines by:
- Moving generic content to _base-expert-prompt.md
- Keeping only PM-specific expertise (JTBD, MoSCoW, metrics)
- Reducing examples (full templates → concise examples)
- Focusing on domain-specific guidance

Composition: _base-expert-prompt.md + product-manager.md = full PM prompt"
```

---

## Task 3: Simplify Architecture Expert

**Files:**
- Read: `ralph-planner/subagents/architecture-expert-prompt.md`
- Create: `ralph-planner/subagents/architecture.md`
- Reference: `ralph-planner/subagents/_base-expert-prompt.md`

**Step 1: Create simplified Architecture expert file**

Create: `ralph-planner/subagents/architecture.md`

```markdown
# Architecture Expert - Domain Specifics

**Specialized expertise:**
- Architectural Decision Records (ADRs)
- C4 model (Context, Container, Component, Code)
- Database schema design
- API contract specification
- NFR technical implementation

---

## Context You Receive

- **design.md** - High-level technical approach
- **PRD.md** (if available) - Product requirements, user stories
- **Epic ID** - Format: `EP-{CONTRIBUTOR}-{NUMBER}`
- **Project context** - Existing architecture, tech stack, database schema

---

## Your Mission

Create technical architecture that defines HOW to implement the feature:
- **STRUCTURE** - Components, modules, layers
- **DECISIONS** - ADRs explaining key choices
- **DATA** - Database schema, API contracts
- **QUALITY** - NFR technical implementation
- **INTEGRATION** - How components connect

---

## Architecture Document Structure

Save to: `.artefacts/{feature-slug}/ARCHITECTURE.md`

### Required Sections

#### 1. System Design Overview
**Purpose:** High-level architecture approach

**Depth 1-2:** Brief description of key components (1 paragraph)
**Depth 3:** Component overview with responsibilities
**Depth 4-5:** Detailed system design with C4 Context diagram

**Example:**
```
System follows layered architecture:
- API Layer: REST endpoints (src/api/export/)
- Service Layer: Business logic (src/services/export/)
- Data Layer: Repository pattern (src/repositories/)
```

#### 2. C4 Diagrams
**Purpose:** Visual architecture representation

**Depth 1-2:** Skip or text-only description
**Depth 3:** Component diagram (boxes + arrows)
**Depth 4-5:** Context + Container + Component diagrams

**Example (text-based):**
```
┌─────────────┐      ┌──────────────┐      ┌──────────┐
│ Export API  │─────▶│ ExportService│─────▶│ Database │
└─────────────┘      └──────────────┘      └──────────┘
       │                     │
       │                     ▼
       │              ┌──────────────┐
       └─────────────▶│ FileStorage  │
                      └──────────────┘
```

#### 3. Architectural Decision Records (ADRs)
**Purpose:** Document key technical decisions

**Format:**
```
**ADR-{N}: [Decision Title]**

**Context:** Why this decision is needed
**Decision:** What we decided to do
**Rationale:** Why this is the best choice
**Alternatives:** What else we considered
**Consequences:** Implications (positive & negative)
```

**Depth 1-2:** 1-2 major decisions only
**Depth 3:** 2-4 key decisions
**Depth 4-5:** Comprehensive ADRs for all significant choices

#### 4. Database Schema
**Purpose:** Define data model changes

**Include:**
- New tables (CREATE statements)
- Schema changes (ALTER statements)
- Indexes for performance
- Relationships and constraints

**Example:**
```sql
CREATE TABLE exports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  format VARCHAR(10) NOT NULL CHECK (format IN ('csv', 'json')),
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  file_path TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_exports_user_id ON exports(user_id);
CREATE INDEX idx_exports_status ON exports(status);
```

#### 5. API Specifications
**Purpose:** Define API contracts

**Include:**
- Endpoint paths and methods
- Request/response schemas
- Status codes and errors
- Authentication requirements

**Example:**
```
POST /api/v1/exports
Auth: Bearer token required

Request:
{
  "format": "csv",
  "filters": { "date_range": "last_30_days" }
}

Response 202 Accepted:
{
  "export_id": "uuid",
  "status": "pending",
  "download_url": null
}

Response 422 Unprocessable:
{
  "error": "invalid_format",
  "message": "Format must be csv or json"
}
```

#### 6. NFR Implementation
**Purpose:** Technical approach for non-functional requirements

**Map NFRs from PRD to technical solutions:**
- Performance → Caching, indexing, async processing
- Security → Auth, validation, audit logging
- Scalability → Queue architecture, rate limiting
- Monitoring → Metrics, logging, alerts

**Example:**
```
**Performance (PRD: <5s for 1000 records)**
- Async job processing (Celery/background worker)
- Streaming CSV generation (not in-memory)
- Database indexes on filter columns

**Security (PRD: Respect permissions)**
- Row-level security in Postgres
- Audit log for all export operations
- Signed download URLs (expire after 1 hour)
```

---

## Architecture-Specific Validation

Before finalizing ARCHITECTURE.md:
- [ ] All major components identified
- [ ] ADRs document key technical decisions
- [ ] Database schema changes are complete and tested
- [ ] API contracts specify all endpoints
- [ ] NFRs from PRD have technical solutions
- [ ] Integration points clearly defined
- [ ] No over-engineering beyond requirements (YAGNI)
```

**Step 2: Verify line count**

Run: `wc -l ralph-planner/subagents/architecture.md`
Expected: ~280-320 lines (down from 998)

**Step 3: Remove old file and commit**

```bash
git rm ralph-planner/subagents/architecture-expert-prompt.md
git add ralph-planner/subagents/architecture.md
git commit -m "refactor(ralph-planner): simplify Architecture expert

Reduce from 998 to ~300 lines by:
- Moving generic content to _base-expert-prompt.md
- Keeping only architecture-specific expertise (ADRs, C4, schema)
- Concise examples (1 per concept vs multiple variations)
- Focus on technical decision-making guidance

Composition: _base-expert-prompt.md + architecture.md = full ARCH prompt"
```

---

## Task 4: Simplify UI/UX Expert

**Files:**
- Read: `ralph-planner/subagents/ui-ux-expert-prompt.md`
- Create: `ralph-planner/subagents/ui-ux.md`
- Reference: `ralph-planner/subagents/_base-expert-prompt.md`

**Step 1: Create simplified UI/UX expert file**

Create: `ralph-planner/subagents/ui-ux.md`

```markdown
# UI/UX Expert - Domain Specifics

**Specialized expertise:**
- Design systems and component libraries
- Accessibility (WCAG 2.1)
- Responsive design patterns
- Interaction design
- Design tokens and theming

---

## Context You Receive

- **design.md** - UI requirements, user flows
- **PRD.md** (if available) - User stories, acceptance criteria
- **ARCHITECTURE.md** (if available) - Technical constraints, components
- **Epic ID** - Format: `EP-{CONTRIBUTOR}-{NUMBER}`
- **Project context** - Existing design system, UI framework

---

## Your Mission

Define the user interface that delivers great UX:
- **DESIGN** - Visual design, layout, components
- **INTERACTION** - User flows, states, feedback
- **ACCESSIBILITY** - WCAG compliance, keyboard nav, screen readers
- **RESPONSIVE** - Mobile, tablet, desktop layouts
- **TOKENS** - Design system variables (colors, spacing, typography)

---

## UI Specification Structure

Save to: `.artefacts/{feature-slug}/UI-SPEC.md`

### Required Sections

#### 1. Design Tokens
**Purpose:** Define reusable design variables

**Include:**
- Colors (primary, secondary, semantic)
- Typography (fonts, sizes, weights)
- Spacing scale
- Border radius, shadows
- Breakpoints (responsive)

**Example:**
```
Colors:
- Primary: --color-primary-500 (#3B82F6)
- Success: --color-success-500 (#10B981)
- Error: --color-error-500 (#EF4444)

Spacing:
- --spacing-xs: 4px
- --spacing-sm: 8px
- --spacing-md: 16px
- --spacing-lg: 24px

Typography:
- --font-heading: Inter, sans-serif
- --font-body: Inter, sans-serif
- --text-sm: 14px / 1.5
- --text-base: 16px / 1.5
```

#### 2. Component Specifications
**Purpose:** Define UI components needed

**For each component:**
- Layout structure
- States (default, hover, active, disabled, loading, error)
- Props/variants
- Accessibility requirements

**Example:**
```
**ExportButton Component**

Layout:
- Button with icon + label
- Icon: DownloadIcon (left), size 20px
- Label: "Export CSV"
- Padding: --spacing-sm --spacing-md

States:
| State | Appearance | Behavior |
|-------|-----------|----------|
| Default | Primary color, cursor pointer | Clickable |
| Hover | Darker shade (-600) | Visual feedback |
| Active | Even darker (-700) | Click feedback |
| Loading | Spinner replaces icon | Not clickable |
| Disabled | Opacity 50%, cursor not-allowed | Not clickable |
| Error | Error color border | Show error message |

Accessibility:
- aria-label="Export data as CSV"
- Keyboard: Enter/Space to activate
- Focus: Visible outline (2px primary color)
```

#### 3. User Flows
**Purpose:** Define step-by-step interactions

**Include:**
- Primary happy path
- Error scenarios
- Edge cases (depth 4-5)

**Example:**
```
**Export Flow**

1. User clicks "Export" button
   → Button enters loading state
   → Spinner shows "Preparing export..."

2. Export processing (2-10s)
   → Progress indicator if >3s expected
   → User can navigate away (export continues in background)

3. Export complete
   → Success toast: "Export ready! Downloading..."
   → File downloads automatically
   → Button returns to default state

**Error Scenarios:**
- No data: Show warning "No data to export"
- Permission denied: Show error "You don't have permission to export"
- Server error: Show error "Export failed. Try again."
```

#### 4. Responsive Design
**Purpose:** Define mobile/tablet/desktop layouts

**Breakpoints:**
- Mobile: <640px
- Tablet: 640px-1024px
- Desktop: >1024px

**Depth 1-2:** Mobile-first, desktop mentions
**Depth 3:** Specific breakpoint behaviors
**Depth 4-5:** Detailed responsive specs per component

**Example:**
```
**Export Page Layout**

Mobile (<640px):
- Full-width export button
- Format selector stacked vertically
- Filters collapse into accordion

Tablet (640-1024px):
- Export button + format selector horizontal
- Filters in 2-column grid

Desktop (>1024px):
- Filters sidebar (left)
- Export preview + controls (right)
```

#### 5. Accessibility Requirements
**Purpose:** WCAG 2.1 compliance

**Include:**
- Keyboard navigation
- Screen reader support (ARIA labels)
- Color contrast (4.5:1 minimum)
- Focus indicators
- Error messaging

**Example:**
```
**WCAG 2.1 AA Compliance**

Keyboard Navigation:
- Tab order: Filters → Export button → Format selector
- Enter/Space: Activate buttons
- Esc: Close modals/dropdowns

Screen Readers:
- Button: aria-label="Export data as CSV file"
- Status: aria-live="polite" for export progress
- Errors: aria-live="assertive" + aria-describedby

Color Contrast:
- Text on background: 4.5:1 minimum
- Interactive elements: 3:1 minimum
- Error messages: Red + icon (don't rely on color alone)

Focus Indicators:
- Visible outline: 2px solid primary color
- Never remove outline (use :focus-visible for mouse users)
```

---

## UI-Specific Validation

Before finalizing UI-SPEC.md:
- [ ] Design tokens defined for all visual properties
- [ ] All UI components have states specified
- [ ] User flows cover happy path + errors
- [ ] Responsive behavior defined (mobile/tablet/desktop)
- [ ] Accessibility requirements complete (WCAG 2.1 AA)
- [ ] Component specs reference existing design system
- [ ] No unnecessary UI complexity (YAGNI)
```

**Step 2: Verify line count**

Run: `wc -l ralph-planner/subagents/ui-ux.md`
Expected: ~320-380 lines (down from 1240)

**Step 3: Remove old file and commit**

```bash
git rm ralph-planner/subagents/ui-ux-expert-prompt.md
git add ralph-planner/subagents/ui-ux.md
git commit -m "refactor(ralph-planner): simplify UI/UX expert

Reduce from 1240 to ~350 lines by:
- Moving generic content to _base-expert-prompt.md
- Keeping only UI-specific expertise (design tokens, a11y, responsive)
- Using tables for states (vs verbose prose)
- Reducing examples from 9 to 3-4 key ones

Composition: _base-expert-prompt.md + ui-ux.md = full UI prompt"
```

---

## Task 5: Update SKILL.md Runtime Composition

**Files:**
- Modify: `ralph-planner/SKILL.md:134-290` (STEP 2: Spawn Expert Subagents)

**Step 1: Update PM subagent prompt construction**

Find section "Subagent 1: Product Manager Expert" (lines ~134-171).

Replace prompt construction instructions:

```markdown
**Prompt construction:**
1. Read `ralph-planner/subagents/_base-expert-prompt.md`
2. Read `ralph-planner/subagents/product-manager.md`
3. Compose full prompt:
   ```
   {contents of _base-expert-prompt.md with placeholders replaced}

   ---

   {contents of product-manager.md}
   ```
4. Replace placeholders in base prompt:
   - `{ROLE}` → "Product Manager"
   - `{DOMAIN}` → "product requirements"
   - `{OUTPUT_ARTIFACT}` → "PRD.md"
   - `{LEVEL}` → actual pmLevel value
5. Pass composed prompt to Task tool
```

**Step 2: Update Architecture subagent prompt construction**

Find section "Subagent 2: Architecture Expert" (lines ~174-217).

Apply same pattern, replacing placeholders:
- `{ROLE}` → "Architecture Expert"
- `{DOMAIN}` → "system architecture"
- `{OUTPUT_ARTIFACT}` → "ARCHITECTURE.md"
- `{LEVEL}` → actual archLevel value

**Step 3: Update UI/UX subagent prompt construction**

Find section "Subagent 3: UI/UX Expert" (lines ~220-265).

Apply same pattern, replacing placeholders:
- `{ROLE}` → "UI/UX Expert"
- `{DOMAIN}` → "user interface design"
- `{OUTPUT_ARTIFACT}` → "UI-SPEC.md"
- `{LEVEL}` → actual uiuxLevel value

**Step 4: Test composition logic**

Verify the composition produces valid prompts by checking placeholder replacement logic is clear.

**Step 5: Commit SKILL.md STEP 2 updates**

```bash
git add ralph-planner/SKILL.md
git commit -m "feat(ralph-planner): update STEP 2 for runtime prompt composition

Change expert prompt construction from single-file read to composition:
- Read _base-expert-prompt.md + {expert}.md
- Replace placeholders (ROLE, DOMAIN, OUTPUT_ARTIFACT, LEVEL)
- Pass composed prompt to Task tool

Enables DRY expert prompts while maintaining customization."
```

---

## Task 6: Simplify SKILL.md Remaining Sections

**Files:**
- Modify: `ralph-planner/SKILL.md` (all sections except STEP 2)

**Step 1: Simplify STEP 0 (Parse Arguments)**

Lines ~14-72. Remove verbose pseudocode, replace with concise description:

```markdown
### STEP 0: Parse Arguments and Display Configuration

Parse args string (e.g., "-b3 -pm4 -arch2 -uiux0") to extract depth levels:
- `-b<N>`: brainstormingDepth (default 5)
- `-pm<N>`: pmLevel (default 5)
- `-arch<N>`: archLevel (default 5)
- `-uiux<N>`: uiuxLevel (default 5)

All levels must be 0-5. Show error if invalid.

Display configuration to user, then continue to STEP 1.
```

Reduction: ~58 lines → ~15 lines

**Step 2: Simplify STEP 3 (Assemble Artifacts)**

Lines ~293-462. Remove verbose examples, keep 1 comprehensive example:

- Remove "Example - Minimal task" (lines ~423-436)
- Keep "Example - Full task with all artifacts" (lines ~386-421)
- Simplify adaptive assembly description (reduce repetition)

Reduction: ~170 lines → ~100 lines

**Step 3: Simplify STEP 4 (Generate Ralph Loop Command)**

Lines ~465-597. Remove verbose prompt structure explanation:

- Keep template reference: "See references/prompt-template.md"
- Remove redundant examples (already in prompt-template.md)
- Simplify output format section

Reduction: ~133 lines → ~60 lines

**Step 4: Remove repetitive configuration displays**

Find all instances of "🤖 Spawning {Expert}..." messages and consolidate into STEP 2 once.

**Step 5: Verify total line count**

Run: `wc -l ralph-planner/SKILL.md`
Expected: ~360-400 lines (down from 596)

**Step 6: Commit SKILL.md simplification**

```bash
git add ralph-planner/SKILL.md
git commit -m "refactor(ralph-planner): simplify SKILL.md verbosity

Reduce from 596 to ~380 lines:
- STEP 0: Remove pseudocode, concise description (58→15 lines)
- STEP 3: Keep 1 example vs 2 (170→100 lines)
- STEP 4: Reference prompt-template.md vs inline (133→60 lines)
- Remove repetitive messaging

Functionality unchanged, readability improved."
```

---

## Task 7: Consolidate Reference Documentation

**Files:**
- Read: `ralph-planner/references/artifacts-structure.md`
- Read: `ralph-planner/references/prodman-templates.md`
- Create: `ralph-planner/references/prodman-spec-format.md`
- Modify: `ralph-planner/references/prompt-template.md`

**Step 1: Merge artifacts-structure.md + prodman-templates.md**

Create: `ralph-planner/references/prodman-spec-format.md`

```markdown
# Prodman Spec Format Reference

## Overview

Ralph-planner creates epics and specs in the `.prodman/` directory following this structure:

```
.prodman/
├── config.yaml (contributor counters)
├── epics/
│   └── EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml
└── specs/
    └── SPEC-{CONTRIBUTOR}-{NUMBER}-{slug}.md
```

Artifacts stored in:
```
.artefacts/{feature-slug}/
├── PRD.md (from PM expert)
├── ARCHITECTURE.md (from Architecture expert)
├── UI-SPEC.md (from UI/UX expert)
└── PROMPT.md (Ralph loop prompt)
```

---

## Epic YAML Format

**File:** `.prodman/epics/EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml`

```yaml
id: EP-{CONTRIBUTOR}-{NUMBER}
title: {Feature name}
description: |
  {Problem statement - 2-3 sentences from PRD if available, else from design.md}

status: in-progress
created: {YYYY-MM-DD}
contributor: {TB|ND}

labels:
  - {tech-stack-label}
  - {priority-label}
  - {domain-label}

acceptance_criteria:
  - {High-level criterion from PRD}
  - {Another criterion}

technical_scope:
  components:
    - {Component name from ARCHITECTURE}
  apis:
    - {API endpoint from ARCHITECTURE}
  database:
    - {Table name from ARCHITECTURE}
```

**Label sources:**
- Tech stack: From ARCHITECTURE.md (e.g., react, typescript, postgresql)
- Priority: From PRD.md MoSCoW (e.g., must-have, should-have)
- Domain: From feature type (e.g., ui, api, database)
- UI framework: From UI-SPEC.md (e.g., tailwind, shadcn, accessibility)

---

## Spec Markdown Format

**File:** `.prodman/specs/SPEC-{CONTRIBUTOR}-{NUMBER}-{slug}.md`

```markdown
# SPEC-{CONTRIBUTOR}-{NUMBER}: {Feature Name}

Epic: EP-{CONTRIBUTOR}-{NUMBER}

## Overview

{1-2 sentence summary from design.md}

## Tasks

### Task 1: {Component/Feature Name}

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext`

{IF PRD available:}
**Product Requirements:**
{Relevant user stories and acceptance criteria}

{IF ARCHITECTURE available:}
**Architecture Context:**
{Component design, API contracts, data models, ADRs}

{IF UI-SPEC available:}
**UI Specification:**
- Layout: {Component structure}
- States: {loading, error, success}
- Interactions: {User flows}
- Design Tokens: {Colors, spacing, typography}
- Accessibility: {WCAG requirements, ARIA}

**Implementation Steps:**
1. {Specific step}
2. {Another step}
3. {Final step}

**Commit:** `{type}({scope}): {description}`

---

{Repeat for each task}
```

**Task synthesis:**
- **Base** (from design.md): High-level steps, file paths
- **+ PRD**: User stories, acceptance criteria, success metrics
- **+ ARCHITECTURE**: File structure, components, APIs, database, ADRs
- **+ UI-SPEC**: Design tokens, component states, accessibility, responsive

---

## Counter Management

**File:** `.prodman/config.yaml`

```yaml
contributors:
  TB:
    counters:
      epic: 12
      spec: 12
  ND:
    counters:
      epic: 8
      spec: 8
```

Increment after creating epic/spec.

---

## Complete Example

**Epic:** `.prodman/epics/EP-TB-003-user-profile-card.yaml`

```yaml
id: EP-TB-003
title: User Profile Card Component
description: |
  Users need a reusable component to display user profiles with real-time
  status updates and accessibility support.

status: in-progress
created: 2026-02-15
contributor: TB

labels:
  - react
  - typescript
  - accessibility
  - must-have

acceptance_criteria:
  - Displays user avatar, name, status in real-time
  - WCAG 2.1 AA compliant
  - Responsive (mobile, tablet, desktop)
  - <1s status update latency

technical_scope:
  components:
    - UserProfileCard
    - UserService (observer pattern)
  apis:
    - GET /api/users/:id
    - WebSocket /ws/users/:id/status
```

**Spec:** `.prodman/specs/SPEC-TB-003-user-profile-card.md` (see Task Structure above)
```

**Step 2: Verify merged file**

Run: `wc -l ralph-planner/references/prodman-spec-format.md`
Expected: ~380-420 lines (down from 785)

**Step 3: Remove old files**

```bash
git rm ralph-planner/references/artifacts-structure.md
git rm ralph-planner/references/prodman-templates.md
```

**Step 4: Simplify prompt-template.md**

Modify: `ralph-planner/references/prompt-template.md`

Remove:
- Verbose dynamic sections explanation (covered in SKILL.md)
- Examples "Partial Artifacts" and "No Artifacts" (keep 1 comprehensive)
- Repetitive codex review insertion explanation

Keep:
- Template structure
- 1 complete example (all artifacts)
- Placeholder replacement logic

Target: 290 → 170-190 lines

**Step 5: Commit reference consolidation**

```bash
git add ralph-planner/references/prodman-spec-format.md
git add ralph-planner/references/prompt-template.md
git commit -m "refactor(ralph-planner): consolidate reference docs

Merge artifacts-structure.md + prodman-templates.md:
→ prodman-spec-format.md (785→400 lines)

Simplify prompt-template.md (290→180 lines):
- Remove verbose examples (keep 1 comprehensive)
- Reduce dynamic sections explanation

Total reduction: 1075→580 lines (46%)"
```

---

## Task 8: Validation - Test Full Ralph Planner Run

**Files:**
- Test: Create a sample feature using ralph-planner
- Verify: Generated artifacts match quality expectations

**Step 1: Create test feature design**

Create: `docs/plans/2026-02-15-test-simple-counter-design.md`

```markdown
# Simple Counter Component - Test Design

**Problem:** Need a reusable counter component for testing ralph-planner simplification.

**Solution:** Build basic counter with increment/decrement buttons.

**Requirements:**
- Buttons: Increment (+1), Decrement (-1)
- Display: Current count
- Styling: Use design system tokens
- Accessibility: Keyboard navigation

**Tech:** React, TypeScript
```

**Step 2: Run ralph-planner with simplified code**

Invoke: `/ralph-planner -b2 -pm2 -arch2 -uiux2`

(Using depth 2 for fast test)

**Step 3: Verify all experts spawn**

Expected output:
```
🎛️ Ralph Planner Configuration:
Brainstorming depth: 2/5
Product Manager: 2/5
Architecture Expert: 2/5
UI/UX Expert: 2/5

🤖 Spawning Product Manager expert (depth 2/5)...
✓ PRD created at .artefacts/simple-counter/PRD.md

🤖 Spawning Architecture expert (depth 2/5)...
   Using PRD as input
✓ Architecture document created at .artefacts/simple-counter/ARCHITECTURE.md

🤖 Spawning UI/UX expert (depth 2/5)...
   Using PRD and ARCHITECTURE as input
✓ UI specification created at .artefacts/simple-counter/UI-SPEC.md
```

**Step 4: Verify artifact quality**

Check each artifact:
- PRD.md: Has problem statement, user stories, acceptance criteria
- ARCHITECTURE.md: Has components, file structure, ADRs
- UI-SPEC.md: Has design tokens, component states, accessibility

**Step 5: Verify epic/spec detail**

Check:
- `.prodman/epics/EP-TB-XXX-simple-counter.yaml` - Has labels, acceptance criteria
- `.prodman/specs/SPEC-TB-XXX-simple-counter.md` - Tasks include PRD + ARCH + UI context

**Step 6: Document validation results**

If issues found, fix simplified files and re-test.

**Step 7: Commit test artifacts**

```bash
git add docs/plans/2026-02-15-test-simple-counter-design.md
git add .artefacts/simple-counter/
git add .prodman/epics/EP-TB-*-simple-counter.yaml
git add .prodman/specs/SPEC-TB-*-simple-counter.md
git commit -m "test(ralph-planner): validate simplification with test feature

Run full ralph-planner workflow with simplified code.
All experts spawned successfully, artifacts quality preserved."
```

---

## Task 9: Run Code Simplifier

**Files:**
- All files in `ralph-planner/`

**Step 1: Run code-simplifier on ralph-planner**

Invoke: `/code-simplifier ralph-planner/`

**Step 2: Review suggestions**

Expected: Minimal suggestions (we already simplified)

Possible findings:
- Further reduce examples
- Consolidate similar sections
- Remove redundant wording

**Step 3: Apply valid suggestions**

Only apply suggestions that:
- Don't sacrifice clarity
- Don't remove domain expertise
- Don't break functionality

**Step 4: Commit code-simplifier improvements**

```bash
git add ralph-planner/
git commit -m "refactor(ralph-planner): apply code-simplifier suggestions

Further simplification based on automated review."
```

---

## Task 10: Run Best Practices

**Files:**
- All modified files

**Step 1: Run follow-best-practices**

Invoke: `/follow-best-practices`

**Step 2: Verify checklist**

Expected checks:
- [x] Code simplification complete
- [x] Artefacts created (design.md, plan.md)
- [x] CLAUDE.md updated (if learnings)
- [x] Convention compliance
- [x] YAGNI check passed

**Step 3: Update CLAUDE.md if needed**

If learnings from simplification should be documented:

```markdown
## Ralph Planner

- Expert prompts use composition: `_base-expert-prompt.md` + `{expert}.md`
- Depth levels (1-5) calibrate output detail
- Artifacts stored in `.artefacts/{feature-slug}/`
- Specs synthesize PRD + ARCHITECTURE + UI-SPEC
```

**Step 4: Final commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with ralph-planner simplification learnings"
```

---

## Task 11: Measure Results

**Files:**
- All modified files

**Step 1: Count final line totals**

```bash
wc -l ralph-planner/SKILL.md
wc -l ralph-planner/subagents/*.md
wc -l ralph-planner/references/*.md
```

**Step 2: Calculate reduction percentage**

| Component | Before | After | Reduction |
|-----------|--------|-------|-----------|
| SKILL.md | 596 | {actual} | {%} |
| Expert prompts | 2762 | {actual} | {%} |
| References | 1075 | {actual} | {%} |
| **Total** | **4433** | **{actual}** | **{%}** |

**Step 3: Verify success criteria**

- [ ] Code reduced by 50-60%
- [ ] Functionality 100% preserved (validated in Task 8)
- [ ] Spec quality unchanged (validated in Task 8)
- [ ] File structure descriptions precise
- [ ] Maintainability improved (base pattern works)
- [ ] YAGNI principles reinforced

**Step 4: Document final metrics**

Add to design document:

```markdown
## Implementation Results

**Achieved:**
- Total reduction: 4433 → {actual} lines ({%}%)
- SKILL.md: 596 → {actual} lines
- Expert prompts: 2762 → {actual} lines
- References: 1075 → {actual} lines

**Validation:**
- ✅ All experts spawn correctly
- ✅ Artifact quality preserved
- ✅ Spec detail unchanged
- ✅ YAGNI principles reinforced
```

**Step 5: Final commit**

```bash
git add docs/plans/2026-02-15-toolkit-simplification-design.md
git commit -m "docs: add implementation results to design doc

Total reduction: {%}% (4433 → {actual} lines)
All success criteria met."
```

---

## Success Criteria

✅ **Code reduced by 50-60%** - Measured in Task 11
✅ **Functionality 100% preserved** - Validated in Task 8
✅ **Spec quality unchanged** - Validated in Task 8
✅ **File structure descriptions precise** - Maintained in all simplified files
✅ **Maintainability improved** - Base + specifics pattern works
✅ **YAGNI principles reinforced** - Checked in Tasks 9-10
✅ **All tests pass** - Ralph planner run successful in Task 8
