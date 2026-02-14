# Prodman Templates

> **Updated for Ralph Planner v2** with expert subagents (Product Manager, Architecture, UI/UX)

## Epic Template

Create at `.prodman/epics/EP-{CONTRIBUTOR}-{NUMBER}-{slug}.yaml`:

Example: `.prodman/epics/EP-TB-003-user-auth.yaml` or `.prodman/epics/EP-ND-017-dashboard.yaml`

```yaml
# Epic: {title}
id: EP-{CONTRIBUTOR}-{NUMBER}
title: {title}
status: planned
priority: {p0|p1|p2|p3}
owner: {CONTRIBUTOR}  # TB or ND
milestone: null
spec: SPEC-{CONTRIBUTOR}-{NUMBER}

description: |
  {2-4 sentence description from PRD problem statement}

technical_scope:
  frontend:
    - {Components from ARCHITECTURE.md and UI-SPEC.md}
    - {UI framework and libraries}
  backend:
    - {Services and APIs from ARCHITECTURE.md}
    - {Database changes from ARCHITECTURE.md schema}
  infrastructure:
    - {Deployment or config changes if applicable}

acceptance_criteria:
  {category from PRD - e.g., "functionality"}:
    - {AC-1 from PRD}
    - {AC-2 from PRD}
  {category from PRD - e.g., "performance"}:
    - {NFR from PRD and ARCHITECTURE}
  {category from PRD - e.g., "accessibility"}:
    - {WCAG requirements from UI-SPEC}

dependencies: []
issues: []
labels: [{tech stack from ARCHITECTURE}, {UI framework from UI-SPEC}]
target_date: null
created_at: "{YYYY-MM-DD}"
updated_at: "{YYYY-MM-DD}"
```

**Notes:**
- `id` format: `EP-{CONTRIBUTOR}-{NUMBER}` (e.g., `EP-TB-003`, `EP-ND-017`)
- `owner` is the contributor (TB or ND)
- `spec` references the corresponding `SPEC-{CONTRIBUTOR}-{NUMBER}`
- `description` extracted from PRD problem statement
- `technical_scope` synthesized from ARCHITECTURE and UI-SPEC
- `acceptance_criteria` grouped by category from PRD, enhanced with NFRs from ARCHITECTURE and accessibility from UI-SPEC
- Counters come from `.prodman/config.yaml` under `contributors.{CONTRIBUTOR}.counters`

## Spec Template (Ultra-Detailed with Expert Context)

Create at `.prodman/specs/SPEC-{CONTRIBUTOR}-{NUMBER}-{slug}.md`:

Example: `.prodman/specs/SPEC-TB-003-user-auth.md`

