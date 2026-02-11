# Project Setup with Prodman + Ralph Workflow

I have installed the claude-toolkit skills and plugins. I've created a basic `.prodman/` structure but it needs to be completed. Please help me set up this project properly for feature development using the prodman + ralph workflow.

## What I need you to do:

### 1. Verify/Complete Prodman Structure

Check if the following structure exists and create missing parts:

```
.prodman/
├── config.yaml           # Project metadata + counters
├── epics/                # Feature epics (EP-XXX-slug.yaml)
├── specs/                # Implementation specs (SPEC-XXX-slug.md)
└── archives/             # Completed epics/specs moved here
```

**`.prodman/config.yaml` template:**
```yaml
project:
  name: "{project-name}"
  description: "{brief description}"

counters:
  epic: 1      # Next available epic number
  spec: 1      # Next available spec number

workflow:
  default_branch: main
  epic_template: epics/EP-{XXX}-{slug}.yaml
  spec_template: specs/SPEC-{XXX}-{slug}.md
```

If this file doesn't exist, create it with appropriate values for this project.

### 2. Create/Update CLAUDE.md

Create a comprehensive `CLAUDE.md` at the project root that documents:

**Required sections:**

```markdown
# Project Overview

{Brief description of what this project does}

## Tech Stack

- **Language:** {language/framework}
- **Key Dependencies:** {main libraries}
- **Build Tool:** {npm/cargo/etc}
- **Testing:** {test framework}

## Project Structure

{Overview of main directories and their purpose}

## Development Workflow

### Feature Development Process

We use the **Prodman + Ralph workflow** for all features:

1. **Planning Phase** - Use `/ralph-planner` or `/ralph-launch`
   - Collaborative brainstorming (ralph-planner) OR quick launch (ralph-launch)
   - Generates epic (.prodman/epics/EP-XXX.yaml)
   - Generates spec (.prodman/specs/SPEC-XXX.md)
   - Outputs a `/ralph-wiggum:ralph-loop` command

2. **Implementation Phase** - Run the Ralph loop
   - Copy-paste the generated loop command
   - Ralph executes the spec task-by-task
   - Auto-commits after each task
   - Tracks progress in progress.txt

3. **Completion Phase** - Best practices checklist
   - Run `/follow-best-practices` after implementation
   - Code simplification
   - Artefact creation (.artefacts/{feature}/)
   - CLAUDE.md maintenance
   - Convention compliance
   - Optional codex review

### When NOT to use Ralph

- **Quick fixes** (1-2 line changes) → just edit directly
- **Exploratory work** → use Claude normally, then formalize if it becomes a feature
- **Documentation updates** → edit directly unless part of a larger feature

## Coding Conventions

{Document your project's conventions:}
- Code style (formatting, naming, etc.)
- File organization patterns
- Testing requirements
- Commit message format
- Error handling patterns
- Security considerations

## Critical Files & Patterns

{Document important files, patterns, or gotchas that Claude should know about}

Example:
- `config/app.config.ts` - Main app configuration, uses Zod validation
- `lib/db/` - Database layer, always use prepared statements
- Never import from `./internal/` outside of lib/

## Common Tasks

### Running Tests
```bash
{command to run tests}
```

### Building
```bash
{build command}
```

### Linting
```bash
{lint command}
```

## Dependencies

{Document when/how to add dependencies, any restrictions}

## Security Notes

{Any security-critical patterns or requirements}
```

**After creating CLAUDE.md:**
- Review it with me to ensure accuracy
- I'll help fill in any missing project-specific details

### 3. Create Artefacts Directory Structure

Create the artefacts directory if it doesn't exist:

```
.artefacts/
└── .gitkeep
```

This is where feature documentation (TESTING.md, CHANGELOG.md) will be stored after implementation.

### 4. Verify Git Setup

Check:
- [ ] `.gitignore` includes appropriate entries
- [ ] `.prodman/archives/` is gitignored (optional - decide based on your needs)
- [ ] `progress.txt` is gitignored (generated during Ralph loops)

### 5. Summary Report

After completing the setup, provide me with:

1. **What was created:** List of new files/directories
2. **What already existed:** Confirmation of existing structure
3. **Next steps:** How to start using the workflow
4. **Quick start example:** Show me how to launch my first feature with ralph-planner

## Important Notes

- **All documentation must be in English**
- **Don't create example epics/specs** - wait for real features
- **Ask questions** if any project-specific information is unclear
- **Be concise** - only document what's necessary, avoid over-engineering

---

Please start by exploring the current project structure and then proceed with the setup steps above.
