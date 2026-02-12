# Ralph Loop Prompt Template

## Output Format

The skills generate a prompt file in the artefact folder and a launch command:

### 1. `.artefacts/{slug}/PROMPT.md` — The prompt fed to Claude each iteration

Contains the full task prompt with progress tracking, pacing rules, workflow, best practices, and completion promise.

### 2. Launch commands

**Standard loop** (implementation only):
```bash
ralph.sh --dir .artefacts/{slug} --promise "EP-{ID}-{XXX} COMPLETE" --max-iterations {N}
```

**Extended loop** (implementation + verification + auto-generated next-steps on a new branch):
```bash
ralph-extended.sh --dir .artefacts/{slug} --promise "EP-{ID}-{XXX} COMPLETE" --max-iterations {N}
```

Run from the project root. Both scripts are in `~/bin/` (in PATH). They read `.artefacts/{slug}/PROMPT.md` and pipe it to Claude repeatedly.

## PROMPT.md Structure

The generated `PROMPT.md` should contain these sections in order:

```
Implement {feature name} following the spec at {absolute path to SPEC-XXX.md}.

PROGRESS TRACKING:
- At the START of every iteration, read `.artefacts/{slug}/progress.txt`.
- It contains the list of completed tasks and current state from previous iterations.
- After completing each task, UPDATE `.artefacts/{slug}/progress.txt` with:
  - Which task you just finished (task number + name)
  - Brief summary of what was done
  - Any issues encountered
  - What task comes next
- This file is your memory across iterations. Keep it accurate.

PACING — ONE TASK PER ITERATION (MANDATORY):
- Each iteration, implement EXACTLY ONE task from the spec. No more.
- After completing that single task: commit, update `.artefacts/{slug}/progress.txt`, then STOP.
- Do NOT look ahead to the next task. Do NOT "while I'm here" other tasks.
- The next iteration will pick up where you left off via `.artefacts/{slug}/progress.txt`.
- Exception: the FINAL iteration handles best practices + completion promise.

WORKFLOW:
1. Read the spec file first.
2. Read `.artefacts/{slug}/progress.txt` to see what's already done from previous iterations.
3. Identify the NEXT SINGLE incomplete task (lowest numbered unfinished task).
4. Implement ONLY that one task, then commit.
5. Update `.artefacts/{slug}/progress.txt` with what you just finished and what comes next.
6. STOP. Do not continue to the next task — let the loop iterate.
7. Only after ALL tasks show complete in `.artefacts/{slug}/progress.txt`, run best practices (see below).

BEST PRACTICES (after ALL implementation tasks are done):
1. Run /code-simplifier to reduce unnecessary complexity in the code you wrote.
2. Create review artefacts:
   - .artefacts/{feature-slug}/TESTING.md — Manual testing guide with exact steps, expected results, and edge cases.
   - .artefacts/{feature-slug}/CHANGELOG.md — What changed: summary, files modified, breaking changes.
3. Run /claude-md-improver and /claude-md-management:revise-claude-md to keep CLAUDE.md current.
4. Verify all code follows CLAUDE.md and AGENTS.md conventions.
5. Check for YAGNI violations — no features beyond what the spec describes.
{codex_review_step}

RULES:
- Follow the project's CLAUDE.md and AGENTS.md conventions.
- Do NOT add features beyond what the spec describes.
- Mark EP-{ID}-{XXX} status as 'complete' in .prodman/epics/ when done.

CRITICAL — DO NOT COMPLETE EARLY:
- You have multiple tasks to implement. Do NOT output the completion promise until ALL of them are done.
- Before outputting <promise>, you MUST verify:
  1. Every task in the spec is implemented (check them off one by one)
  2. `.artefacts/{slug}/progress.txt` shows ALL tasks as complete
  3. /code-simplifier has been run
  4. Review artefacts are created in .artefacts/{feature-slug}/
  5. /claude-md-improver and /claude-md-management:revise-claude-md have been run
  6. Code follows CLAUDE.md and AGENTS.md conventions
  7. No YAGNI violations
  {codex_review_check}
- If ANY task is incomplete, keep working. You have plenty of iterations.

Output <promise>EP-{ID}-{XXX} COMPLETE</promise> ONLY when every single task is implemented, best practices are done, and all checks above pass.
```

### Codex review insertion

If the user opts in to codex review, insert at `{codex_review_step}`:
```
6. Run /codex-review against the spec for an independent second opinion on spec compliance and code quality.
7. If Codex review finds issues, fix them before completing.
```

And at `{codex_review_check}`:
```
8. Codex review has passed
```

If the user opts out (default), remove those placeholders entirely.

## Iteration Estimation

Calculate suggested iterations:

| Plan complexity | Tasks | Suggested iterations |
|----------------|-------|---------------------|
| Small          | 1-3   | 8-10                |
| Medium         | 4-7   | 12-18               |
| Large          | 8-12  | 20-30               |
| Very large     | 13+   | 30+ (consider splitting into multiple epics) |

Formula: `(number of tasks × 2.5) + 3 buffer`, rounded up to nearest 5.

If the plan has 13+ tasks, suggest splitting into multiple epics with separate ralph loops.

## Example

For a 6-task plan creating EP-ND-002 (without codex review):

**Generated `.artefacts/quick-start/PROMPT.md`:**

```
Implement Quick Start lite space following the spec at /Users/nikitadmitrieff/Projects/coby/mvp-early-bk/coby-v2/.prodman/specs/SPEC-002-quick-start.md.

PROGRESS TRACKING:
- At the START of every iteration, read `.artefacts/quick-start/progress.txt`.
...
(full prompt from template above)
...
Output <promise>EP-ND-002 COMPLETE</promise> ONLY when every single task is implemented, best practices are done, and all checks above pass.
```

**Launch commands:**

```bash
ralph.sh --dir .artefacts/quick-start --promise "EP-ND-002 COMPLETE" --max-iterations 18
```
or extended:
```bash
ralph-extended.sh --dir .artefacts/quick-start --promise "EP-ND-002 COMPLETE" --max-iterations 18
```