```markdown
# {Feature Name} Implementation Plan

> **For the Ralph loop:** Follow this plan task-by-task. Track progress in `.artefacts/{feature-slug}/progress.txt`.

**Epic:** EP-{CONTRIBUTOR}-{NUMBER}
**Goal:** {One sentence from PRD}
**Architecture:** {2-3 sentences from ARCHITECTURE.md overview}

**Artifacts:**
- PRD: `.prodman/artifacts/EP-{CONTRIBUTOR}-{NUMBER}-{slug}/PRD.md`
- Architecture: `.prodman/artifacts/EP-{CONTRIBUTOR}-{NUMBER}-{slug}/ARCHITECTURE.md`
- UI Spec: `.prodman/artifacts/EP-{CONTRIBUTOR}-{NUMBER}-{slug}/UI-SPEC.md`

**Success Metrics (from PRD):**
- {Primary metric with target}
- {Secondary metric with target}

---

### Task 1: {Component/Change Name}

**Files:**
- Create: `exact/path/to/new-file.ext` (from ARCHITECTURE file structure)
- Create: `exact/path/to/styles.ext` (from UI-SPEC)
- Modify: `exact/path/to/existing-file.ext` (if modifying)

**Architecture Context (from ARCHITECTURE.md):**
{Extract relevant architecture decisions, component responsibilities, data flow, patterns to use}

**UI Specification (from UI-SPEC.md):**
{Extract design tokens, component states, accessibility requirements, responsive behavior}

**Product Requirements (from PRD.md):**
{Extract relevant user story, acceptance criteria, success metric to impact}

**Implementation Steps:**
1. {Step 1 - specific action}
2. {Step 2 - specific action}
3. {Step 3 - specific action}
4. {Step N - verification step}

**Commit:** `{type}: {description}`

---

### Task 2: {Next Component}

**Files:**
- Create: `path/to/file`

**Architecture Context:**
{Relevant context}

**UI Specification:**
{Relevant context}

**Product Requirements:**
{Relevant context}

**Implementation Steps:**
1. {Step}

**Commit:** `{type}: {description}`

---

### Task N: E2E / Functional Tests (if feature is substantial)

**Files:**
- Create: `tests/e2e/test_{feature}.ext`

**What to do:**
Write end-to-end tests that exercise the feature as a real user would.
Tests should be:
- Comprehensible to a non-developer reading them
- Covering the main happy path and key edge cases
- Runnable with a single command

**Commit:** `test: add e2e tests for {feature}`

---

### Final Verification

**Acceptance Criteria (from PRD):**
- [ ] {AC-1 from PRD}
- [ ] {AC-2 from PRD}
- [ ] {AC-N from PRD}

**Architecture Verification (from ARCHITECTURE.md):**
- [ ] All NFRs met (performance, security, scalability)
- [ ] Database schema matches design
- [ ] API endpoints implemented per spec

**UI Verification (from UI-SPEC.md):**
- [ ] All component states implemented (default, hover, focus, active, disabled, loading, error)
- [ ] Design tokens used consistently
- [ ] WCAG 2.1 AA accessibility compliance (contrast, keyboard, ARIA)
- [ ] Responsive behavior works across breakpoints

**General:**
- [ ] All tasks implemented per spec
- [ ] `.artefacts/{feature-slug}/progress.txt` shows all tasks complete
- [ ] `.artefacts/{feature-slug}/TESTING.md` created
- [ ] `.artefacts/{feature-slug}/CHANGELOG.md` created
```

**Notes for Ultra-Detailed Specs:**

1. **Task Context Synthesis:**
   - Each task combines information from PRD, ARCHITECTURE, and UI-SPEC
   - Architecture Context: component structure, patterns, data flow, NFR considerations
   - UI Specification: design tokens, states, accessibility, responsive behavior
   - Product Requirements: user value, acceptance criteria, success metrics

