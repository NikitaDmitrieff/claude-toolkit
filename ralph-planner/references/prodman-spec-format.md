# Prodman Spec Format Reference

## Overview

Ralph-planner creates epics and specs in the `.prodman/` directory, with expert artifacts in `.artefacts/`.

```
.prodman/
├── config.yaml (contributor counters)
├── epics/
│   └── EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml
└── specs/
    └── SPEC-{CONTRIBUTOR}-{NUMBER}-{slug}.md

.artefacts/{feature-slug}/
├── PRD.md (from PM expert)
├── ARCHITECTURE.md (from Architecture expert)
├── UI-SPEC.md (from UI/UX expert)
├── PROMPT.md (Ralph loop prompt)
└── progress.txt (implementation progress tracking)
```

---

## Epic YAML Format

**File:** `.prodman/epics/EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml`

```yaml
id: EP-{CONTRIBUTOR}-{NUMBER}
title: {Feature name}
status: planned
priority: {p0|p1|p2|p3}
owner: {CONTRIBUTOR}  # TB or ND
milestone: null
spec: SPEC-{CONTRIBUTOR}-{NUMBER}

description: |
  {2-4 sentence description from PRD problem statement, or design.md if no PRD}

technical_scope:
  frontend:
    - {Components from ARCHITECTURE.md and UI-SPEC.md}
  backend:
    - {Services and APIs from ARCHITECTURE.md}
  infrastructure:
    - {Deployment or config changes if applicable}

acceptance_criteria:
  {category - e.g., "functionality"}:
    - {AC from PRD}
  {category - e.g., "performance"}:
    - {NFR from PRD/ARCHITECTURE}
  {category - e.g., "accessibility"}:
    - {WCAG requirements from UI-SPEC}

dependencies: []
issues: []
labels: [{tech stack from ARCHITECTURE}, {UI framework from UI-SPEC}]
target_date: null
created_at: "{YYYY-MM-DD}"
updated_at: "{YYYY-MM-DD}"
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
# {Feature Name} Implementation Plan

> **For the Ralph loop:** Follow this plan task-by-task. Track progress in `.artefacts/{feature-slug}/progress.txt`.

**Epic:** EP-{CONTRIBUTOR}-{NUMBER}
**Goal:** {One sentence from PRD or design.md}
**Architecture:** {2-3 sentences from ARCHITECTURE.md overview, if available}

**Artifacts:**
- PRD: `.artefacts/{feature-slug}/PRD.md`
- Architecture: `.artefacts/{feature-slug}/ARCHITECTURE.md`
- UI Spec: `.artefacts/{feature-slug}/UI-SPEC.md`

**Success Metrics (from PRD):**
- {Primary metric with target}
- {Secondary metric with target}

---

### Task 1: {Component/Change Name}

**Files:**
- Create: `exact/path/to/new-file.ext`
- Modify: `exact/path/to/existing-file.ext`

{IF PRD available:}
**Product Requirements (from PRD.md):**
{Relevant user stories and acceptance criteria}

{IF ARCHITECTURE available:}
**Architecture Context (from ARCHITECTURE.md):**
{Component design, API contracts, data models, ADRs}

{IF UI-SPEC available:}
**UI Specification (from UI-SPEC.md):**
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

### Task N: E2E / Functional Tests (if feature is substantial)

**Files:**
- Create: `tests/e2e/test_{feature}.ext`

Write end-to-end tests exercising the feature as a real user would.

**Commit:** `test: add e2e tests for {feature}`

---

### Final Verification

**Acceptance Criteria (from PRD):**
- [ ] {AC-1}
- [ ] {AC-2}

**Architecture Verification:**
- [ ] All NFRs met (performance, security, scalability)
- [ ] Database schema matches design
- [ ] API endpoints implemented per spec

**UI Verification:**
- [ ] All component states implemented
- [ ] Design tokens used consistently
- [ ] WCAG 2.1 AA accessibility compliance
- [ ] Responsive behavior works across breakpoints
```

