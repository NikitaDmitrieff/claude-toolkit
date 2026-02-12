#!/bin/bash
# Ralph Loop Extended — iterative loop + verification + next-steps loop
# Based on the Ralph Wiggum technique: https://ghuntley.com/ralph/
#
# Usage:
#   ralph-extended.sh [options]
#   ralph-extended.sh --promise "EP-001 COMPLETE" --max-iterations 20
#   ralph-extended.sh --prompt custom-prompt.md
#   ralph-extended.sh --no-verify       # skip the verification pass
#   ralph-extended.sh --no-next-steps   # skip the next-steps loop
#
# Phase 1: Main Ralph loop (PROMPT.md → claude → repeat)
# Phase 2: Verification pass (fresh Claude reviews + Chrome MCP)
# Phase 3: Next-steps generation (fresh Claude writes .ralph-next-steps-prompt.md)
# Phase 4: Branch + second Ralph loop on {branch}-next-steps

set -eo pipefail

# --- Defaults ---
PROMPT_FILE="PROMPT.md"
MAX_ITERATIONS=25
COMPLETION_PROMISE=""
LOG_FILE=".ralph-output.log"
NEXT_STEPS_PROMPT=".ralph-next-steps-prompt.md"
VERIFY=true
NEXT_STEPS=true
WORK_DIR=""

# --- Help ---
show_help() {
  cat <<'EOF'
Ralph Loop Extended — iterative loop + verification + next-steps loop

USAGE:
  ralph-extended.sh [options]

OPTIONS:
  --dir DIR               Look for PROMPT.md inside DIR (e.g. .artefacts/my-epic)
  --prompt FILE           Prompt file to use (default: PROMPT.md)
  --max-iterations N      Max iterations before auto-stop (default: 25)
  --promise TEXT          Completion promise — stops when <promise>TEXT</promise> detected
  --no-verify            Skip the verification pass
  --no-next-steps        Skip the next-steps generation and second loop
  -h, --help             Show this help

PHASES:
  1. Main loop        Iterates PROMPT.md until promise or max iterations
  2. Verification     Fresh Claude reviews all changes (Chrome MCP, tests, build)
  3. Next-steps gen   Fresh Claude writes .ralph-next-steps-prompt.md
  4. Second loop      Creates {branch}-next-steps, runs Ralph loop with generated prompt

EXAMPLES:
  ralph-extended.sh --promise "EP-001 COMPLETE" --max-iterations 20
  ralph-extended.sh --prompt PROMPT-auth.md --promise "AUTH DONE"
  ralph-extended.sh --no-next-steps --max-iterations 10
  ralph-extended.sh --no-verify --no-next-steps --max-iterations 5

STOPPING:
  Ctrl+C              Stop after current iteration finishes
  Ctrl+C twice        Force stop immediately
  --max-iterations    Auto-stop at iteration limit
  --promise           Auto-stop when Claude outputs <promise>TEXT</promise>
EOF
}

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --dir)
      [[ -z "${2:-}" ]] && echo "Error: --dir requires a directory path" >&2 && exit 1
      WORK_DIR="$2"; shift 2 ;;
    --prompt)
      [[ -z "${2:-}" ]] && echo "Error: --prompt requires a file path" >&2 && exit 1
      PROMPT_FILE="$2"; shift 2 ;;
    --max-iterations)
      [[ -z "${2:-}" ]] && echo "Error: --max-iterations requires a number" >&2 && exit 1
      [[ ! "$2" =~ ^[0-9]+$ ]] && echo "Error: --max-iterations must be a positive integer" >&2 && exit 1
      MAX_ITERATIONS="$2"; shift 2 ;;
    --promise)
      [[ -z "${2:-}" ]] && echo "Error: --promise requires text" >&2 && exit 1
      COMPLETION_PROMISE="$2"; shift 2 ;;
    --no-verify) VERIFY=false; shift ;;
    --no-next-steps) NEXT_STEPS=false; shift ;;
    -h|--help) show_help; exit 0 ;;
    *) echo "Error: unknown option '$1'. Use --help for usage." >&2; exit 1 ;;
  esac
done

# --- Cleanup on exit ---
cleanup() {
  rm -f "$LOG_FILE"
  echo ""
  echo "Ralph loop stopped."
}
trap cleanup EXIT

