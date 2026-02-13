# Ralph Planner v2

**Plan features with expert subagents, then launch Ralph loops for implementation.**

Ralph Planner v2 uses 3 specialized AI agents (Product Manager, Architecture Expert, UI/UX Expert) to create ultra-detailed specifications that enable faster, higher-quality implementation.

---

## 🚀 Quick Start

```bash
/ralph-planner "build user authentication"
```

That's it! Ralph-planner will:
1. Run collaborative brainstorming
2. Ask you "TB or ND?" (contributor)
3. Spawn 3 expert agents to create specifications
4. Assemble ultra-detailed epic + spec
5. Generate ready-to-launch Ralph loop command

**Time:** ~5-7 minutes (including 3 agents)
**Output:** Epic, Spec (3x more detailed than v1), and 3 expert artifacts

---

## ✨ What's New in v2

### Expert Subagents

**3 specialized agents** create comprehensive specifications:

1. **Product Manager** → PRD.md
   - Problem statement, success metrics
   - User stories, acceptance criteria
   - Feature breakdown, scope definition

2. **Architecture Expert** → ARCHITECTURE.md
   - Architecture Decision Records (ADRs)
   - C4 diagrams, database schema, API specs
   - NFR coverage (performance, security, scalability)

3. **UI/UX Expert** → UI-SPEC.md
   - Design tokens (typography, colors, spacing)
   - Component library (states, variants, accessibility)
   - Responsive design, interaction flows

### Ultra-Detailed Specs

**Each task in the spec now includes:**

```markdown
### Task 3: Create UserProfileCard Component

**Files:** (from ARCHITECTURE)
- Create: src/components/UserProfileCard/UserProfileCard.tsx

**Architecture Context:**
Component uses Observer pattern for real-time updates...

**UI Specification:**
- Design tokens: avatar 64px, spacing-md, color-success
- States: loading, success, error
- Accessibility: ARIA labels, WCAG 2.1 AA

**Product Requirements:**
Must meet AC-2.1: status updates < 1s latency

**Implementation Steps:**
1. Create types
2. Implement component structure
3. Wire up WebSocket subscription
4. Add accessibility
```

### Artifact Storage

All expert specifications saved for reference:

```
.prodman/artifacts/EP-TB-003-user-auth/
├── PRD.md               (Product Requirements)
├── ARCHITECTURE.md      (Architecture Design)
└── UI-SPEC.md          (UI Specification)
```

Ralph loop can consult these during implementation.

---

## 📖 How It Works

### 5-Step Workflow

```
1. Brainstorming
   ↓ design.md created
2. Ask Contributor (TB or ND)
   ↓ epic ID determined
3. Spawn 3 Expert Subagents
   ↓ PRD, ARCHITECTURE, UI-SPEC created
4. Assemble Ultra-Detailed Artifacts
   ↓ epic + spec created
5. Generate Ralph Loop Command
   ↓ ready to launch
```

### Example Session

```
You: /ralph-planner "add dark mode toggle"

Claude: [Runs brainstorming]
        Who is creating this epic? (TB or ND)

You: TB

Claude: 🤖 Spawning Product Manager expert...
        ✓ PRD created: .prodman/artifacts/EP-TB-003-dark-mode/PRD.md

        🤖 Spawning Architecture expert...
        ✓ Architecture created: .prodman/artifacts/EP-TB-003-dark-mode/ARCHITECTURE.md

        🤖 Spawning UI/UX expert...
        ✓ UI spec created: .prodman/artifacts/EP-TB-003-dark-mode/UI-SPEC.md

        ✓ Created EP-TB-003 and SPEC-TB-003

        Here's your Ralph loop command (~15 iterations for 5 tasks):

        /ralph-wiggum:ralph-loop "..." --completion-promise "EP-TB-003 COMPLETE" --max-iterations 15

        Copy and paste to launch!
```

---

## 🎯 Benefits

### vs Ralph Planner v1

| Aspect | v1 | v2 |
|--------|----|----|
| **Spec Detail** | Basic tasks | Ultra-detailed with 3 contexts |
| **Context** | Design doc only | PRD + ARCH + UI-SPEC |
| **Time** | 2-3 min | 5-7 min |
| **Ralph Errors** | Moderate | Significantly fewer |
| **Traceability** | Limited | Full (PRD → ARCH → UI → Code) |

### vs BMAD Method

| Aspect | BMAD | Ralph Planner v2 |
|--------|------|------------------|
| **Agents** | 12+ | 3 (focused) |
| **Workflow** | Separate phases | Integrated with ralph loop |
| **Time** | 10-15 min | 5-7 min |
| **Customization** | Generic | TB/ND contributor system |
| **Integration** | Standalone | Seamless with toolkit |

---

## 📁 File Structure

```
.prodman/
├── config.yaml                           # TB/ND counters
├── epics/
│   ├── EP-TB-001-feature-a.yaml
│   └── EP-ND-001-feature-b.yaml
├── specs/
│   ├── SPEC-TB-001-feature-a.md         # Ultra-detailed
│   └── SPEC-ND-001-feature-b.md
└── artifacts/                            # ⭐ NEW IN V2
    ├── EP-TB-001-feature-a/
    │   ├── PRD.md                        # Product Requirements
    │   ├── ARCHITECTURE.md               # Architecture Design
    │   └── UI-SPEC.md                    # UI Specification
    └── EP-ND-001-feature-b/
        ├── PRD.md
        ├── ARCHITECTURE.md
        └── UI-SPEC.md
```

---

## 🔧 Configuration

