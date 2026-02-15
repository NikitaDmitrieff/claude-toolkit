# Ralph Loop Prompt Template

## Overview

Ralph-planner creates:
1. A `PROMPT.md` file in `.artefacts/{feature-slug}/` containing the prompt
2. A shell command to launch the Ralph loop

## Command Format

```bash
./ralph.sh --dir .artefacts/{feature-slug} --promise "EP-{CONTRIBUTOR}-{NUMBER} COMPLETE" --max-iterations {N}
```

## PROMPT.md Structure

The `PROMPT.md` file saved to `.artefacts/{feature-slug}/` should contain these sections in order:

```
Implement {feature name} following the spec at {absolute path to SPEC-{CONTRIBUTOR}-{NUMBER}.md}.

{{EXPERT_ARTIFACTS_SECTION}}

PROGRESS TRACKING:
- At the START of every iteration, read `.artefacts/{feature-slug}/progress.txt`.
- It contains the list of completed tasks and current state from previous iterations.
- After completing each task, UPDATE `.artefacts/{feature-slug}/progress.txt` with:
  - Which task you just finished (task number + name)
  - Brief summary of what was done
  - Any issues encountered
  - What task comes next
- This file is your memory across iterations. Keep it accurate.

PACING — ONE TASK PER ITERATION (MANDATORY):
- Each iteration, implement EXACTLY ONE task from the spec. No more.
- After completing that single task: commit, update .artefacts/{feature-slug}/progress.txt, then STOP.
- Do NOT look ahead to the next task. Do NOT "while I'm here" other tasks.
- The next iteration will pick up where you left off via .artefacts/{feature-slug}/progress.txt.
- Exception: the FINAL iteration handles best practices + completion promise.

WORKFLOW:
1. Read the spec file first.
2. Read `.artefacts/{feature-slug}/progress.txt` to see what's already done from previous iterations.
3. Identify the NEXT SINGLE incomplete task (lowest numbered unfinished task).
4. Implement ONLY that one task, then commit.
5. Update `.artefacts/{feature-slug}/progress.txt` with what you just finished and what comes next.
6. STOP. Do not continue to the next task — let the loop iterate.
7. Only after ALL tasks show complete in .artefacts/{feature-slug}/progress.txt, run best practices (see below).

BEST PRACTICES (after ALL implementation tasks are done):
1. Run /code-simplifier to reduce unnecessary complexity in the code you wrote.
2. Create review artefacts:
   - .artefacts/{feature-slug}/TESTING.md — Manual testing guide with exact steps, expected results, and edge cases.
   - .artefacts/{feature-slug}/CHANGELOG.md — What changed: summary, files modified, breaking changes.
3. Update CLAUDE.md with learnings from this session:
   - Review the implementation for patterns, commands, or gotchas worth documenting
   - Draft concise additions (one-line format: `<command>` - `<brief description>`)
   - Directly append to CLAUDE.md using the Edit tool (no approval needed in loop context)
   - Keep additions minimal - only genuinely useful context for future Claude sessions
4. Verify all code follows CLAUDE.md conventions.
5. Check for YAGNI violations — no features beyond what the spec describes.
{codex_review_step}

RULES:
- Follow the project's CLAUDE.md and AGENTS.md conventions.
- Do NOT add features beyond what the spec describes.
- Mark EP-{CONTRIBUTOR}-{NUMBER} status as 'complete' in .prodman/epics/ when done.

CRITICAL — DO NOT COMPLETE EARLY:
- You have multiple tasks to implement. Do NOT output the completion promise until ALL of them are done.
- Before outputting <promise>, you MUST verify:
  1. Every task in the spec is implemented (check them off one by one)
  2. `.artefacts/{feature-slug}/progress.txt` shows ALL tasks as complete
  3. /code-simplifier has been run
  4. Review artefacts are created in .artefacts/{feature-slug}/
  5. CLAUDE.md has been updated with session learnings (if applicable)
  6. Code follows CLAUDE.md conventions
  7. No YAGNI violations
  {codex_review_check}
- If ANY task is incomplete, keep working. You have plenty of iterations.

Output <promise>EP-{CONTRIBUTOR}-{NUMBER} COMPLETE</promise> ONLY when every single task is implemented, best practices are done, and all checks above pass.
```

### Dynamic Sections

**`{{EXPERT_ARTIFACTS_SECTION}}`** — Replace based on which artifacts were created:

- If artifacts exist: List paths to PRD.md, ARCHITECTURE.md, UI-SPEC.md (only those with agent level > 0), plus "Consult them when you need clarification on WHY or HOW."
- If no artifacts: "Note: No expert artifacts available. Refer to the spec and design document for guidance."

**`{codex_review_step}`** — If user opts in to codex review:
```
6. Run /codex-review against the spec for an independent second opinion.
7. If Codex review finds issues, fix them before completing.
```

**`{codex_review_check}`** — If user opts in: `8. Codex review has passed`

If user opts out (default), remove these placeholders entirely.

## Iteration Estimation

| Plan complexity | Tasks | Suggested iterations |
|----------------|-------|---------------------|
| Small          | 1-3   | 8-10                |
| Medium         | 4-7   | 12-18               |
| Large          | 8-12  | 20-30               |
| Very large     | 13+   | 30+ (consider splitting) |

Formula: `(number of tasks * 2.5) + 3 buffer`, rounded up to nearest 5.

## Example - All Artifacts

For a 6-task plan creating EP-TB-003 with all agents enabled:

**Command:**
```bash
./ralph.sh --dir .artefacts/user-auth --promise "EP-TB-003 COMPLETE" --max-iterations 18
```

**PROMPT.md content:**
```
Implement user authentication following the spec at /path/to/.prodman/specs/SPEC-TB-003-user-auth.md.

EXPERT ARTIFACTS (reference during implementation):
- PRD: /path/to/.artefacts/user-auth/PRD.md
- Architecture: /path/to/.artefacts/user-auth/ARCHITECTURE.md
- UI Spec: /path/to/.artefacts/user-auth/UI-SPEC.md

These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.

[... rest of template sections ...]
```
