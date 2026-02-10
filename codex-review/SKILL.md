---
name: codex-review
description: "Review implementation using OpenAI Codex MCP as an independent second opinion. Use after completing a feature, epic, or set of changes — verifies both spec compliance and code quality. Triggers on: 'review with codex', 'codex review', 'get a second opinion', or when referenced by other skills (e.g., ralph-planner)."
---

# Codex Review

Get an independent code review from OpenAI Codex via MCP, checking both spec compliance and code quality.

## When to Use

- After completing all tasks in a ralph loop or implementation plan
- After finishing a feature branch before PR
- When you want a second opinion on code changes

## Process

### 1. Gather Context

Collect the review inputs:

- **Spec/plan file** — path to the prodman spec or plan document (if available)
- **Changed files** — run `git diff main --name-only` (or relevant base branch) to get the list
- **Diff** — run `git diff main` for the full changeset

### 2. Send to Codex

Use `mcp__codex__codex` with:

```
prompt: "Review the following code changes against the spec and for code quality.

SPEC: {paste spec content or 'No spec provided — review for code quality only'}

CHANGED FILES:
{list of files}

DIFF:
{full diff}

Review for:

1. SPEC COMPLIANCE
- Are all acceptance criteria met?
- Are there any tasks from the spec that are missing or incomplete?
- Does the implementation match what was planned?

2. CODE QUALITY
- Bugs or logic errors
- Security issues (injection, XSS, auth bypass, etc.)
- Anti-patterns or code smells
- Missing error handling at system boundaries
- Unnecessary complexity (YAGNI violations)
- Test coverage gaps

3. SUMMARY
- Overall assessment: PASS / NEEDS CHANGES
- List of issues found (if any), ordered by severity
- Suggested fixes for each issue"

sandbox: "read-only"
cwd: "{project root}"
```

### 3. Process Findings

After receiving the Codex response:

- **PASS** — Report the clean review to the user
- **NEEDS CHANGES** — Present the issues clearly:

```
## Codex Review Results

**Status:** NEEDS CHANGES

### Issues Found
1. **[Severity]** {description} — {file}:{line}
   Fix: {suggested fix}

### Recommended Actions
- {action items}
```

If inside a ralph loop, fix the issues before outputting the completion promise.

## Key Principles

- **Read-only sandbox** — Codex reviews but does not modify files
- **Independent opinion** — Codex uses a different model, catching blind spots
- **Spec-aware** — Always include the spec when available for compliance checking
- **Actionable output** — Every issue includes a suggested fix
