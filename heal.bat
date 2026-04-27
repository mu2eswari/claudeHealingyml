@echo off
REM heal.bat — Self-Healing CI Agent with User Permission Control

echo.
echo ============================================
echo    SELF-HEALING CI AGENT — POC
echo    Powered by Claude Code
echo ============================================
echo.

REM Create logs directory
if not exist ci-logs mkdir ci-logs

REM Step 1: Run tests
echo Step 1: Running test suite...
echo.
call npm test > ci-logs\test-output.log 2>&1
set TEST_EXIT=%ERRORLEVEL%

REM Check log for failures as backup
findstr /i "failed" ci-logs\test-output.log > nul
if %ERRORLEVEL% == 0 set TEST_EXIT=1

type ci-logs\test-output.log
echo.

REM Step 2: If passed, exit
if %TEST_EXIT% == 0 (
    echo All tests passed! No healing needed.
    exit /b 0
)

REM Step 3: Tests failed — show menu to user
echo ============================================
echo  TEST FAILURES DETECTED
echo ============================================
echo.
echo  What would you like to do?
echo.
echo  [1] Auto-fix and rerun tests (Claude decides)
echo  [2] Show me the failures only, I will fix manually
echo  [3] Exit without doing anything
echo.
set /p USER_CHOICE="Enter your choice (1/2/3): "

REM Step 4: Handle user choice
if "%USER_CHOICE%"=="3" (
    echo Exiting. No changes made.
    exit /b 0
)

if "%USER_CHOICE%"=="2" (
    echo.
    echo ============================================
    echo  FAILURE SUMMARY
    echo ============================================
    findstr /i "FAIL\|Error\|expected\|received" ci-logs\test-output.log
    echo.
    echo Fix the issues manually and run heal.bat again.
    exit /b 0
)

if "%USER_CHOICE%"=="1" (
    echo.
    echo Step 2: Analyzing failures...
    echo.

    REM Step 5: Ask what kind of fix
    echo ============================================
    echo  SELECT FIX MODE
    echo ============================================
    echo.
    echo  [1] Minor fix only (max 5 lines changed)
    echo  [2] Standard fix (max 15 lines changed)
    echo  [3] Let Claude decide the scope
    echo.
    set /p FIX_MODE="Enter fix mode (1/2/3): "

    if "%FIX_MODE%"=="1" set MAX_LINES=5
    if "%FIX_MODE%"=="2" set MAX_LINES=15
    if "%FIX_MODE%"=="3" set MAX_LINES=20

    REM Step 6: Ask about auto-commit
    echo.
    echo  Auto-commit the fix after healing?
    echo  [1] Yes, commit automatically
    echo  [2] No, let me review first
    echo.
    set /p AUTO_COMMIT="Enter choice (1/2): "

    REM Step 7: Call Claude based on choices
    echo.
    echo Starting Claude self-healing agent...
    echo.

    if "%AUTO_COMMIT%"=="1" (
        claude -p "You are a self-healing CI agent. STEP 1: Read ./ci-logs/test-output.log. STEP 2: Read only changed source files in ./routes/ and ./models/. STEP 3: Classify failures as Deterministic or Flaky. STEP 4: For DETERMINISTIC failures apply minimal fix — maximum %MAX_LINES% lines changed. STEP 5: Run npm test to verify. STEP 6: Write RCA.md. STEP 7: git add -A then git commit -m 'fix(auto): self-healed by Claude agent'." --allowedTools "Read,Write,Bash" --permission-mode acceptEdits
    ) else (
        claude -p "You are a self-healing CI agent. STEP 1: Read ./ci-logs/test-output.log. STEP 2: Read only changed source files in ./routes/ and ./models/. STEP 3: Classify failures as Deterministic or Flaky. STEP 4: For DETERMINISTIC failures apply minimal fix — maximum %MAX_LINES% lines changed. STEP 5: Run npm test to verify. STEP 6: Write RCA.md. DO NOT git commit — leave that to the developer." --allowedTools "Read,Write,Bash" --permission-mode acceptEdits
    )
)

echo.
echo ============================================
echo  Healing agent finished.
echo  Check RCA.md for full diagnosis.
echo  Run: git log --oneline -3
echo ============================================
echo.

REM Step 8: Ask user to rerun tests after fix
echo.
echo ============================================
echo  FIX APPLIED — WHAT NEXT?
echo ============================================
echo.
echo  [1] Rerun tests now to confirm fix
echo  [2] Show what Claude changed (git diff)
echo  [3] Show RCA.md
echo  [4] Exit
echo.

:RERUN_MENU
set /p RERUN_CHOICE="Enter your choice (1/2/3/4): "

if "%RERUN_CHOICE%"=="4" (
    echo Exiting.
    exit /b 0
)

if "%RERUN_CHOICE%"=="3" (
    echo.
    echo ============================================
    type RCA.md
    echo ============================================
    echo.
    goto RERUN_MENU
)

if "%RERUN_CHOICE%"=="2" (
    echo.
    echo ============================================
    echo  FILES CHANGED BY CLAUDE
    echo ============================================
    git diff HEAD~1
    echo.
    goto RERUN_MENU
)

if "%RERUN_CHOICE%"=="1" (
    echo.
    echo Rerunning tests...
    echo.
    call npm test > ci-logs\test-output.log 2>&1
    set RERUN_EXIT=%ERRORLEVEL%

    findstr /i "failed" ci-logs\test-output.log > nul
    if %ERRORLEVEL% == 0 set RERUN_EXIT=1

    type ci-logs\test-output.log
    echo.

    if %RERUN_EXIT% == 0 (
        echo ============================================
        echo  ALL TESTS PASSED after fix!
        echo  Run: git push   when ready
        echo ============================================
    ) else (
        echo ============================================
        echo  TESTS STILL FAILING after fix.
        echo  Claude could not fully heal this issue.
        echo  Please fix manually and rerun heal.bat.
        echo ============================================
    )
    echo.
    goto RERUN_MENU
)