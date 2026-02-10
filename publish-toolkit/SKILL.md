---
name: publish-toolkit
description: "Sync local skills to the claude-toolkit repo and optionally commit + push. Use when you've edited skills and want to publish changes for collaborators. Triggers on: 'publish toolkit', 'sync skills', 'push skills', 'update toolkit'."
---

# Publish Toolkit

Sync skills from `~/.claude/skills/` to the `claude-toolkit` repo, then commit and push.

## Process

### Step 1: Sync

Run the sync script:

```bash
~/Projects/claude-toolkit/sync.sh
```

If the user says "include new skills" or "add all", run with `--all`:

```bash
~/Projects/claude-toolkit/sync.sh --all
```

### Step 2: Review changes

Run `git -C ~/Projects/claude-toolkit status` and `git -C ~/Projects/claude-toolkit diff` to show the user what changed.

Present a summary:
```
Changes to publish:
- modified: ralph-planner/SKILL.md (updated brainstorm rules)
- added: new-skill/SKILL.md
```

### Step 3: Commit and push

Ask the user for a commit message, or propose one based on the changes.

Then:

```bash
cd ~/Projects/claude-toolkit && git add . && git commit -m "{message}" && git push
```

If the repo hasn't been pushed to GitHub yet, inform the user they need to create it first:

```bash
cd ~/Projects/claude-toolkit && gh repo create claude-toolkit --public --source=. --push
```

## Key Principles

- **Always sync before committing** — never commit stale files
- **Show diff before pushing** — let the user review what goes out
- **Don't auto-push** — always confirm with the user before `git push`
