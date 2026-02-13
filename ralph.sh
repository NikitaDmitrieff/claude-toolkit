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
MAX_ITERATIONS=30
COMPLETION_PROMISE=""
LOG_FILE=".ralph-output.log"
PROMPT_DIR=""
WORK_DIR=""
DEBUG_MODE=false

# --- Help ---
show_help() {
  cat <<'EOF'
Ralph Loop — iterative Claude Code development loop

USAGE:
  ralph.sh [options]

OPTIONS:
  --dir DIR               Look for PROMPT.md in DIR (e.g., .artefacts/my-epic)
  --work-dir DIR          Change to DIR before running loop (where Claude works)
  --prompt FILE           Prompt file to use (default: PROMPT.md, relative to --dir if specified)
  --max-iterations N      Max iterations before auto-stop (default: 25)
  --promise TEXT          Completion promise — stops when <promise>TEXT</promise> detected
  --debug                 Show promise detection debug info after each iteration
  -h, --help             Show this help

EXAMPLES:
  # Work in current dir, use PROMPT.md from current dir
  ./ralph.sh --promise "EP-001 COMPLETE" --max-iterations 20

  # Read PROMPT.md from .artefacts/my-epic/, work in current dir
  ./ralph.sh --dir .artefacts/my-epic --promise "EP-001 COMPLETE" --max-iterations 20

  # Read PROMPT.md from .artefacts/my-epic/, work in specific directory
  ./ralph.sh --dir .artefacts/my-epic --work-dir /path/to/project --promise "EP-001 COMPLETE" --max-iterations 20

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
      PROMPT_DIR="$2"; shift 2 ;;
    --work-dir)
      [[ -z "${2:-}" ]] && echo "Error: --work-dir requires a directory path" >&2 && exit 1
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
    --debug)
      DEBUG_MODE=true; shift ;;
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

# --- Resolve --dir (where to find PROMPT.md) ---
if [[ -n "$PROMPT_DIR" ]]; then
  if [[ ! -d "$PROMPT_DIR" ]]; then
    echo "Error: directory '$PROMPT_DIR' does not exist" >&2
    exit 1
  fi
  PROMPT_FILE="$PROMPT_DIR/$PROMPT_FILE"
fi

# --- Validate prompt file exists ---
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: $PROMPT_FILE not found" >&2
  echo "Create a PROMPT.md file with your task description, or use --prompt to specify a different file." >&2
  exit 1
fi

# --- Resolve --work-dir (where Claude should work) ---
if [[ -n "$WORK_DIR" ]]; then
  if [[ ! -d "$WORK_DIR" ]]; then
    echo "Error: work directory '$WORK_DIR' does not exist" >&2
    exit 1
  fi
  echo "Changing to work directory: $WORK_DIR"
  cd "$WORK_DIR"
fi

# --- Summary ---
echo "╔══════════════════════════════════════════════╗"
echo "║  Ralph Loop                                  ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Working dir: $(pwd)"
echo "║  Prompt:      $PROMPT_FILE"
echo "║  Iterations:  $MAX_ITERATIONS max"
if [[ -n "$COMPLETION_PROMISE" ]]; then
echo "║  Promise:     $COMPLETION_PROMISE"
else
echo "║  Promise:     (none — runs until max iterations)"
fi
echo "║  Stop:        Ctrl+C"
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

  # Check for completion promise in output (multi-line safe, whitespace tolerant)
  if [[ -n "$COMPLETION_PROMISE" ]]; then
    # Normalize whitespace: remove newlines and collapse spaces
    NORMALIZED_LOG=$(tr -d '\n\r' < "$LOG_FILE" 2>/dev/null | tr -s ' ')
    NORMALIZED_PROMISE="<promise>$COMPLETION_PROMISE</promise>"

    if [[ "$DEBUG_MODE" == true ]]; then
      echo ""
      echo "[DEBUG] Looking for: $NORMALIZED_PROMISE"
      echo "[DEBUG] Promise found: $(echo "$NORMALIZED_LOG" | grep -oF "$NORMALIZED_PROMISE" || echo "NO")"
    fi

    if echo "$NORMALIZED_LOG" | grep -qF "$NORMALIZED_PROMISE"; then
      echo ""
      echo "══════════════════════════════════════════════"
      echo "  ✓ Promise detected after $i iterations!"
      echo "══════════════════════════════════════════════"
      exit 0
    fi
  fi

  echo ""
  echo "--- Iteration $i complete. Continuing... ---"
done

echo ""
echo "══════════════════════════════════════════════"
echo "  Max iterations ($MAX_ITERATIONS) reached."
echo "══════════════════════════════════════════════"