### Contributor Setup

Edit `.prodman/config.yaml`:

```yaml
contributors:
  TB:
    name: Tom
    counters:
      epic: 3
      spec: 3
  ND:
    name: Nikita Dmitrieff
    counters:
      epic: 17
      spec: 17
```

Ralph-planner will ask which contributor and use the appropriate counter.

---

## 📚 Documentation

- **SKILL.md** - Complete workflow steps
- **SKILL_NOTES.md** - Implementation notes and changes
- **references/prodman-templates.md** - Epic and spec formats
- **references/prompt-template.md** - Ralph loop command structure
- **references/artifacts-structure.md** - Deep dive on artifacts
- **subagents/** - Expert agent prompts (reference only)

---

## 🧪 Testing

Ralph Planner v2 has been validated with:
- ✅ Structure validation (all files created)
- ✅ Workflow simulation (5-step process verified)
- ✅ Format validation (EP-{CONTRIBUTOR}-{NUMBER} format)
- ✅ Content validation (PRD/ARCH/UI synthesis)
- ✅ BMAD comparison (comparable quality, better integration)

See `.research/TEST_VALIDATION.md` for detailed test results.

---

## 🔄 Migration from v1

**Backward Compatible:** Old v1 epics/specs continue to work.

**Gradual Adoption:**
- New features → Use v2 (with artifacts)
- Old features → Remain v1 (no artifacts)
- No migration needed

**Identifying Version:**
- v1: No `.prodman/artifacts/` directory
- v2: Has artifacts directory with PRD, ARCHITECTURE, UI-SPEC

---

## 💡 Tips

### For Best Results

1. **Be specific in brainstorming** - More context = better specs
2. **Review artifacts** - Check PRD/ARCH/UI before Ralph loop
3. **Consult artifacts during implementation** - Ralph loop can reference them
4. **Use for complex features** - v2 shines with multi-component features
5. **Simpler features?** - v1 (without subagents) might be faster

### When to Use v2

✅ **Use v2 for:**
- Multi-component features
- Features with UI + backend + database
- Features requiring accessibility compliance
- Features with performance requirements
- Complex user flows

⏭️ **Skip to v1 for:**
- Trivial bug fixes
- Single-file changes
- Quick config updates
- Documentation-only changes

---

## 🐛 Troubleshooting

### "Subagent failed to create artifact"

**Cause:** Subagent prompt may be too complex for context
**Fix:** Simplify design.md or break into smaller features

### "Spec tasks don't include context"

**Cause:** Assembly step didn't synthesize artifacts correctly
**Fix:** Check that PRD, ARCH, UI-SPEC were created successfully

### "Ralph loop can't find artifacts"

**Cause:** Path in Ralph loop prompt is incorrect
**Fix:** Verify paths match actual artifact locations

### "TB/ND counter out of sync"

**Cause:** Manual epic creation without updating config
**Fix:** Update `.prodman/config.yaml` counters manually

---

## 🚦 Workflow Checklist

**Before launching ralph-planner:**
- [ ] Clear feature idea (what to build)
- [ ] Access to `.prodman/config.yaml` (for counter)
- [ ] 5-7 minutes available (for subagents)

**During ralph-planner:**
- [ ] Participate in brainstorming (answer questions)
- [ ] Specify contributor when asked (TB or ND)
- [ ] Wait for all 3 subagents to complete (~5 min)
- [ ] Review generated epic/spec (optional but recommended)

**After ralph-planner:**
- [ ] Copy Ralph loop command
- [ ] Paste and launch in project directory
- [ ] Monitor progress via `progress.txt`

---

## 🎓 Learning Resources

### Understanding the Agents

- **Product Manager Prompt** - `subagents/product-manager-prompt.md`
  Learn: RICE prioritization, user stories, acceptance criteria

- **Architecture Expert Prompt** - `subagents/architecture-expert-prompt.md`
  Learn: ADRs, C4 model, NFR coverage, API design

- **UI/UX Expert Prompt** - `subagents/ui-ux-expert-prompt.md`
  Learn: Design tokens, WCAG 2.1 AA, responsive design

### Research Documents

- `.research/phase1-frameworks-comparison.md` - BMAD vs Spec Kit vs OpenSpec
- `.research/phase1-best-practices-summary.md` - Industry best practices
- `.research/TEST_VALIDATION.md` - Validation test results

---

## 📝 Version History

### v2.0 (2026-02-13)
- ✨ Added 3 expert subagents (Product Manager, Architecture, UI/UX)
- ✨ Ultra-detailed spec format with PRD/ARCH/UI contexts
- ✨ Artifact storage system for expert specifications
- ✨ Enhanced templates for comprehensive task descriptions
- ✨ Ralph loop integration with artifact references
- ✅ Backward compatible with v1 epics/specs

### v1.0 (Original)
- Basic brainstorming → epic/spec → Ralph loop workflow
- Single-context spec tasks
- No artifact storage

---

## 🤝 Contributing

Improvements welcome! Key areas:
- Additional expert agents (QA, DevOps, Security)
- Enhanced artifact templates
- Automated artifact validation
- Cross-project artifact reuse

---

## 📄 License

Part of claude-toolkit. Same license applies.

---

## 🆘 Support

**Questions?** Check:
1. This README
2. `SKILL.md` (detailed workflow)
3. `references/artifacts-structure.md` (deep dive)
4. `.research/TEST_VALIDATION.md` (examples)

**Issues?** File in claude-toolkit repo.

---

**Ralph Planner v2** - Spec-driven development with expert AI agents. 🚀
