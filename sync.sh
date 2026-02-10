#!/usr/bin/env bash
set -euo pipefail

# Claude Toolkit — Sync
# Copies skills from ~/.claude/skills/ → this repo.
# Run this after editing skills locally to stage them for commit.

# ---------- helpers ----------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { printf "${GREEN}[✓]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
error() { printf "${RED}[✗]${NC} %s\n" "$1"; }

# ---------- resolve paths ----------

SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_SOURCE" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ "$SCRIPT_SOURCE" != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
REPO_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"

SKILLS_DIR="$HOME/.claude/skills"

if [ ! -d "$SKILLS_DIR" ]; then
    error "~/.claude/skills/ not found"
    exit 1
fi

# ---------- tracked skills ----------

# Only sync skills that are already in the repo (don't auto-add new ones).
# To add a new skill, copy it manually first or use --all.

SYNC_ALL=false
if [[ "${1:-}" == "--all" ]]; then
    SYNC_ALL=true
fi

echo ""
echo "Claude Toolkit — Sync"
echo "====================="
echo ""
echo "Source: $SKILLS_DIR"
echo "Target: $REPO_DIR"
echo ""

SYNCED=0
SKIPPED=0
ADDED=0

sync_skill() {
    local skill_name="$1"
    local source="$SKILLS_DIR/$skill_name"
    local target="$REPO_DIR/$skill_name"

    if [ ! -d "$source" ]; then
        warn "$skill_name — not found in ~/.claude/skills/, skipping"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    # Skip if source is a symlink pointing into the repo (friend's install)
    if [ -L "$source" ]; then
        local link_target
        link_target="$(readlink "$source")"
        if [[ "$link_target" == "$REPO_DIR"* ]]; then
            warn "$skill_name — is a symlink to this repo, skipping"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
    fi

    # rsync: mirror source → target, delete files removed from source
    rsync -a --delete \
        --exclude='.DS_Store' \
        "$source/" "$target/"

    info "$skill_name — synced"
    SYNCED=$((SYNCED + 1))
}

# Sync existing skills in the repo
for dir in "$REPO_DIR"/*/; do
    [ -f "$dir/SKILL.md" ] || continue
    skill_name="$(basename "$dir")"
    sync_skill "$skill_name"
done

# If --all, also add any new skills not yet in the repo
if [ "$SYNC_ALL" = true ]; then
    for dir in "$SKILLS_DIR"/*/; do
        [ -f "$dir/SKILL.md" ] || continue
        skill_name="$(basename "$dir")"
        if [ ! -d "$REPO_DIR/$skill_name" ]; then
            echo -n "  New skill found: $skill_name. Add to toolkit? [y/N] "
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                rsync -a --exclude='.DS_Store' "$dir" "$REPO_DIR/$skill_name/"
                info "$skill_name — added"
                ADDED=$((ADDED + 1))
            else
                warn "$skill_name — skipped"
                SKIPPED=$((SKIPPED + 1))
            fi
        fi
    done
fi

# ---------- git status ----------

echo ""
echo "Done!"
echo "  Synced:  $SYNCED"
[ $ADDED -gt 0 ]   && echo "  Added:   $ADDED"
[ $SKIPPED -gt 0 ] && echo "  Skipped: $SKIPPED"
echo ""

# Show what changed
cd "$REPO_DIR"
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "No changes detected — toolkit is already up to date."
else
    echo "Changes ready to commit:"
    echo ""
    git status --short
    echo ""
    echo "To publish:"
    echo "  cd $REPO_DIR"
    echo "  git add . && git commit -m 'update skills' && git push"
fi
