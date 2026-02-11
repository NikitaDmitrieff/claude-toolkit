#!/bin/bash
# Ralph Loop — Bash implementation of the Ralph Wiggum technique
# https://ghuntley.com/ralph/
#
# Usage:
#   ralph.sh [options]
#   ralph.sh --promise "EP-001 COMPLETE" --max-iterations 20
#   ralph.sh --prompt custom-prompt.md
#
# The script reads PROMPT.md from the current directory and pipes it to
# Claude Code repeatedly. Each iteration, Claude sees its previous work
# in the files and git history, building incrementally toward completion.

set -eo pipefail

# --- Defaults ---
PROMPT_FILE="PROMPT.md"
MAX_ITERATIONS=25
COMPLETION_PROMISE=""
LOG_FILE=".ralph-output.log"

# --- Help ---
show_help() {
  cat <<'EOF'
Ralph Loop — iterative Claude Code development loop

USAGE:
  ralph.sh [options]

OPTIONS:
  --prompt FILE           Prompt file to use (default: PROMPT.md)
  --max-iterations N      Max iterations before auto-stop (default: 25)
  --promise TEXT          Completion promise — stops when <promise>TEXT</promise> detected
  -h, --help             Show this help

EXAMPLES:
  ./ralph.sh --promise "EP-001 COMPLETE" --max-iterations 20
  ./ralph.sh --prompt PROMPT-auth.md --promise "AUTH DONE" --max-iterations 10

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

# --- Validate ---
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: $PROMPT_FILE not found in $(pwd)" >&2
  echo "Create a PROMPT.md file with your task description, or use --prompt to specify a different file." >&2
  exit 1
fi

# --- Summary ---
echo "╔══════════════════════════════════════════════╗"
echo "║  Ralph Loop                                  ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Prompt:     $PROMPT_FILE"
echo "║  Iterations: $MAX_ITERATIONS max"
if [[ -n "$COMPLETION_PROMISE" ]]; then
echo "║  Promise:    $COMPLETION_PROMISE"
else
echo "║  Promise:    (none — runs until max iterations)"
fi
echo "║  Stop:       Ctrl+C"
echo "╚══════════════════════════════════════════════╝"
echo ""

# --- Loop ---
for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Iteration $i / $MAX_ITERATIONS"
  echo "══════════════════════════════════════════════"
  echo ""

  # Pipe prompt to Claude — allow non-zero exit (claude may exit 1 on some iterations)
  cat "$PROMPT_FILE" | claude --dangerously-skip-permissions 2>&1 | tee "$LOG_FILE" || true

  # Check for completion promise in output
  if [[ -n "$COMPLETION_PROMISE" ]] && grep -q "<promise>$COMPLETION_PROMISE</promise>" "$LOG_FILE" 2>/dev/null; then
    echo ""
    echo "══════════════════════════════════════════════"
    echo "  Done! Promise detected after $i iterations."
    echo "══════════════════════════════════════════════"
    exit 0
  fi

  echo ""
  echo "--- Iteration $i complete. Continuing... ---"
done

echo ""
echo "══════════════════════════════════════════════"
echo "  Max iterations ($MAX_ITERATIONS) reached."
echo "══════════════════════════════════════════════"
