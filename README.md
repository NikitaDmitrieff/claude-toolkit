# Claude Toolkit

A collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Install once, update with `git pull`.

## Skills Included

| Skill | What it does |
|-------|-------------|
| **follow-best-practices** | Post-implementation checklist: code simplification, artefact creation, CLAUDE.md maintenance, convention compliance, YAGNI check, optional codex review. Works standalone or inside ralph loops. |
| **ralph-planner** | Collaborative brainstorming → prodman artifacts (epic + spec) → Ralph loop command. Full planning flow. |
| **ralph-launch** | Skip brainstorming — go straight from a feature description to artifacts + Ralph loop command. |
| **codex-review** | Independent code review using OpenAI Codex MCP as a second opinion. |
| **publish-toolkit** | Sync local skills to this repo and commit + push. For toolkit maintainers only. |
| **tdd_cycle** | Enforces Red-Green-Refactor TDD cycle. |
| **test-and-commit** | Run tests then commit if they pass. |
| **skill-creator** | Guide for creating new Claude Code skills. |

## Two Roles

This repo supports two workflows:

### Collaborator (your friend)

Clone → install → get updates via `git pull`.

### Maintainer (you, the skills author)

Edit skills in `~/.claude/skills/` → sync to this repo → commit + push. Collaborators get your changes on their next `git pull`.

---

## Collaborator Setup

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working
- Git

### Steps

1. **Clone this repo:**

   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-toolkit.git
   cd claude-toolkit
   ```

2. **Run the installer:**

   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   This symlinks every skill into `~/.claude/skills/`. Updates are just a `git pull` — no re-install needed.

3. **Install required plugins** (inside Claude Code):

   ```
   /install-plugin code-simplifier
   /install-plugin claude-md-management
   /install-plugin superpowers
   ```

4. **Install optional plugins** (inside Claude Code):

   ```
   /install-plugin codex              # for /codex-review
   /install-plugin ralph-wiggum       # required for ralph-launch / ralph-planner
   /install-plugin context7           # up-to-date library docs
   ```

### Getting Updates

```bash
cd /path/to/claude-toolkit
git pull
```

That's it. Since skills are symlinked, changes are picked up immediately.

### Uninstalling

Remove the symlinks from `~/.claude/skills/`:

```bash
# Remove all toolkit symlinks
cd ~/.claude/skills
find . -maxdepth 1 -type l -lname '*/claude-toolkit/*' -delete
```

Or remove individual skills:

```bash
rm ~/.claude/skills/follow-best-practices
rm ~/.claude/skills/ralph-planner
# etc.
```

---

## Maintainer Workflow

As the toolkit author, you edit skills directly in `~/.claude/skills/` (your source of truth). When you're ready to share changes:

### Option A: Use the `/publish-toolkit` skill (inside Claude Code)

Just say "publish toolkit" or "sync skills" in Claude Code. It will:
1. Run `sync.sh` to copy your latest skills into this repo
2. Show you a diff of what changed
3. Commit and push with your approval

### Option B: Manual sync

```bash
cd /path/to/claude-toolkit

# Sync existing skills from ~/.claude/skills/ → this repo
./sync.sh

# Or sync + detect new skills you've created
./sync.sh --all

# Review, commit, push
git add .
git commit -m "update skills"
git push
```

### Adding a new skill to the toolkit

1. Create the skill as usual in `~/.claude/skills/my-new-skill/SKILL.md`
2. Run `./sync.sh --all` — it will detect the new skill and ask to add it
3. Commit and push

---

## WSL / Linux Notes

Both scripts (`install.sh` and `sync.sh`) work on macOS and Linux/WSL. If you're on WSL:

- Make sure Claude Code is installed **inside WSL**, not on the Windows side
- `~/.claude` should be in your WSL home directory (not `/mnt/c/Users/...`)
- Symlinks work natively in WSL, no extra config needed

## Repo Structure

```
claude-toolkit/
├── install.sh                          # For collaborators: symlinks skills into ~/.claude/skills/
├── sync.sh                             # For maintainers: copies ~/.claude/skills/ → this repo
├── README.md                           # This file
├── follow-best-practices/
│   ├── SKILL.md                        # Standalone skill definition
│   └── references/
│       └── checklist.md                # Single source of truth for best practices
├── ralph-planner/
│   ├── SKILL.md
│   └── references/
│       ├── prodman-templates.md        # Epic + spec templates
│       └── prompt-template.md          # Ralph loop prompt structure
├── ralph-launch/
│   └── SKILL.md
├── codex-review/
│   └── SKILL.md
├── publish-toolkit/
│   └── SKILL.md
├── tdd_cycle/
│   └── SKILL.md
├── test-and-commit/
│   └── SKILL.md
├── skill-creator/
│   └── SKILL.md
└── reddit-fetch/
    └── SKILL.md
```
