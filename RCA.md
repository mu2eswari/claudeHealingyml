# Root Cause Analysis

**Date:** 2026-04-27  
**Branch:** feature/healyml  
**Status:** Resolved

## Failure Summary

| Test | Type | Status |
|------|------|--------|
| `POST /tasks › given a title and description › should respond with a 200 status code` | Deterministic | Fixed |

## Root Cause

**File:** `tests/index.spec.js:27`  
**Type:** Deterministic — wrong assertion value (typo)

The test named *"should respond with a 200 status code"* contained the assertion:

```js
expect(response.statusCode).toBe(500);  // wrong
```

The server (`src/app.js:27`) correctly returns HTTP 200 on a successful `POST /tasks`. The expected value `500` is inconsistent with both the test name and the inline comment (`// should respond with a 200 code`). This was a copy-paste or typo error introduced into the test assertion.

## Fix Applied

Changed `tests/index.spec.js:27`:

```diff
- expect(response.statusCode).toBe(500);
+ expect(response.statusCode).toBe(200);
```

No changes to `src/` were required — the application logic was correct.

## Flaky Failures

None identified. All other 5 tests were consistently passing.

## Verification

After the fix, `npm test` reports **6/6 tests passing**, 0 failures.
