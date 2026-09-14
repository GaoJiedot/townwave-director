@echo off
REM ============================================================
REM TownWave Director · 自动更新（每次使用 skill 前拉取最新版）
REM - 仅快进合并 (--ff-only)，绝不覆盖你本地未推送的改动
REM - 非交互、不暂停，给调用方（agent / 终端）返回退出码
REM ============================================================
cd /d "%~dp0"
call gitw.bat pull --ff-only --prune 2>&1
exit /b %errorlevel%
