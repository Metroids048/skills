@echo off
setlocal
set V=%USERPROFILE%\.ai-workspace\vendor\jamesrochabrun-skills\skills
set C=%USERPROFILE%\.cursor\skills
set L=%USERPROFILE%\.claude\skills
set X=%USERPROFILE%\.codex\skills
if not exist "%X%" mkdir "%X%"

for %%S in (
  anthropic-architect
  llm-router
  engineer-expertise-extractor
  design-brief-generator
  content-brief-generator
  query-expert
  technical-launch-planner
  qa-test-planner
) do (
  call :link %%S
)
echo DONE james picks
exit /b 0

:link
set NAME=%~1
set T=%V%\%NAME%
if not exist "%T%" (
  echo SKIP missing %T%
  exit /b 0
)
call :mkone "%C%\%NAME%" "%T%"
call :mkone "%L%\%NAME%" "%T%"
call :mkone "%X%\%NAME%" "%T%"
exit /b 0

:mkone
set DEST=%~1
set TARGET=%~2
if exist "%DEST%" rmdir "%DEST%" 2>nul
mklink /J "%DEST%" "%TARGET%" >nul 2>&1
if errorlevel 1 (
  echo FAIL %DEST%
) else (
  echo OK %DEST%
)
exit /b 0
