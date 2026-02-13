# Ralph Planner v2 - Implementation Notes

## Changes from v1

### Old Workflow (v1)
1. Brainstorming → design.md
2. Create epic + spec from design.md
3. Generate Ralph loop command

### New Workflow (v2)
1. Brainstorming → design.md
2. Ask contributor (TB/ND)
3. **Spawn 3 expert subagents**:
   - Product Manager → PRD.md
   - Architecture Expert → ARCHITECTURE.md
   - UI/UX Expert → UI-SPEC.md
4. **Assemble artifacts** → epic + ultra-detailed spec
5. Generate Ralph loop command

## Key Improvements

### 1. Expert Subagents
- **Product Manager**: Creates comprehensive PRD with user stories, metrics, acceptance criteria
- **Architecture Expert**: Designs system with ADRs, C4 diagrams, NFR coverage
- **UI/UX Expert**: Specifies UI with design tokens, accessibility, responsive design

### 2. Ultra-Detailed Specs
Each task in the spec now includes:
- **Architecture Context**: Component structure, patterns, data flow
- **UI Specification**: Design tokens, states, accessibility requirements
- **Product Requirements**: Acceptance criteria, user value, metrics

### 3. Artifacts Storage
All intermediate artifacts saved in:
```
.prodman/artifacts/EP-{CONTRIBUTOR}-{NUMBER}-{slug}/
├── PRD.md
├── ARCHITECTURE.md
└── UI-SPEC.md
```

### 4. Contributor-Based Numbering
- Supports TB (Tom) and ND (Nikita) with separate counters
- Format: `EP-TB-003`, `EP-ND-017`
- Always asks user "Who is creating this epic?"

## Implementation Details

### Subagent Execution
- **Sequential execution** (not parallel) recommended
- Product Manager first → defines WHAT and WHY
- Architecture Expert second → defines HOW (technical)
- UI/UX Expert third → defines HOW (interface)

### Task Synthesis
Each task assembles information from:
- **PRD**: User stories, acceptance criteria, success metrics
- **ARCHITECTURE**: File paths, components, APIs, database schema
- **UI-SPEC**: Design tokens, component states, accessibility, responsive behavior

### Prompt System
Subagent prompts stored in:
- `ralph-planner/subagents/product-manager-prompt.md`
- `ralph-planner/subagents/architecture-expert-prompt.md`
- `ralph-planner/subagents/ui-ux-expert-prompt.md`

## Benefits

1. **3x More Detailed Specs**: Tasks include architectural, UI, and product context
2. **Fewer Ralph Loop Errors**: Clear implementation guidance reduces ambiguity
3. **Better Traceability**: PRD user stories → Architecture components → UI components
4. **Reusable Artifacts**: PRD/ARCH/UI can be referenced during implementation

## Backward Compatibility

- Old epics/specs still work (no migration needed)
- New workflow only applies to new features created via ralph-planner
- Ralph loop reads specs the same way (enhanced task format is additive)

## Testing Strategy

After implementation:
1. Test with a real feature (simple example)
2. Verify all 3 subagents spawn correctly
3. Verify PRD, ARCH, UI artifacts are created
4. Verify epic/spec are ultra-detailed
5. Verify Ralph loop command is correct
6. Run Ralph loop to ensure specs are actionable
