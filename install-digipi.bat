@echo off
setlocal
title DigiPi Pi3B+ SignaLink TM-D700 installer
cd /d "%~dp0"

echo.
echo DigiPi installer for Raspberry Pi 3B+ / SignaLink USB / Kenwood TM-D700
echo This will request Administrator rights so the microSD can be written.
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
  echo Elevating...
  powershell -NoProfile -Command "Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0install-digipi.ps1\"'"
  exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-digipi.ps1" %*
set EXITCODE=%ERRORLEVEL%
echo.
pause
exit /b %EXITCODE%
