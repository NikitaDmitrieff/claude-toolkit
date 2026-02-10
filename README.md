# Claude Toolkit

A collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Install once, update with `git pull`.

## Skills Included

| Skill | What it does |
|-------|-------------|
| **follow-best-practices** | Post-implementation checklist: code simplification, artefact creation, CLAUDE.md maintenance, convention compliance, YAGNI check, optional codex review. Works standalone or inside ralph loops. |
| **ralph-planner** | Collaborative brainstorming → prodman artifacts (epic + spec) → Ralph loop command. Full planning flow. |
| **ralph-launch** | Skip brainstorming — go straight from a feature description to artifacts + Ralph loop command. |
| **codex-review** | Independent code review using OpenAI Codex MCP as a second opinion. |
| **tdd_cycle** | Enforces Red-Green-Refactor TDD cycle. |
| **test-and-commit** | Run tests then commit if they pass. |
| **skill-creator** | Guide for creating new Claude Code skills. |
| **reddit-fetch** | Fetch Reddit content when WebFetch is blocked. |

## Installation

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

## Updating

```bash
cd /path/to/claude-toolkit
git pull
```

That's it. Since skills are symlinked, changes are picked up immediately.

## Uninstalling

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

## WSL / Linux Notes

The install script works on both macOS and Linux/WSL. If you're on WSL:

- Make sure Claude Code is installed **inside WSL**, not on the Windows side
- `~/.claude` should be in your WSL home directory (not `/mnt/c/Users/...`)
- Symlinks work natively in WSL, no extra config needed

## Repo Structure

```
claude-toolkit/
├── install.sh                          # Installer script
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
├── tdd_cycle/
│   └── SKILL.md
├── test-and-commit/
│   └── SKILL.md
├── skill-creator/
│   └── SKILL.md
└── reddit-fetch/
    └── SKILL.md
```
