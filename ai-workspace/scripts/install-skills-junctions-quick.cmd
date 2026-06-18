@echo off
setlocal
set VENDOR=%USERPROFILE%\.ai-workspace\vendor
set CURSOR=%USERPROFILE%\.cursor\skills
set CLAUDE=%USERPROFILE%\.claude\skills
set CODEX=%USERPROFILE%\.codex\skills

if not exist "%CURSOR%\claude-code-prompts-reference" mkdir "%CURSOR%\claude-code-prompts-reference"
if not exist "%CURSOR%\claude-code-prompts-reference\patterns" mklink /J "%CURSOR%\claude-code-prompts-reference\patterns" "%VENDOR%\claude-code-prompts\patterns"
if not exist "%CURSOR%\claude-code-prompts-reference\skills" mklink /J "%CURSOR%\claude-code-prompts-reference\skills" "%VENDOR%\claude-code-prompts\skills"
if not exist "%CURSOR%\claude-code-prompts-reference\complete-prompts" mklink /J "%CURSOR%\claude-code-prompts-reference\complete-prompts" "%VENDOR%\claude-code-prompts\complete-prompts"

if not exist "%CURSOR%\most-capable-agent-reference\vendor" mklink /J "%CURSOR%\most-capable-agent-reference\vendor" "%VENDOR%\most-capable-agent"

for %%S in (claude-code-prompts-reference most-capable-agent-reference context-engineering ai-prompt-engineering workflow-gate) do (
  if not exist "%CLAUDE%\%%S" mklink /J "%CLAUDE%\%%S" "%CURSOR%\%%S"
  if not exist "%CODEX%\%%S" mklink /J "%CODEX%\%%S" "%CURSOR%\%%S"
)

echo DONE
