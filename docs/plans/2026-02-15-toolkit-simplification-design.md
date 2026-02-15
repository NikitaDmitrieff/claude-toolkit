# Toolkit Simplification - YAGNI Audit & Optimization

**Date:** 2026-02-15
**Status:** Design
**Owner:** Tom

## Problem Statement

The claude-toolkit, particularly ralph-planner, has accumulated ~144KB of code across prompts and documentation. Analysis shows significant duplication and verbosity:

- ralph-planner/SKILL.md: 596 lines (largest skill in toolkit)
- Expert prompts: 80KB total (UI/UX: 36KB, Architecture: 28KB, PM: 16KB)
- Reference docs: 44KB (artifacts-structure, prodman-templates, prompt-template)
- High duplication across 3 expert prompts (similar structure, depth calibrations)

**Goal:** Reduce code by ~40% while maintaining 100% functionality and spec quality.

## Design Approach

**Strategy:** Moderated Simplification (Balanced)

Extract common patterns into shared base, preserve domain-specific expertise, eliminate duplication without sacrificing spec quality.

## Architecture

### New Structure

```
ralph-planner/
├── SKILL.md (simplified: 596 → 350-400 lines)
├── subagents/
│   ├── _base-expert-prompt.md (NEW: ~200 lines, shared structure)
│   ├── product-manager.md (reduced: 524 → 200-300 lines, specifics only)
│   ├── architecture.md (reduced: 998 → 200-300 lines, specifics only)
│   └── ui-ux.md (reduced: 1240 → 200-300 lines, specifics only)
├── references/
│   ├── prodman-spec-format.md (consolidated: artifacts-structure + prodman-templates)
│   └── prompt-template.md (simplified: 290 → 200 lines)
└── README.md (unchanged)
```

### Base Expert Prompt (_base-expert-prompt.md)

**Contains:**
- Depth calibration framework (levels 1-5)
- Generic workflow integration
- Standard output structure
- Quality checklist template
- Best practices (shared across all experts)

**Template placeholders:**
- `{ROLE}` - Product Manager | Architecture Expert | UI/UX Expert
- `{DOMAIN}` - product requirements | system architecture | user interface
- `{OUTPUT_ARTIFACT}` - PRD.md | ARCHITECTURE.md | UI-SPEC.md

### Expert-Specific Files

Each expert file contains ONLY:
- Role-specific expertise areas
- Domain-specific sections (e.g., PM: user stories, ARCH: C4 diagrams, UI: design tokens)
- Role-specific examples
- Domain-specific validation criteria

**Composition:** Base + Specifics = Full expert prompt (runtime assembly in SKILL.md STEP 2)

## Implementation Plan

### Phase 1: Extract Base Expert Prompt

**File:** `ralph-planner/subagents/_base-expert-prompt.md`

**Content to extract from all 3 experts:**
1. Depth calibration structure (Levels 1-5 framework)
2. Workflow role description (input → your output → next steps)
3. Generic output structure template
4. Best practices section (common to all)
5. Quality checklist (adapt with placeholders)

**Lines:** ~200

### Phase 2: Simplify Expert-Specific Files

#### Product Manager (product-manager.md)

**Keep:**
- PM-specific expertise (RICE, MoSCoW, JTBD)
- PRD sections: Problem Statement, Success Metrics, User Stories, Acceptance Criteria, Scope, NFRs
- 1-2 examples per depth level (not full templates)

**Remove:**
- Generic workflow description (now in base)
- Depth calibration explanations (now in base)
- Repetitive examples
- Full template (reference prodman-spec-format.md instead)

**Target:** 524 → 250 lines

#### Architecture Expert (architecture.md)

**Keep:**
- ARCH-specific expertise (ADRs, C4, NFR coverage)
- Architecture sections: System Design, C4 Diagrams, Database Schema, API Specs, NFRs
- Domain-specific examples (ADR template, C4 examples)

**Remove:**
- Generic workflow (now in base)
- Depth calibration (now in base)
- Duplicated best practices
- Verbose examples (keep 1 concise example per concept)

**Target:** 998 → 300 lines

#### UI/UX Expert (ui-ux.md)

**Keep:**
- UI-specific expertise (Design Systems, Accessibility, Responsive Design)
- UI sections: Design Tokens, Component Library, Accessibility, Responsive Behavior, Interaction Flows
- Domain-specific examples (component states, design token structure)

**Remove:**
- Generic workflow (now in base)
- Depth calibration (now in base)
- Excessive examples (currently 9 "Example" markers - reduce to 3-4 key ones)
- Verbose state descriptions (use tables instead of prose)

**Target:** 1240 → 350 lines

### Phase 3: Simplify SKILL.md

**Current:** 596 lines

**Optimizations:**
1. Reduce verbosity in STEP descriptions (30% reduction)
2. Remove repetitive examples (keep 1 comprehensive example instead of 3)
3. Simplify depth parsing explanation (pseudocode → concise description)
4. Consolidate "after completion" messaging (currently repeated per agent)
5. Reference base-expert-prompt.md instead of re-explaining workflow