**Task synthesis:** Each task combines info from available artifacts:
- **Base** (design.md): High-level steps, file paths
- **+ PRD**: User stories, acceptance criteria, success metrics
- **+ ARCHITECTURE**: File structure, components, APIs, database, ADRs
- **+ UI-SPEC**: Design tokens, component states, accessibility, responsive

**Task ordering:** Dependencies first. Each task is self-contained: one logical change, one commit.

**Testing:** E2E test task only for substantial features. Tests validate PRD acceptance criteria.

---

## Counter Management

**File:** `.prodman/config.yaml`

```yaml
contributors:
  TB:
    name: Tom
    counters:
      epic: 12
      spec: 12
  ND:
    name: Nikita Dmitrieff
    counters:
      epic: 8
      spec: 8
```

Increment counter for the contributor after creating epic/spec.

---

## Complete Example

**Epic:** `.prodman/epics/EP-TB-003-user-profile-card.yaml`

```yaml
id: EP-TB-003
title: User Profile Card Component
status: planned
priority: p1
owner: TB
milestone: null
spec: SPEC-TB-003

description: |
  Users need a reusable component to display user profiles with real-time
  status updates and accessibility support.

technical_scope:
  frontend:
    - UserProfileCard component
    - Design tokens integration
  backend:
    - GET /api/users/:id/profile
    - WebSocket /ws/users/:id/status

acceptance_criteria:
  functionality:
    - Displays user avatar, name, status in real-time
    - Status updates reflect within 1 second
  accessibility:
    - WCAG 2.1 AA compliant
    - Keyboard navigable
  performance:
    - <1s status update latency

dependencies: []
issues: []
labels: [react, typescript, accessibility, must-have]
target_date: null
created_at: "2026-02-15"
updated_at: "2026-02-15"
```

**Spec task example:**

```markdown
### Task 3: Create UserProfileCard Component

**Files:**
- Create: `src/components/UserProfileCard/UserProfileCard.tsx`
- Create: `src/components/UserProfileCard/UserProfileCard.styles.ts`
- Create: `src/components/UserProfileCard/types.ts`

**Product Requirements (from PRD.md):**
Fulfills US-2: "As a user, I want to see other users' profiles..."
AC-2.1: Online status updates within 1 second. Performance target: <1s latency.

**Architecture Context (from ARCHITECTURE.md):**
Profile module (src/profile/). Observer pattern for real-time updates.
UserService API contract in services/user.ts. Data flow: API → Cache → State.

**UI Specification (from UI-SPEC.md):**
- Layout: Card with avatar (64px), name, status badge
- States: loading (skeleton), success (data), error (retry button)
- Design Tokens: spacing-md, color-primary-500, shadow-sm, radius-md
- Accessibility: aria-label on status badge, focusable card, :focus-visible outline

**Implementation Steps:**
1. Create type definitions in types.ts
2. Implement component structure with loading/error/success states
3. Add styled-components using design tokens
4. Wire up UserService.subscribe() for real-time updates
5. Add ARIA labels and keyboard navigation
6. Test accessibility with screen reader

**Commit:** `feat(profile): add UserProfileCard component with real-time status`
```

---

## Artifact Descriptions

| Artifact | Created By | Purpose | Contains |
|----------|-----------|---------|----------|
| PRD.md | PM Expert | WHAT and WHY | Problem statement, success metrics, user stories, acceptance criteria, scope, NFRs |
| ARCHITECTURE.md | Arch Expert | HOW (technical) | ADRs, C4 diagrams, database schema, API specs, NFR coverage, file structure |
| UI-SPEC.md | UI/UX Expert | HOW (interface) | Design tokens, component library, accessibility, responsive design, interaction flows |
| PROMPT.md | Ralph-planner | Loop execution | Complete prompt for ralph.sh to execute |

**Lifecycle:** Artifacts are immutable planning snapshots. If requirements change, create a new epic with new artifacts.
