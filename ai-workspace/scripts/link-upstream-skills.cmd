@echo off
setlocal
set CURSOR=%USERPROFILE%\.cursor\skills
set CLAUDE=%USERPROFILE%\.claude\skills
set CODEX=%USERPROFILE%\.codex\skills
set PE=%USERPROFILE%\.ai-workspace\vendor\ai-prompt-engineering-upstream\ai-prompt-engineering
set CE=%USERPROFILE%\.ai-workspace\vendor\PAIPlugin-prompting\context-engineering

call :link ai-prompt-engineering "%PE%"
call :link context-engineering "%CE%"
echo DONE
exit /b 0

:link
set NAME=%~1
set TARGET=%~2
if exist "%CURSOR%\%NAME%" rmdir "%CURSOR%\%NAME%" 2>nul
if exist "%CLAUDE%\%NAME%" rmdir "%CLAUDE%\%NAME%" 2>nul
if exist "%CODEX%\%NAME%" rmdir "%CODEX%\%NAME%" 2>nul
mklink /J "%CURSOR%\%NAME%" "%TARGET%"
mklink /J "%CLAUDE%\%NAME%" "%TARGET%"
mklink /J "%CODEX%\%NAME%" "%TARGET%"
exit /b 0
