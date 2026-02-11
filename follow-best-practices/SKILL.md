---
name: follow-best-practices
description: "Run post-implementation best practices: code simplification, artefact creation, CLAUDE.md maintenance, convention compliance, YAGNI check, and optional codex review. Use after completing a feature, bug fix, or any coding session. Triggers on: 'best practices', 'cleanup', 'post-implementation', 'run best practices', or when referenced by other skills."
---

# Follow Best Practices

Run the full post-implementation best practices checklist. Can be invoked standalone or referenced by other skills (ralph-planner, ralph-launch).

See [references/checklist.md](references/checklist.md) for the full checklist definition.

## Process

### Step 1: Detect Scope

Auto-detect what was worked on:
- Run `git diff --name-only` and `git diff --cached --name-only` to find changed files
- Run `git status` to find untracked files
- Analyze the changes to identify the feature/work area

Present a summary to the user:

```
Looks like you worked on: {description based on changed files}
Suggested slug for artefacts: `{slug}`

Is that right, or would you like to adjust?
```

If the scope is unclear or spans unrelated areas, ask the user to clarify.

### Step 2: Run the Checklist

Execute each item from [references/checklist.md](references/checklist.md) in order:

1. **Code simplification** — Run `/code-simplifier` on changed files
2. **Artefacts** — Create `.artefacts/{slug}/TESTING.md` and `CHANGELOG.md`
3. **CLAUDE.md maintenance** — Run `/claude-md-improver` and `/claude-md-management:revise-claude-md`
4. **Convention compliance** — Check against `CLAUDE.md` and `AGENTS.md`
5. **YAGNI check** — Flag anything that looks like scope creep
6. **Codex review** — Ask once: "Want me to run a codex review? (off by default)" — if yes, run `/codex-review`

### Step 3: Report

Summarize what was done:

```
Best practices complete:
- [x] Code simplified
- [x] Artefacts created at .artefacts/{slug}/
- [x] CLAUDE.md updated
- [x] Conventions verified
- [x] YAGNI check passed
- [ ] Codex review (skipped / passed / issues fixed)
```

## Key Principles

- **Auto-detect, then confirm** — Don't make the user describe what they worked on if git can tell you
- **Single source of truth** — The checklist lives in `references/checklist.md`, shared with ralph skills
- **Non-destructive** — This skill only adds/improves, never deletes user code
- **Fast** — Skip steps that don't apply (e.g., no AGENTS.md in the project = skip that check)
