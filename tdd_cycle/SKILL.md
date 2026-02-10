---
name: tdd_cycle
description: Enforces the TDD cycle (Red-Green-Refactor) for implementing new features or fixes.
---

# TDD Cycle Enforcement Skill

This skill guides you through the Mandatory TDD workflow.

## 🚨 CRITICAL RULE
**YOU MUST NOT WRITE IMPLEMENTATION CODE UNTIL YOU HAVE A FAILING TEST.**

## Step 1: Understand & Plan (Red Phase)
1.  **Read the Rules**: View `backend/tests/README.md` to understand where your test belongs.
2.  **Create/Update Test**: Write your test case in the appropriate `tests/` directory.
3.  **Verify Failure**: Run the test to confirm it fails.
    - Command: `make test` (or specific layer, e.g., `make test-api`)
    - **Outcome**: The test MUST fail. If it passes, your test is wrong or the feature already exists.

## Step 2: Implement (Green Phase)
1.  **Write Code**: Write the *minimum* amount of code to make the test pass.
2.  **Verify Pass**: Run the test again.
    - Command: `make test`
    - **Outcome**: All tests MUST pass.

## Step 3: Refactor (Refactor Phase)
1.  **Clean Up**: improvements, optimization, removing duplication.
2.  **Verify Integrity**: Run tests again to ensure refactoring didn't break anything.

## Usage Example
When user asks: "Add a new route /api/foo"

1.  **Agent**: "I will start the TDD cycle."
2.  **Agent**: Writes `tests/api/test_foo.py`.
3.  **Agent**: Runs `make test-api`. Result: `404 Not Found` (Failure Confirmed).
4.  **Agent**: Writes `routers/api.py`.
5.  **Agent**: Runs `make test-api`. Result: `200 OK` (Pass Confirmed).
