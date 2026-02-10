#!/usr/bin/env bash
set -euo pipefail

# Claude Toolkit — Installer
# Works on macOS and Linux/WSL.
# Symlinks every skill in this repo into ~/.claude/skills/
# so updates are just a `git pull` away.

# ---------- helpers ----------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { printf "${GREEN}[✓]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
error() { printf "${RED}[✗]${NC} %s\n" "$1"; }

# ---------- resolve repo root ----------

# Follow symlinks to get the real path of this script
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_SOURCE" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ "$SCRIPT_SOURCE" != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
REPO_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"

# ---------- detect claude dir ----------

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

if [ ! -d "$CLAUDE_DIR" ]; then
    error "~/.claude directory not found. Is Claude Code installed?"
    echo "  Install it first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

mkdir -p "$SKILLS_DIR"

# ---------- collect skills ----------

# Every top-level directory in the repo that contains a SKILL.md is a skill
SKILLS=()
for dir in "$REPO_DIR"/*/; do
    [ -f "$dir/SKILL.md" ] && SKILLS+=("$(basename "$dir")")
done

if [ ${#SKILLS[@]} -eq 0 ]; then
    error "No skills found in $REPO_DIR (looking for dirs with SKILL.md)"
    exit 1
fi

echo ""
echo "Claude Toolkit Installer"
echo "========================"
echo ""
echo "Repo:   $REPO_DIR"
echo "Target: $SKILLS_DIR"
echo ""
echo "Skills to install:"
for skill in "${SKILLS[@]}"; do
    echo "  - $skill"
done
echo ""

# ---------- symlink each skill ----------

INSTALLED=0
SKIPPED=0
REPLACED=0

for skill in "${SKILLS[@]}"; do
    SOURCE="$REPO_DIR/$skill"
    TARGET="$SKILLS_DIR/$skill"

    if [ -L "$TARGET" ]; then
        EXISTING_LINK="$(readlink "$TARGET")"
        if [ "$EXISTING_LINK" = "$SOURCE" ]; then
            warn "$skill — already linked, skipping"
            SKIPPED=$((SKIPPED + 1))
            continue
        else
            warn "$skill — symlink exists but points elsewhere ($EXISTING_LINK)"
            echo -n "  Replace it? [y/N] "
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                rm "$TARGET"
                REPLACED=$((REPLACED + 1))
            else
                warn "$skill — skipped (kept existing link)"
                SKIPPED=$((SKIPPED + 1))
                continue
            fi
        fi
    elif [ -d "$TARGET" ]; then
        warn "$skill — directory already exists (not a symlink)"
        echo -n "  Replace with symlink? Your local copy will be deleted. [y/N] "
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            rm -rf "$TARGET"
            REPLACED=$((REPLACED + 1))
        else
            warn "$skill — skipped (kept existing directory)"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi
    fi

    ln -s "$SOURCE" "$TARGET"
    info "$skill — linked"
    INSTALLED=$((INSTALLED + 1))
done

# ---------- summary ----------

echo ""
echo "Done!"
echo "  Installed: $INSTALLED"
[ $REPLACED -gt 0 ] && echo "  Replaced:  $REPLACED"
[ $SKIPPED -gt 0 ]  && echo "  Skipped:   $SKIPPED"
echo ""

# ---------- required plugins reminder ----------

echo "========================"
echo "Required Plugins"
echo "========================"
echo ""
echo "Some skills depend on Claude Code plugins. Install them by running"
echo "these commands inside Claude Code (one at a time):"
echo ""
echo "  /install-plugin code-simplifier"
echo "  /install-plugin claude-md-management"
echo "  /install-plugin superpowers"
echo ""
echo "Optional (for codex review):"
echo "  /install-plugin codex"
echo ""
echo "Also recommended:"
echo "  /install-plugin ralph-wiggum    (required for ralph-launch / ralph-planner)"
echo "  /install-plugin context7        (up-to-date library docs)"
echo ""

# ---------- WSL note ----------

if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "========================"
    echo "WSL Detected"
    echo "========================"
    echo ""
    echo "You're running under WSL. A few notes:"
    echo "  - Make sure Claude Code is installed inside WSL, not Windows-side"
    echo "  - ~/.claude should be in your WSL home, not /mnt/c/Users/..."
    echo "  - Symlinks work natively in WSL, no extra setup needed"
    echo ""
fi
