# Prodman Templates

## Contributor Identification

Before creating any artifacts, determine which contributor is working:

1. Read `.prodman/config.yaml` — it lists contributors with their initials (e.g., `ND`, `TB`)
2. Each contributor has their own counters (`counters.epic`, `counters.spec`)
3. Use the contributor's initials as `{ID}` in all IDs below
4. If the contributor is not in the config, ask them to add themselves first

## Epic Template

Create at `.prodman/epics/EP-{ID}-{XXX}-{slug}.yaml`:

```yaml
# Epic: {title}
id: EP-{ID}-{XXX}
title: {title}
status: planned
priority: {p0|p1|p2|p3}
owner: {ID}
milestone: null
spec: SPEC-{ID}-{XXX}

description: |
  {2-4 sentence description of the feature.}

technical_scope:
  frontend:
    - {bullet points of frontend changes}
  backend:
    - {bullet points of backend changes}

acceptance_criteria:
  {category_1}:
    - {criterion}
    - {criterion}
  {category_2}:
    - {criterion}

dependencies: []
issues: []
labels: [{relevant labels}]
target_date: null
created_at: "{YYYY-MM-DD}"
updated_at: "{YYYY-MM-DD}"
```

**Notes:**
- `{ID}` is the contributor's initials (e.g., `ND`, `TB`)
- `{XXX}` numbers come from `.prodman/config.yaml` under `contributors.{ID}.counters.epic` (use next value, then increment)
- `spec` references the corresponding SPEC-{ID}-XXX
- `acceptance_criteria` grouped by category (e.g., `visual`, `functionality`, `integration`)
- Keep scope realistic — only what was discussed in brainstorm

## Spec Template

Create at `.prodman/specs/SPEC-{ID}-{XXX}-{slug}.md`:

```markdown
# {Feature Name} Implementation Plan

> **For the Ralph loop:** Follow this plan task-by-task. Track progress in `progress.txt`.

**Epic:** EP-{ID}-{XXX}
**Goal:** {One sentence}
**Architecture:** {2-3 sentences about approach}

---

### Task 1: {Component/Change Name}

**Files:**
- Create: `exact/path/to/new-file.ext`
- Modify: `exact/path/to/existing-file.ext`

**What to do:**
{Clear description of the changes to make. Include code snippets where helpful.}

**Commit:** `{type}: {description}`

---

### Task 2: {Next Component}

{same structure}

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

- [ ] All tasks implemented per spec
- [ ] All acceptance criteria from EP-{ID}-{XXX} met
- [ ] `progress.txt` shows all tasks complete
- [ ] `.artefacts/{feature-slug}/TESTING.md` created
- [ ] `.artefacts/{feature-slug}/CHANGELOG.md` created
```

**Notes:**
- Tasks are ordered by dependency (earlier tasks don't depend on later ones)
- Each task is self-contained: one logical change, one commit
- The e2e test task is only included for substantial features (not trivial UI tweaks, config changes, etc.)
- For frontend-only changes, specify appropriate verification (e.g., `npm run build`, `npm run lint`, or manual browser check)

## Config Update

After creating both artifacts, update `.prodman/config.yaml` under the contributor's key:

```yaml
contributors:
  {ID}:
    counters:
      epic: {previous + 1}
      spec: {previous + 1}
```
