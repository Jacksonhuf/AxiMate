@echo off
REM Double-click or run from cmd; uses Windows PowerShell (no pwsh required).
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build-RippleWindows.ps1"
exit /b %ERRORLEVEL%