2. **Task Granularity:**
   - Tasks are ordered by dependency (earlier tasks don't depend on later ones)
   - Each task is self-contained: one logical change, one commit
   - Break complex components into multiple tasks (types → structure → styling → logic → accessibility)

3. **Testing:**
   - The e2e test task is only included for substantial features (not trivial UI tweaks, config changes, etc.)
   - Tests should validate PRD acceptance criteria and user stories
   - For frontend-only changes, specify appropriate verification (e.g., `npm run build`, `npm run lint`, manual browser check)

4. **Implementation Guidance:**
   - Include exact file paths from ARCHITECTURE.md file structure
   - Reference specific design tokens from UI-SPEC.md
   - Include specific patterns/practices from ARCHITECTURE.md (e.g., "use Observer pattern", "implement circuit breaker")
   - Include accessibility requirements from UI-SPEC.md (ARIA labels, keyboard navigation)

5. **Verification:**
   - Final verification checklist includes PRD acceptance criteria, ARCHITECTURE NFRs, and UI-SPEC requirements
   - This ensures all 3 expert perspectives are validated

## Config Update

After creating both artifacts, update `.prodman/config.yaml`:

For contributor-based counters (TB/ND system):

```yaml
contributors:
  TB:
    name: Tom
    counters:
      epic: {previous + 1}
      spec: {previous + 1}
  ND:
    name: Nikita Dmitrieff
    counters:
      epic: {previous + 1}
      spec: {previous + 1}
```

Only increment the counter for the contributor who created the epic.

---

## Example: Ultra-Detailed Task

Here's a full example of what a task looks like with PRD, ARCHITECTURE, and UI-SPEC context:

```markdown
### Task 3: Create UserProfileCard Component

**Files:**
- Create: `src/components/UserProfileCard/UserProfileCard.tsx`
- Create: `src/components/UserProfileCard/UserProfileCard.styles.ts`
- Create: `src/components/UserProfileCard/types.ts`
- Modify: `src/types/user.ts` (add Profile type if needed)

**Architecture Context (from ARCHITECTURE.md):**
This component is part of the Profile module (src/profile/). It implements the Observer pattern
for real-time status updates and uses the UserService API contract defined in services/user.ts.

**Data Flow:**
```
UserService.subscribe(userId) → WebSocket connection → State update → Component re-render
```

**API Endpoint Used:**
- `GET /api/v1/users/:id/profile` - Fetch profile data
- WebSocket: `wss://api/users/:id/status` - Real-time status updates

**NFR Considerations:**
- Performance: Status updates must render in < 1s (from PRD AC-2.1)
- Error Handling: Display error state if WebSocket connection fails, with retry button

---

**UI Specification (from UI-SPEC.md):**

**Design Tokens:**
- Avatar size: 64px
- Spacing: spacing-md (16px) between elements
- Colors:
  - Online status: color-success (#10B981)
  - Offline status: color-neutral-400 (#9CA3AF)
  - Card background: color-surface (#FFFFFF)
- Border radius: radius-md (8px)
- Shadow: shadow-sm on hover

**Component States:**
- **Loading**: Skeleton placeholder (gray boxes)
- **Success**: Display avatar, name, status badge
- **Error**: Error icon with retry button

**Interactions:**
- Click card → Opens profile modal
- Hover card → Elevation increase (shadow-md)
- Hover status badge → Tooltip shows "Last seen {time}"

**Accessibility (WCAG 2.1 AA):**
- Avatar has `alt` text with user name
- Status badge includes `aria-label="Online"` or `aria-label="Offline"`
- Card is focusable with keyboard (Tab key)
- Focus indicator visible (2px primary color outline)
- Click/Enter activates modal

**Responsive:**
- Mobile (<640px): Card full width, avatar 48px
- Tablet/Desktop (≥640px): Card fixed width 300px, avatar 64px

---

**Product Requirements (from PRD.md):**

**User Story (US-3):**
"As a team member, when I view the team dashboard, I want to see who is online in real-time,
so I can decide whether to message them or wait."

**Acceptance Criteria (AC-2.1):**
"Online status updates must be reflected in the UI within 1 second of status change"

**Success Metric:**
Increase team engagement by 15% (measured by message send rate to online users)

---

**Implementation Steps:**

1. **Create types** in `types.ts`:
   ```typescript
   export interface Profile {
     id: string;
     name: string;
     avatar: string;
     status: 'online' | 'offline';
     lastSeen?: Date;
   }

   export interface UserProfileCardProps {
     userId: string;
     onClick?: () => void;
   }
   ```

2. **Create component structure** in `UserProfileCard.tsx`:
   - Import UserService and types
   - useState for profile data, loading, error
   - useEffect to subscribe to UserService on mount
   - Handle WebSocket connection (auto-reconnect on failure)
   - Render loading/error/success states

3. **Create styled components** in `UserProfileCard.styles.ts`:
   - Use design tokens from UI-SPEC (spacing-md, color-success, radius-md, shadow-sm)
   - Implement hover elevation (shadow-md)
   - Responsive styles (avatar size changes at 640px breakpoint)

4. **Implement accessibility**:
   - Add `alt={profile.name}` to avatar
   - Add `aria-label` to status badge
   - Make card focusable with `tabIndex={0}`
   - Handle Enter key press for modal activation
   - Add `:focus-visible` styling (2px outline)

5. **Add tooltip on status hover**:
   - Use Tooltip component (from UI library)
   - Show "Last seen {timeAgo}" for offline users
   - Show "Online" for online users

6. **Test real-time updates**:
   - Verify status changes reflect within 1s (AC-2.1)
   - Test WebSocket reconnection on connection loss
   - Verify keyboard navigation works
   - Test screen reader (VoiceOver/NVDA)

**Commit:** `feat(profile): add UserProfileCard component with real-time status`
```

This example shows how all 3 expert contexts (PRD, ARCHITECTURE, UI-SPEC) are synthesized into
one ultra-detailed task with clear implementation guidance.
