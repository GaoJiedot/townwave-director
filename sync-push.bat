@echo off
REM Commit all changes and push to GitHub (run at the END of a work session).
cd /d "%~dp0"
call gitw.bat add -A
call gitw.bat commit -m "sync: %date% %time%" || echo Nothing new to commit
call gitw.bat push -u origin main
echo.
echo Done. You can close this window.
pause >nul
