# Best Practices Checklist

Single source of truth for post-implementation best practices. Used by:
- `/follow-best-practices` (standalone execution)
- `/ralph-planner` and `/ralph-launch` (inlined into ralph loop prompts)

---

## 1. Code Simplification

Run `/code-simplifier` on all code written or modified during this session.

Focus: reduce unnecessary complexity, remove dead code, simplify abstractions that aren't earning their keep.

## 2. Artefacts

Create the following in `.artefacts/{feature-slug}/`:

### TESTING.md — Manual testing guide
- Exact steps to test the feature (URLs, commands, clicks)
- What to look for / expected results at each step
- Edge cases worth checking

### CHANGELOG.md — What changed
- Summary of the feature
- Files created/modified, grouped by concern
- Any breaking changes or migration notes

## 3. CLAUDE.md Maintenance

Run both:
1. `/claude-md-improver` — audit and improve CLAUDE.md quality
2. `/claude-md-management:revise-claude-md` — update CLAUDE.md with learnings from this session

## 4. Convention Compliance

Verify the work follows:
- `CLAUDE.md` conventions (if present)
- `AGENTS.md` conventions (if present)

Flag any deviations and fix them.

## 5. YAGNI Check

Review the changes for scope creep:
- No features beyond what was described/requested
- No speculative abstractions or "nice to have" additions
- No unnecessary configuration or flexibility

If anything looks like it wasn't asked for, flag it to the user.

## 6. Codex Review (optional)

Off by default. When opted in:
- Run `/codex-review` for an independent second opinion on code quality and spec compliance
- Fix any issues found before considering the work complete

---

## For Ralph Loop Prompts

When inlining into a ralph loop prompt, the workflow steps should be:

```
BEST PRACTICES (after ALL implementation tasks are done):
1. Run /code-simplifier to reduce unnecessary complexity in the code you wrote.
2. Create review artefacts:
   - .artefacts/{feature-slug}/TESTING.md — Manual testing guide with exact steps, expected results, and edge cases.
   - .artefacts/{feature-slug}/CHANGELOG.md — What changed: summary, files modified, breaking changes.
3. Run /claude-md-improver and /claude-md-management:revise-claude-md to keep CLAUDE.md current.
4. Verify all code follows CLAUDE.md and AGENTS.md conventions.
5. Check for YAGNI violations — no features beyond what the spec describes.
{codex_review_step}
```

And the corresponding verification checks:

```
BEST PRACTICES VERIFICATION (before completing):
- /code-simplifier has been run
- Review artefacts are created in .artefacts/{feature-slug}/
- /claude-md-improver and /claude-md-management:revise-claude-md have been run
- Code follows CLAUDE.md and AGENTS.md conventions
- No YAGNI violations
{codex_review_check}
```