# --- Resolve --dir ---
if [[ -n "$WORK_DIR" ]]; then
  if [[ ! -d "$WORK_DIR" ]]; then
    echo "Error: directory '$WORK_DIR' does not exist" >&2
    exit 1
  fi
  PROMPT_FILE="$WORK_DIR/$PROMPT_FILE"
  NEXT_STEPS_PROMPT="$WORK_DIR/$NEXT_STEPS_PROMPT"
fi

# --- Validate ---
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: $PROMPT_FILE not found in $(pwd)" >&2
  echo "Create a PROMPT.md file with your task description, or use --prompt to specify a different file." >&2
  exit 1
fi

# --- Summary ---
echo "╔══════════════════════════════════════════════════╗"
echo "║  Ralph Loop Extended                             ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  Prompt:      $PROMPT_FILE"
echo "║  Iterations:  $MAX_ITERATIONS max"
if [[ -n "$COMPLETION_PROMISE" ]]; then
echo "║  Promise:     $COMPLETION_PROMISE"
else
echo "║  Promise:     (none — runs until max iterations)"
fi
echo "║  Verify:      $VERIFY"
echo "║  Next steps:  $NEXT_STEPS"
echo "║  Stop:        Ctrl+C"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# =============================================
# PHASE 1: MAIN LOOP
# =============================================

for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Phase 1 — Iteration $i / $MAX_ITERATIONS"
  echo "══════════════════════════════════════════════"
  echo ""

  cat "$PROMPT_FILE" | claude --dangerously-skip-permissions 2>&1 | tee "$LOG_FILE" || true

  if [[ -n "$COMPLETION_PROMISE" ]] && grep -q "<promise>$COMPLETION_PROMISE</promise>" "$LOG_FILE" 2>/dev/null; then
    echo ""
    echo "══════════════════════════════════════════════"
    echo "  Promise detected after $i iterations."
    echo "══════════════════════════════════════════════"
    break
  fi

  echo ""
  echo "--- Iteration $i complete. Continuing... ---"
done

echo ""
echo "══════════════════════════════════════════════"
echo "  Phase 1 complete."
echo "══════════════════════════════════════════════"

# =============================================
# PHASE 2: VERIFICATION PASS
# =============================================

if [[ "$VERIFY" == "true" ]]; then
  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Phase 2 — Verification"
  echo "══════════════════════════════════════════════"
  echo ""

  DIFF_STAT=$(git diff --stat HEAD~"${i:-1}" HEAD 2>/dev/null || git diff --stat HEAD 2>/dev/null || echo "(could not compute diff)")

  cat <<VERIFY_PROMPT | claude --dangerously-skip-permissions 2>&1 | tee "$LOG_FILE" || true
You are a verification agent. A previous Claude agent just finished working on a task.
Your job is to double-check that everything works correctly.

## What was the task

$(cat "$PROMPT_FILE")

## What changed

$DIFF_STAT

## Your verification checklist

1. Read progress.txt (if it exists) to understand what was done
2. Review the git log and diff to see all changes made
3. If this is a web application, use the Chrome MCP browser tools to navigate to the app and visually verify it works:
   - Take screenshots of key pages
   - Check for console errors
   - Verify the UI matches expectations
4. If tests exist, run them
5. If a build command exists, run it and check for errors
6. Check for any obvious issues: broken imports, missing files, syntax errors
7. If you find problems, fix them and commit the fixes

Report what you verified and whether everything looks good.
VERIFY_PROMPT

  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Verification complete."
  echo "══════════════════════════════════════════════"
else
  echo ""
  echo "  Skipped verification (--no-verify)."
fi

# =============================================
# PHASE 3: NEXT-STEPS GENERATION
# =============================================

if [[ "$NEXT_STEPS" == "true" ]]; then
  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Phase 3 — Generating next-steps prompt"
  echo "══════════════════════════════════════════════"
  echo ""

  # Remove any stale next-steps prompt from a previous run
  rm -f "$NEXT_STEPS_PROMPT"

  ORIGINAL_PROMPT=$(cat "$PROMPT_FILE")
  GIT_LOG=$(git log --oneline -20 2>/dev/null || echo "(no git history)")
  DIFF_STAT_FULL=$(git diff --stat HEAD~"${i:-1}" HEAD 2>/dev/null || git diff --stat HEAD 2>/dev/null || echo "(could not compute diff)")
  PROGRESS=$(cat progress.txt 2>/dev/null || echo "(no progress.txt found)")

  cat <<NEXTSTEPS_PROMPT | claude --dangerously-skip-permissions 2>&1 | tee "$LOG_FILE" || true
