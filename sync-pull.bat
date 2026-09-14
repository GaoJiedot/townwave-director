@echo off
REM Pull latest changes from GitHub (run at the START of a work session).
REM 仅快进合并，不会覆盖你本地未推送的改动。
cd /d "%~dp0"
call gitw.bat pull --ff-only --prune
echo.
echo Done. You can close this window.
pause >nul
