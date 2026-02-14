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

The `{{EXPERT_ARTIFACTS_SECTION}}` placeholder should be replaced with content based on which artifacts were created:

**If at least one artifact exists:**

```
EXPERT ARTIFACTS (reference during implementation):
{{IF PRD.md exists}}
- PRD: {absolute path to .artefacts/{feature-slug}/PRD.md}
{{END}}
{{IF ARCHITECTURE.md exists}}
- Architecture: {absolute path to .artefacts/{feature-slug}/ARCHITECTURE.md}
{{END}}
{{IF UI-SPEC.md exists}}
- UI Spec: {absolute path to .artefacts/{feature-slug}/UI-SPEC.md}
{{END}}

These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.
```

**If no artifacts exist (all agents disabled):**

```
Note: No expert artifacts available. Refer to the spec and design document for guidance.
```

**Construction logic:**

When building the prompt in SKILL.md STEP 4:

```javascript
let artifacts = []
if (pmLevel > 0) artifacts.push(`- PRD: ${absolutePath}/.artefacts/${featureSlug}/PRD.md`)
if (archLevel > 0) artifacts.push(`- Architecture: ${absolutePath}/.artefacts/${featureSlug}/ARCHITECTURE.md`)
if (uiuxLevel > 0) artifacts.push(`- UI Spec: ${absolutePath}/.artefacts/${featureSlug}/UI-SPEC.md`)

let artifactsSection
if (artifacts.length > 0) {
  artifactsSection = `EXPERT ARTIFACTS (reference during implementation):
${artifacts.join('\n')}

These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.`
} else {
  artifactsSection = `Note: No expert artifacts available. Refer to the spec and design document for guidance.`
}

finalPrompt = promptTemplate.replace('{{EXPERT_ARTIFACTS_SECTION}}', artifactsSection)
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

## Example - All Artifacts Available

For a 6-task plan creating EP-TB-003 with all agents enabled (without codex review).

**Command:**
```bash
./ralph.sh --dir .artefacts/user-auth --promise "EP-TB-003 COMPLETE" --max-iterations 18
```

**PROMPT.md content** (`.artefacts/user-auth/PROMPT.md`):
```
Implement user authentication following the spec at /home/tom/projects/connect-coby/.prodman/specs/SPEC-TB-003-user-auth.md.

EXPERT ARTIFACTS (reference during implementation):
- PRD: /home/tom/projects/connect-coby/.artefacts/user-auth/PRD.md
- Architecture: /home/tom/projects/connect-coby/.artefacts/user-auth/ARCHITECTURE.md
- UI Spec: /home/tom/projects/connect-coby/.artefacts/user-auth/UI-SPEC.md

These artifacts provide deep context on requirements, architecture decisions, and UI design.
Consult them when you need clarification on WHY or HOW something should be implemented.

PROGRESS TRACKING:
- At the START of every iteration, read .artefacts/user-auth/progress.txt.
- It contains the list of completed tasks and current state from previous iterations.
- After completing each task, UPDATE .artefacts/user-auth/progress.txt with:
  - Which task you just finished (task number + name)
  - Brief summary of what was done
  - Any issues encountered
  - What task comes next
- This file is your memory across iterations. Keep it accurate.

PACING — ONE TASK PER ITERATION (MANDATORY):
- Each iteration, implement EXACTLY ONE task from the spec. No more.
- After completing that single task: commit, update .artefacts/user-auth/progress.txt, then STOP.
- Do NOT look ahead to the next task. Do NOT while-I'm-here other tasks.
- The next iteration will pick up where you left off via .artefacts/user-auth/progress.txt.
- Exception: the FINAL iteration handles best practices + completion promise.

WORKFLOW:
1. Read the spec file first.
2. Read .artefacts/user-auth/progress.txt to see what is already done from previous iterations.
3. Identify the NEXT SINGLE incomplete task (lowest numbered unfinished task).
4. Implement ONLY that one task, then commit.
5. Update .artefacts/user-auth/progress.txt with what you just finished and what comes next.
6. STOP. Do not continue to the next task — let the loop iterate.
7. Only after ALL tasks show complete in .artefacts/user-auth/progress.txt, run best practices (see below).

BEST PRACTICES (after ALL implementation tasks are done):
1. Run /code-simplifier to reduce unnecessary complexity in the code you wrote.
2. Create review artefacts:
   - .artefacts/user-auth/TESTING.md — Manual testing guide with exact steps, expected results, and edge cases.
   - .artefacts/user-auth/CHANGELOG.md — What changed: summary, files modified, breaking changes.
3. Update CLAUDE.md with learnings from this session:
   - Review the implementation for patterns, commands, or gotchas worth documenting
   - Draft concise additions (one-line format: `<command>` - `<brief description>`)
   - Directly append to CLAUDE.md using the Edit tool (no approval needed in loop context)
   - Keep additions minimal - only genuinely useful context for future Claude sessions
4. Verify all code follows CLAUDE.md and AGENTS.md conventions.
5. Check for YAGNI violations — no features beyond what the spec describes.

RULES:
- Follow the project's CLAUDE.md and AGENTS.md conventions.
- Do NOT add features beyond what the spec describes.
- Mark EP-TB-003 status as complete in .prodman/epics/ when done.

CRITICAL — DO NOT COMPLETE EARLY:
- You have 6 tasks to implement. Do NOT output the completion promise until ALL of them are done.
- Before outputting the promise, you MUST verify:
  1. Every task in the spec is implemented (check them off one by one)
  2. .artefacts/user-auth/progress.txt shows ALL tasks as complete
  3. /code-simplifier has been run
  4. Review artefacts are created in .artefacts/user-auth/
  5. CLAUDE.md has been updated with session learnings (if applicable)
  6. Code follows CLAUDE.md and AGENTS.md conventions
  7. No YAGNI violations
- If ANY task is incomplete, keep working. You have plenty of iterations.

Output <promise>EP-TB-003 COMPLETE</promise> ONLY when every single task is implemented, best practices are done, and all checks above pass.
```

---

## Example - Partial Artifacts

For a 5-task plan creating EP-TB-005 with only PM and Architecture enabled (no UI/UX).

**Command:**
```bash
./ralph.sh --dir .artefacts/data-export --promise "EP-TB-005 COMPLETE" --max-iterations 15
```

**PROMPT.md content** (`.artefacts/data-export/PROMPT.md`):
```
Implement data export feature following the spec at /home/tom/projects/app/.prodman/specs/SPEC-TB-005-data-export.md.

EXPERT ARTIFACTS (reference during implementation):
- PRD: /home/tom/projects/app/.artefacts/data-export/PRD.md
- Architecture: /home/tom/projects/app/.artefacts/data-export/ARCHITECTURE.md

These artifacts provide deep context on requirements and architecture decisions.
Consult them when you need clarification on WHY or HOW something should be implemented.

[... rest of prompt template ...]
```

---

## Example - No Artifacts

For a minimal 3-task utility feature creating EP-TB-007 with no agents (design.md only).

**Command:**
```bash
./ralph.sh --dir .artefacts/date-formatter --promise "EP-TB-007 COMPLETE" --max-iterations 10
```

**PROMPT.md content** (`.artefacts/date-formatter/PROMPT.md`):
```
Implement date formatter utility following the spec at /home/tom/projects/app/.prodman/specs/SPEC-TB-007-date-formatter.md.

Note: No expert artifacts available. Refer to the spec and design document for guidance.

[... rest of prompt template ...]
```
