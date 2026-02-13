# Spec-Driven Development Frameworks Comparison

## Sources

- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec)
- [Framework Comparison Article](https://redreamality.com/blog/-sddbmad-vs-spec-kit-vs-openspec-vs-promptx/)

## What is Spec-Driven Development (SDD)?

**Definition:** Making technical decisions explicit, reviewable, and evolvable. Think of it as version control for your thinking.

**Key Principle:** Specifications become executable, directly generating working implementations rather than just guiding them.

**Why SDD?** Moves beyond quick "vibe-coding" experiments toward repeatable, verifiable workflow.

---

## Framework Comparison Matrix

| Framework | Philosophy | Best For | Complexity | Key Features |
|-----------|------------|----------|------------|--------------|
| **BMAD** | Full agile team simulation | Greenfield products, complex features | HIGH | 12+ agents, 50+ workflows, scale-adaptive |
| **Spec Kit** | Microsoft-backed, rigorous | Enterprise teams, heavy governance | MEDIUM-HIGH | Templates, CLI, phase gates |
| **OpenSpec** | Lightweight, brownfield-first | Existing codebases, iterative teams | LOW | No API keys, 20+ tool support, TypeScript |
| **PromptX** | Context management platform | Expert teams, custom AI workflows | MEDIUM | MCP-based, conversational, "AI as person" |

---

## GitHub Spec Kit (Microsoft)

**URL:** https://github.com/github/spec-kit
**License:** MIT
**Language:** Python

### Core Components

1. **Templates** - Structured specification formats
2. **CLI Tools** - Commands for scaffolding and validation
3. **Prompts** - AI agent instructions

### Six Core Principles

1. **Specifications as lingua franca** - Spec is the primary artifact
2. **Executable specifications** - Precise enough to generate working systems
3. **Continuous refinement** - AI analyzes specs for ambiguity and gaps
4. **Research-driven context** - Research agents gather critical context
5. **Version control for thinking** - Track evolution of technical decisions
6. **Reviewable and evolvable** - Specs can be reviewed like code

### Workflow

```
Specification → Technical Plan → Testable Tasks → AI Implementation
```

### Phase Gates

- Heavy governance with explicit gates
- Rigorous validation at each phase
- Documentation-centric

### Pros

✅ Enterprise-ready
✅ Microsoft backing
✅ Thorough documentation
✅ Clear phase structure

### Cons

❌ Heavyweight (lots of Markdown)
❌ Python setup required
❌ Rigid phase gates
❌ Can slow down iteration

### When to Use

- Large enterprise teams
- Projects requiring heavy governance
- Compliance-heavy domains
- Teams new to SDD (good structure)

---

## OpenSpec

**URL:** https://github.com/Fission-AI/OpenSpec
**License:** Open Source
**Language:** TypeScript

### Philosophy

**Brownfield-first:** Most work happens on existing codebases (1→n), not greenfield (0→1).

**Lightweight:** Add a spec layer without heavy process overhead.

**Universal:** Works with 20+ tools (Claude Code, Cursor, GitHub Copilot, etc.)

### Core Features

- No API keys required
- No MCP required
- Simple `npm install`
- Iterate freely (no rigid gates)
- Minimal setup

### Workflow

```
Agree on spec → Write code → Iterate
```

### Pros

✅ Lightweight and fast
✅ Brownfield-focused (realistic)
✅ TypeScript ecosystem
✅ Free iteration
✅ No API dependencies

### Cons

❌ Less structure than Spec Kit
❌ Less guidance for beginners
❌ Fewer templates

### When to Use

- Existing codebases (brownfield)
- Teams that value speed over governance
- TypeScript/Node.js shops
- Teams already comfortable with AI coding

---

## PromptX

**Philosophy:** Treat AI as a person, not software.

**Type:** Context management platform (not a workflow tool)

### Core Features

- MCP-based (Model Context Protocol)
- Conversational interaction (no commands/syntax)
- Custom context injection
- Works on top of existing tools (Cursor, Claude)

### Workflow

```
Define context → Converse with AI → AI generates with full context
```

### Pros

✅ Natural conversational interface
✅ Deep custom context
✅ Supercharges existing workflows
✅ Expert-level augmentation

### Cons

❌ Requires MCP setup
❌ Less structured than SDD frameworks
❌ Not workflow-oriented

### When to Use

- Expert teams already using Cursor/Claude
- Need deep, custom context management
- Want conversational interface
- Not looking for rigid workflow

---

## BMAD vs Others

**BMAD strengths:**
- Most comprehensive (12+ agents, 50+ workflows)
- Simulates full agile team
- Scale-adaptive intelligence
- Strong for greenfield products

**BMAD vs Spec Kit:**
- BMAD: Agent-centric, Party Mode, more fun
- Spec Kit: Process-centric, more rigorous, enterprise-friendly

**BMAD vs OpenSpec:**
- BMAD: Heavyweight, greenfield-focused
- OpenSpec: Lightweight, brownfield-focused

---

## Key Takeaways for Ralph-Planner

### What to Adopt

1. **Spec Kit's Core Principles**
   - Specifications as primary artifact
   - Executable specifications
   - Continuous refinement
   - Research-driven context

2. **OpenSpec's Philosophy**
   - Brownfield-first (ralph-planner works on existing projects)
   - Lightweight process
   - Free iteration

3. **BMAD's Agent Approach**
   - Specialized agents (PM, Architect, UX)
   - Structured workflows
   - Scale-adaptive

### What to Avoid

❌ Spec Kit's heavyweight governance (too slow)
❌ OpenSpec's lack of structure (we want guidance)
❌ PromptX's conversational looseness (we want workflow)

### Our Hybrid Approach

**Best of all worlds:**

- **BMAD agents** (PM, Architect, UX) for expertise
- **Spec Kit principles** (executable specs, refinement)
- **OpenSpec speed** (lightweight, fast iteration)
- **Ralph-planner integration** (seamless with existing workflow)

**Result:**
- 3 expert agents (not 12+, too heavy)
- Structured but not rigid (no phase gates)
- Executable specs (PRD, ARCH, UI → final spec)
- Brownfield-friendly (works on connect-coby)
- TB/ND counter system preserved

---

## Comparative Workflow

| Phase | Spec Kit | OpenSpec | BMAD | Ralph-Planner (Our Approach) |
|-------|----------|----------|------|------------------------------|
| **Discovery** | Research agent | Spec draft | Analyst → PM | Brainstorming skill |
| **Planning** | Spec refinement | Spec iteration | PM → PRD | PM agent → PRD.md |
| **Architecture** | Tech plan | (implicit) | Architect | Architect agent → ARCHITECTURE.md |
| **UI/UX** | (implicit) | (implicit) | UX Designer | UI agent → UI-SPEC.md |
| **Breakdown** | Task decomposition | Task list | Scrum Master → Stories | Assemble → Epic/Spec |
| **Implementation** | AI agents | AI coding | Developer agent | Ralph loop |
| **Validation** | Review gates | Tests | QA agent | Ralph loop + codex-review |

---

## Conclusion

Our ralph-planner approach is a **hybrid SDD framework** inspired by:

- **BMAD** - Agent structure and workflows
- **Spec Kit** - Executable specification principles
- **OpenSpec** - Lightweight, brownfield-first philosophy

**Unique value:**
- Tailored to your workflow (TB/ND, prodman, Ralph loop)
- Not as heavy as BMAD (3 agents vs 12+)
- Not as rigid as Spec Kit (no phase gates)
- More structured than OpenSpec (guided workflows)

**Result:** Specs 3x more detailed than current, without slowing you down.

## Sources

- [Diving Into Spec-Driven Development With GitHub Spec Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit)
- [GitHub Spec Kit Repository](https://github.com/github/spec-kit)
- [OpenSpec Repository](https://github.com/Fission-AI/OpenSpec)
- [Framework Comparison](https://redreamality.com/blog/-sddbmad-vs-spec-kit-vs-openspec-vs-promptx/)
- [OpenSpec Deep Dive](https://redreamality.com/garden/notes/openspec-guide/)
