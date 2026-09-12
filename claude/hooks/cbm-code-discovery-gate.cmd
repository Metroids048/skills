@echo off
REM codebase-memory-mcp search augmenter (Windows PreToolUse wrapper).
REM Runs hook-augment in background so Grep/Glob is never blocked.
REM Failures are silent (exit 0).
set "BIN=%USERPROFILE%\.local\bin\codebase-memory-mcp.exe"
if not exist "%BIN%" exit /b 0
start /b "" "%BIN%" hook-augment >nul 2>&1
exit /b 0
