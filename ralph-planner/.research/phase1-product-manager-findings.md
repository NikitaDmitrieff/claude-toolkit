# Product Manager Agent Research - Findings

## Source 1: alirezarezvani/claude-skills Product Manager Toolkit

**URL:** https://github.com/alirezarezvani/claude-skills/blob/main/product-team/product-manager-toolkit/SKILL.md

### Key Insights

**Comprehensive PM toolkit with:**
- RICE prioritization framework
- Customer interview analysis
- PRD development process
- Discovery frameworks
- Go-to-market strategies

### Core Workflows

1. **Feature Prioritization Process**
   ```
   Gather → Score → Analyze → Plan → Validate → Execute
   ```

2. **Customer Discovery Process**
   ```
   Plan → Recruit → Interview → Analyze → Synthesize → Validate
   ```

3. **PRD Development Process**
   ```
   Scope → Draft → Review → Refine → Approve → Track
   ```

### PRD Templates Available

| Template | Use Case | Timeline |
|----------|----------|----------|
| Standard PRD | Complex features, cross-team | 6-8 weeks |
| One-Page PRD | Simple features, single team | 2-4 weeks |
| Feature Brief | Exploration phase | 1 week |
| Agile Epic | Sprint-based delivery | Ongoing |

### PRD Best Practices

**Writing Great PRDs:**
- Start with the problem, not the solution
- Include clear success metrics upfront
- Explicitly state what's out of scope
- Use visuals (wireframes, flows, diagrams)
- Keep technical details in appendix
- Version control all changes

### PRD Structure (Standard Template)

Based on the skill, a PRD should include:

1. **Problem Statement** (lead with this)
2. **Success Metrics** (define upfront)
3. **Scope**
   - In-scope features
   - **Explicitly** out-of-scope items
4. **User Stories / Jobs to be Done**
5. **Wireframes/Mockups**
6. **Technical Feasibility** (from engineering review)
7. **Market Validation** (from sales)
8. **Operational Impact** (from support)
9. **Trade-off Decisions** (documented)

### Validation Checklist (Before Finalizing)

- [ ] Compare against strategic goals
- [ ] Run sensitivity analysis (what if estimates wrong by 2x?)
- [ ] Review with stakeholders for blind spots
- [ ] Check for missing dependencies
- [ ] Validate effort estimates with engineering

### Post-Launch Tracking

- [ ] Compare actual metrics vs targets
- [ ] Conduct user feedback sessions
- [ ] Document what worked and what didn't
- [ ] Update estimation accuracy data
- [ ] Share learnings with team

## Key Takeaways for Our Product Manager Subagent

1. **Focus on problem first** - Always start PRD with problem statement
2. **Metrics-driven** - Define success metrics upfront
3. **Scope management** - Explicitly state out-of-scope
4. **Validation gates** - Multiple review cycles before approval
5. **Post-launch learning** - Track actual vs predicted metrics

## Adaptation for Ralph-Planner Workflow

Our Product Manager subagent should:
- **Input:** design.md (from brainstorming)
- **Output:** PRD.md with:
  - Problem statement
  - User stories (linked to acceptance criteria)
  - Success metrics
  - Scope (in/out)
  - Jobs to be done
  - Validation against strategic goals

This PRD will then feed into:
- Architecture Expert (for technical design)
- UI Expert (for interface design)
- Final epic/spec assembly

## Next Steps

- Continue research on System Architect agent
- Continue research on UX Designer agent
- Compare with other frameworks (BMAD official, Spec Kit, OpenSpec)
- Synthesize findings into our custom prompt