You are a planning agent. A previous Claude agent just finished implementing a task.
Your ONLY job is to output a prompt for the NEXT phase of work. Do NOT implement anything.

## The original task

$ORIGINAL_PROMPT

## What was done (progress.txt)

$PROGRESS

## Recent git history

$GIT_LOG

## Files changed

$DIFF_STAT_FULL

## Your instructions

Analyze what was built and output a complete Ralph loop prompt for the next phase of work.

You MUST wrap your prompt output between these exact markers:

---RALPH-NEXT-STEPS-BEGIN---
(your prompt content here)
---RALPH-NEXT-STEPS-END---

The prompt you output MUST:
- Be a self-contained task description (the next Claude agent won't have context from this session)
- List concrete, specific next steps: improvements, missing features, polish, bugs to fix, tests to add
- Include clear completion criteria
- End with: "When all tasks are complete, output: <promise>NEXT-STEPS COMPLETE</promise>"
- Be realistic about what can be accomplished in $MAX_ITERATIONS iterations
- Reference specific files and code paths from the project

The prompt you output MUST NOT:
- Repeat work that was already done
- Include vague tasks like "improve code quality" without specifics
- Be longer than 200 lines

CRITICAL: Output ONLY the prompt between the markers. Do NOT create files. Do NOT implement anything.
NEXTSTEPS_PROMPT

  # Extract the prompt content between markers and write the file
  if grep -q "RALPH-NEXT-STEPS-BEGIN" "$LOG_FILE" 2>/dev/null; then
    sed -n '/---RALPH-NEXT-STEPS-BEGIN---/,/---RALPH-NEXT-STEPS-END---/p' "$LOG_FILE" \
      | sed '1d;$d' \
      > "$NEXT_STEPS_PROMPT"
  fi

  # Check that the file was created and is not empty
  if [[ ! -s "$NEXT_STEPS_PROMPT" ]]; then
    echo ""
    echo "══════════════════════════════════════════════"
    echo "  WARNING: Could not extract next-steps prompt"
    echo "  from Claude output. Skipping Phase 4."
    echo "══════════════════════════════════════════════"
    exit 0
  fi

  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Next-steps prompt generated."
  echo "══════════════════════════════════════════════"

  # =============================================
  # PHASE 4: BRANCH + SECOND RALPH LOOP
  # =============================================

  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Phase 4 — Second loop on new branch"
  echo "══════════════════════════════════════════════"
  echo ""

  # Commit any uncommitted work from verification/generation phases
  git add -A && git commit -m "ralph: end of phase 1 — ready for next-steps" 2>/dev/null || true

  # Create next-steps branch
  CURRENT_BRANCH=$(git branch --show-current)
  NEXT_BRANCH="${CURRENT_BRANCH}-next-steps"

  # Handle case where branch already exists (re-run)
  if git show-ref --verify --quiet "refs/heads/$NEXT_BRANCH" 2>/dev/null; then
    NEXT_BRANCH="${CURRENT_BRANCH}-next-steps-$(date +%s)"
  fi

  git checkout -b "$NEXT_BRANCH"

  echo "  Branch: $NEXT_BRANCH"
  echo "  Prompt: $NEXT_STEPS_PROMPT"
  echo "  Iterations: $MAX_ITERATIONS max"
  echo ""

  for j in $(seq 1 "$MAX_ITERATIONS"); do
    echo ""
    echo "══════════════════════════════════════════════"
    echo "  Phase 4 — Iteration $j / $MAX_ITERATIONS"
    echo "══════════════════════════════════════════════"
    echo ""

    cat "$NEXT_STEPS_PROMPT" | claude --dangerously-skip-permissions 2>&1 | tee "$LOG_FILE" || true

    if grep -q "<promise>NEXT-STEPS COMPLETE</promise>" "$LOG_FILE" 2>/dev/null; then
      echo ""
      echo "══════════════════════════════════════════════"
      echo "  Next-steps promise detected after $j iterations."
      echo "══════════════════════════════════════════════"
      break
    fi

    echo ""
    echo "--- Phase 4 iteration $j complete. Continuing... ---"
  done

  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Phase 4 complete."
  echo "══════════════════════════════════════════════"
  echo ""
  echo "  Phase 1 result: branch '$CURRENT_BRANCH'"
  echo "  Phase 4 result: branch '$NEXT_BRANCH'"
  echo ""
  echo "  Compare with: git diff $CURRENT_BRANCH...$NEXT_BRANCH"

else
  echo ""
  echo "  Skipped next-steps (--no-next-steps)."
fi