**Specific changes:**
- STEP 2 (subagent spawning): Simplify prompt construction instructions
  - Current: Explains reading + replacing `{LEVEL}` for each agent
  - New: "Compose: base-expert-prompt.md + {expert}-specifics.md, replace {LEVEL}"
- Reduce configuration display verbosity
- Consolidate artifact tracking (currently verbose)

**Target:** 596 → 380 lines

### Phase 4: Consolidate References

#### Merge: artifacts-structure.md + prodman-templates.md → prodman-spec-format.md

**Rationale:** These two files describe the same thing (epic/spec format) from different angles

**New file structure:**
1. Overview (what prodman uses)
2. Epic YAML format (from prodman-templates.md)
3. Spec Markdown format (from prodman-templates.md)
4. Artifacts directory structure (from artifacts-structure.md)
5. Examples (1 complete example instead of multiple)

**Target:** 426 + 359 = 785 lines → 400 lines

#### Simplify: prompt-template.md

**Current:** 290 lines

**Optimizations:**
- Remove verbose examples (3 examples → 1 comprehensive)
- Simplify dynamic sections explanation (currently very verbose)
- Consolidate iteration estimation table

**Target:** 290 → 180 lines

### Phase 5: Update SKILL.md Runtime Composition

**STEP 2 prompt construction (for each expert):**

```markdown
**If {expert}Level >= 1, spawn with Task tool:**

**Prompt construction:**
1. Read `ralph-planner/subagents/_base-expert-prompt.md`
2. Read `ralph-planner/subagents/{expert}.md`
3. Compose: Base + Expert-specific content
4. Replace placeholders:
   - `{LEVEL}` → {expert}Level
   - `{ROLE}` → "Product Manager" | "Architecture Expert" | "UI/UX Expert"
   - `{OUTPUT_ARTIFACT}` → "PRD.md" | "ARCHITECTURE.md" | "UI-SPEC.md"
5. Pass composed prompt to Task tool
```

### Phase 6: Simplify ralph.sh (if needed)

**Review:** ralph.sh is already minimal (~176 lines)

**Audit:** Check for any unnecessary verbosity in comments or output

**Target:** Keep as-is or minimal reduction (176 → 160 lines if any improvements found)

## Validation Criteria

### Functionality Preservation (CRITICAL)

**Before/After Tests:**
1. Run ralph-planner on a test feature (e.g., simple CRUD)
2. Verify all 3 experts spawn correctly
3. Compare generated PRD, ARCHITECTURE, UI-SPEC quality
4. Verify epic/spec detail level matches original
5. Run Ralph loop to confirm specs are still actionable

**Success:** Specs are functionally identical in quality and detail

### Code Reduction Metrics

| Component | Before | Target | Reduction |
|-----------|--------|--------|-----------|
| ralph-planner/SKILL.md | 596 lines | 380 lines | 36% |
| Expert prompts total | 2762 lines | 900 lines | 67% |
| References total | 1075 lines | 580 lines | 46% |
| **Total** | **4433 lines** | **1860 lines** | **58%** |

**File size:** ~144KB → ~60KB (~58% reduction)

### Quality Preservation

**Checklist:**
- [ ] Depth calibration (1-5) still works
- [ ] Expert prompts maintain domain expertise
- [ ] Specs still include Architecture + Product + UI context
- [ ] YAGNI principles reinforced (not weakened)
- [ ] SKILL.md still clear and complete
- [ ] Documentation describes file structures precisely

## Anti-Patterns to Avoid

1. **Don't remove domain expertise** - Keep PM/ARCH/UI-specific knowledge
2. **Don't over-DRY** - Some repetition is OK if it aids clarity
3. **Don't lose precision** - File structure descriptions must stay detailed
4. **Don't break composition** - Base + Specifics must work seamlessly
5. **Don't sacrifice examples** - Keep 1-2 key examples per concept

## Implementation Order

1. Create `_base-expert-prompt.md` (extract common structure)
2. Simplify `product-manager.md` (test composition works)
3. Simplify `architecture.md` (verify pattern)
4. Simplify `ui-ux.md` (complete expert simplification)
5. Update `SKILL.md` STEP 2 (runtime composition)
6. Simplify `SKILL.md` rest (remove verbosity)
7. Consolidate references (merge + simplify)
8. Validate with full ralph-planner run
9. Run /code-simplifier on result
10. Run /follow-best-practices

## Success Criteria

✅ Code reduced by 50-60%
✅ Functionality 100% preserved
✅ Spec quality unchanged
✅ File structure descriptions precise
✅ Maintainability improved (base pattern)
✅ YAGNI principles reinforced
✅ All tests pass

## Risk Mitigation

**Risk:** Breaking expert prompt quality
**Mitigation:** Test each expert individually before integrating

**Risk:** Losing important edge case guidance
**Mitigation:** Review each deletion, preserve critical edge cases in base

**Risk:** Runtime composition fails
**Mitigation:** Test composition logic with simple string replacement first

**Risk:** Specs become less detailed
**Mitigation:** Run A/B comparison on same feature before/after
