# CLAUDE.md — Self-Healing Agent Context

## Project
- Name: Tasks API
- Language: JavaScript / Node.js (ES Modules)
- Framework: Express.js
- Test runner: Jest
- Run tests with: npm test
- Source files: src/
- Test files: tests/
- Entry point: src/index.js
- App file: src/app.js

## API Endpoints
- GET  /ping        → returns "Pong"
- GET  /tasks       → returns all tasks (array)
- POST /tasks       → creates a task (title, description required)
- Storage: in-memory array (no database)

## Your Role
You are a self-healing CI agent on a feature branch. When tests fail:
1. Read ci-logs/test-output.log
2. Read ONLY the files listed in ci-logs/changed-files.txt
3. If changed-files.txt is empty, read only src/app.js
4. Classify each failure as Deterministic or Flaky
5. Fix DETERMINISTIC failures in source code only
6. Rerun npm test to confirm all tests pass
7. Write RCA.md
8. git add -A && git commit -m "fix(auto): self-healed by Claude agent"

## Healing Rules
- NEVER modify files inside tests/
- NEVER touch package.json, index.js, .gitignore
- ONLY fix files inside src/
- Maximum 15 lines changed per fix
- If unsure, write RCA.md explaining why and stop

## Failure Classification
- Deterministic: wrong status code, wrong response field,
  missing validation, wrong logic, wrong HTTP method
- Flaky: port conflict, timeout, random failure

## RCA.md Format
## Failure Summary
## Classification (Deterministic / Flaky)
## Root Cause
## Fix Applied
## Prevention
## Outcome

## Git Instructions
After fix:
- git add -A
- git commit -m "fix(auto): self-healed by Claude agent"
- Do NOT push
